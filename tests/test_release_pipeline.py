"""Release regression checks using isolated Git repos and a fake GitHub CLI."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
FAKE_GH = r'''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
args=sys.argv[1:]
state=Path(os.environ['GH_STATE'])
with state.with_suffix('.calls').open('a') as file: file.write(json.dumps(args)+'\n')
if args[:2]==['auth','setup-git']: pass
elif args[0]=='api': print('Generated release notes')
elif args[:2]==['release','view']:
    if not state.exists(): sys.exit(1)
    print(state.read_text())
elif args[:2]==['release','create']:
    state.write_text(json.dumps({'isDraft':True,'targetCommitish':os.environ['RELEASE_SHA']}))
elif args[:2]==['release','upload']:
    if os.environ.get('FAIL_UPLOAD'): sys.exit(1)
elif args[:2]==['release','edit']:
    data=json.loads(state.read_text()); data['isDraft']=False; state.write_text(json.dumps(data))
else: raise RuntimeError(args)
'''


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='release-check-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / 'source'
        self.repo.mkdir()
        self.env = {key: value for key, value in os.environ.items() if not key.startswith('GIT_')}
        self.env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_NOSYSTEM='1')
        self.git('init', '-q', '-b', 'main')
        self.git('config', 'user.name', 'Release tests')
        self.git('config', 'user.email', 'release@example.test')
        self.commit('chore: initial snapshot')
        self.git('tag', 'v0.8.5')

    def git(self, *args):
        return subprocess.check_output(['git', *args], cwd=self.repo, env=self.env,
                                       text=True, stderr=subprocess.PIPE).strip()

    def commit(self, subject):
        self.git('commit', '--allow-empty', '-qm', subject)

    def plan(self, bump='auto'):
        return json.loads(subprocess.check_output(
            [sys.executable, str(ROOT / 'scripts/release_version.py'), bump],
            cwd=self.repo, env=self.env, text=True))

    def prepare_publication(self):
        self.commit('feat: new installer')
        self.sha = self.git('rev-parse', 'HEAD')
        remote = self.root / 'origin.git'
        subprocess.run(['git', 'init', '-q', '--bare', str(remote)], env=self.env, check=True)
        self.git('remote', 'add', 'origin', str(remote))
        self.git('push', '-q', '-u', 'origin', 'main', '--tags')
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        gh = self.bin / 'gh'
        gh.write_text(FAKE_GH)
        gh.chmod(0o755)
        self.state = self.root / 'release.json'
        self.env.update(PATH=str(self.bin) + os.pathsep + self.env['PATH'],
                        GH_STATE=str(self.state), GH_TOKEN='test-token', RELEASE_SHA=self.sha,
                        VERSION='v0.9.0', PREVIOUS_TAG='v0.8.5', GITHUB_REPOSITORY='example/test')
        output = self.repo / 'output'
        output.mkdir()
        (output / 'aperture-bootstrap-v0.9.0-test.img.zst').write_bytes(b'image')
        (output / 'linux-bootstrap-v0.9.0-test.iso').write_bytes(b'iso')

    def publish(self):
        return subprocess.run(['bash', str(ROOT / 'scripts/publish-release.sh')],
                              cwd=self.repo, env=self.env, text=True, capture_output=True)

    def test_no_new_commits(self):
        self.assertFalse(self.plan()['changed'])
        self.assertEqual(self.plan()['version'], 'v0.8.5')

    def test_feature_and_exact_sha(self):
        self.commit('feat(installers): add image')
        self.assertEqual(self.plan()['version'], 'v0.9.0')
        self.assertEqual(self.plan()['sha'], self.git('rev-parse', 'HEAD'))

    def test_dependency_updates_release_a_patch(self):
        self.commit('chore: refresh lockfile')
        self.assertEqual(self.plan()['version'], 'v0.8.6')

    def test_breaking_subject(self):
        self.commit('fix!: change format')
        self.assertEqual(self.plan()['version'], 'v1.0.0')

    def test_breaking_body(self):
        self.commit('feat: update\n\nBREAKING CHANGE: new format')
        self.assertEqual(self.plan()['version'], 'v1.0.0')

    def test_breaking_hyphenated_body(self):
        self.commit('fix: update\n\nBREAKING-CHANGE: new format')
        self.assertEqual(self.plan()['version'], 'v1.0.0')

    def test_manual_major(self):
        self.commit('fix: installer')
        self.assertEqual(self.plan('major')['version'], 'v1.0.0')

    def test_ignores_legacy_prerelease_and_unreachable_tags(self):
        self.git('tag', 'v202607231949')
        self.git('tag', 'v8.0.0-rc.1')
        self.git('checkout', '-qb', 'other')
        self.commit('feat: unmerged')
        self.git('tag', 'v99.0.0')
        self.git('checkout', '-q', 'main')
        self.commit('fix: main')
        self.assertEqual(self.plan()['version'], 'v0.8.6')

    def test_existing_tag_can_resume_with_previous_version(self):
        self.commit('feat: installer')
        self.git('tag', 'v0.9.0')
        self.assertEqual(self.plan(), dict(version='v0.9.0', previous='v0.8.5',
                                         sha=self.git('rev-parse', 'HEAD'), changed=False))

    def test_collector_rejects_missing_and_empty_images(self):
        source = self.root / 'images'
        source.mkdir()
        command = ['bash', str(ROOT / 'scripts/collect-release-artifacts.sh'),
                   'rpi', str(source), 'v0.9.0', str(self.root / 'output')]
        self.assertNotEqual(subprocess.run(command, capture_output=True).returncode, 0)
        image = source / 'test.img.zst'
        image.touch()
        self.assertNotEqual(subprocess.run(command, capture_output=True).returncode, 0)
        image.write_bytes(b'image')
        subprocess.run(command, check=True, capture_output=True)
        self.assertEqual((self.root / 'output/aperture-bootstrap-v0.9.0-test.img.zst').read_bytes(), b'image')

    def test_missing_assets_cannot_create_a_tag(self):
        self.prepare_publication()
        (self.repo / 'output/linux-bootstrap-v0.9.0-test.iso').unlink()
        self.assertNotEqual(self.publish().returncode, 0)
        self.assertEqual(self.git('tag', '-l', 'v0.9.0'), '')

    def test_upload_failure_resumes_draft_then_keeps_published_release(self):
        self.prepare_publication()
        self.env['FAIL_UPLOAD'] = '1'
        self.assertNotEqual(self.publish().returncode, 0)
        self.assertTrue(json.loads(self.state.read_text())['isDraft'])
        del self.env['FAIL_UPLOAD']
        result = self.publish()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(json.loads(self.state.read_text())['isDraft'])
        before = self.state.with_suffix('.calls').read_text().count('"upload"')
        self.assertEqual(self.publish().returncode, 0)
        self.assertEqual(self.state.with_suffix('.calls').read_text().count('"upload"'), before)
        self.assertEqual(self.git('rev-parse', 'main'), self.sha)
        self.assertEqual(self.git('rev-parse', 'v0.9.0^{commit}'), self.sha)
        self.assertIn('CHANGELOG.md', (self.repo / 'output/SHA256SUMS').read_text())
        subprocess.run(['sha256sum', '-c', 'SHA256SUMS'], cwd=self.repo / 'output',
                       env=self.env, check=True, capture_output=True)

    def test_draft_for_another_commit_is_not_modified(self):
        self.prepare_publication()
        self.state.write_text(json.dumps({'isDraft': True, 'targetCommitish': '0' * 40}))
        self.assertNotEqual(self.publish().returncode, 0)
        self.assertEqual(json.loads(self.state.read_text())['targetCommitish'], '0' * 40)

    def test_conflicting_remote_tag_is_not_changed(self):
        self.prepare_publication()
        self.git('tag', 'v0.9.0', 'v0.8.5')
        self.git('push', '-q', 'origin', 'v0.9.0')
        self.assertNotEqual(self.publish().returncode, 0)
        self.assertEqual(self.git('rev-parse', 'v0.9.0'), self.git('rev-parse', 'v0.8.5'))
        self.assertFalse(self.state.exists())


if __name__ == '__main__':
    unittest.main()
