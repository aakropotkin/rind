# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ ytypes }: let

  yt    = ytypes // ytypes.Core // ytypes.Prim;
  pats  = ( import ../re/uri.nix ).patterns;
  tpat' = name: pname: yt.restrict name ( lib.test pats.${pname} ) yt.string;
  tpat  = name: tpat' name "${name}_p";
  lib.test = p: s: ( builtins.match p s ) != null;

# ---------------------------------------------------------------------------- #

  Strings = {
    # Scheme sub-parts as `<DATA_FORMAT>+<TRANSPORT_LAYER>', e.g. `file+https'
    # This technically isn't standardized but everyone uses it.
    layer         = tpat "layer";
    transport     = Strings.layer;
    data          = Strings.layer;
    scheme        = tpat "scheme";
    rel_path      = tpat "rel_path";
    abs_path      = tpat "abs_path";
    net_path      = tpat "net_path";
    # NOTE: the names "absolute/relative" are somewhat confusing because they
    # may refer to "absolute/relative URIs", or paths.
    # The type "path" should be renamed.
    # XXX: NOT relative!
    path          = yt.either Strings.abs_path Strings.net_path;
    authority     = tpat "authority";
    query         = tpat "query";
    fragment      = tpat "fragment";
    abs_uri       = tpat "abs_uri";
    rel_uri       = tpat "rel_uri";
    uri_ref       = tpat "uri_ref";
    hier_part     = tpat "hier_part";
    opaque_part   = tpat "opaque_part";
    segment       = tpat "segment";
    path_segments = tpat "path_segments";
    server        = tpat "server";
    userinfo      = tpat "userinfo";
    hostport      = tpat "hostport";
    host          = tpat "host";
    hostname      = tpat "hostname";
    port          = tpat "port";
    ipv4_addr     = tpat "ipv4_addr";
    ipv6_addr     = tpat "ipv6_addr";
    ip_addr       = yt.either Strings.ipv6_addr Strings.ipv4_addr;
    param         = tpat "param";
  };  # End Strings


# ---------------------------------------------------------------------------- #

  Sums = {
    uri = yt.sum "uri" {
      absolute = Strings.abs_uri;
      relative = Strings.rel_uri;
    };
    host = yt.sum "host" { inherit (Strings) hostname ip_addr; };
  };


# ---------------------------------------------------------------------------- #

  Attrs = {
    params = yt.attrs ( yt.option Strings.param );
  };


# ---------------------------------------------------------------------------- #

  Structs = {
    hostport = yt.struct "hostport" {
      inherit (Sums) host;
      port = yt.option Strings.port;
    };
    scheme = yt.struct "scheme" {
      transport = Strings.layer;
      data      = yt.option Strings.layer;
    };
    url = yt.struct "url" {
      inherit (Structs) scheme;
      path      = yt.option Strings.path;
      authority = yt.option Strings.authority;  # technically part of "path"
      query     = yt.option Attrs.params;
      fragment  = yt.option Strings.fragment;
    };
  };


# ---------------------------------------------------------------------------- #

in {
  inherit
    Strings Sums Attrs Structs
  ;
}

# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
