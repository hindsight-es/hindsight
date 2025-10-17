# Hindsight Website

Static website for the Hindsight project, built with [Hakyll](https://jaspervdj.be/hakyll/) and integrating Sphinx documentation.

## Architecture

- **Hakyll**: Static site generator for main website (blog, landing pages)
- **Sphinx**: Technical documentation (tutorials, API reference, guides)
- **Symlink integration**: `docs-build -> ../docs/build/html` allows Hakyll to include Sphinx output

## Local Development

### Prerequisites

The development environment is managed via Nix. Ensure you have Nix installed, then:

```bash
# Enter development shell
nix develop
```

This provides all necessary dependencies: GHC, Cabal, Sphinx, Python, Pandoc, etc.

### Building the Site

**Full build** (Sphinx docs + Hakyll site):

```bash
# From project root
./scripts/deploy-site.sh
```

Or manually:

```bash
# Build Sphinx documentation
cd docs
make html

# Build Hakyll site
cd ../website
cabal run site build
```

**Watch mode** (auto-rebuild on changes):

```bash
cd website
cabal run site watch
# Site available at http://localhost:8000
```

**Clean build artifacts**:

```bash
cd website
cabal run site clean
```

### Project Structure

```
website/
├── site.hs              # Hakyll configuration
├── content/             # Markdown content
│   ├── index.md         # Landing page
│   ├── about.md         # About page
│   └── posts/           # Blog posts
├── templates/           # HTML templates
├── css/                 # Stylesheets
├── docs-build/          # Symlink to ../docs/build/html
├── _site/               # Generated site (gitignored)
└── _cache/              # Hakyll cache (gitignored)
```

## Deployment

The site is automatically deployed to GitHub Pages via GitHub Actions.

### Automatic Deployment

Push to the `main` branch triggers deployment:

```bash
git push hindsight-es main
```

The workflow (`.github/workflows/deploy-site.yaml`):
1. Builds Sphinx documentation
2. Builds Hakyll site
3. Deploys to GitHub Pages

**Live site**: https://hindsight-es.github.io/hindsight/

### Manual Deployment Testing

Test the build locally before pushing:

```bash
./scripts/deploy-site.sh
```

This runs the same build steps as CI without deploying.

### GitHub Pages Configuration

The repository uses the official GitHub Pages deployment actions:
- `actions/upload-pages-artifact@v4` - Uploads site artifact
- `actions/deploy-pages@v4` - Deploys to GitHub Pages

**Required permissions** (already configured in workflow):
- `pages: write` - Deploy to Pages
- `id-token: write` - Verify deployment source
- `contents: read` - Checkout repository

**Repository settings**:
1. Go to Settings → Pages
2. Source: **GitHub Actions** (not branch-based)
3. No additional configuration needed

### Deployment Triggers

The workflow runs on:
- **Push to main**: When `website/**` or `docs/**` files change
- **Manual dispatch**: Via GitHub Actions UI ("Run workflow" button)

### Troubleshooting

**Build fails in CI but works locally?**
- Ensure all dependencies are in `flake.nix`
- Check Nix cache setup (cachix)
- Review workflow logs for missing tools

**Site not updating?**
- Check GitHub Actions tab for workflow status
- Verify workflow triggered (check commit touched `website/` or `docs/`)
- GitHub Pages can take 1-2 minutes to update after deployment

**Sphinx docs not showing?**
- Ensure `docs-build` symlink points to `../docs/build/html`
- Run `cd docs && make html` before building Hakyll site
- Check Hakyll routes in `site.hs` (line 36-40)

## Development Workflow

1. **Make changes** to Markdown content, templates, or Sphinx docs
2. **Test locally**: `cabal run site watch` (or `./scripts/deploy-site.sh` for full build)
3. **Commit changes**: `git commit -am "Update documentation"`
4. **Push to deploy**: `git push hindsight-es main`
5. **Verify**: Check https://hindsight-es.github.io/hindsight/

## Adding Content

### Blog Posts

Create a new file in `content/posts/`:

```bash
# content/posts/2025-01-15-my-post.md
---
title: My Post Title
date: 2025-01-15
author: Your Name
---

Post content here...
```

### Static Pages

Add Markdown files to `content/`:

```bash
# content/features.md
---
title: Features
---

Feature list...
```

Update `site.hs` to add routing for new pages.

### Documentation

Sphinx documentation lives in `docs/source/`. See `docs/README.md` for details.

## Technical Details

### Hakyll Configuration

- **Destination**: `_site/` (generated HTML)
- **Cache**: `_cache/` (Hakyll build cache)
- **Templates**: Loaded from `templates/`
- **Sphinx integration**: Copies `docs-build/**` to `docs/` in output

### Dependencies

Managed via `flake.nix`:
- GHC 9.10.2
- Cabal
- Hakyll 4.16+
- Sphinx + RTD theme
- Pandoc

### CI Environment

GitHub Actions uses Nix to replicate the local development environment:
- `cachix/install-nix-action@v27` - Install Nix
- `cachix/cachix-action@v15` - Optional Nix cache (faster builds)

## Resources

- [Hakyll Documentation](https://jaspervdj.be/hakyll/)
- [Sphinx Documentation](https://www.sphinx-doc.org/)
- [GitHub Pages Actions](https://github.com/actions/deploy-pages)
