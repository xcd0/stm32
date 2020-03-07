# bootloaderを入れる

ST-LINK V2 を使って書き込んだ。

## bootloaderの導入 まとめ

windows用の必要なファイルはbootloaderディレクトリに全部置いている。

windowsでmsysを使っているならこのディレクトリに入って、

	$ ./st-flash.exe write generic_boot20_pc13.bin 0x8000000

でよい。

汎用的に書くと、以下のようになる。

1. st-flashをゲットする。(ビルドがいるかも)
1. st-flashにPATHを通す。
1. generic_boot20_pc13.binをゲットする。(拾ってくる)
1. generic_boot20_pc13.binをカレントディレクトリに置く。
1. `st-flash.exe write generic_boot20_pc13.bin 0x8000000` で書き込む。
1. BluePillがそこそこ早くちかちかする。(0.2秒間隔くらい？)

これでよいはず。

以下はこれに至るまでの経緯。

## bootloaderを入れる

ST-LINK V2 を使って書き込んだ。

1. https://github.com/rogerclarkmelbourne/STM32duino-bootloader  
をcloneする。サブモジュールにした。  

1. STM32duino-bootloader/bootloader_only_binaries/generic_boot20_pc13.bin  
を書き込む。  

[STM32F103C8T6の乗ったDIP化モジュール](http://www.aitendo.com/product/13348)は750円(税別)だった。  
こういう販売サイトに置いてあるpdfとか画像は、
サイトが見られなくなったりするとなんだかんだ探し回ったりしないといけなくなって困るので、
ここに置いておく。 [データシートのPDF ./datasheet/STM32F103C8T6.pdf](./datasheet/STM32F103C8T6.pdf)

[ST-LINK V2](http://www.aitendo.com/product/16082) はaitendoから買った。  
ご丁寧に本体にpin配置がプリントしてある。(このピン配置は間違っている)  

このaitendoのST-LINKは互換品で、正規品ではない安物である。  
そして重要なのが本体に印字されているピンアサインが実際とは異なるということである...  
詳しくは下の折り畳みを参照。  

私の購入したST-LINKに印字されていた内容はこのような感じであった。  

| ピン番号 | アサイン | ピン番号 | アサイン |
| ---      | ---      | ---      | ---      |
| 1        | RST      | 2        | SWCLK    |
| 3        | SWIM     | 4        | SWDIO    |
| 5        | GND      | 6        | GND      |
| 7        | 3.3V     | 8        | 3.3V     |
| 9        | 5.0V     | 10       | 5.0V     |

正しくはこうであった。

| ピン番号 | アサイン | ピン番号 | アサイン  |
| ---      | ---      | ---      | ---       |
| 1        | RST      | 2        | * SWDIO * |
| 3        | SWIM     | 4        | * SWCLK * |
| 5        | GND      | 6        | GND       |
| 7        | 3.3V     | 8        | 3.3V      |
| 9        | 5.0V     | 10       | 5.0V      |

ピンヘッダ用接続ケーブルのPSをついでに買っていたので  
これを4本割いて適当に指す。  
SWCLK, SWDIO, GND, 3.3Vを使う。  
http://www.aitendo.com/product/15275  

### bootloaderの導入でてこずった

<details>
<summary>奮闘</summary>

stlinkで書き込むバイナリが置いていない。  
ビルドした。 windows10+MSYS2でやっている。

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
ネットの情報によると、書き込みコマンドは

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

	open(generic_boot20_pc13.bin) == -1

とあるのでコマンドのgeneric_boot20_pc13.binが開けていないようだ。
確かにカレントには置いてない()
bootloaderというディレクトリを掘ってそこにgeneric_boot20_pc13.binをコピーした。

	$ cd bootloader
	$ ../binary/stlink/bin/st-flash.exe write generic_boot20_pc13.bin 0x8000000
	st-flash 1.6.0
	2020-03-07T21:37:25 INFO common.c: Loading device parameters....
	2020-03-07T21:37:25 INFO common.c: Device connected is: F1 Medium-density device, id 0x20036410
	2020-03-07T21:37:25 INFO common.c: SRAM size: 0x5000 bytes (20 KiB), Flash: 0x10000 bytes (64 KiB) in pages of 1024 bytes
	2020-03-07T21:37:25 INFO common.c: Attempting to write 7172 (0x1c04) bytes to stm32 address: 134217728 (0x8000000) Flash page at addr: 0x08001c00 erased
	2020-03-07T21:37:25 INFO common.c: Finished erasing 8 pages of 1024 (0x400) bytes
	2020-03-07T21:37:25 INFO common.c: Starting Flash write for VL/F0/F3/F1_XL core id
	2020-03-07T21:37:25 INFO flash_loader.c: Successfully loaded flash loader in sram 8/8 pages written
	2020-03-07T21:37:25 INFO common.c: Starting verification of write complete
	2020-03-07T21:37:25 INFO common.c: Flash written and verified! jolly good!

お？これは行けた風な..
確かにBluePillのLEDがぴこぴこしている。

これでSTLINK経由でのbootloaderの書き込みは成功したものとみてよいだろう。 

</details>


