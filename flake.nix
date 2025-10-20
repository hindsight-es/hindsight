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
          # Using ghc910 which has excellent version alignment with cabal.project.freeze
          haskellPackages = pkgs.haskell.packages.ghc910.extend (self: super:
            let
              # Source overrides for local and git packages
              sources = pkgs.haskell.lib.compose.packageSourceOverrides {
                # Local hindsight packages
                hindsight-core = ./hindsight-core;
                hindsight-memory-store = ./hindsight-memory-store;
                hindsight-filesystem-store = ./hindsight-filesystem-store;
                hindsight-postgresql-store = ./hindsight-postgresql-store;
                hindsight-postgresql-projections = ./hindsight-postgresql-projections;
                hindsight-tutorials = ./hindsight-tutorials;
                hindsight-website = ./website;
                munihac = ./munihac;

                # Git dependencies (with hashes for Nix purity)
                tmp-postgres = pkgs.fetchFromGitHub {
                  owner = "jfischoff";
                  repo = "tmp-postgres";
                  rev = "7f2467a6d6d5f6db7eed59919a6773fe006cf22b";
                  sha256 = "sha256-dE1OQN7I4Lxy6RBdLCvm75Z9D/Hu+9G4ejV2pEtvL1A=";
                };
              } self super;
            in
            sources // {
              # Disable tests for all overridden packages
              foundation = pkgs.haskell.lib.dontCheck super.foundation;
              tmp-postgres = pkgs.haskell.lib.dontCheck sources.tmp-postgres;
              postgresql-syntax = pkgs.haskell.lib.dontCheck super.postgresql-syntax; # FAILING text suite 

              # Disable tests for all hindsight packages (critical: prevents test execution during inter-package builds)
              hindsight-core = pkgs.haskell.lib.dontCheck sources.hindsight-core;
              hindsight-memory-store = pkgs.haskell.lib.dontCheck sources.hindsight-memory-store;
              hindsight-filesystem-store = pkgs.haskell.lib.dontCheck sources.hindsight-filesystem-store;
              hindsight-postgresql-store = pkgs.haskell.lib.dontCheck sources.hindsight-postgresql-store;
              hindsight-postgresql-projections = pkgs.haskell.lib.dontCheck sources.hindsight-postgresql-projections;
              hindsight-tutorials = pkgs.haskell.lib.dontCheck sources.hindsight-tutorials;
              hindsight-website = pkgs.haskell.lib.dontCheck sources.hindsight-website;
              munihac = pkgs.haskell.lib.dontCheck sources.munihac;

              # ============================================================
              # CRITICAL OVERRIDES - Only what's actually needed
              # ============================================================

              # Jailbreaks for packages rejecting our overrides
              # tasty-hedgehog = pkgs.haskell.lib.doJailbreak super.tasty-hedgehog;  # Needs hedgehog >= 1.7
              # time-compat = pkgs.haskell.lib.doJailbreak super.time-compat;  # Rejects random 1.3.1

              # # hedgehog 1.7 (nixpkgs has 1.5)
              # hedgehog = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "hedgehog";
              #     ver = "1.7";
              #     sha256 = "sha256-flX5CCnhZYG/nNzDr/rD/KrPgs9DIfVX2kPjEMm3khE=";
              #   } {}
              # );

              # # random 1.3.1 (nixpkgs has 1.2.1.3)
              # random = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "random";
              #     ver = "1.3.1";
              #     sha256 = "sha256-M2xVhHMZ7Lqvx/F832mGirHULgzv7TjP/oNkQ4V6YLM=";
              #   } {}
              # );

              # # criterion 1.6.4.1 (nixpkgs has 1.6.4.0)
              # criterion = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "criterion";
              #     ver = "1.6.4.1";
              #     sha256 = "sha256-673mD22+aQhhy2UaY+qwHM4hfVjy8UUPocBkX4xAtbc=";
              #   } {}
              # );

              # # optparse-applicative 0.19.0.0 (nixpkgs has 0.18.1.0)
              # # This was causing cascading failures when QuickCheck was upgraded
              # optparse-applicative = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "optparse-applicative";
              #     ver = "0.19.0.0";
              #     sha256 = "sha256-dhqvRILfdbpYPMxC+WpAyO0KUfq2nLopGk1NdSN2SDM=";
              #   } {}
              # );

              # # Citeproc 0.10 (nixpkgs has 0.9.0.1) - required for pandoc 3.8.2
              # citeproc = pkgs.haskell.lib.dontCheck (
              #   pkgs.haskell.lib.doJailbreak (
              #     self.callHackageDirect {
              #       pkg = "citeproc";
              #       ver = "0.10";
              #       sha256 = "sha256-j5f+nB1x6aGAWeRjIdHkecXwRsYsqbqVHRz8md1qkfk=";
              #     } {}
              #   )
              # );

              # # Pandoc 3.8.2 (nixpkgs has 3.7.0.2) - required for HighlightMethod API
              # pandoc = pkgs.haskell.lib.dontCheck (
              #   pkgs.haskell.lib.doJailbreak (
              #     self.callHackageDirect {
              #       pkg = "pandoc";
              #       ver = "3.8.2";
              #       sha256 = "sha256-/MEHAjXiRy5URBpp8xYDCaS/c5q0ZYpEjZAY2EhhFIA=";
              #     } {}
              #   )
              # );
            }
          );

          # Build all hindsight packages with tests disabled
          hindsight-core-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-core;
          hindsight-memory-store-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-memory-store;
          hindsight-filesystem-store-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-filesystem-store;
          hindsight-postgresql-store-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-postgresql-store;
          hindsight-postgresql-projections-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-postgresql-projections;
          hindsight-tutorials-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-tutorials;
          hindsight-website-exe = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-website;

        in {
          # Core hindsight packages
          hindsight-core = hindsight-core-pkg;
          hindsight-memory-store = hindsight-memory-store-pkg;
          hindsight-filesystem-store = hindsight-filesystem-store-pkg;
          hindsight-postgresql-store = hindsight-postgresql-store-pkg;
          hindsight-postgresql-projections = hindsight-postgresql-projections-pkg;
          hindsight-tutorials = hindsight-tutorials-pkg;

          # Website static site generator (used by GitHub Actions to build hindsight.events)
          hindsight-website = hindsight-website-exe;

          # Default: build all core packages
          default = pkgs.symlinkJoin {
            name = "hindsight-all";
            paths = [
              hindsight-core-pkg
              hindsight-memory-store-pkg
              hindsight-filesystem-store-pkg
              hindsight-postgresql-store-pkg
              hindsight-postgresql-projections-pkg
              hindsight-tutorials-pkg
            ];
          };
        });

      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Same extended package set as above (ghc910 for version alignment)
          haskellPackages = pkgs.haskell.packages.ghc910.extend (self: super:
            let
              sources = pkgs.haskell.lib.compose.packageSourceOverrides {
                hindsight-core = ./hindsight-core;
                hindsight-memory-store = ./hindsight-memory-store;
                hindsight-filesystem-store = ./hindsight-filesystem-store;
                hindsight-postgresql-store = ./hindsight-postgresql-store;
                hindsight-postgresql-projections = ./hindsight-postgresql-projections;
                hindsight-tutorials = ./hindsight-tutorials;
                hindsight-website = ./website;
                munihac = ./munihac;

                tmp-postgres = pkgs.fetchFromGitHub {
                  owner = "jfischoff";
                  repo = "tmp-postgres";
                  rev = "7f2467a6d6d5f6db7eed59919a6773fe006cf22b";
                  sha256 = "sha256-dE1OQN7I4Lxy6RBdLCvm75Z9D/Hu+9G4ejV2pEtvL1A=";
                };
              } self super;
            in
            sources // {
              # Disable tests for all overridden packages
              tmp-postgres = pkgs.haskell.lib.dontCheck sources.tmp-postgres;

              # ============================================================
              # CRITICAL OVERRIDES - Same as packages section above
              # ============================================================

              # QuickCheck = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "QuickCheck";
              #     ver = "2.16.0.0";
              #     sha256 = "sha256-HWL+HFdHG6Vnk+Thfa0AoEjgPggiQmyKMLRYUUKLAZU=";
              #   } {}
              # );

              # hedgehog = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "hedgehog";
              #     ver = "1.7";
              #     sha256 = "sha256-flX5CCnhZYG/nNzDr/rD/KrPgs9DIfVX2kPjEMm3khE=";
              #   } {}
              # );

              # random = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "random";
              #     ver = "1.3.1";
              #     sha256 = "sha256-M2xVhHMZ7Lqvx/F832mGirHULgzv7TjP/oNkQ4V6YLM=";
              #   } {}
              # );

              # criterion = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "criterion";
              #     ver = "1.6.4.1";
              #     sha256 = "sha256-673mD22+aQhhy2UaY+qwHM4hfVjy8UUPocBkX4xAtbc=";
              #   } {}
              # );

              # optparse-applicative = pkgs.haskell.lib.dontCheck (
              #   self.callHackageDirect {
              #     pkg = "optparse-applicative";
              #     ver = "0.19.0.0";
              #     sha256 = "sha256-dhqvRILfdbpYPMxC+WpAyO0KUfq2nLopGk1NdSN2SDM=";
              #   } {}
              # );

              # citeproc = pkgs.haskell.lib.dontCheck (
              #   pkgs.haskell.lib.doJailbreak (
              #     self.callHackageDirect {
              #       pkg = "citeproc";
              #       ver = "0.10";
              #       sha256 = "sha256-j5f+nB1x6aGAWeRjIdHkecXwRsYsqbqVHRz8md1qkfk=";
              #     } {}
              #   )
              # );

              # pandoc = pkgs.haskell.lib.dontCheck (
              #   pkgs.haskell.lib.doJailbreak (
              #     self.callHackageDirect {
              #       pkg = "pandoc";
              #       ver = "3.8.2";
              #       sha256 = "sha256-/MEHAjXiRy5URBpp8xYDCaS/c5q0ZYpEjZAY2EhhFIA=";
              #     } {}
              #   )
              # );

              # ============================================================
              # JAILBREAKS - Packages with tight version bounds rejecting our overrides
              # ============================================================
              # attoparsec = pkgs.haskell.lib.doJailbreak super.attoparsec;
              # indexed-traversable-instances = pkgs.haskell.lib.doJailbreak super.indexed-traversable-instances;
              # integer-conversion = pkgs.haskell.lib.doJailbreak super.integer-conversion;
              # integer-logarithms = pkgs.haskell.lib.doJailbreak super.integer-logarithms;
              # psqueues = pkgs.haskell.lib.doJailbreak super.psqueues;
              # time-compat = pkgs.haskell.lib.doJailbreak super.time-compat;
              # unicode-transforms = pkgs.haskell.lib.doJailbreak super.unicode-transforms;
              # uuid-types = pkgs.haskell.lib.doJailbreak super.uuid-types;


              # tasty-hedgehog: needs jailbreak to accept hedgehog 1.7
              # tasty-hedgehog = pkgs.haskell.lib.doJailbreak super.tasty-hedgehog;
              # text-iso8601 = pkgs.haskell.lib.doJailbreak super.text-iso8601;
              # uuid = pkgs.haskell.lib.doJailbreak super.uuid;
              # vector-algorithms = pkgs.haskell.lib.doJailbreak super.vector-algorithms;
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
            jq
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
              echo "  cabal build all              - Build all packages"
              echo "  cabal test                   - Run test suite"
              echo "  cd docs && make html         - Build documentation"
              echo ""
              echo "Nix build:"
              echo "  nix build .#hindsight-website  - Build website generator (for hindsight.events)"
            '';
          };

          # Minimal CI shell
          ci = haskellPackages.shellFor {
            packages = p: [
              p.hindsight-core
              p.hindsight-memory-store
              p.hindsight-filesystem-store
              p.hindsight-postgresql-store
              p.hindsight-postgresql-projections
              p.hindsight-tutorials
            ];
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
