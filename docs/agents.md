# AI agents / Agentes de IA

[README](../README.md)

[English](#english) | [Español](#español)

## English

Configuration: `my.agentWiki.enable`, `my.agentWiki.autoSync.enable`.

The shared vault beneath `~/.vaults/` supplies agent instructions
and the standalone GLaDOS skill. Activation registers configured hooks for Codex,
Claude Code and Hermes, reporting `OK: GLaDOS <agent>` on success instead of full JSON.
Hook registration and voice authorization are separate; existing runtime permissions
still apply. Optional vault synchronization defaults to a 300-second interval.

## Español

`my.agentWiki.enable` conecta el vault de `~/.vaults/` y sus instrucciones.
La integración de Codex, Claude Code y Hermes muestra una línea OK por agente.
Registrar hooks no concede autorización de voz. `my.agentWiki.autoSync.enable`
controla la sincronización periódica; el intervalo predeterminado es 300 segundos.
