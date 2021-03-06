module These exposing (These(..), these, mapBoth, mergeWith, merge, align)

{-|
A type that may be an `a`, a `b`, or both an `a` and a `b` at once.

@docs These, these, mapBoth, mergeWith, merge, align
-}

{-|
This type is very closely related to [Result a b](http://package.elm-lang.org/packages/elm-lang/core/latest/Result#Result).

While [Result a b](http://package.elm-lang.org/packages/elm-lang/core/latest/Result#Result)
models exclusive-or, this type models inclusive-or.
-}
type These a b
  = This a
  | That b
  | These a b

{-|
There is only one implementation of this function.
It is fully described by the type signature.

Replace any `a`s with `c`s and replace any `b`s with `d`s.
-}
mapBoth : (a -> c) -> (b -> d) -> These a b -> These c d
mapBoth f g =
  these (This << f) (That << g) (\a b -> These (f a) (g b))

{-|
Destroy the structure of a [These a b](#These).

The first two functions are applied to the `This a` and `That b` values, respectively.
The third function is applied to the `These a b` value.
-}
these : (a -> c) -> (b -> c) -> (a -> b -> c) -> These a b -> c
these f g h these =
  case these of
    This a ->
      f a
    That b ->
      g b
    These a b ->
      h a b

{-|
A version of [mergeWith](#mergeWith) that does not modify the `This a` or `That a` values.
-}
merge : (a -> a -> a) -> These a a -> a
merge =
  these identity identity

{-|
Similar to [these](#these).

The difference is that in the `These a b` case
we apply the second and third functions and merge the results with the first function.
-}
mergeWith : (c -> c -> c) -> (a -> c) -> (b -> c) -> These a b -> c
mergeWith f g h =
  these g h (\x y -> f (g x) (h y))

{-|
Similar to [List.Extra.zip](http://package.elm-lang.org/packages/elm-community/list-extra/latest/List-Extra#zip)
except the resulting list is the length of the longer list.

We can also think of this from a relational algebra perspective (or SQL if that's your thing).
We view each list as a relation (table) where the primary key is its index in the list.
Then [List.Extra.zip](http://package.elm-lang.org/packages/elm-community/list-extra/latest/List-Extra#zip)
can be viewed as a natural join (inner join),
and [align](#align) can be viewed as a full outer join.
-}
align : List a -> List b -> List (These a b)
align =
  align' []

align' : List (These a b) -> List a -> List b -> List (These a b)
align' acc xss yss =
  case (xss, yss) of
    ([], []) ->
      List.reverse acc
    (x::xs, []) ->
      align' (This x::acc) xs []
    ([], y::ys) ->
      align' (That y::acc) [] ys
    (x::xs, y::ys) ->
      align' (These x y::acc) xs ys
