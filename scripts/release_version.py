"""Plan stable releases from reachable SemVer tags without changing Git refs."""
import json
import re
import subprocess
import sys


def git(*args):
    return subprocess.check_output(['git', *args], text=True).strip()


def plan(bump='auto'):
    if bump not in {'auto', 'patch', 'minor', 'major'}:
        raise ValueError('Invalid version bump')
    sha = git('rev-parse', 'HEAD')
    tags = sorted((tuple(map(int, match.groups())), tag)
                  for tag in git('tag', '--merged', sha).splitlines()
                  if (match := re.fullmatch(r'v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', tag)))
    base = tags[-1][1] if tags else ''
    if base and git('rev-parse', f'{base}^{{commit}}') == sha:
        previous = next((tag for _, tag in reversed(tags)
                         if git('rev-parse', f'{tag}^{{commit}}') != sha), '')
        return dict(version=base, previous=previous, sha=sha, changed=False)
    messages = git('log', '--format=%B%x00', f'{base}..{sha}' if base else sha).split('\0')
    if bump == 'auto':
        subjects = [message.strip().splitlines()[0] for message in messages if message.strip()]
        if any(re.search(r'^BREAKING[ -]CHANGE:', message, re.M) for message in messages) or any(
            re.match(r'\w+(?:\([^\n)]*\))?!:', subject) for subject in subjects
        ):
            bump = 'major'
        elif any(re.match(r'feat(?:\([^\n)]*\))?:', subject) for subject in subjects):
            bump = 'minor'
        else:
            bump = 'patch'
    major, minor, patch = tags[-1][0] if tags else (0, 0, 0)
    if bump == 'major':
        major, minor, patch = major + 1, 0, 0
    elif bump == 'minor':
        minor, patch = minor + 1, 0
    else:
        patch += 1
    return dict(version=f'v{major}.{minor}.{patch}', previous=base, sha=sha, changed=True)


if __name__ == '__main__':
    print(json.dumps(plan(sys.argv[1] if len(sys.argv) > 1 else 'auto')))
