"""Exercise private-input authentication and prerelease failure propagation."""
import base64
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class CISecretHandlingTests(unittest.TestCase):
    def test_workflows_do_not_export_decoded_keys(self):
        for workflow in (ROOT / '.github/workflows').glob('*.yaml'):
            self.assertFalse('DECODED_SSH_KEY' in workflow.read_text(), str(workflow))

    def test_all_ssh_jobs_use_scoped_secrets_and_cleanup(self):
        jobs = 0
        for workflow in (ROOT / '.github/workflows').glob('*.yaml'):
            for job in re.split(r'(?=^  [a-zA-Z][\w-]*:\n)', workflow.read_text(), flags=re.M):
                if 'name: Load private-input SSH key' not in job:
                    continue
                jobs += 1
                self.assertIn('CI_SSH_KEY_BASE64: ${{ secrets.SECRETS_REPO_SSH_KEY_BASE64 }}', job)
                self.assertIn('setup-ci-ssh.sh', job)
                self.assertIn("if: always() && env.SSH_AGENT_PID != ''", job)
                self.assertIn('run: ssh-agent -k >/dev/null', job)
        self.assertEqual(jobs, 8)

    def test_prerelease_collector_accepts_only_valid_tags(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'test.img.zst').write_bytes(b'image')
            command = ['bash', str(ROOT / 'scripts/collect-release-artifacts.sh'), 'rpi', str(root)]
            for tag in ('pre-202611220411', 'v0.9.0'):
                result = subprocess.run(command + [tag, str(root / 'output')], capture_output=True)
                self.assertEqual(result.returncode, 0)
                self.assertTrue((root / f'output/aperture-bootstrap-{tag}-test.img.zst').is_file())
            for tag in ('pre-invalid', '../escape', 'v1.2', 'pre-2026'):
                self.assertNotEqual(subprocess.run(command + [tag, str(root / 'output')],
                                                   capture_output=True).returncode, 0)

    def test_agent_loads_key_without_exporting_or_printing_it(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            key = root / 'key'
            subprocess.run(['ssh-keygen', '-q', '-t', 'ed25519', '-N', '',
                            '-C', 'ci-regression', '-f', str(key)], check=True)
            private = key.read_text()
            job_env = root / 'job-env'
            job_env.touch()
            env = dict(os.environ, CI_SSH_KEY_BASE64=base64.b64encode(key.read_bytes()).decode(),
                       GITHUB_ENV=str(job_env))
            result = subprocess.run(['bash', str(ROOT / 'scripts/setup-ci-ssh.sh')],
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, 'SSH setup failed')
            exported = dict(line.split('=', 1) for line in job_env.read_text().splitlines())
            try:
                self.assertEqual(set(exported), {'SSH_AUTH_SOCK', 'SSH_AGENT_PID'})
                for line in private.splitlines():
                    self.assertFalse(line in result.stdout + result.stderr + job_env.read_text(),
                                     'Private key material escaped the SSH loader')
                self.assertNotIn(env['CI_SSH_KEY_BASE64'], result.stdout + result.stderr)
                agent_env = dict(os.environ, **exported)
                identities = subprocess.run(['ssh-add', '-l'], env=agent_env,
                                            capture_output=True, text=True, check=True)
                self.assertIn('ci-regression', identities.stdout)
            finally:
                if 'SSH_AGENT_PID' in exported:
                    subprocess.run(['ssh-agent', '-k'], env=dict(os.environ, **exported),
                                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def test_invalid_base64_fails_without_exporting_agent(self):
        with tempfile.TemporaryDirectory() as directory:
            job_env = Path(directory) / 'job-env'
            job_env.touch()
            env = dict(os.environ, CI_SSH_KEY_BASE64='invalid-base64!', GITHUB_ENV=str(job_env))
            result = subprocess.run(['bash', str(ROOT / 'scripts/setup-ci-ssh.sh')],
                                    env=env, capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(job_env.read_text(), '')

    def test_prerelease_build_errors_remain_visible_and_fail(self):
        workflow = (ROOT / '.github/workflows/promote-to-main.yaml').read_text()
        builds = re.findall(r'      - name: Build (?:aperture-bootstrap SD image|linux-bootstrap ISO)\n(.*?)(?=      - uses:)',
                            workflow, re.S)
        self.assertEqual(len(builds), 2)
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            nix = root / 'nix'
            nix.write_text('#!/bin/sh\necho "fixture Nix build error" >&2\nexit 42\n')
            nix.chmod(0o755)
            for step in builds:
                body = step.split('        run: |\n', 1)[1]
                body = '\n'.join(line[10:] for line in body.splitlines())
                body = body.replace('${{ needs.prepare.outputs.tag }}', 'pre-202611220411')
                result = subprocess.run(['bash', '-e', '-c', body], cwd=root,
                                        env=dict(os.environ, PATH=str(root) + os.pathsep + os.environ['PATH']),
                                        capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('fixture Nix build error', result.stderr)
                self.assertFalse((root / 'output').exists())


if __name__ == '__main__':
    unittest.main()
