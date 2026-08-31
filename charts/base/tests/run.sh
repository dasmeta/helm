#!/usr/bin/env bash
#
# Validation suite for the base chart PodDisruptionBudget behaviour.
#
# Renders the chart with helm template across a matrix of values files and asserts
# on the result. Requires no Kubernetes cluster and no cloud credentials.
#
# Case files live in ./cases/ and carry their assertions as `#@` directives:
#
#   #@ desc: human readable description
#   #@ assert-no-pdb                 no PodDisruptionBudget may be rendered
#   #@ assert: <yq expression>       must evaluate to true against the rendered PDB
#   #@ expect-fail: <substring>      render must fail and print this substring
#
# A case whose filename starts with `invalid-` is a negative case: the render is
# required to fail. Every other case is positive and the render must succeed.
#
# Usage:
#   ./charts/base/tests/run.sh                 run against the working tree
#   ./charts/base/tests/run.sh --baseline main run against an unmodified ref
#
# Baseline mode exists to satisfy SC-006: every assertion must be shown to fail
# against the chart as it exists today, otherwise it is asserting nothing.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASES_DIR="${SCRIPT_DIR}/cases"
CHART_DIR="${SCRIPT_DIR}/.."
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
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
    *) echo "error: unknown argument '$1'" >&2; usage >&2; exit 2 ;;
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
  CHART_DIR="${WORKTREE}/charts/base"
  echo "BASELINE MODE: chart rendered from ref '${BASELINE_REF}', cases from working tree"
  echo
fi

directive()     { grep -E "^#@ $1:" "$2" 2>/dev/null | sed -E "s/^#@ $1:[[:space:]]*//"; }
has_directive() { grep -qE "^#@ $1([[:space:]]|$)" "$2" 2>/dev/null; }
# yq emits "---" or whitespace for an empty selection; treat that as absent.
is_empty()      { [ -z "$(printf '%s' "$1" | tr -d '[:space:]-')" ]; }

pass=0
fail=0
declare -a failures=()

shopt -s nullglob
for case_file in "${CASES_DIR}"/*.yaml; do
  name="$(basename "${case_file}" .yaml)"
  desc="$(directive desc "${case_file}")"
  out="$(helm template pdbtest "${CHART_DIR}" -f "${case_file}" 2>&1)"
  rc=$?
  ok=1
  reason=""

  if [[ "${name}" == invalid-* ]]; then
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
      pdb="$(printf '%s' "${out}" | yq 'select(.kind == "PodDisruptionBudget")' 2>/dev/null)"
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

  if [ ${ok} -eq 1 ]; then
    pass=$((pass + 1))
    printf 'PASS  %-44s %s\n' "${name}" "${desc}"
  else
    fail=$((fail + 1))
    failures+=("${name}: ${reason}")
    printf 'FAIL  %-44s %s\n' "${name}" "${desc}"
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
  exit 0
fi

[ ${fail} -eq 0 ]
