{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/2405.5.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
    }:
    {
      nixosModules.default =
        { lib, config, ... }:
        {
          options.wsl.distro = {
            enable = lib.options.mkOption {
              type = lib.types.bool;
              default = false;
            };
            config = lib.options.mkOption {
              default = { };
            };
          };
          config.environment.etc."wsl-distribution.conf" = lib.modules.mkIf config.wsl.distro.enable {
            enable = true;
            text = lib.generators.toINI { } config.wsl.distro.config;
            mode = "0644";
          };
        };
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        # https://github.com/nix-community/NixOS-WSL/blob/a6b9cf0b7805e2c50829020a73e7bde683fd36dd/flake.nix#L29-L74
        modules = [
          nixos-wsl.nixosModules.wsl
          self.nixosModules.default
          (
            { config, ... }:
            {
              config = {
                nixpkgs.hostPlatform = "x86_64-linux";
                system.stateVersion = config.system.nixos.release;
                wsl = {
                  enable = true;
                  distro = {
                    enable = true;
                    config = {
                      oobe.defaultName = "NixOS";
                      shortcut.icon = nixpkgs.legacyPackages.${config.nixpkgs.hostPlatform.system}.fetchurl {
                        url = "https://raw.githubusercontent.com/nix-community/NixOS-WSL/refs/tags/2405.5.4/Launcher/Launcher/nixos.ico";
                        hash = "sha256-heA2OU04L0roefvt0zg6lCrv1ZKfQxyuLs5LWDs/Oyk=";
                      };
                    };
                  };
                };
                programs.bash.loginShellInit = "nixos-wsl-welcome";
              };
            }
          )
        ];
      };
      apps =
        let
          config = self.nixosConfigurations.default.config;
        in
        {
          ${config.nixpkgs.hostPlatform.system}.build = {
            # https://github.com/numtide/flake-utils/blob/11707dc2f618dd54ca8739b309ec4fc024de578b/lib.nix#L193-L201
            type = "app";
            program =
              let
                # https://nix-community.github.io/NixOS-WSL/building.html
                drv = config.system.build.tarballBuilder;
              in
              "${drv}/bin/${drv.meta.mainProgram}";
          };
        };
    };
}
