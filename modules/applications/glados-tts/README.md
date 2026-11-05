# GLaDOS playback engine

This module provides `glados-say` (Piper/model/player) and `glados-agent`
(Python with PyYAML and jsonschema). It does not register agent hooks.
`glados-agent` loads the standalone skill from `~/.vaults/amgmt/skills/glados`.
The standalone skill owns configuration, phrases, renewal and session throttling.
Legacy journal settings and legacy hook registration are retired.

Prepare changes through Nix and validate affected hosts without a system switch.
For installation and migration, follow the standalone skill's integration guide.
Codex hook trust and Hermes shell-hook approval remain native runtime decisions;
never prepopulate their trust records. Other runtimes remain text-only unless
explicitly authorized. Invoke `glados-say` with validated phrase text only.
