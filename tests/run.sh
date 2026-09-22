#!/usr/bin/env bash
#
# Validation suite for this repository's charts.
#
# Renders a chart with helm template across a matrix of values files and asserts
# on the result. Requires no Kubernetes cluster and no cloud credentials.
#
# Layout mirrors examples/: one directory per chart, one per ability inside it.
#
#   tests/<chart>/<ability>/<case>.yaml
#   tests/base/pdb/floor-2-default.yaml
#
# Every case under tests/<chart>/ is rendered against charts/<chart>. Adding an
# ability is adding a directory; adding a chart is adding one level up. Nothing
# in the runner needs to change for either.
#
# Case files carry their assertions as `#@` directives:
#
#   #@ desc: human readable description
#   #@ assert-no-pdb                 no PodDisruptionBudget may be rendered
#   #@ assert: <yq expression>       must evaluate to true against the rendered PDB
#   #@ expect-fail: <substring>      render must fail and print this substring
#   #@ kube-version: <semver>        render against this kubernetes version rather than helm's default
#   #@ assert-notes: <substring>     install NOTES must contain this
#   #@ assert-no-notes: <substring>  install NOTES must NOT contain this
#
# The notes directives render with `helm install --dry-run`, because `helm template` does not produce
# NOTES.txt at all -- a fixture asserting on notes through the template path silently tests nothing.
#
# THEY NEED A REACHABLE CLUSTER. helm 3.15 has no offline path for NOTES.txt: --dry-run=client still asks
# the API server for its version, and --show-only does not cover it. Where no cluster is reachable these
# specific assertions are reported as SKIPPED rather than passed, so CI stays honest about what it checked.
#
# A case whose filename starts with `invalid-` is a negative case: the render is
# required to fail. Every other case is positive and the render must succeed.
#
# Usage:
#   ./tests/run.sh                        every chart
#   ./tests/run.sh base                   one chart
#   ./tests/run.sh base pdb               one ability
#   ./tests/run.sh --baseline main        render from an unmodified ref
#
# Baseline mode exists so that every assertion is shown to fail against the chart
# as it exists today, otherwise it is asserting nothing. It ENFORCES that: a
# negative case that already passes at baseline was already being refused before
# the change, proves nothing about it, and makes the run exit non-zero.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
CHARTS_ROOT="${REPO_ROOT}/charts"
FILTER_CHART=""
FILTER_ABILITY=""
BASELINE_REF=""
WORKTREE=""
TMPPARENT=""

usage() {
  sed -n '2,26p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --baseline)
      BASELINE_REF="${2:-}"
      if [ -z "${BASELINE_REF}" ]; then echo "error: --baseline requires a git ref" >&2; exit 2; fi
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "error: unknown argument '$1'" >&2; usage >&2; exit 2 ;;
    *)
      if [ -z "${FILTER_CHART}" ]; then FILTER_CHART="$1"
      elif [ -z "${FILTER_ABILITY}" ]; then FILTER_ABILITY="$1"
      else echo "error: unexpected argument '$1'" >&2; usage >&2; exit 2
      fi
      shift
      ;;
  esac
done

cleanup() {
  if [ -n "${WORKTREE}" ]; then
    git -C "${REPO_ROOT}" worktree remove --force "${WORKTREE}" >/dev/null 2>&1
  fi
  if [ -n "${TMPPARENT}" ]; then rm -rf "${TMPPARENT}"; fi
}
trap cleanup EXIT

if [ -n "${BASELINE_REF}" ]; then
  TMPPARENT="$(mktemp -d)"
  WORKTREE="${TMPPARENT}/baseline"
  if ! git -C "${REPO_ROOT}" worktree add --detach "${WORKTREE}" "${BASELINE_REF}" >/dev/null 2>&1; then
    echo "error: could not create worktree for ref '${BASELINE_REF}'" >&2
    exit 2
  fi
  CHARTS_ROOT="${WORKTREE}/charts"
  echo "BASELINE MODE: charts rendered from ref '${BASELINE_REF}', cases from working tree"
  echo
