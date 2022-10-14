# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ ytypes }: let

  yt = ytypes // ytypes.Core // ytypes.Prim;
  GitRef = import ./git-ref.nix { inherit ytypes; };
  lib.test = patt: s: ( builtins.match patt s ) != null;

# ---------------------------------------------------------------------------- #

  # A sha1 hash
  RE.rev_p = "[[:xdigit:]]\{40\}";

  Strings = {
    owner = let
      chars = lib.test "[a-zA-Z0-9]([a-zA-Z0-9-]*[^-])?";
      # No consecutive hyphens are allowed
      hyphens = s: ! ( lib.test ".*--.*" s );
      len = s: ( builtins.stringLength s ) <= 39;
      cond = s: ( len s ) && ( chars s ) && ( hyphens s );
    in yt.restrict "git:owner" cond yt.string;

    rev = yt.restrict "git:rev" ( lib.test RE.rev_p ) yt.string;
  };

# ---------------------------------------------------------------------------- #

in {
  Strings = Strings // GitRef.Strings;
  RE      = RE // GitRef.RE;
  inherit (GitRef)
    Eithers
    tryParseRef
    parseRef
    isRefStrict
    isRef
  ;

  inherit (Strings) owner rev;
  inherit (GitRef.Eithers) ref;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
