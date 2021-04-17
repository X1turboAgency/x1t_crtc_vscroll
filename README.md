﻿# X1turbo CRTC 縦スクロールサンプル

## はじめに

X1turboで縦方向のスムーズなスクロールは可能だろうか？  
実現のきっかけは、スーパーターボさんがアップされていたYs2Opの動画でした。  
  
この中で、CRTCによる滑らかな縦スクロールを CRTCを制御する事で実現しています。  
この動画を参考に、CRTCによる縦スクロール制御をテストを作ってみたのが以下の動画です。

https://youtu.be/apw9Nl0azIc

このプロジェクトでは、CRTC制御によるスムーズな縦スクロールコードを公開しています。  


## セットアップ / 環境
想定環境: Windows8.1/10 (64bit)  

ビルドに必要な実行ファイルは内包していますが、z80アセンブラ本体は同梱していません。  
アセンブラは、紅茶羊羹さんの z80asmを想定しています。こちらは別途入手して下さい。  
入手した z80as.exe を、bin/z80as フォルダにコピーして下さい。  

## ビルド・実行方法
project/build.bat を実行すると、以下の２つのファイルを作成します。  

 - x1t_crtcv_2d.d88 (2D用)
 - x1t_crtcv_2hd.d88 (2HD用)

このファイルはエミュレータでは正常に実行することができないので、実機で実行してください。

## 動作環境
以下の機種で動作するのを確認しています。
 - X1turboZIII / X1turboII

 - 15KHzモードで表示可能なディスプレイ
   - 当方ではXPC4を使用して表示テストを行っています。
   - 15KHz対応の液晶ディスプレイやブラウン管で正常に  
   表示できるか試してみて頂けると助かります。

## CRTC 縦スクロールの仕組み
動作内容については以下のページで解説しています。

https://x1turbo-agency.hatenablog.jp/entry/2021/04/04/014943


## プロジェクト/ファイル説明

| フォルダ名         | サブフォルダ      | 説明                                            |
|-------------------|------------------|-------------------------------------------------|
| bin               |                  | ツール類                                         |
|                   | make2d.exe       | アセンブル済み.binファイルを .2d形式に変換します。  |
|                   | x12d_d88.exe     | 2dファイルをd88ファイルへ変換します。              |
| src               |                  |                                                 |
|                   | input/           | 入力処理                                         |
|                   | render/          | 描画処理ユーティリティ                            |
|                   | util/            | 各種ユーティリティ                                |
|                   | video/           | CRTC処理                                         |
|                   | main.asm         | メイン処理                                       |
|                   | boot_data.asm    | ブート処理                                       |
|                   | prog_end.asm     | プログラム終了位置判定                            |
|                   | value_define.asm | ラベル定義                                       |
| x1t_crtcv_2d.d88  |                  | FD実行イメージ (2D用)                            |
| x1t_crtcv_2hd.d88 |                  | FD実行イメージ (2HD)                             |

## 参考
スーパーターボさんが制作されていたYs2 Op動画  

 - https://youtu.be/ubsD9Cfz0PY

## 謝辞
このプログラムのアセンブルは、紅茶羊羹さんの z80asm の使用を想定しています。  
Z80プログラム制作にいつも活用させて頂いています。  

このサンプルは、すーぱーたーぼさんのスクロール動画を参考にして制作しています。  
いつもありがとうございます。  

## 免責事項
掲載されているソース、プログラム、手法などの情報については一切の保証が無いものとして  
ご利用ください。  
プロジェクトに含まれているソース,プログラムは説明文書等に記載のある通りに動作する事を  
期待して掲載していますが、性能の保証は致しません。  
これらのソース、プログラムを利用した事によるいかなる損害も作者は一切責任を負いません。  
ご使用の前に、バックアップ等のデータの保存対策や運用のテストを行ってください。  

## 更新履歴
2021/04/17 Ver 1.0 公開  
