SET BAT_DIR=%~dp0
cd %~dp0

dfu-util -a 2 -D generic_boot20_pc13.bin

