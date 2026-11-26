# =========================================================
# Archivo de Configuración de NixOS / Home Manager
# Repositorio: TheMakunga Infrastructure
# Módulo auto-gestionado.
# =========================================================
{
  lib,
  fetchFromGitHub,
  linkFarm,
  runCommand,
}: let
  matt = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "6654f6b60cd9d5be8b54c6fafe44346dabeb3b76";
    hash = "sha256-N5tpUIHO2VFeJntBTl6/VLDIVpqoshwFxNJlfXXUwsQ=";
  };
  vercel = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "skills";
    rev = "773fb2c7bbf16781670a3520affc4abd0c6151ae";
    hash = "sha256-cnw/zGRoAGTb8thGTXlWliFXKU1Vr4Mn/bfwiXgDwVI=";
  };
  ponytail = fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "ebd8654c2c627f721eb8f9c0d1bd4090a29f9e10";
    hash = "sha256-5m6JW3U6EMYUg4YVLh7nRRTWGY3shrFQ0wK0bediVFc=";
  };
  addy = fetchFromGitHub {
    owner = "addyosmani";
    repo = "agent-skills";
    rev = "6ca0cd7db39b41b1c37e26d335c507ee92382c6d";
    hash = "sha256-26aWgnw92KcA4b6bqpbWvs6aSCwBmIsANffUI445B8U=";
  };
  simplification = runCommand "code-simplification-skill" {} ''
    cp -r ${addy}/skills/code-simplification "$out"
    chmod -R u+w "$out"
    test "$(sed -n '4p' "$out/SKILL.md")" = '---'
    # Match the installed plugin's explicit-invocation setting.
    sed -i '4i disable-model-invocation: true' "$out/SKILL.md"
    cp ${addy}/LICENSE "$out/LICENSE"
  '';
  paths = {
    "ask-matt" = "skills/engineering/ask-matt";
    "claude-handoff" = "skills/in-progress/claude-handoff";
    "code-review" = "skills/engineering/code-review";
    "codebase-design" = "skills/engineering/codebase-design";
    "diagnosing-bugs" = "skills/engineering/diagnosing-bugs";
    "domain-modeling" = "skills/engineering/domain-modeling";
    "git-guardrails-claude-code" = "skills/misc/git-guardrails-claude-code";
    "grill-me" = "skills/productivity/grill-me";
    "grill-with-docs" = "skills/engineering/grill-with-docs";
    "grilling" = "skills/productivity/grilling";
    "handoff" = "skills/productivity/handoff";
    "implement" = "skills/engineering/implement";
    "implement-spec" = "skills/in-progress/implement-spec";
    "improve-codebase-architecture" = "skills/engineering/improve-codebase-architecture";
    "loop-me" = "skills/in-progress/loop-me";
    "migrate-to-shoehorn" = "skills/misc/migrate-to-shoehorn";
    "prototype" = "skills/engineering/prototype";
    "research" = "skills/engineering/research";
    "resolving-merge-conflicts" = "skills/engineering/resolving-merge-conflicts";
    "retro" = "skills/in-progress/retro";
    "scaffold-exercises" = "skills/misc/scaffold-exercises";
    "setup-matt-pocock-skills" = "skills/engineering/setup-matt-pocock-skills";
    "setup-pre-commit" = "skills/misc/setup-pre-commit";
    "setup-ts-deep-modules" = "skills/in-progress/setup-ts-deep-modules";
    "tdd" = "skills/engineering/tdd";
    "teach" = "skills/productivity/teach";
    "to-questionnaire" = "skills/productivity/to-questionnaire";
    "to-spec" = "skills/engineering/to-spec";
    "to-tickets" = "skills/engineering/to-tickets";
    "triage" = "skills/engineering/triage";
    "wait-what" = "skills/productivity/wait-what";
    "wayfinder" = "skills/engineering/wayfinder";
    "wizard" = "skills/engineering/wizard";
    "writing-beats" = "skills/in-progress/writing-beats";
    "writing-for-agents" = "skills/productivity/writing-for-agents";
    "writing-fragments" = "skills/in-progress/writing-fragments";
    "writing-shape" = "skills/in-progress/writing-shape";
  };
in
  linkFarm "codex-user-skills" (
    lib.mapAttrsToList (name: path: {
      inherit name;
      path = "${matt}/${path}";
    })
    paths
    ++ [
      {
        name = "find-skills";
        path = "${vercel}/skills/find-skills";
      }
    ]
    ++ map (name: {
      inherit name;
      path = "${ponytail}/skills/${name}";
    })
    ["ponytail" "ponytail-audit" "ponytail-debt" "ponytail-gain" "ponytail-help" "ponytail-review"]
    ++ [
      {
        name = "code-simplification";
        path = simplification;
      }
    ]
  )
