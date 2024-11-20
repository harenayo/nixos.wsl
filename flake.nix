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
        # https://github.com/nix-community/NixOS-WSL/blob/a6b9cf0b7805e2c50829020a73e7bde683fd36dd/flake.nix#L29-L74
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
        # https://github.com/numtide/flake-utils/blob/11707dc2f618dd54ca8739b309ec4fc024de578b/lib.nix#L193-L201
        type = "app";
        program =
          let
            # https://nix-community.github.io/NixOS-WSL/building.html
            drv = self.nixosConfigurations.default.config.system.build.tarballBuilder;
          in
          "${drv}/bin/${drv.meta.mainProgram}";
      };
    };
}
