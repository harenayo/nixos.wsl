{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
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
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-wsl.nixosModules.wsl
          (
            { config, ... }:
            {
              config = {
                wsl.enable = true;
                nixpkgs.hostPlatform = "x86_64-linux";
                system.stateVersion = config.system.nixos.release;
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
          ${config.nixpkgs.hostPlatform}.build = config.system.build.tarballBuilder;
        };
    };
}
