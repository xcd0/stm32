# stm32を使ってみる

Blue Pillといわれる STM32F103C8T6 の乗った安いもりもりマイコンを使ってみる。
![](./img/STM32-D40-dim.png)
AとかBとかのピンがいっぱいあるのがわかる。
72MHz駆動の32Bitマイコン。

MCU | STM32F103 (ARM 32-bit Cortex-M3 CPU Core)
CLOCK | 72MHz (Max)
VOLTAGE | 2.0～3.6V
| DIPで使うPin | 40pin(3.3v,GNDx2,R) |
|Flash |64KBytes|
|SRAM |20KByte|
厳密にはマイコンじゃなくてMPUらしい(よくしらない)。つまりつよい。

2年前の資料だが、  
KbD Pre APRIL 2018 - 春から始める ARM で自作キーボード https://booth.pm/ja/items/840614  
を参考にちまちまやってみる。

## 環境

win10 + msys2

## bootloaderを入れる

1. https://github.com/rogerclarkmelbourne/STM32duino-bootloader  
をcloneする。サブモジュールにした。  

1. STM32duino-bootloader/bootloader_only_binaries/generic_boot20_pc13.bin  
を書き込む。  

STM32F103C8T6の乗ったDIP化モジュールは750円(税別)だった。  
http://www.aitendo.com/product/13348  
こういう販売サイトに置いてあるpdfとか画像は、  
サイトが見られなくなったりするとなんだかんだ探し回ったりしないといけなくなって困るので、  
ここに置いておく。 [データシートのPDF ./datasheet/STM32F103C8T6.pdf](./datasheet/STM32F103C8T6.pdf)


stlinkはaitendoから買った。  
http://www.aitendo.com/product/16082  

ご丁寧に本体にpin配置がプリントしてある。  
http://www.aitendo.com/product/15275  
のPSをついでに買っていたのでこれを4本割いて適当に指す。  
SWCLK, SWDIO, GND, 3.3Vを使う。  

### ここでてこずった
stlinkのバイナリが置いてない。  
ビルドした。 windows10でやってる。

https://github.com/texane/stlink/blob/master/doc/compiling.md
より

	Installation
	Install 7Zip from http://www.7-zip.org
	Install CMake from https://cmake.org/download
	Install MinGW64 from https://sourceforge.net/projects/mingw-w64 (mingw-w64-install.exe)
	Git clone or download stlink sourcefiles zip

だそうだ。MinGW64のインストールがなっがい。  
インストールが終わったらダウンロードしておいたreleaseのv1.6.0のなかの  
`stlink-1.6.0\scripts\mingw64-build.bat` を実行する。  
これでなんか_installと言うディレクトリができたのでこれを覗いてみると、`Program Files (x86)`というフォルダがあった。  
おそらくこれを`C:\Program Files (x86)`とかに置くといいのだろうと思われるのでこれをコピーした。  
とりあえずビルド云々が面倒だったのでこの_installというディレクトリをそのままzipにしておいた。  
使えるかは知らないけども使えるなら使ってよい。多分ほかにいるdllとかあるとおもう。  
これで`C:\Program Files (x86)\stlink\bin`にそれっぽいバイナリが3つ入った。  

* st-util.exe
* st-flash.exe
* st-info.exe

これでようやくbootloaderを書き込めそう。  

$ st-flash write generic_boot20_pc13.bin 0x8000000

的な感じらしい。

	$ ./binary/stlink/bin/st-flash.exe write generic_boot20_pc13.bin 0x8000000
	st-flash 1.6.0
	2020-03-06T07:06:35 WARN usb.c: Couldn't find any ST-Link/V2 devices

ダメだった。\_(┐「ε:)\_

https://github.com/texane/stlink/issues/651 にそれっぽのがあるUSB3.0はなんかあるらしい。
ドライバーのアップデートで解決したとある。

