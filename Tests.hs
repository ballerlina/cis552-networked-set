-- Testing code for Final Project

module Tests where

import Test.HUnit (runTestTT,Test(..),Assertion, (~?=), (~:), assert)
import Test.QuickCheck 

import Control.Monad

import qualified Parser as P
import qualified ParserCombinators as P

import MultiplayerGame
import Logic

-----------------------------------------------------------------
main :: IO ()
main = do
   _ <- runTestTT (TestList [getCardsTest, removePuncTest, boardContainsSetTest,
                 validSetTest, playableSetTest, playableBoardTest])
   quickCheck prop_playableBoardTrue
   quickCheck prop_playableBoardFalse
   return ()

------------------------ Unit Testing ---------------------------
getCardsTest :: Test
getCardsTest = "Test if pulling correct cards from board" ~:
  TestList [getCards board (Just (1,2,3)) ~?= Just (Card Oval Shaded Two Green, 
                      Card Oval Outline Two Green,
                      Card Oval Shaded Three Red),
        getCards board (Just (5,10,1)) ~?= Just (Card Triangle Solid Three Green, 
                      Card Triangle Outline One Purple,
                      Card Oval Shaded Two Green),
        getCards board (Just (4,7,3)) ~?= Just (Card Squiggle Solid One Green, 
                      Card Squiggle Solid Two Purple,
                      Card Oval Shaded Three Red)
        ] where
        board = [Card Oval Shaded Two Green, Card Oval Outline Two Green,
            Card Oval Shaded Three Red, Card Squiggle Solid One Green,
            Card Triangle Solid Three Green, Card Triangle Shaded Three Purple,
            Card Squiggle Solid Two Purple, Card Squiggle Shaded Three Green,
            Card Triangle Outline One Red, Card Triangle Outline One Purple,
            Card Squiggle Outline Two Green, Card Oval Solid Three Green]

removePuncTest :: Test
removePuncTest = "Test for turning set into parable string set" ~:
  TestList [removePunc s1 ~?= "Card Oval Shaded Three Red,Card Triangle Shaded Three Purple,Card Squiggle Solid One Purple",
        removePunc s2 ~?= "Card Squiggle Outline One Red,Card Triangle Outline One Purple,Card Oval Shaded Two Red",
        removePunc s3 ~?= "Card Triangle Outline Two Green,Card Oval Solid Three Purple,Card Triangle Shaded Two Purple",
        removePunc s4 ~?= "Card Squiggle Shaded Three Red,Card Squiggle Solid One Purple,Card Triangle Shaded Three Purple"
        ] where
      s1 = Just (Card Oval Shaded Three Red,Card Triangle Shaded Three Purple,Card Squiggle Solid One Purple)
      s2 = Just (Card Squiggle Outline One Red,Card Triangle Outline One Purple,Card Oval Shaded Two Red)
      s3 = Just (Card Triangle Outline Two Green,Card Oval Solid Three Purple,Card Triangle Shaded Two Purple)
      s4 = Just (Card Squiggle Shaded Three Red,Card Squiggle Solid One Purple,Card Triangle Shaded Three Purple)

boardContainsSetTest :: Test
boardContainsSetTest = "Test if a set is in the board" ~:
  TestList [boardContainsSet setInBoard board ~?= True,
        boardContainsSet setNotInBoard board ~?= False,
        boardContainsSet invalidSetInBoard board ~?= True,
        boardContainsSet invalidSetNotInBoard board ~?= False
        ] where
        setInBoard = (Card Oval Shaded Three Red,Card Triangle Shaded Three Purple,Card Squiggle Shaded Three Green)
        setNotInBoard = (Card Oval Outline Two Green,Card Oval Shaded One Green,Card Oval Solid Three Green)
        invalidSetInBoard = (Card Oval Shaded Two Green, Card Oval Outline Two Green,Card Oval Shaded Three Red)
        invalidSetNotInBoard = (Card Oval Shaded Two Green, Card Oval Outline One Green,Card Oval Shaded Three Red)
        board = [Card Oval Shaded Two Green, Card Oval Outline Two Green,
            Card Oval Shaded Three Red, Card Squiggle Solid One Green,
            Card Triangle Solid Three Green, Card Triangle Shaded Three Purple,
            Card Squiggle Solid Two Purple, Card Squiggle Shaded Three Green,
            Card Triangle Outline One Red, Card Triangle Outline One Purple,
            Card Squiggle Outline Two Green, Card Oval Solid Three Green]

