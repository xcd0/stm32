# stm32を使ってみる

Blue Pillといわれる STM32F103C8T6 の乗った安いもりもりマイコンを使ってみる。  

![](./img/STM32-D40-dim.png)

AとかBとかのピンがいっぱいあるのがわかる。  
72MHz駆動の32Bitマイコン。  
厳密にはマイコンじゃなくてMPUらしい(よくしらない)。つまりつよい?。  

| パーツ       | 詳細                                      |
| ---          | ---                                       |
| MCU          | STM32F103 (ARM 32-bit Cortex-M3 CPU Core) |
| CLOCK        | 72MHz (Max)                               |
| VOLTAGE      | 2.0～3.6V                                 |
| DIPで使うPin | 40pin(3.3v,GNDx2,R)                       |
| Flash        | 64KBytes                                  |
| SRAM         | 20KByte                                   |


2年前の資料だが、[KbD Pre APRIL 2018 - 春から始める ARM で自作キーボード](https://booth.pm/ja/items/840614) を参考にちまちまやってみる。

## 環境

win10 + msys2

## 購入したもの

| 物         | 説明         | 値段(税別) | 正式名称                         | URL                                  |
| ---        | ---          | ---        | ---                              | ---                                  |
| BluePill   | 使うマイコン | 750円      | DIP化STM32モジュール [STM32-D40] | http://www.aitendo.com/product/13348 |
| ST-LINK V2 | ライター     | 500円      | STM8/STM32ライタ [STLINKV2]      | http://www.aitendo.com/product/16082 |
|導線|つなぐケーブル|ピンヘッダ用接続ケーブル PS|http://www.aitendo.com/product/15275 |
|||||

## やったこと

1. bootloaderを入れる。



### bootloaderの導入

[長くなったので./bootloader/readme.mdに書いた。](./bootloader/readme.md)  

windows用の必要なファイルはbootloaderディレクトリに全部置いている。  
このリポジトリをクローンしているなら、とりあえずこれで書き込める。

	cd bootloader
	./st-flash.exe write generic_boot20_pc13.bin 0x8000000

 BluePillがそこそこ早く(0.2秒間隔くらい？)ちかちかする。
詳しくは./bootloader/readme.mdを参照。



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
