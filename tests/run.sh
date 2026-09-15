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
has_directive() { grep -qE "^#@ $1([[:space:]]|$)" "$2" 2>/dev/null; }
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
declare -a failures=()
# Negative cases that passed at BASELINE. Each one was already refused by the unmodified chart, so it
# demonstrates nothing about the change and the suite must say so rather than counting it as a pass.
declare -a vacuous=()

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

  is_negative=0
  [[ "$(basename "${case_file}")" == invalid-* ]] && is_negative=1
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
  if [ ${ok} -eq 1 ] && { has_directive assert-notes "${case_file}" || has_directive assert-no-notes "${case_file}"; }; then
    notes="$(helm install --dry-run testrelease "${CHART_DIR}" -f "${case_file}" ${kubever:+--kube-version "${kubever}"} 2>&1)"
    while IFS= read -r want; do
      [ -z "${want}" ] && continue
      printf '%s' "${notes}" | grep -qF -- "${want}" || { ok=0; reason="install notes missing: ${want}"; }
    done < <(directive assert-notes "${case_file}")
    while IFS= read -r unwanted; do
      [ -z "${unwanted}" ] && continue
      if printf '%s' "${notes}" | grep -qF -- "${unwanted}"; then
        ok=0; reason="install notes contained what must not be there: ${unwanted}"
      fi
    done < <(directive assert-no-notes "${case_file}")
  fi

  if [ ${ok} -eq 1 ]; then
    pass=$((pass + 1))
    if [ -n "${BASELINE_REF}" ] && [ "${is_negative}" = 1 ]; then
      # Refused by the UNMODIFIED chart, so this case cannot be evidence for the change.
      vacuous+=("${name}")
      printf 'VACUOUS  %-49s %s\n' "${name}" "${desc}"
    else
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
printf 'passed: %d   failed: %d   total: %d\n' "${pass}" "${fail}" "$((pass + fail))"

if [ ${fail} -gt 0 ]; then
  echo
  echo "Failures:"
  for f in "${failures[@]}"; do echo "  - ${f}"; done
fi

if [ -n "${BASELINE_REF}" ]; then
  echo
  echo "NOTE: in baseline mode failures are EXPECTED. Every negative case must fail"
  echo "here; a negative case that passes against an unmodified chart asserts nothing."
  if [ ${#vacuous[@]} -gt 0 ]; then
    echo
    echo "VACUOUS negative cases -- already refused by the unmodified chart, so they"
    echo "demonstrate nothing about this change. Correct them before relying on them:"
    for v in "${vacuous[@]}"; do echo "  - ${v}"; done
    exit 1
  fi
  echo "No vacuous negative cases: every one of them fails at baseline, as required."
  exit 0
fi

[ ${fail} -eq 0 ]
