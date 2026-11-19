#!/usr/bin/env bash
set -euo pipefail
: "${GH_TOKEN:?}" "${VERSION:?}" "${RELEASE_SHA:?}" "${GITHUB_REPOSITORY:?}"
[[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
[[ "$RELEASE_SHA" =~ ^[a-f0-9]{40}$ ]]
test "$(git rev-parse HEAD)" = "$RELEASE_SHA"
git merge-base --is-ancestor "$RELEASE_SHA" refs/remotes/origin/main
shopt -s nullglob
rpi=(output/aperture-bootstrap-"$VERSION"-*.img output/aperture-bootstrap-"$VERSION"-*.img.zst output/aperture-bootstrap-"$VERSION"-*.img.gz)
linux=(output/linux-bootstrap-"$VERSION"-*.iso output/linux-bootstrap-"$VERSION"-*.iso.zst output/linux-bootstrap-"$VERSION"-*.iso.gz)
(( ${#rpi[@]} > 0 && ${#linux[@]} > 0 ))
for file in "${rpi[@]}" "${linux[@]}"; do test -s "$file"; done

gh auth setup-git
if [ -n "$(git ls-remote --tags origin "refs/tags/$VERSION")" ]; then
  git fetch origin "refs/tags/$VERSION:refs/tags/$VERSION"
  test "$(git rev-parse "$VERSION^{commit}")" = "$RELEASE_SHA"
else
  git tag "$VERSION" "$RELEASE_SHA"
  git push origin "refs/tags/$VERSION"
fi
if gh release view "$VERSION" --json isDraft,targetCommitish > release-state.json; then
  if [ "$(jq -r '.isDraft' release-state.json)" = false ]; then
    echo "Release $VERSION is already published; leaving it unchanged."
    exit 0
  fi
  test "$(jq -r '.targetCommitish' release-state.json)" = "$RELEASE_SHA"
fi
notes_args=(-f "tag_name=$VERSION" -f "target_commitish=$RELEASE_SHA")
if [ -n "${PREVIOUS_TAG:-}" ]; then notes_args+=(-f "previous_tag_name=$PREVIOUS_TAG"); fi
gh api --method POST "repos/$GITHUB_REPOSITORY/releases/generate-notes" "${notes_args[@]}" --jq .body > release-notes.md
{
  printf '# %s\n\n' "$VERSION"
  cat release-notes.md
  if [ -f CHANGELOG.md ]; then printf '\n\n'; cat CHANGELOG.md; fi
} > output/CHANGELOG.md
checksum_files=()
for file in "${rpi[@]}" "${linux[@]}"; do checksum_files+=("$(basename "$file")"); done
(cd output && sha256sum "${checksum_files[@]}" CHANGELOG.md > SHA256SUMS)
if [ ! -s release-state.json ]; then
  gh release create "$VERSION" --verify-tag --target "$RELEASE_SHA" \
    --title "Release $VERSION" --notes-file release-notes.md --draft
fi
gh release upload "$VERSION" "${rpi[@]}" "${linux[@]}" output/CHANGELOG.md output/SHA256SUMS --clobber
gh release edit "$VERSION" --draft=false --latest
echo "Published $VERSION from $RELEASE_SHA"
