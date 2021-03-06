module Text.BlazeHtml.Internal.HtmlMonad
    ( HtmlMonad (..)
    ) where

import Data.Monoid

import GHC.Exts (IsString (..))

import Text.BlazeHtml.Internal.Html

newtype HtmlMonad h a = HtmlMonad { runHtmlMonad :: h }

instance (Monoid h) => Monoid (HtmlMonad h a) where
    mempty                                = HtmlMonad mempty
    mappend (HtmlMonad h1) (HtmlMonad h2) = HtmlMonad $ h1 `mappend` h2

instance (Html h) => Html (HtmlMonad h a) where
    separate (HtmlMonad h1) (HtmlMonad h2) = HtmlMonad $ h1 `separate` h2
    unescapedText t = HtmlMonad $ unescapedText t
    leafElement t = HtmlMonad $ leafElement t
    nodeElement t (HtmlMonad h) = HtmlMonad $ nodeElement t h
    modifyAttributeModifier f (HtmlMonad h) =
        HtmlMonad $ modifyAttributeModifier f h
    
instance (Monoid h) => Monad (HtmlMonad h) where
    return   = mempty
    (HtmlMonad h1) >> (HtmlMonad h2) = HtmlMonad $ h1 `mappend` h2
    (HtmlMonad h1) >>= f = let HtmlMonad h2 = f errorMessage
                           in HtmlMonad $ h1 `mappend` h2
      where
        errorMessage = error "HtmlMonad: >>= returning values not supported."

instance (Html h) => IsString (HtmlMonad h a) where
    fromString = text . fromString