デバイスマネージャーで見ると確かに何か出ている。
[](./img/stlink_1.png)
ここでアップデートを検索しても出なかったのであきらめて本家に行く。
https://www.st.com/content/st_com/ja/products/development-tools/software-development-tools/stm32-software-development-tools/stm32-utilities/stsw-link009.html
なんか登録させられる。  
入れてみた後再度実行。

	$ ./binary/stlink/bin/st-flash.exe write generic_boot20_pc13.bin 0x8000000
	st-flash 1.6.0
	2020-03-06T07:17:57 INFO usb.c: -- exit_dfu_mode
	2020-03-06T07:17:57 INFO common.c: Loading device parameters....
	2020-03-06T07:17:57 WARN common.c: unknown chip id! 0x5fa0004

これでもだめだった。\_(┐「ε:)\_

https://github.com/texane/stlink/issues/715

	I just had the same thing with a blue pill
	- my cheap stlink clone appears to have the markings for SWDIO and SWCLK swapped.
	After swapping the lines over it flashed fine.

まじか。ってことで入れ替えてみた。  
SWDIOとSWCLKを入れ替えて実行。 

	$ ./binary/stlink/bin/st-flash.exe write generic_boot20_pc13.bin 0x8000000
	st-flash 1.6.0
	2020-03-06T07:26:12 INFO common.c: Loading device parameters....
	2020-03-06T07:26:12 INFO common.c: Device connected is: F1 Medium-density device, id 0x20036410
	2020-03-06T07:26:12 INFO common.c: SRAM size: 0x5000 bytes (20 KiB), Flash: 0x10000 bytes (64 KiB) in pages of 1024 bytes
	open(generic_boot20_pc13.bin) == -1
	2020-03-06T07:26:12 ERROR common.c: map_file() == -1
	stlink_fwrite_flash() == -1

これは...aitendoのstlinkもミスってるということ...  
でもまだ駄目っぽい。

	$ ./binary/stlink/bin/st-flash.exe erase
	st-flash 1.6.0
	2020-03-06T07:32:59 INFO common.c: Loading device parameters....
	2020-03-06T07:32:59 INFO common.c: Device connected is: F1 Medium-density device, id 0x20036410
	2020-03-06T07:32:59 INFO common.c: SRAM size: 0x5000 bytes (20 KiB), Flash: 0x10000 bytes (64 KiB) in pages of 1024 bytes
	Mass erasing

STのST-LINK Utilityというのがあるので使ってみる

	07:42:05 : Flash memory erased.
	07:42:19 : Memory programmed in 1s and 547ms.
	07:42:19 : Verification...OK
	07:42:19 : Programmed memory Checksum: 0x001790A8
	07:42:22 : Disconnected from device.
	07:42:22 : Connection to device is lost: check power supply and debug connection.
	07:42:22 : If the target is in low power mode, please enable "Debug in Low Power mode" option from Target->settings menu.

できたっぽい。もしかすると電源電圧か何かが良くないのかもしれない。

## QMKを入れる

KbD Pre APRIL 2018 - 春から始める ARM で自作キーボード https://booth.pm/ja/items/840614  
をそのままなぞる。

	$ git submodule add https://github.com/qmk/qmk_firmware
	$ cd qmk_fimware
	$ git submodule sync --recursive
	$ git submodule update --init --recursive
	$ make chibios_test/stm32_f103_onekey:default
	QMK Firmware 0.8.13
	make: *** No rule to make target 'chibios_test/stm32_f103_onekey:default'. Stop.
	|
	|  QMK's make format recently changed to use folder locations and colons:
	|     make project_folder:keymap[:target]
	|  Examples:
	|     make planck/rev4:default:dfu
	|     make planck:default
	|

あれっもしや...  
https://github.com/qmk/qmk_firmware/tree/master/keyboards/chibios_test/  
404だと...\_(┐「ε:)\_  
２年前はもうだめな模

## リンク
https://ht-deko.com/arduino/stm32f103c8t6.html
https://qiita.com/nanbuwks/items/ba37f049f45378da0e2b#stm32f103c8とは
