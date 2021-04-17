;---------------------------------------------------------------; 
;	メモリに値をセット
;	HLreg: メモリ先頭アドレス
;	BCreg: セットするサイズ
;	Areg: セットする値
;---------------------------------------------------------------; 
clear_mem:
	xor	a

fill_mem:
	ld d,h
	ld e,l
	inc de

	dec bc

	ld (hl),a
	ldir

	ret

;---------------------------------------------------------------; 
	END
