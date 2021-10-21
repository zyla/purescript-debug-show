module DebugShow where

import Prelude

import Data.Map as Map
import Data.Array as Array
import Data.Tuple (Tuple(..))
import Unsafe.Coerce (unsafeCoerce)
import Data.Foldable (any)
import Data.Maybe (Maybe(..))
import Foreign (Foreign, unsafeToForeign)
import Unsafe.Reference (unsafeRefEq)
import Foreign.Object (Object)

foreign import data Constructor :: Type
foreign import getConstructor :: forall a. a -> Constructor

instance Eq Constructor where eq = unsafeRefEq

constructorName :: Constructor -> String
constructorName con = (unsafeCoerce con :: { name :: String }).name

foreign import isInstanceOf :: Constructor -> Any -> Boolean

isOneOf :: Array Constructor -> Any -> Boolean
isOneOf cons x = any (\con -> isInstanceOf con x) cons

foreign import data Any :: Type

toAny :: forall a. a -> Any
toAny = unsafeCoerce

unsafeFromAny :: forall a. Any -> a
unsafeFromAny = unsafeCoerce

-- Data.Map

mapConstructors :: Array Constructor
mapConstructors =
  [ getConstructor Map.empty
  , getConstructor (Map.singleton 1 unit)
  , getConstructor (Map.fromFoldable [Tuple 1 unit, Tuple 2 unit])
  ]

mapDecoder :: Decoder
mapDecoder recur x
  | isOneOf mapConstructors x =
    let m = unsafeCoerce x :: Map.Map Any Any
        kvs = Map.toUnfoldable m :: Array (Tuple Any Any)
    in Just $ unsafeToForeign $ map (\(Tuple k v) -> [recur k, recur v]) kvs
  | otherwise = Nothing

tupleConstructor :: Constructor
tupleConstructor = getConstructor (Tuple unit unit)

tupleDecoder :: Decoder
tupleDecoder recur x
  | isInstanceOf tupleConstructor x =
    let Tuple x y = unsafeCoerce x
    in Just $ unsafeToForeign [recur x, recur y]
  | otherwise = Nothing

-- toDebugJSON

type Decoder = (Any -> Foreign) -> Any -> Maybe Foreign

decoders :: Array Decoder
decoders = [mapDecoder, tupleDecoder]

useDecoder :: forall a. a -> Maybe Foreign
useDecoder x = Array.findMap (\d -> d toDebugJSON (toAny x)) decoders

toDebugJSON :: forall a. a -> Foreign
toDebugJSON x
  | Just result <- useDecoder x
    = result
  | isUndefined x
    = unsafeToForeign "<undefined>"
  | isPrimitive x
    = unsafeToForeign x
  | isArray x
    = let array = unsafeCoerce x :: Array Any
      in unsafeToForeign $ toDebugJSON <$> array
  | getConstructor x /= plainRecordConstructor
    = unsafeToForeign $
      Array.cons (unsafeToForeign (constructorName (getConstructor x)))
      (toDebugJSON <$> getSumTypeArgs x)
  | otherwise
    = let obj = unsafeCoerce x :: Object Any
      in unsafeToForeign $ toDebugJSON <$> obj

plainRecordConstructor :: Constructor
plainRecordConstructor = getConstructor {}

foreign import isPrimitive :: forall a. a -> Boolean
foreign import isUndefined :: forall a. a -> Boolean
foreign import isArray :: forall a. a -> Boolean
foreign import getSumTypeArgs :: forall a. a -> Array Any
foreign import toJSON :: forall a. a -> String

debugShow :: forall a. a -> String
debugShow = toJSON <<< toDebugJSON
