@echo off

SET WDIR=%~dp0
cd %WDIR%

SET MCMD=bin\make2d.exe

call %WDIR%\make.bat

cd %WDIR%

SET SRC=x1t_crtcv.bin
SET DST=x1t_crtcv.2d
SET BOOTNAME=X1tCRTCV

echo データバイナリ: %SRC%
echo 出力2Dファイル: %DST%

%MCMD% %DST% %SRC% -n %BOOTNAME%

SET DCMD=bin\x12d_d88.exe
SET D88FILE_2D=x1t_crtcv_2d.d88
SET D88NAME2D=X1tCRTCV_2D

%DCMD% %DST% %D88FILE_2D% -tr 1

SET D88FILE_2HD=x1t_crtcv_2hd.d88
SET D88NAME2HD=X1tCRTCV_2HD

%DCMD% %DST% %D88FILE_2HD% -tr 1 -2hd

pause

