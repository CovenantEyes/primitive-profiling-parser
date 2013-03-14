import System.Environment (getArgs)
import Data.Functor ((<$>))
import Data.List (partition, foldl')
import Data.Text (Text)
import qualified Data.Text as T (lines, span, strip, unpack)
import qualified Data.Text.IO as Tio (readFile)

delim = '\t'

-- An Entry describes the average and count of all input lines identified by `entryName`
data Entry = Entry { entryName  :: Text
                   , entrySum   :: Double
                   , entryCount :: Int}

main :: IO ()
main = do
    (fileName:_) <- getArgs
    xs <- map lineToPair . T.lines <$> Tio.readFile fileName
    putStrLn $ columnizeFields "ID" "AVERAGE" "COUNT" "SUM"
    mapM_ (putStrLn . entryToString) (entries xs)
    where
        entries xs = map pairToEntry (combine xs)

-- Takes four strings and places them in columns of varying widths for display purposes.
columnizeFields :: String -> String -> String -> String -> String
columnizeFields f1 f2 f3 f4 = column 50 f1 ++ column 25 f2 ++ column 15 f3 ++ f4
    where column width str = str ++ replicate (width - length str) ' '

-- Renders a single entry to a string for display purposes.
entryToString :: Entry -> String
entryToString (Entry name_ sum_ count_) =
    columnizeFields (T.unpack name_)
                    (show $ average sum_ count_)
                    ('x' : show count_)
                    ('=' : show sum_)
    where average s c = realToFrac sum_ / fromIntegral count_

-- Takes a key-value pair and transforms it into an entry. The key is the entry's name and the
-- value is a list of times that all correspond to that entry.
pairToEntry :: (Text, [Double]) -> Entry
pairToEntry (key, vs) = Entry key sum_ count_ where (sum_, count_) = sumAndCount vs

-- Parses a line from the input file and returns the two columns as a tuple.
lineToPair :: Text -> (Text, Double)
lineToPair str = (T.strip key, double)
    where (key, value) = T.span (/= delim) str
          double = read (T.unpack (T.strip value))

-- Takes a list of key-value pairs and, for each unique key in the list, aggregates all its values.
combine :: (Eq k) => [(k,v)] -> [(k,[v])]
combine [] = []
combine ((k,v):xs) = (k, v:values) : (combine nonmatching)
    where
        (matching, nonmatching) = partition ((k==) . fst) xs
        values = map snd matching

-- Calculates the sum and size of a list of numbers. This code could be much simpler, but this
-- method was chosen after the simpler way was too slow and memory-intensive on large input files.
sumAndCount :: (Real a, Integral c) => [a] -> (a, c)
sumAndCount xs = foldl' step (0, 0) xs where step (s, c) n = (s+n, c+1)
