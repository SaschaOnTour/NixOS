# AI Coding Tools: Claude Code, Codex, OpenCode
{ pkgs, lib, userConfig, ... }:

let
  aiFeatures = userConfig.features.ai or {};

  codex-wrapper = pkgs.writeShellScriptBin "codex" ''
    exec ${pkgs.nodejs_22}/bin/npx -y @openai/codex "$@"
  '';

  opencode-wrapper = pkgs.writeShellScriptBin "opencode" ''
    exec ${pkgs.nodejs_22}/bin/npx -y opencode-ai "$@"
  '';
in
{
  environment.systemPackages =
    (lib.optionals (aiFeatures.claudeCode or false) [ pkgs.claude-code ])
    ++ (lib.optionals (aiFeatures.chatgptCodex or false) [ codex-wrapper ])
    ++ (lib.optionals (aiFeatures.openCode or false) [ opencode-wrapper ]);
}
