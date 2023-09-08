--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.markdown", "teaching.markdown", "contact.md"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "chicago-in-text-bibliography.csl" $ compile cslCompiler
--    match "cox.bib" $ compile biblioCompiler
    match "cox2.bib" $ compile biblioCompiler


    match "cv.md" $ do
        route $ setExtension "html"
        compile $
            myPandocBiblioCompiler2 >>=
            loadAndApplyTemplate "templates/default.html" defaultContext

    match "research.markdown" $ do
        route $ setExtension "html"
        compile $
            myPandocBiblioCompiler2 >>=
            loadAndApplyTemplate "templates/default.html" defaultContext
    
{- 
    match "cv.html" $ do
        route idRoute
        compile $ do
            getResourceBody
                >>= loadAndApplyTemplate "templates/default2.html" defaultContext
                >>= relativizeUrls -}

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

{-
myPandocBiblioCompiler :: Compiler (Item String)
myPandocBiblioCompiler = do
     csl <- load "chicago-in-text-bibliography.csl"
     bib <- load "cox.bib"
     getResourceBody >>=
         readPandocBiblio defaultHakyllReaderOptions csl bib >>=
         return . writePandoc
-}

myPandocBiblioCompiler2 :: Compiler (Item String)
myPandocBiblioCompiler2 = 
  pandocBiblioCompiler "chicago-in-text-bibliography.csl" "cox2.bib" 
