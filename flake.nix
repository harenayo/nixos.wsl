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
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-wsl.nixosModules.wsl
          (
            { config, ... }:
            {
              config = {
                wsl.enable = true;
                nixpkgs.hostPlatform = system;
                system.stateVersion = config.system.nixos.release;
                programs.bash.loginShellInit = "nixos-wsl-welcome";
              };
            }
          )
        ];
      };
      apps.${system}.build = {
        type = "app";
        program =
          let
            drv = self.nixosConfigurations.default.config.system.build.tarballBuilder;
          in
          "${drv}/bin/${drv.meta.mainProgram}";
      };
    };
}
