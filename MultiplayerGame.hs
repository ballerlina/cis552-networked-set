module MultiplayerGame where

import Network
import System.IO
import Control.Concurrent
import Control.Monad
import Data.Maybe

import Logic
import qualified Parser as P


------------------- Definitions (Networking) -------------------

type ServerFlag = Bool
type Message = String
data InputSource =
    Stdin
  | Network
  deriving (Eq)


---------------------------------- THE GAME ---------------------------------------

createGame :: Handle -> Chan (InputSource, Message) -> ServerFlag -> IO ()
createGame handle chan isServer = withSocketsDo $ do
    putStrLn "Created a new game."
    board <- drawCards 12 genAll
    let deck = removeList genAll board
    when isServer (hPrint handle board >> displayBoard board)
    mainLoop handle chan isServer deck board

mainLoop :: Handle -> Chan (InputSource, Message) -> ServerFlag -> Deck -> Board -> IO ()
mainLoop handle chan isServer deck board = withSocketsDo $
    if not (playableBoard board) && null deck
      then do
        putStrLn "No sets left, the game has ended.\n"
        hPutStrLn handle "exit" -- Fix later?
      else do
        (src, input) <- readChan chan
        if input == "exit"
          then putStrLn "You or the other player quit.\n"
          else playTurn handle chan isServer deck board src input

playTurn :: Handle -> Chan (InputSource, Message) -> ServerFlag ->
            Deck -> Board -> InputSource -> Message -> IO ()
playTurn handle chan isServer deck board src input = withSocketsDo $
    if src == Stdin
    then do
      let ints = P.getParse parseInP input
      let playedSet = getCards board ints
      let stringSet = removePunc playedSet
      -- validates whether the user's input was a valid set, and if so sends a network msg
      if playableSet playedSet board
      --if playableSet (P.getParse parseCards input) board
        then do
          putStrLn "Nice! You got a set."
          hPutStrLn handle stringSet
          putStrLn ("Cards remaining in deck: " ++ (show $ length deck))
          if isServer
            then serverUpdateGameState stringSet
            else updateGameState board
        else do
          putStrLn "Not a valid set or set not in board!"
          updateGameState board
    else if src == Network then
      if isSet input -- Other player sent a valid set
        then do
          putStrLn "\nOther player found the set: "
          let set = P.getParse parseCards input
          case set of 
            Just (c1, c2, c3) -> do
              putStrLn (pshow c1)
              putStrLn (pshow c2)
              putStrLn (pshow c3)
            _                 -> putStrLn input
          putStrLn ("Cards remaining in deck: " ++ (show $ length deck))
          if isServer
            then serverUpdateGameState input
            else updateGameState board
        else do -- Server sent a new board to the client
          let mBoard = P.getParse parseBoard input
          if isJust mBoard
            then do
              let board' = fromJust mBoard
              displayBoard board'
              updateGameState board'
            else
              putStrLn "Received invalid board from server."
    else
      error "Unknown input source"
    where serverUpdateGameState input' = do
              (deck', board') <- updateBoardAndDeck
                                    (setToList $ fromJust $ P.getParse parseCards input')
                                     deck board
              hPrint handle board' -- ** sends the new board to client
              displayBoard board'
              mainLoop handle chan isServer deck' board'
          updateGameState = mainLoop handle chan isServer deck
