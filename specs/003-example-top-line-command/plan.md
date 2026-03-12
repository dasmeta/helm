# Implementation Plan: Example top-line helm diff command

**Branch**: `003-example-top-line-command` | **Date**: 2026-03-09 | **Spec**: [spec.md](./spec.md)

## Summary

Add the constitution-required first line to 15 example YAML files that are missing it: `# helm diff upgrade --install -n localhost <release> ./charts/<chart-name>/ -f ./examples/<chart-name>/<file>.yaml`. No other edits; validate with helm template after each file.

## Technical Context

**Scope**: 15 files under `examples/`. Format: prepend one comment line; release name can match example name (e.g. minimal, with-only-job). Namespace: `localhost` (or default) per existing examples.

## Constitution Check

| Principle | Gate | Status |
|-----------|------|--------|
| Example files top line | New/edited examples MUST have top-line command comment | PASS (this feature adds it to existing) |

## Project Structure

- **Examples to fix**: See tasks.md. Charts: base, base-cronjob, cloudwatch-agent-prometheus, flagger-metrics-and-alerts, helm-chart-test, kafka-connect, karpenter-nodes, kubernetes-event-exporter-enriched, mongodb-bi-connector, namespaces-and-docker-auth, nfs-provisioner, pgcat, sentry-relay, spqr-router, weave-scope.
