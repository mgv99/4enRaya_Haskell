import System.Random

data Col = Col [Int] deriving(Show)

data Board = Board [Col] deriving(Show)

createBoard :: Int -> Int -> Board
createBoard n m = Board (take m $ repeat $ Col (take n $ repeat 0))

--00000000000000000000000000000000000000000000000000000000000000000000000
--0000000000000000000000  PRINT THE BOARD  000000000000000000000000000000
--00000000000000000000000000000000000000000000000000000000000000000000000

printIndex :: Int -> Int -> IO ()
printIndex 0 m = do
  putStr $ show 0
  printIndex (1) m
printIndex i m = do
  if (i == m) then do
    putStrLn $ show i
  else do
    putStr " "
    printIndex (i+1) m

printRow :: Board -> Int -> String
printRow (Board []) _ = ""
printRow (Board ((Col c):cs)) n
  | ((c !! n) == 0) = "·" ++ (printRow (Board cs) n)
  | ((c !! n) == 1) = "o" ++ (printRow (Board cs) n)
  | ((c !! n) == 2) = "x" ++ (printRow (Board cs) n)

showBoardRec :: Board -> Int -> IO ()
showBoardRec (Board cs) (-1) = do
  printIndex 0 ((length cs)-1)
  return ()
showBoardRec b n = do
  putStrLn $ printRow b n
  showBoardRec b (n-1)

showBoard :: Board -> IO()
showBoard (Board ((Col c):cs)) = showBoardRec (Board ((Col c):cs)) ((length c)-1)


--000000000000000000000000000000000000000000000000000000000000000000000000
--0000000000000000000000  UPDATE THE BOARD  000000000000000000000000000000
--000000000000000000000000000000000000000000000000000000000000000000000000

updateCol :: [Int] -> Int -> Int -> Int -> [Int]
updateCol c (-1) _ _ = c ++ [-1]
updateCol (x:xs) i n p
  | (x == 0) = (p:xs) ++ [n-i]
  | otherwise = (x:(updateCol xs (i-1) n p))

findCol :: [Col] -> Int -> Int -> [Col]
findCol ((Col c):cs) i p
  | (i == 0)  = ((Col u):cs)
  | otherwise = (Col c):(findCol cs (i-1) p)
  where
    n = (length c)-1
    u = updateCol c n n p

             --Board -> Col -> Jug -> Result
updateBoard :: Board -> Int -> Int -> (Board, Int)
updateBoard (Board cs) i p
  | (i > ((length cs)-1)) = (Board cs, -1)
  | (i < 0)               = (Board cs, -1)
  | otherwise             = (Board (new_cs), index)
  where
    res = findCol cs i p
    index = lastInCol (res !! i)
    new_cs = removeIndex res i

lastInCol :: Col -> Int
lastInCol (Col c) = last c

removeLast :: [a] -> [a]
removeLast (x:[]) = []
removeLast (x:xs) = (x:(removeLast xs))

removeIndex :: [Col] -> Int -> [Col]
removeIndex ((Col c):cs) i
  | (i == 0) = ((Col r):cs)
  | otherwise = ((Col c):(removeIndex cs (i-1)))
  where
    r = removeLast c
--00000000000000000000000000000000000000000000000000000000000000000000000
--0000000000000000000000  INITIALIZE GAME  000000000000000000000000000000
--00000000000000000000000000000000000000000000000000000000000000000000000

initBoard :: IO Board
initBoard = do
  putStrLn "Please introduce the number of rows of the board (min. 4)"
  rows <- getLine
  let n = read rows :: Int
  if (n < 4) then do
    putStrLn "\nERROR: You must introduce minimum 4 rows\n"
    initBoard
  else do
    putStrLn "Please introduce the number of columns of the board (min. 4)"
    cols <- getLine
    let m = read cols :: Int
    if (m < 4) then do
      putStrLn "\nERROR: You must introduce minimum 4 columns\n"
      initBoard
    else
      return (createBoard n m)

--00000000000000000000000000000000000000000000000000000000000000000000000
--000000000000000000000000000000  PLAY  000000000000000000000000000000000
--00000000000000000000000000000000000000000000000000000000000000000000000

checkWin :: Board -> Int -> Int -> Int
checkWin b c i = -1

play :: Board -> Int -> IO Int--winner
play b player = do
  putStrLn "Select a column"
  col <- getLine
  let c = read col :: Int
  let (new_b, i) = updateBoard b c player
  showBoard new_b
  putStrLn $ "Index : "++(show i)
  let w = checkWin new_b c i
  if (w /= -1) then
    return w
  else
    play new_b ((mod player 2)+1)

--00000000000000000000000000000000000000000000000000000000000000000000000
--00000000000000000000000000000  MAIN  0000000000000000000000000000000000
--00000000000000000000000000000000000000000000000000000000000000000000000

main :: IO ()
main = do
  putStrLn "Welcome to the Connect4 game"
  b <- initBoard
  showBoard b
  winner <- play b 1
  case winner of
    0 -> putStrLn "Draw"
    1 -> putStrLn "You win!"
    2 -> putStrLn "CPU wins!"
    otherwise -> putStrLn "Error. Something were wrong"
  return ()