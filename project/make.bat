@echo off

SET WDIR=%~dp0
SET CMD=%WDIR%\bin\z80as\z80as.exe

SET SRCDIR=%WDIR%\src

cd %SRCDIR%

SET SRC= ^
 value_define.asm^
 main.asm^
 render\render_util.asm^
 input\input.asm^
 video\crtc.asm^
 util\mem_util.asm

SET SRC=boot_data.asm %SRC% prog_end.asm
SET DST=%WDIR%\x1t_crtcv.bin

echo ÉAÉZÉìÉuÉã %SRC% Å® %DST%

%CMD% -o %DST% %SRC% -x

pause

