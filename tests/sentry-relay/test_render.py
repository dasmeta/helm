"""Validate the scheduling contract of the rendered Relay workloads."""
import pathlib
import subprocess
import unittest

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[2]
CHART = ROOT / "charts/sentry-relay"


def workload(kind, priority=None):
    command = ["helm", "template", "relay-test", str(CHART),
               "--set", f"workload={kind}",
               "--set", "upstream=https://example.invalid"]
    if priority is not None:
        command += ["--set-string", f"priorityClassName={priority}"]
    documents = yaml.safe_load_all(subprocess.check_output(command, text=True))
    return next(document for document in documents
                if document and document.get("kind") == kind)


class SchedulingContract(unittest.TestCase):
    def test_defaults_preserve_resources_and_admission_defaults(self):
        for kind in ("DaemonSet", "Deployment"):
            with self.subTest(kind=kind):
                spec = workload(kind)["spec"]["template"]["spec"]
                self.assertNotIn("priorityClassName", spec)
                self.assertNotIn("preemptionPolicy", spec)
                self.assertEqual(spec["containers"][0]["resources"]["requests"],
                                 {"cpu": "100m", "memory": "256Mi"})

    def test_priority_class_reaches_each_pod_template(self):
        for kind in ("DaemonSet", "Deployment"):
            with self.subTest(kind=kind):
                default = workload(kind)["spec"]["template"]["spec"]
                configured = workload(kind, "relay-agents")["spec"]["template"]["spec"]
                self.assertEqual(configured.pop("priorityClassName", None), "relay-agents")
                # The scheduling option must not change image, config, requests or probes.
                self.assertEqual(configured, default)


if __name__ == "__main__":
    unittest.main()
