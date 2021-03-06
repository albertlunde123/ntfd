module Spec.Clients.OpenWeatherMap where

import Control.Concurrent.Async (mapConcurrently)
import Data.Either (isRight)
import Test.Hspec

import Spec.Helpers (defaultWeatherCfg)
import Clients.OpenWeatherMap (fetchOwm, toWeatherIcon, QueryType(..))

spec :: IO ()
spec = hspec $ describe "OpenWeatherMap client" $ do
    it "should fetch data from OpenWeatherMap" $ do
        config              <- defaultWeatherCfg
        [current, forecast] <- mapConcurrently (fetchOwm config) [Current, Forecast]
        current `shouldSatisfy` isRight
        forecast `shouldSatisfy` isRight

    it "should print weather icons (needs patched font to display properly)" $ do
        putStrLn $ "Clear sky - day: " ++ [toWeatherIcon "01d"]
        putStrLn $ "Clear sky - night: " ++ [toWeatherIcon "01n"]
        putStrLn $ "Few clouds (11-25%) - day: " ++ [toWeatherIcon "02d"]
        putStrLn $ "Few clouds (11-25%) - night: " ++ [toWeatherIcon "02n"]
        putStrLn $ "Scattered clouds (25-50%) - day/night: " ++ [toWeatherIcon "03d"]
        putStrLn $ "Scattered clouds (25-50%) - day/night: " ++ [toWeatherIcon "03n"]
        putStrLn
            $  "Broken / Overcast clouds (51-84% / 85-100%) - day/night: "
            ++ [toWeatherIcon "04d"]
        putStrLn
            $  "Broken / Overcast clouds (51-84% / 85-100%) - day/night: "
            ++ [toWeatherIcon "04n"]
        putStrLn $ "Shower rain - day/night: " ++ [toWeatherIcon "09d"]
        putStrLn $ "Shower rain - day/night: " ++ [toWeatherIcon "09n"]
        putStrLn $ "Moderate / heavy rain - day: " ++ [toWeatherIcon "10d"]
        putStrLn $ "Moderate / heavy rain - night: " ++ [toWeatherIcon "10n"]
        putStrLn $ "Thunderstorm - day: " ++ [toWeatherIcon "11d"]
        putStrLn $ "Thunderstorm - night: " ++ [toWeatherIcon "11n"]
        putStrLn $ "Snow - day: " ++ [toWeatherIcon "13d"]
        putStrLn $ "Snow - night: " ++ [toWeatherIcon "13n"]
        putStrLn $ "Fog - day: " ++ [toWeatherIcon "50d"]
        putStrLn $ "Fog - night: " ++ [toWeatherIcon "50n"]
        putStrLn $ "Missing icon: " ++ [toWeatherIcon "lolwtf"]
        return ()
