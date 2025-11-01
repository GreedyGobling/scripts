@echo off
:: Set monitor sleep timeout to 5 minutes (both AC and battery)
powercfg -change monitor-timeout-ac 1
powercfg -change monitor-timeout-dc 1
