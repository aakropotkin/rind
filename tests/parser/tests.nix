# ============================================================================ #
#
# General tests for `parser' routines.
#
# ---------------------------------------------------------------------------- #

{ lib }: let

# ---------------------------------------------------------------------------- #

  tests = {

# ---------------------------------------------------------------------------- #

    testParseRepo = let
      url = "https://github.com/aakropotkin/rime.git";
    in {
      expr = with lib.parser;
        parseAbsolutePath (
          parseNetworkPath (
            parseHierarchyPart (
              parseAbsoluteUri (
                parseUriRef url
              ).uri.absolute
            ).part.hierarchy
          ).path.network
        ).path.absolute;
      expected = ["aakropotkin" "rime.git"];
    };


# ---------------------------------------------------------------------------- #

  };  # End Tests


# ---------------------------------------------------------------------------- #

in tests


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
