{
  description = "Fort Knox NixOS - Secure Developer Workstation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangowc = {
      url = "github:DreamMaoMao/mangowc";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:amaanq/helium-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, impermanence, home-manager, rust-overlay, niri, mangowc, zen-browser, helium, ... }@inputs:
  let
    userConfig = import ./config.nix;
    style = import ./style.nix;
  in {
    nixosConfigurations.${userConfig.hostname} = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs style userConfig;
      };
      modules = [
        # Set platform (replaces deprecated top-level 'system' attribute)
        { nixpkgs.hostPlatform = "x86_64-linux"; }

        # Flake modules
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        home-manager.nixosModules.home-manager
        mangowc.nixosModules.mango

        # Add niri Home-Manager module to all users
        {
          home-manager.sharedModules = [ niri.homeModules.niri ];
        }

        # Rust overlay
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ rust-overlay.overlays.default ];
        })

        # Host configuration
        ./hosts/default
      ];
    };
  };
}
