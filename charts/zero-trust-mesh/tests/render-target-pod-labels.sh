#!/usr/bin/env sh
set -eu

chart_dir="${1:-.}"
values_file="${chart_dir}/tests/target-pod-labels-values.yaml"
rendered="$(helm template ztm-target-pod-labels "${chart_dir}" -n default -f "${values_file}")"

if ! printf '%s\n' "${rendered}" | grep -q 'app: backend'; then
  echo "targetPodLabels app label was not rendered" >&2
  exit 1
fi

if ! printf '%s\n' "${rendered}" | grep -q 'component: api'; then
  echo "targetPodLabels component label was not rendered" >&2
  exit 1
fi

if printf '%s\n' "${rendered}" | grep -q 'app.kubernetes.io/name: backend'; then
  echo "targetPodLabels should replace default target pod selector labels" >&2
  exit 1
fi
