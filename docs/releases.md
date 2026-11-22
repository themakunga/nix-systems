# Releases and branch workflow / Releases y ramas

[README](../README.md)

[English](#english) | [Español](#español)

## English

1. **`develop`:** integration and default branch. Pushes and pull requests run CI and
   security checks. The manual **Promote develop to main** workflow opens a promotion
   PR and builds a prerelease; it does not merge `main` automatically.
2. **`main`:** stable source approved by the owner. **Release** always snapshots this
   branch once, then builds both installers from that exact commit. It never pushes
   a changelog commit to `main`.
3. **Manual stable release:** open **Actions → Release → Run workflow**, select
   `develop` (or `main` after the updated workflow reaches it), and choose `auto`,
   `patch`, `minor` or `major`. The selected workflow branch does not change the
   installer source: it is always `main`.
4. **Weekly stable release:** Mondays at **10:00 UTC**, the workflow checks for new
   main commits. With none, it skips the builds. `auto` uses Conventional Commits:
   breaking changes increment major, `feat` increments minor, and other new commits
   increment patch, including dependency updates. Historical prerelease/date tags
   do not participate in stable version calculation.
5. **Publication:** both nonempty installers must succeed before a tag is created.
   GitHub's workflow token publishes a draft, uploads the images, generated
   `CHANGELOG.md` and `SHA256SUMS`, then marks the release published/latest. A retry
   can resume an unfinished draft; a published version is left unchanged.

The stable installer targets are `aperture-bootstrap` (ARM64 SD image) and
`linux-bootstrap` (x86_64 ISO). Download them from
[Releases](https://github.com/themakunga/nix-systems/releases); these are bootstrap
installers, not an image for every configured host. The generated changelog is a
release asset; publication does not rewrite the repository's historical changelog.
The workflow uses `GITHUB_TOKEN` for tags/releases; a separate `RELEASE_TOKEN` is
not required. Existing private-input and Cachix credentials remain necessary for
image builds. Never add credential values to this README.

Check release behavior locally without publishing or building images:

```sh
python3 -m unittest discover -s tests -p test_release_pipeline.py
actionlint .github/workflows/release.yaml
```

## Español

1. **`develop`:** rama de integración y predeterminada. Los pushes y PR ejecutan CI
   y seguridad. **Promote develop to main** abre un PR de promoción y genera un
   prerelease; no fusiona `main` automáticamente.
2. **`main`:** fuente estable aprobada por el propietario. **Release** toma una única
   revisión de esta rama y construye ambos instaladores desde ella. No publica
   commits de changelog en `main`.
3. **Release manual:** abre **Actions → Release → Run workflow**, selecciona `develop`
   (o `main` cuando incorpore el workflow actualizado) y elige `auto`, `patch`, `minor`
   o `major`. Las imágenes siempre proceden de `main`, independientemente de la rama
   elegida para ejecutar el workflow.
4. **Release semanal:** cada lunes a las **10:00 UTC**, comprueba si hay commits nuevos
   en `main`. Sin cambios, omite las compilaciones. `auto` sigue Conventional Commits:
   cambios incompatibles incrementan la versión mayor, `feat` la menor y el resto
   incrementa el parche, incluidas las actualizaciones de dependencias. Los tags de
   prerelease o fecha no intervienen en el cálculo de versiones estables.
5. **Publicación:** exige ambos instaladores completos antes de crear el tag. Publica
   primero un borrador, adjunta imágenes, `CHANGELOG.md` y `SHA256SUMS`, y lo hace
   público al terminar. Los nuevos intentos completan borradores pendientes y
   conservan intactos los releases ya publicados.

Los destinos son `aperture-bootstrap` (imagen SD ARM64) y `linux-bootstrap` (ISO
x86_64). Se descargan desde [Releases](https://github.com/themakunga/nix-systems/releases).
Son instaladores iniciales; no se genera una imagen distinta para cada host. El
changelog generado se adjunta al release y no reemplaza el archivo histórico del
repositorio. Tags y releases usan `GITHUB_TOKEN`, sin necesitar `RELEASE_TOKEN`.
Las credenciales existentes para inputs privados y Cachix siguen siendo necesarias;
no copies sus valores al README.

Comprueba el flujo sin publicar ni construir imágenes:

```sh
python3 -m unittest discover -s tests -p test_release_pipeline.py
actionlint .github/workflows/release.yaml
```
