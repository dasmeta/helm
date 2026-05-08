#!/usr/bin/env sh
set -eu

chart_dir="${1:-.}"
values_file="${chart_dir}/tests/ip-egress-values.yaml"
rendered="$(helm template ztm-ip-egress "${chart_dir}" -n default -f "${values_file}")"

if ! printf '%s\n' "${rendered}" | grep -q 'kind: ServiceEntry'; then
  echo "IP egress ServiceEntry was not rendered" >&2
  exit 1
fi

if ! printf '%s\n' "${rendered}" | grep -q 'resolution: NONE'; then
  echo "IP egress ServiceEntry must use resolution NONE" >&2
  exit 1
fi

if ! printf '%s\n' "${rendered}" | grep -q '192.0.2.10/32'; then
  echo "single IP should be normalized to /32" >&2
  exit 1
fi

if ! printf '%s\n' "${rendered}" | grep -q '198.51.100.0/24'; then
  echo "CIDR IP block was not rendered" >&2
  exit 1
fi

if ! printf '%s\n' "${rendered}" | grep -q 'kind: NetworkPolicy'; then
  echo "IP egress NetworkPolicy was not rendered" >&2
  exit 1
fi

if ! printf '%s\n' "${rendered}" | grep -q 'ipBlock:'; then
  echo "NetworkPolicy should use ipBlock for IP egress" >&2
  exit 1
fi

if ! printf '%s\n' "${rendered}" | grep -q 'port: 443'; then
  echo "port 443 was not rendered" >&2
  exit 1
fi

if ! printf '%s\n' "${rendered}" | grep -q 'port: 8080'; then
  echo "port 8080 was not rendered" >&2
  exit 1
fi
