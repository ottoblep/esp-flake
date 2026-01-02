{
  callPackage,
  rust,
  lib,
  stdenv,
  fetchurl,
}: let
  version = "1.90.0.0";
  component = import {};
  # Remove keys from attrsets whose value is null.
  removeNulls = set:
    removeAttrs set
    (lib.filter (name: set.${name} == null)
      (lib.attrNames set));
  # FIXME: https://github.com/NixOS/nixpkgs/pull/146274
  toRustTarget = platform:
    if platform.isWasi
    then "${platform.parsed.cpu.name}-wasi"
    else rust.toRustTarget platform;
  mkComponentSet = callPackage ./rust/mk-component-set.nix {
    inherit toRustTarget removeNulls;
    # src =
  };
  mkAggregated = callPackage ./rust/mk-aggregated.nix {};

  selComponents = mkComponentSet {
    inherit version;
    renames = {};
    platform = "x86_64-linux";
    srcs = {
      rustc = fetchurl {
        url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-${version}-x86_64-unknown-linux-gnu.tar.xz";
        hash = "sha256-GmHoiEIVdOQbg72rNtSpg1GqYvV1tVXBtJczZprFacc=";
      };
      rust-src = fetchurl {
        url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-src-${version}.tar.xz";
        hash = "sha256-BqSkAyX0ftKGBXIzYV3WtT5zjF59QE2T1DZO2fZNpZk=";
      };
    };
  };
in
  assert stdenv.system == "x86_64-linux";
    mkAggregated {
      pname = "rust-xtensa";
      date = "2025-16-09";
      inherit version;
      availableComponents = selComponents;
      selectedComponents = [selComponents.rustc selComponents.rust-src];
    }
