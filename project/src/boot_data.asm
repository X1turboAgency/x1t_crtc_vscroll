;---------------------------------------------------------------; 
;	プログラムブートデータ
;	LOADM形式にするため、先頭に開始アドレスと、長さ(-1)を付与する。
;---------------------------------------------------------------; 

PROG_TOP	equ	06000h
PROG_LENG	equ PROG_END - PROG_TOP

	ORG PROG_TOP-4
	dw	PROG_TOP
	dw	PROG_END

	jp	START_MAIN

	END
