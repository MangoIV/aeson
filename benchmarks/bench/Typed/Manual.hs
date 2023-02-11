{-# LANGUAGE CPP #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Typed.Manual (benchmarks, decodeBenchmarks) where

import Prelude.Compat
import Bench

import Data.Aeson hiding (Result)
import qualified Data.Aeson.Decoding as Dec
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as L
import Twitter.Manual
import Utils

encodeDirect :: Result -> L.ByteString
encodeDirect = encode

encodeDirectStrict :: Result -> B.ByteString
encodeDirectStrict = L.toStrict . encode

encodeViaValue :: Result -> L.ByteString
encodeViaValue = encode . toJSON

benchmarks :: Benchmark
benchmarks =
  env ((,) <$> readV "twitter100.json" <*> readV "jp100.json") $ \ ~(twitter100, jp100) ->
  bgroup "Manual" [
      bgroup "direct" [
        bench "twitter100" $ nf encodeDirect twitter100
      , bench "jp100"      $ nf encodeDirect jp100
      ]
    , bgroup "strictViaLazy" [
        bench "twitter100" $ whnf encodeDirectStrict twitter100
      , bench "jp100"      $ whnf encodeDirectStrict jp100
      ]
    , bgroup "viaValue" [
        bench "twitter100" $ nf encodeViaValue twitter100
      , bench "jp100"      $ nf encodeViaValue jp100
      ]
    ]

decodeDirect :: B.ByteString -> Maybe Result
decodeDirect = decodeStrict

decodeTokens :: B.ByteString -> Maybe Result
decodeTokens = Dec.decodeStrict

decodeBenchmarks :: Benchmark
decodeBenchmarks =
  env ((,) <$> readS "twitter100.json" <*> readS "jp100.json") $ \ ~(twitter100, jp100) ->
  bgroup "Manual"
    [ bgroup "direct"
      [ bench "twitter100"  $ nf decodeDirect twitter100
      , bench "jp100"       $ nf decodeDirect jp100
      , bench "twitter100t" $ nf decodeTokens twitter100
      , bench "jp100t"      $ nf decodeTokens jp100
      ]
    ]