fi

directive()     { grep -E "^#@ $1:" "$2" 2>/dev/null | sed -E "s/^#@ $1:[[:space:]]*//"; }
# The colon is part of every directive that takes a value, so it has to be accepted here. Without it the
# notes gates below silently returned false and their cases reported PASS while asserting nothing.
has_directive() { grep -qE "^#@ $1([[:space:]:]|$)" "$2" 2>/dev/null; }
# yq emits "---" or whitespace for an empty selection; treat that as absent.
is_empty()      { [ -z "$(printf '%s' "$1" | tr -d '[:space:]-')" ]; }

# A missing or broken yq turns every rendered budget into a false "none was rendered", and lets
# assert-no-pdb cases pass without inspecting any YAML at all. The suite would report success while
# asserting nothing, which is worse than failing.
for dep in helm yq jq; do
  command -v "${dep}" >/dev/null 2>&1 || { echo "error: ${dep} is required and not on PATH" >&2; exit 2; }
done

pass=0
fail=0
# Cases that passed everything they could RUN, but where some assertion could not run at all.
# Counted apart from `pass` so the summary line can never imply coverage that did not happen.
partial=0
declare -a failures=()
# Negative cases that passed at BASELINE. Each one was already refused by the unmodified chart, so it
# demonstrates nothing about the change and the suite must say so rather than counting it as a pass.
declare -a vacuous=()
# Assertions that could not run in this environment. Reported, never counted as passes.
declare -a skipped=()

# find rather than a glob: the wildcards have to survive being optional, and a quoted glob stays literal.
#
# Read with a while loop rather than mapfile, which is bash 4+. macOS ships bash 3.2 at /bin/bash, so the
# documented `./tests/run.sh` failed there with `mapfile: command not found` and an unbound array -- on the
# machines this is developed on, while passing CI on ubuntu's bash 5.
CASE_FILES=()
while IFS= read -r _f; do
  [ -n "${_f}" ] && CASE_FILES+=("${_f}")
done < <(
  find "${SCRIPT_DIR}" -mindepth 3 -maxdepth 3 -name '*.yaml' \
    -path "${SCRIPT_DIR}/${FILTER_CHART:-*}/${FILTER_ABILITY:-*}/*" | sort
)

