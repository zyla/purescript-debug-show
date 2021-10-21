module Test.Main where

import Prelude

import Data.Maybe (Maybe(..))
import DebugShow (debugShow)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Foreign (Foreign)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import Data.Tuple (Tuple(..))
import Data.Map as Map

foreign import null :: Foreign
foreign import undefined :: Foreign

data Sum = C1 Int | C2 Int Int

main :: Effect Unit
main = launchAff_ $ runSpec [consoleReporter] do
  describe "debugShow" do
    it "primitives" do
      debugShow unit `shouldEqual` "{}"
      debugShow 123 `shouldEqual` "123"
      debugShow 1.23 `shouldEqual` "1.23"
      debugShow "hello" `shouldEqual` "\"hello\""
      debugShow null `shouldEqual` "null"
      debugShow undefined `shouldEqual` "\"<undefined>\""
    it "records" do
      debugShow { foo: 1, bar: 2 } `shouldEqual` """{"foo":1,"bar":2}"""
      debugShow { n: null } `shouldEqual` """{"n":null}"""
      debugShow { u: undefined } `shouldEqual` """{"u":"<undefined>"}"""
    it "sum types" do
      debugShow Nothing `shouldEqual` """["Nothing"]"""
      debugShow (Just 1) `shouldEqual` """["Just",1]"""
      debugShow (C2 2 3) `shouldEqual` """["C2",2,3]"""
    it "arrays" do
      debugShow [1,2,3] `shouldEqual` """[1,2,3]"""
    it "tuples" do
      debugShow (Tuple 1 2) `shouldEqual` """[1,2]"""
    it "maps" do
      debugShow Map.empty `shouldEqual` """[]"""
      debugShow (Map.fromFoldable [Tuple 1 2, Tuple 3 4]) `shouldEqual` """[[1,2],[3,4]]"""
      debugShow (Map.fromFoldable [Tuple 1 2, Tuple 2 3, Tuple 3 4, Tuple 4 5])
        `shouldEqual` """[[1,2],[2,3],[3,4],[4,5]]"""
