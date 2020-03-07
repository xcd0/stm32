@echo off

SET COM_PORT=COM5

SET BAT_DIR=%~dp0
cd %~dp0

stm32flash.exe -f -v -w generic_boot20_pc13.bin %COM_PORT%