# Development tools: SDKs, IDEs, Docker, AI
{ pkgs, userConfig, ... }:

{
  # Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # nix-ld for JetBrains and other binaries
  programs.nix-ld.enable = true;

  # Environment variables for caches
  environment.variables = {
    CARGO_TARGET_DIR = "/home/${userConfig.username}/.cache/cargo-target";
    NUGET_PACKAGES = "/home/${userConfig.username}/.nuget/packages";
  };

  environment.systemPackages = with pkgs; [
    # === IDEs ===
    jetbrains.rider
    jetbrains.idea
    jetbrains.rust-rover
    zed-editor

    # === Languages ===
    # .NET 10
    dotnet-sdk_10

    # Java 21
    jdk21
    maven

    # Rust (via overlay)
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" "llvm-tools-preview" ];
    })

    # Node.js (for tooling)
    nodejs_22

    # === Rust Tools ===
    cargo-llvm-cov
    cargo-nextest
    bacon
    mold  # Fast linker

    # === Docker Tools ===
    docker-compose
    lazydocker

    # === Git ===
    git
    gh
    lazygit
  ];
}
