{
  description = "Hindsight - Type-safe event sourcing system";

  # Automatic binary cache configuration
  # Users with Nix flakes enabled will automatically use hindsight-es cachix
  nixConfig = {
    extra-substituters = [
      "https://hindsight-es.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hindsight-es.cachix.org-1:2UQwF1OeL+6JQqIEhPXRivkNIRuO5dNcBrWYZ3vbpWk="
    ];
  };

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
          # IMPORTANT: http2-tls override must come BEFORE other package overrides
          haskellPackages = (pkgs.haskell.packages.ghc910.override {
            overrides = self: super: {
              # Override http2-tls FIRST so all dependencies use this version
              http2-tls = pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.doJailbreak (self.callCabal2nix "http2-tls" (pkgs.fetchFromGitHub {
                owner = "kazu-yamamoto";
                repo = "http2-tls";
                rev = "e4297d0fb932bde750f817f34c2ea9c4810bb2ee";  # PR#15 - drops old tls support
                sha256 = "sha256-JUBn0Dn9dKoE9nqm5WrjQmVrSF85foApvbCGI04gobU=";
              }) {}));
            };
          }).extend (self: super:
            let
              # Source overrides for local and git packages
              sources = pkgs.haskell.lib.compose.packageSourceOverrides {
                # Local hindsight packages
                hindsight-core = ./hindsight-core;
                hindsight-memory-store = ./hindsight-memory-store;
                hindsight-filesystem-store = ./hindsight-filesystem-store;
                hindsight-postgresql-store = ./hindsight-postgresql-store;
                hindsight-postgresql-projections = ./hindsight-postgresql-projections;
                hindsight-kurrentdb-store = ./hindsight-kurrentdb-store;
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
              postgresql-syntax = pkgs.haskell.lib.dontCheck super.postgresql-syntax;

              # Fetch http2-tls from source to get version compatible with tls >= 2.1
              http2-tls = pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.doJailbreak (self.callCabal2nix "http2-tls" (pkgs.fetchFromGitHub {
                owner = "kazu-yamamoto";
                repo = "http2-tls";
                rev = "e4297d0fb932bde750f817f34c2ea9c4810bb2ee";  # PR#15 - drops old tls support
                sha256 = "sha256-JUBn0Dn9dKoE9nqm5WrjQmVrSF85foApvbCGI04gobU=";
              }) {}));

              grapesy = pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.doJailbreak super.grapesy);

              # Jailbreak proto-lens packages to allow newer base/ghc-prim
              proto-lens = pkgs.haskell.lib.doJailbreak super.proto-lens;
              proto-lens-runtime = pkgs.haskell.lib.doJailbreak super.proto-lens-runtime;
              proto-lens-protobuf-types = pkgs.haskell.lib.doJailbreak super.proto-lens-protobuf-types;
              proto-lens-setup = pkgs.haskell.lib.doJailbreak super.proto-lens-setup;
              proto-lens-protoc = pkgs.haskell.lib.doJailbreak super.proto-lens-protoc;
              snappy-c = pkgs.haskell.lib.doJailbreak super.snappy-c;

              # Disable tests for all hindsight packages (critical: prevents test execution during inter-package builds)
              hindsight-core = pkgs.haskell.lib.dontCheck sources.hindsight-core;
              hindsight-memory-store = pkgs.haskell.lib.dontCheck sources.hindsight-memory-store;
              hindsight-filesystem-store = pkgs.haskell.lib.dontCheck sources.hindsight-filesystem-store;
              hindsight-postgresql-store = pkgs.haskell.lib.dontCheck sources.hindsight-postgresql-store;
              hindsight-postgresql-projections = pkgs.haskell.lib.dontCheck sources.hindsight-postgresql-projections;
              hindsight-kurrentdb-store = pkgs.haskell.lib.dontCheck sources.hindsight-kurrentdb-store;
              hindsight-tutorials = pkgs.haskell.lib.dontCheck sources.hindsight-tutorials;
              hindsight-website = pkgs.haskell.lib.dontCheck sources.hindsight-website;
            }
          );

          # Build all hindsight packages with tests disabled
          hindsight-core-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-core;
          hindsight-memory-store-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-memory-store;
          hindsight-filesystem-store-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-filesystem-store;
          hindsight-postgresql-store-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-postgresql-store;
          hindsight-postgresql-projections-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-postgresql-projections;
          hindsight-kurrentdb-store-pkg = pkgs.haskell.lib.dontCheck haskellPackages.hindsight-kurrentdb-store;
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
          # IMPORTANT: http2-tls override must come BEFORE other package overrides
          haskellPackages = (pkgs.haskell.packages.ghc910.override {
            overrides = self: super: {
              # Override http2-tls FIRST so all dependencies use this version
              http2-tls = pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.doJailbreak (self.callCabal2nix "http2-tls" (pkgs.fetchFromGitHub {
                owner = "kazu-yamamoto";
                repo = "http2-tls";
                rev = "e4297d0fb932bde750f817f34c2ea9c4810bb2ee";  # PR#15 - drops old tls support
                sha256 = "sha256-JUBn0Dn9dKoE9nqm5WrjQmVrSF85foApvbCGI04gobU=";
              }) {}));
            };
          }).extend (self: super:
            let
              sources = pkgs.haskell.lib.compose.packageSourceOverrides {
                hindsight-core = ./hindsight-core;
                hindsight-memory-store = ./hindsight-memory-store;
                hindsight-filesystem-store = ./hindsight-filesystem-store;
                hindsight-postgresql-store = ./hindsight-postgresql-store;
                hindsight-postgresql-projections = ./hindsight-postgresql-projections;
                hindsight-kurrentdb-store = ./hindsight-kurrentdb-store;
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

              grapesy = pkgs.haskell.lib.dontCheck (pkgs.haskell.lib.doJailbreak super.grapesy);

              # Jailbreak proto-lens packages to allow newer base/ghc-prim
              proto-lens = pkgs.haskell.lib.doJailbreak super.proto-lens;
              proto-lens-runtime = pkgs.haskell.lib.doJailbreak super.proto-lens-runtime;
              proto-lens-protobuf-types = pkgs.haskell.lib.doJailbreak super.proto-lens-protobuf-types;
              proto-lens-setup = pkgs.haskell.lib.doJailbreak super.proto-lens-setup;
              proto-lens-protoc = pkgs.haskell.lib.doJailbreak super.proto-lens-protoc;
              snappy-c = pkgs.haskell.lib.doJailbreak super.snappy-c;
            }
          );

          # All Hindsight packages (shared between dev shells)
          hindsightPackages = p: [
            p.hindsight-core
            p.hindsight-memory-store
            p.hindsight-filesystem-store
            p.hindsight-postgresql-store
            p.hindsight-postgresql-projections
            # Temporarily excluded due to gRPC dependency issues - build manually with cabal
            # p.hindsight-kurrentdb-store
            p.hindsight-tutorials
            p.hindsight-website
          ];

          # Core dependencies
          coreBuildInputs = with pkgs; [
            haskellPackages.cabal-install
            haskellPackages.proto-lens-protoc  # For proto-lens code generation
            pkg-config
            postgresql.dev
            protobuf  # For proto-lens code generation
            snappy  # For grapesy (gRPC compression)
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

          ciTools = coreBuildInputs ++ docsBuildInputs ++ (with pkgs; [
            haskellPackages.fourmolu
            haskellPackages.weeder
          ]);

        in {
          # Full development shell (with hls and others)
          default = haskellPackages.shellFor {
            packages = hindsightPackages;
            buildInputs = ciTools ++ (with pkgs; [
              git
              haskellPackages.haskell-language-server
              jq
            ]);

            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.zstd pkgs.zlib pkgs.snappy ]}"''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

              echo "🚀 Hindsight development environment (full)"
              echo "Using GHC: $(ghc --version)"
              echo "Using Cabal: $(cabal --version)"
              echo ""
              echo "Available tools:"
              echo "  - Haskell Language Server (HLS)"
              echo "  - fourmolu (code formatter)"
              echo "  - jq (JSON processing)"
              echo ""
              echo "Dev workflow:"
              echo "  cabal build all              - Build all packages"
              echo "  cabal test                   - Run test suite"
              echo "  fourmolu --mode inplace \$(find . -name '*.hs') - Format code"
              echo "  cd docs && make html         - Build documentation"
              echo ""
              echo "For CI-like builds, use: nix develop .#ci"
            '';
          };

          # Minimal CI shell
          ci = haskellPackages.shellFor {
            packages = hindsightPackages;
            buildInputs = ciTools;

            shellHook = ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.zstd pkgs.zlib pkgs.snappy ]}"''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

              echo "📦 Hindsight CI environment (minimal)"
              echo "Using GHC: $(ghc --version)"
              echo "Using Cabal: $(cabal --version)"
              echo ""
              echo "CI workflow:"
              echo "  cabal build all --project-file=cabal.project.ci"
              echo "  cabal test all --project-file=cabal.project.ci"
              echo "  fourmolu --mode check \$(find . -name '*.hs')"
              echo "  weeder"
              echo ""
              echo "For full dev tools (HLS, jq), use: nix develop"
            '';
          };
        });
    };
}
