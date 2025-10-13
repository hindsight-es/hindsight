{
  description = "Hindsight - Type-safe event sourcing system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Extend Haskell package set with our local packages + git deps
          haskellPackages = pkgs.haskell.packages.ghc9102.extend (self: super:
            let
              # Source overrides for local and git packages
              sources = pkgs.haskell.lib.compose.packageSourceOverrides {
                # Local packages
                hindsight = ./hindsight;
                hindsight-website = ./website;
                munihac = ./munihac;

                # Git dependencies (with hashes for Nix purity)
                tmp-postgres = pkgs.fetchFromGitHub {
                  owner = "jfischoff";
                  repo = "tmp-postgres";
                  rev = "7f2467a6d6d5f6db7eed59919a6773fe006cf22b";
                  sha256 = "sha256-dE1OQN7I4Lxy6RBdLCvm75Z9D/Hu+9G4ejV2pEtvL1A=";
                };

                # Weeder 2.10.0 (released Aug 1, 2025) - required for GHC 9.10.2 support
                # This commit is the official 2.10.0 release tag
                # We override because nixpkgs GHC 9.10.2 package set may not have 2.10.0 yet
                weeder = pkgs.fetchFromGitHub {
                  owner = "ocharles";
                  repo = "weeder";
                  rev = "fb052ddad9a69442937feed5958fe9bab03b1fc1"; # tag: 2.10.0
                  sha256 = "sha256-mUc2iPoiOgp6qLVeG1sJHo1fSYvy+DO+E2ED/bWtnyY=";
                };
              } self super;
            in
            sources // {
              # Disable tests for packages with flaky tests
              foundation = pkgs.haskell.lib.dontCheck super.foundation;
              weeder = pkgs.haskell.lib.dontCheck sources.weeder;

              # Citeproc 0.10+ required for pandoc 3.8.2 (nixpkgs has older version)
              citeproc = pkgs.haskell.lib.dontCheck (
                pkgs.haskell.lib.doJailbreak (
                  self.callHackageDirect {
                    pkg = "citeproc";
                    ver = "0.10";
                    sha256 = "sha256-j5f+nB1x6aGAWeRjIdHkecXwRsYsqbqVHRz8md1qkfk=";
                  } {}
                )
              );

              # Pandoc 3.8.2 required for HighlightMethod API (nixpkgs has 3.7.x)
              pandoc = pkgs.haskell.lib.dontCheck (
                pkgs.haskell.lib.doJailbreak (
                  self.callHackageDirect {
                    pkg = "pandoc";
                    ver = "3.8.2";
                    sha256 = "sha256-/MEHAjXiRy5URBpp8xYDCaS/c5q0ZYpEjZAY2EhhFIA=";
                  } {}
                )
              );
            }
          );

          # Disable tests for faster CI builds
          hindsight-lib = pkgs.haskell.lib.dontCheck haskellPackages.hindsight;
          hindsight-website-exe = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-website;
          munihac-exe = pkgs.haskell.lib.dontCheck haskellPackages.munihac;

        in {
          # Main library
          hindsight = hindsight-lib;

          # Website executable (what CI needs)
          hindsight-website = hindsight-website-exe;

          # Demo executables
          munihac = munihac-exe;

          # Default: website for CI
          default = hindsight-website-exe;
        });

      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Same extended package set as above
          haskellPackages = pkgs.haskell.packages.ghc9102.extend (self: super:
            let
              sources = pkgs.haskell.lib.compose.packageSourceOverrides {
                hindsight = ./hindsight;
                hindsight-website = ./website;
                munihac = ./munihac;

                tmp-postgres = pkgs.fetchFromGitHub {
                  owner = "jfischoff";
                  repo = "tmp-postgres";
                  rev = "7f2467a6d6d5f6db7eed59919a6773fe006cf22b";
                  sha256 = "sha256-dE1OQN7I4Lxy6RBdLCvm75Z9D/Hu+9G4ejV2pEtvL1A=";
                };

                # Weeder 2.10.0 (released Aug 1, 2025) - required for GHC 9.10.2 support
                # This commit is the official 2.10.0 release tag
                # We override because nixpkgs GHC 9.10.2 package set may not have 2.10.0 yet
                weeder = pkgs.fetchFromGitHub {
                  owner = "ocharles";
                  repo = "weeder";
                  rev = "fb052ddad9a69442937feed5958fe9bab03b1fc1"; # tag: 2.10.0
                  sha256 = "sha256-mUc2iPoiOgp6qLVeG1sJHo1fSYvy+DO+E2ED/bWtnyY=";
                };
              } self super;
            in
            sources // {
              # Disable tests for packages with flaky tests
              foundation = pkgs.haskell.lib.dontCheck super.foundation;
              weeder = pkgs.haskell.lib.dontCheck sources.weeder;

              # Citeproc 0.10+ required for pandoc 3.8.2 (nixpkgs has older version)
              citeproc = pkgs.haskell.lib.dontCheck (
                pkgs.haskell.lib.doJailbreak (
                  self.callHackageDirect {
                    pkg = "citeproc";
                    ver = "0.10";
                    sha256 = "sha256-j5f+nB1x6aGAWeRjIdHkecXwRsYsqbqVHRz8md1qkfk=";
                  } {}
                )
              );

              # Pandoc 3.8.2 required for HighlightMethod API (nixpkgs has 3.7.x)
              pandoc = pkgs.haskell.lib.dontCheck (
                pkgs.haskell.lib.doJailbreak (
                  self.callHackageDirect {
                    pkg = "pandoc";
                    ver = "3.8.2";
                    sha256 = "sha256-/MEHAjXiRy5URBpp8xYDCaS/c5q0ZYpEjZAY2EhhFIA=";
                  } {}
                )
              );
            }
          );

          # Core dependencies
          coreBuildInputs = with pkgs; [
            haskellPackages.cabal-install
            postgresql.dev
            zlib.dev
            zstd
          ];

          # Docs dependencies
          docsBuildInputs = with pkgs; [
            pandoc
            python3
            python3Packages.sphinx
            python3Packages.sphinx-rtd-theme
            python3Packages.sphinxawesome-theme
            python3Packages.myst-parser
          ];

          # Full dev tools
          devTools = coreBuildInputs ++ docsBuildInputs ++ (with pkgs; [
            haskellPackages.ghcid
            haskellPackages.graphmod
            haskellPackages.weeder
            git
            graphviz
            R
            rPackages.ggplot2
            rPackages.dplyr
            rPackages.readr
            rPackages.broom
            rPackages.gridExtra
            rPackages.scales
            haskellPackages.haskell-language-server
          ]);

        in {
          # Full development shell
          default = haskellPackages.shellFor {
            packages = p: [ ];
            buildInputs = devTools;

            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.zstd pkgs.zlib ]}"''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

              echo "🚀 Hindsight development environment"
              echo "Using GHC: $(ghc --version)"
              echo "Using Cabal: $(cabal --version)"
              echo ""
              echo "Dev workflow:"
              echo "  cabal build all       - Build with cabal"
              echo "  cabal test            - Run tests"
              echo ""
              echo "Nix builds (CI-ready):"
              echo "  nix build .#hindsight          - Build library"
              echo "  nix build .#hindsight-website  - Build website"
              echo ""
            '';
          };

          # Minimal CI shell
          ci = haskellPackages.shellFor {
            packages = p: [ ];
            buildInputs = coreBuildInputs ++ docsBuildInputs;

            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.zstd pkgs.zlib ]}"''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

              echo "📦 Hindsight CI environment"
              echo "Using GHC: $(ghc --version)"
              echo "Using Cabal: $(cabal --version)"
              echo ""
            '';
          };
        });
    };
}