if [ ${#CASE_FILES[@]} -eq 0 ]; then
  echo "error: no cases matched${FILTER_CHART:+ chart '${FILTER_CHART}'}${FILTER_ABILITY:+ ability '${FILTER_ABILITY}'}" >&2
  exit 2
fi

for case_file in "${CASE_FILES[@]}"; do
  # tests/<chart>/<ability>/<case>.yaml -- the chart is two directories up.
  ability="$(basename "$(dirname "${case_file}")")"
  chart="$(basename "$(dirname "$(dirname "${case_file}")")")"
  CHART_DIR="${CHARTS_ROOT}/${chart}"
  if [ ! -d "${CHART_DIR}" ]; then
    echo "error: case ${case_file} names chart '${chart}', which does not exist" >&2
    exit 2
  fi
  name="${chart}/${ability}/$(basename "${case_file}" .yaml)"
  desc="$(directive desc "${case_file}")"
  kubever="$(directive kube-version "${case_file}")"
  if [ -n "${kubever}" ]; then
    out="$(helm template testrelease "${CHART_DIR}" -f "${case_file}" --kube-version "${kubever}" 2>&1)"
  else
    out="$(helm template testrelease "${CHART_DIR}" -f "${case_file}" 2>&1)"
  fi
  rc=$?
  ok=1
  reason=""

  # The DIRECTIVE declares intent; the filename is a convention. Keying only on the name meant a fixture
  # carrying expect-fail but named otherwise was graded as a positive case -- so if the chart accepted the
  # very thing it says must be refused, the case passed.
  is_negative=0
  [[ "$(basename "${case_file}")" == invalid-* ]] && is_negative=1
  has_directive expect-fail "${case_file}" && is_negative=1

  # BASELINE MODE grades negative cases on one question only: does the OLD chart accept this input?
  # If it does, the new guard is what refuses it and the case is evidence. If the old chart refuses it
  # too -- for ANY reason, including one unrelated to this change -- the case proves nothing. Matching on
  # the expected substring was not enough: an old chart failing for a different reason produced an
  # ordinary failure, which baseline mode ignored, and the gate reported no vacuous cases.
  if [ -n "${BASELINE_REF}" ] && [ "${is_negative}" = 1 ]; then
    if [ ${rc} -eq 0 ]; then
      pass=$((pass + 1))
      printf 'USABLE   %-49s %s\n' "${name}" "${desc}"
    else
      vacuous+=("${name}: old chart already refused it -- $(printf '%s' "${out}" | grep -o 'Error:.*' | head -1 | cut -c1-120)")
      fail=$((fail + 1))
      printf 'VACUOUS  %-49s %s\n' "${name}" "${desc}"
      printf '        -> the unmodified chart refuses this too, so it is not evidence for the change\n'
    fi
    continue
  fi
  if [ "${is_negative}" = 1 ]; then
    expect="$(directive expect-fail "${case_file}")"
    if [ -z "${expect}" ]; then
      ok=0; reason="negative case has no '#@ expect-fail:' directive"
    elif [ ${rc} -eq 0 ]; then
      ok=0; reason="render SUCCEEDED but this configuration must be refused"
    elif ! printf '%s' "${out}" | grep -qF -- "${expect}"; then
      ok=0; reason="refused, but message lacked expected text: ${expect}"
    fi
  else
    if [ ${rc} -ne 0 ]; then
      ok=0; reason="render failed: $(printf '%s' "${out}" | head -2 | tr '\n' ' ')"
    else
      pdb="$(printf '%s' "${out}" | yq 'select(.kind == "PodDisruptionBudget")' 2>&1)"
      yq_rc=$?
      if [ ${yq_rc} -ne 0 ]; then
        ok=0; reason="yq failed on the rendered output: $(printf '%s' "${pdb}" | head -1)"
        pdb=""
      fi
      if has_directive assert-no-pdb "${case_file}"; then
        if ! is_empty "${pdb}"; then ok=0; reason="expected NO PodDisruptionBudget, but one was rendered"; fi
      else
        if is_empty "${pdb}"; then
          ok=0; reason="expected a PodDisruptionBudget, none was rendered"
        else
          while IFS= read -r expr; do
            [ -z "${expr}" ] && continue
            res="$(printf '%s' "${pdb}" | yq "${expr}" 2>&1)"
            if [ "${res}" != "true" ]; then
              ok=0; reason="assertion failed: ${expr} (evaluated to: ${res})"
              break
            fi
          done < <(directive assert "${case_file}")
        fi
      fi
    fi
  fi

  # NOTES.txt is produced by `helm install`, not by `helm template`, so it needs its own render.
  notes_skip=0
  if [ ${ok} -eq 1 ] && { has_directive assert-notes "${case_file}" || has_directive assert-no-notes "${case_file}"; }; then
    notes="$(helm install --dry-run testrelease "${CHART_DIR}" -f "${case_file}" ${kubever:+--kube-version "${kubever}"} 2>&1)"
    notes_rc=$?
    if [ ${notes_rc} -ne 0 ] && printf '%s' "${notes}" | grep -q 'cluster unreachable'; then
      # NOTES.txt is rendered by `helm install`, and helm 3.15 has no offline path for it: --dry-run=client
      # still asks the API server for its version, and --show-only does not cover NOTES.txt. Where there is
      # no cluster these assertions cannot run, so they are SKIPPED and said so -- not silently passed,
      # which is the failure mode that put them here.
      skipped+=("${name}: notes assertions need a reachable cluster")
      notes_skip=1
    elif [ ${notes_rc} -ne 0 ]; then
      # Any other failure produces no notes, so every assert-no-notes would pass for the wrong reason.
      ok=0; reason="notes render failed: $(printf '%s' "${notes}" | head -1)"
    fi
    while IFS= read -r want; do
      [ -z "${want}" ] && continue
      [ "${notes_skip}" = 1 ] && continue
      printf '%s' "${notes}" | grep -qF -- "${want}" || { ok=0; reason="install notes missing: ${want}"; }
    done < <(directive assert-notes "${case_file}")
    while IFS= read -r unwanted; do
      [ -z "${unwanted}" ] && continue
      [ "${notes_skip}" = 1 ] && continue
      if printf '%s' "${notes}" | grep -qF -- "${unwanted}"; then
        ok=0; reason="install notes contained what must not be there: ${unwanted}"
      fi
    done < <(directive assert-no-notes "${case_file}")
  fi

  if [ ${ok} -eq 1 ]; then
    if [ "${notes_skip}" = 1 ]; then
      # Some assertion in this case could not run. What DID run passed, and saying PASS here would put
      # the unrun part behind a footnote while the headline claimed coverage -- which is the exact
      # failure these cases were written to catch, reproduced in the runner reporting them.
      partial=$((partial + 1))
      printf 'PARTIAL  %-49s %s\n' "${name}" "${desc}"
    else
      pass=$((pass + 1))
      printf 'PASS  %-52s %s\n' "${name}" "${desc}"
    fi
  else
    fail=$((fail + 1))
    failures+=("${name}: ${reason}")
    printf 'FAIL  %-52s %s\n' "${name}" "${desc}"
    printf '        -> %s\n' "${reason}"
  fi
done
shopt -u nullglob

echo
echo "-----------------------------------------------------------"
printf 'passed: %d   partial: %d   failed: %d   total: %d\n' \
  "${pass}" "${partial}" "${fail}" "$((pass + partial + fail))"
if [ ${partial} -gt 0 ]; then
  echo "PARTIAL means the case ran and what ran passed, but at least one assertion could not run."
  echo "Those cases are NOT counted as passed. See the SKIPPED list below for which checks were missed."
fi
if [ ${#skipped[@]} -gt 0 ]; then
  echo
  echo "SKIPPED assertions (the case still ran; these specific checks could not):"
  for sk in "${skipped[@]}"; do echo "  - ${sk}"; done
fi

# A skipped assertion is not a passed one. Exiting 0 here is what let a required CI job stay green while
# neither NOTES assertion ran, so a regression in that path would have merged unnoticed.
if [ ${partial} -gt 0 ]; then
  echo
  echo "FAILING: ${partial} case(s) could not run every assertion. Provide what they need -- the notes"
  echo "assertions want a reachable cluster -- or remove them. A gate that skips is not a gate."
fi

if [ ${fail} -gt 0 ]; then
  echo
  echo "Failures:"
  for f in "${failures[@]}"; do echo "  - ${f}"; done
fi

if [ -n "${BASELINE_REF}" ]; then
  echo
  echo "NOTE: in baseline mode POSITIVE cases are expected to fail -- the feature does not exist"
  echo "on this ref. Negative cases are graded the other way: the unmodified chart must ACCEPT"
  echo "each one, because a case it already refuses is not evidence for this change."
  if [ ${#vacuous[@]} -gt 0 ]; then
    echo
    echo "VACUOUS negative cases -- already refused by the unmodified chart, so they"
    echo "demonstrate nothing about this change. Correct them before relying on them:"
    for v in "${vacuous[@]}"; do echo "  - ${v}"; done
    exit 1
  fi
  echo "No vacuous negative cases: the unmodified chart ACCEPTS every one of them, so each is evidence."
  exit 0
fi

[ ${fail} -eq 0 ] && [ ${partial} -eq 0 ]
