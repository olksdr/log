-- | Stdout logging back-end.
module Log.Backend.StandardOutput (
    simpleStdoutLogger
  , stdoutLogger
  , withSimpleStdOutLogger
  , withSimpleJsonLineStdOutLogger
  ) where

import Prelude
import qualified Data.Text.IO as T
import System.IO

import Log.Data
import Log.Internal.Logger
import Log.Logger

-- | Create a 'simpleStdoutlogger' for the duration of the given
-- action, making sure that stdout is flushed afterwards.
withSimpleStdOutLogger :: (Logger -> IO r) -> IO r
withSimpleStdOutLogger act = do
  logger <- stdoutLogger
  withLogger logger act

-- | Create a simple jsonline logger for the duration of the given
-- action, making sure that stdout is flushed afterwards.
withSimpleJsonLineStdOutLogger :: (Logger -> IO r) -> IO r
withSimpleJsonLineStdOutLogger act = do
  logger <- mkLogger "jsonlines-stdout" $
                      (\msg -> (T.putStrLn . showJsonLineLogMessage Nothing $ msg)
                                >> hFlush stdout)
  withLogger logger act

{-# DEPRECATED simpleStdoutLogger "Use 'withSimpleStdOutLogger'" #-}

-- | Simple, synchronous logger that prints messages to standard
-- output. Flushes 'stdout' on each call to 'loggerWriteMessage'. Use
-- 'Log.Backend.StandardOutput.Bulk.withBulkStdOutLogger' if you want
-- buffering.
simpleStdoutLogger :: Logger
simpleStdoutLogger = Logger {
    loggerWriteMessage = \msg -> (T.putStrLn . showLogMessage Nothing $ msg)
                                 >> hFlush stdout
  , loggerWaitForWrite = hFlush stdout
  , loggerShutdown     = return ()
  }

{-# DEPRECATED stdoutLogger "Use 'withSimpleStdOutLogger'" #-}

-- | Create a logger that prints messages to standard output.
stdoutLogger :: IO Logger
stdoutLogger = mkLogger "stdout" $ T.putStrLn . showLogMessage Nothing
