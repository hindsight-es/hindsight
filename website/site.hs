{-# LANGUAGE OverloadedStrings #-}

module Main where

import Hakyll
import Hakyll.Web.Feed
import System.FilePath (takeBaseName, (</>))
import Text.Pandoc.Definition
import Text.Pandoc.Highlighting (pygments)
import Text.Pandoc.Options (WriterOptions (..))
import Text.Pandoc.Walk (walk)

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

config :: Configuration
config =
    defaultConfiguration
        { destinationDirectory = "_site"
        , storeDirectory = "_cache"
        , tmpDirectory = "_cache/tmp"
        , providerDirectory = "."
        }

feedConfiguration :: FeedConfiguration
feedConfiguration =
    FeedConfiguration
        { feedTitle = "Hindsight Blog"
        , feedDescription = "Type-safe event sourcing in Haskell"
        , feedAuthorName = "Gaël Deest"
        , feedAuthorEmail = "[email protected]"
        , feedRoot = "https://hindsight.events"
        }

--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------

main :: IO ()
main = hakyllWith config $ do
    -- Templates (must be first so they can be loaded by other rules)
    match "templates/*" $ compile templateBodyCompiler

    -- Copy CNAME file for custom domain
    match "CNAME" $ do
        route idRoute
        compile copyFileCompiler

    -- Copy static assets
    match "css/*" $ do
        route idRoute
        compile copyFileCompiler

    match "js/*" $ do
        route idRoute
        compile copyFileCompiler

    -- Copy Sphinx documentation (built separately via symlink)
    -- docs-build is a symlink to ../docs/build/html
    match "docs-build/**" $ do
        route $ customRoute $ \ident ->
            "docs" </> drop (length ("docs-build/" :: String)) (toFilePath ident)
        compile copyFileCompiler

    -- Render index page
    match "content/index.md" $ do
        route $ customRoute $ const "index.html"
        compile $ do
            pandocMermaidCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    -- Render about page
    match "content/about.md" $ do
        route $ customRoute $ \ident ->
            let base = takeBaseName (toFilePath ident)
             in base ++ ".html"
        compile $ do
            pandocMermaidCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    -- Blog posts
    match "content/posts/*" $ do
        route $ setExtension "html"
        compile $ do
            pandocMermaidCompiler
                >>= loadAndApplyTemplate "templates/post.html" postCtx
                >>= saveSnapshot "content"
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

    -- Blog archive/index
    create ["blog.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "content/posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts)
                        `mappend` constField "title" "Blog"
                        `mappend` defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/post-list.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    -- RSS Feed
    create ["rss.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "content/posts/*" "content"
            renderRss feedConfiguration feedCtx posts

    -- Atom Feed
    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "content/posts/*" "content"
            renderAtom feedConfiguration feedCtx posts

    -- JSON Feed
    create ["feed.json"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "content/posts/*" "content"
            renderJson feedConfiguration feedCtx posts

--------------------------------------------------------------------------------
-- Pandoc Options & Filters
--------------------------------------------------------------------------------

writerOptions :: WriterOptions
writerOptions =
    defaultHakyllWriterOptions
        { writerHighlightStyle = Just pygments
        }

-- | Transform mermaid code blocks into divs that Mermaid.js can render
mermaidTransform :: Block -> Block
mermaidTransform (CodeBlock (_, classes, _) content)
    | "mermaid" `elem` classes =
        RawBlock (Format "html") $ "<div class=\"mermaid\">\n" <> content <> "\n</div>"
mermaidTransform x = x

-- | Pandoc compiler with mermaid support
pandocMermaidCompiler :: Compiler (Item String)
pandocMermaidCompiler =
    pandocCompilerWithTransform
        defaultHakyllReaderOptions
        writerOptions
        (walk mermaidTransform)

--------------------------------------------------------------------------------
-- Contexts
--------------------------------------------------------------------------------

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y"
        `mappend` defaultContext
