{-# LANGUAGE OverloadedStrings #-}

module Main where

import Hakyll
import System.FilePath ((</>), takeBaseName)
import Text.Pandoc.Highlighting (pygments)
import Text.Pandoc.Options (WriterOptions(..), HighlightMethod(..))

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

config :: Configuration
config = defaultConfiguration
    { destinationDirectory = "_site"
    , storeDirectory       = "_cache"
    , tmpDirectory         = "_cache/tmp"
    , providerDirectory    = "."
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
            pandocCompilerWith defaultHakyllReaderOptions writerOptions
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    -- Render about page
    match "content/about.md" $ do
        route $ customRoute $ \ident ->
            let base = takeBaseName (toFilePath ident)
            in base ++ ".html"
        compile $ do
            pandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

    -- Blog posts
    match "content/posts/*" $ do
        route $ setExtension "html"
        compile $ do
            pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html" postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

    -- Blog archive/index
    create ["blog.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "content/posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Blog"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/post-list.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

--------------------------------------------------------------------------------
-- Pandoc Options
--------------------------------------------------------------------------------

writerOptions :: WriterOptions
writerOptions = defaultHakyllWriterOptions
    { writerHighlightMethod = Skylighting pygments
    }

--------------------------------------------------------------------------------
-- Contexts
--------------------------------------------------------------------------------

postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext
