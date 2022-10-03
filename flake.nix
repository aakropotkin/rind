# ============================================================================ #
#
# Nix CLI wrapper generator and misc utils for augmenting the use of Nix's
# flake UX patterns.
#
# - URI parser and type checker written in pure Nix.
#   + Allows you to parse URIs from Nix expressions matching Nix's builtin
#     `parseFlakeRef' and `fetchTree' processors.
#   + Allows registries, locks, and flake inputs to be created programmatically
#     without using Nix's CLI directly.
#
# ---------------------------------------------------------------------------- #

{
  description = "A Nix CLI extension kit";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/master";
  inputs.ak-nix.url  = "github:aakropotkin/ak-nix/main";
  inputs.ak-nix.inputs.nixpkgs.follows = "/nixpkgs";

# ---------------------------------------------------------------------------- #

  outputs = { self, nixpkgs, ak-nix, ... } @ inputs: let
    lib = ak-nix.lib.extend self.overlays.lib;
    pkgsForSys = system: nixpkgs.legacyPackages.${system};
  in {  # Begin Outputs

    inherit lib;

# ---------------------------------------------------------------------------- #

    # Pure `lib' extensions.
    # Mostly regex patterns aside from the URI types.
    overlays.lib = final: prev: {
      parser = import "${toString ./lib/parsers/uri.nix}" { lib = final; };
      liburi = import "${toString ./lib/uri.nix}" { lib = final; };
      regexps = ( prev.regexps or {} ) // {
        uri = import "${toString ./re/uri.nix}";
      };
      ytypes = ( prev.ytypes or {} ) //
               ( import "${toString ./types/uri.nix}" { lib = final; } );
    };
    # Nixpkgs overlay: Builders, Packages, Overrides, etc.
    overlays.pkgs = final: prev: let
      callPackagesWith = auto: prev.lib.callPackagesWith ( final // auto );
      callPackageWith  = auto: prev.lib.callPackageWith ( final // auto );
      callPackages     = callPackagesWith {};
      callPackage      = callPackageWith {};
    in {
      lib = prev.lib.extend self.overlays.lib;
    };
    overlays.default = self.overlays.pkgs;


# ---------------------------------------------------------------------------- #

    # Installable Packages for Flake CLI.
    packages = lib.eachDefaultSystemMap ( system: let
      pkgsFor = pkgsForSys system;
      testFlake = lib.libflake.callFlake ./tests {
        rime = self;
        inherit ak-nix;
        self = testFlake;
      };
    in {
      inherit (testFlake.packages.${system}) tests;
    } );


# ---------------------------------------------------------------------------- #

  };  # End Outputs
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