validSetTest :: Test
validSetTest = "Test if a set is valid" ~:
  TestList [validSet vSet ~?= True,
        validSet inSet ~?= False
        ] where
          vSet = (Card Oval Shaded Three Red,Card Triangle Shaded Three Purple,Card Squiggle Shaded Three Green)
          inSet = (Card Oval Shaded Two Green, Card Oval Outline Two Green,Card Oval Shaded Three Red)

playableSetTest :: Test
playableSetTest = "Test if a set playable" ~:
  TestList [playableSet setInBoard board ~?= True,
        playableSet setNotInBoard board ~?= False,
        playableSet invalidSetInBoard board ~?= False,
        playableSet invalidSetNotInBoard board ~?= False
        ] where
        setInBoard = Just (Card Oval Shaded Three Red,Card Triangle Shaded Three Purple,Card Squiggle Shaded Three Green)
        setNotInBoard = Just (Card Oval Outline Two Green,Card Oval Shaded One Green,Card Oval Solid Three Green)
        invalidSetInBoard = Just (Card Oval Shaded Two Green, Card Oval Outline Two Green,Card Oval Shaded Three Red)
        invalidSetNotInBoard = Just (Card Oval Shaded Two Green, Card Oval Outline One Green,Card Oval Shaded Three Red)
        board = [Card Oval Shaded Two Green, Card Oval Outline Two Green,
            Card Oval Shaded Three Red, Card Squiggle Solid One Green,
            Card Triangle Solid Three Green, Card Triangle Shaded Three Purple,
            Card Squiggle Solid Two Purple, Card Squiggle Shaded Three Green,
            Card Triangle Outline One Red, Card Triangle Outline One Purple,
            Card Squiggle Outline Two Green, Card Oval Solid Three Green]

playableBoardTest :: Test
playableBoardTest = "Test if a board playable" ~:
  TestList [playableBoard boardValid ~?= True,
        playableBoard boardInvalid ~?= False
        ] where
        boardValid = [Card Oval Shaded Two Green, Card Oval Outline Two Green,
            Card Oval Shaded Three Red, Card Squiggle Solid One Green,
            Card Triangle Solid Three Green, Card Triangle Shaded Three Purple,
            Card Squiggle Solid Two Purple, Card Squiggle Shaded Three Green,
            Card Triangle Outline One Red, Card Triangle Outline One Purple,
            Card Squiggle Outline Two Green, Card Oval Solid Three Green]
        boardInvalid = [Card Oval Outline Three Red,Card Oval Solid One Green,
            Card Oval Solid Two Purple,Card Triangle Solid One Purple,
            Card Oval Solid Two Green,Card Squiggle Shaded One Green,
            Card Triangle Outline Two Red,Card Squiggle Outline Three Purple,
            Card Triangle Outline Two Purple,Card Squiggle Outline Three Red,
            Card Oval Shaded Three Purple,Card Oval Solid One Purple]

------------------------ Quickcheck Cases -----------------------
instance Arbitrary Shape where
  arbitrary = elements [ Triangle
                       , Squiggle
                       , Oval
                       ]

instance Arbitrary Filling where
  arbitrary = elements [ Shaded
                       , Solid
                       , Outline
                       ]

instance Arbitrary Number where
  arbitrary = elements [ One
                       , Two
                       , Three
                       ]

instance Arbitrary Color where
  arbitrary = elements [ Green
                       , Red
                       , Purple
                       ]

instance Arbitrary Card where
  arbitrary = genCard

-- Generate a card
genCard :: Gen Card
genCard = Card <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary

-- Generate a set
genSet :: Gen Set
genSet = (,,) <$> arbitrary <*> arbitrary <*> arbitrary

-- Generate a list of cards of length n
genBoard :: Int -> Gen Board
genBoard 0 = return []
genBoard n = liftM2 (:) arbitrary otherCard
   where otherCard = genBoard (n - 1)

-- Generate a board that contains a set
genBoardPos :: Gen Board
genBoardPos = do 
  set <- genBoard 3 
  if (validSet (tuplify set)) 
    then do
      rest <- genBoard 9
      return (set ++ rest)
    else genBoardPos

-- Generate a board that does not contain a set
genBoardNeg :: Gen Board
genBoardNeg = do
  board <- genBoard 12
  createNeg board where 
    createNeg cards = do
    case retrieveValidSet cards of
      Just (x,y,z) -> do
        new <- genCard
        let c' = replaceCard x new cards
        createNeg c'
      Nothing -> return cards

prop_playableBoardTrue :: Property
prop_playableBoardTrue = forAll genBoardPos playableBoard

prop_playableBoardFalse :: Property
prop_playableBoardFalse = forAll genBoardNeg $ \xs ->
  not (playableBoard xs)

