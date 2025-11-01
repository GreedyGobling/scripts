@echo off
:: Disable monitor sleep on both AC power and battery
powercfg -change monitor-timeout-ac 0
powercfg -change monitor-timeout-dc 0
