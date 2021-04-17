;//---------------------------------------------------------------;
;//	VRAMを指定の値で埋める。
;//		BCreg: VRAM アドレス
;//		HLreg: 長さ
;//		Dreg: 埋める値
;//---------------------------------------------------------------;
clear_graphic_vram_b:
	ld bc, B_VRAM_ADRS
	ld hl, 4000h
	ld d, 000h
	jr fill_vram

clear_graphic_vram_r:
	ld bc, R_VRAM_ADRS
	ld hl, 4000h
	ld d, 000h
	jr fill_vram

clear_graphic_vram_g:
	ld bc, G_VRAM_ADRS
	ld hl, 4000h
	ld d, 000h
	jr fill_vram

clear_text_vram:
	ld bc, TEXT_VRAM_ADRS
	ld hl, 0800h
	ld d, 00h
	jr fill_vram

clear_kanji_vram:
	ld bc, KANJI_VRAM_ADRS
	ld hl, 0800h
	ld d, 00h
	jr fill_vram

fill_attr_vram:
; Areg: 書込みデータ
	; テキストアトリビュートを書込む。
	ld bc, ATTR_VRAM_ADRS
	ld hl, 0800h
	jr fill_vram

fill_attr_vram_line:
	; 全部PCGアトリビュートにする。
	ld bc, ATTR_VRAM_ADRS
	ld hl, 0028h
	ld d, 02fh
	call	fill_vram

	ld bc, ATTR_VRAM_ADRS+0400h
	ld hl, 0028h
	ld d, 02fh
	call	fill_vram

	ret

; デバッグ表示領域初期化
fill_text_attr_vram_ascii:
	; attr
	ld	bc, ATTR_VRAM_ADRS+40*23
	ld	hl, 20
	ld	d,07h
	call	fill_vram

	ld	bc, ATTR_VRAM_ADRS+0400h+40*23
	ld	hl, 20
	ld	d,07h
	call	fill_vram

	; text (23行目を空白で埋める)
	ld	bc, TEXT_VRAM_ADRS+40*23
	ld	hl, 20
	ld	d,020h
	call	fill_vram

	ld	bc, TEXT_VRAM_ADRS+0400h+40*23
	ld	hl, 20
	ld	d,020h
	call	fill_vram

	ret

; VRAM書込み
; BCreg: 書込み先アドレス
; HLreg: 書込みサイズ
; Dreg: 書き込む内容
fill_vram:
fv_1:
	out (c),d
	inc bc

	dec hl
	ld a,h
	or l
	jr	nz, fv_1

	ret

; サンプル文字列を表示領域に書き込む。
write_sample_ascii:
	ld		bc, TEXT_VRAM_ADRS
	call	write_ascii_sub
	ld		bc, TEXT_VRAM_ADRS + 0400h

write_ascii_sub:
	ld		hl, 40*25
	ld		d,040h
	ld		e, 01h

	ld		ixh,40
wsa_2:
	out		(c),d
	inc		d

	ld		a,d
	cp		07fh
	jr		c,wsa_1
;
	ld		d,040h
wsa_1:
	res		4,b
	out		(c),e
	set		4,b

	dec		ixh
	jr		nz,wsa_3
;
	ld		ixh,40
	inc		e
	ld		a,e
	cp		08h
	jr		c,wsa_3
;
	ld		e,01h
wsa_3:

	inc		bc
	dec		hl
	ld		a,h
	or		l
	jr		nz,wsa_2
;
	ret

;//---------------------------------------------------------------; 
;// Text(PCG)の上にGRAMを表示する。
;// 0(黒)は下げておかないとTextが見えない。
;// 黒を使うにはどれかの色が犠牲になる。(=GRAM 7色しか見えない)
;//---------------------------------------------------------------; 
vram_priority:
	ld		bc, 01300h
	ld		a, 0feh		; 0以外はGRAMが優先。
	out		(c),a

	ret

vram_priority_full:
	ld		bc, 01300h
	ld		a, 0ffh		; 0以外はGRAMが優先。
	out		(c),a

	ret

init_vram_palette:
	ld bc, 1000h

	ld a, GAME_PALET_B
	ld hl, ( GAME_PALET_R << 8 ) | GAME_PALET_G

	out (c),a
	inc b
	out (c),h
	inc b
	out (c),l

	ret

;---------------------------------------------------------------; 
;		処理棒
;---------------------------------------------------------------; 
; 青色
task_bar:
	push	bc
	push	hl

	ld		bc,01000h
	ld		hl, ( GAME_PALET_B << 8 ) | GAME_PALET_B | 0x01

tbr_1:
	out		(c),l
	ld		l,8
tb_1:
	dec		l
	jr		nz,tb_1
	out		(c),h

	pop		hl
	pop		bc

	ret

; 赤色
task_bar_red:
	push	bc
	push	hl

	ld		bc,01100h
	ld		hl, ( GAME_PALET_R << 8 ) | GAME_PALET_R | 0x01
	jr		tbr_1

; 処理量で色が変わる処理バー。
; 0フレーム目: 青色
; 1フレーム目: 赤色
; 2フレーム目以降: 緑色
task_bar_vsync:
	ld	bc,01000h
	ld	a, (vsync_state)
	ld	hl, ( GAME_PALET_B << 8 ) | GAME_PALET_B | 0x01
	cp	01h+1
	jr	c, tv_1
;
	inc	b
	ld	hl, ( GAME_PALET_R << 8 ) | GAME_PALET_R | 0x01
	cp	03h+1
	jr	c, tv_1
;
	inc	b
	ld	hl, ( GAME_PALET_G << 8 ) | GAME_PALET_G | 0x01

tv_1:
	out		(c),l
	ld		l,8
tbv_1:
	dec		l
	jr		nz,tbv_1

	; 元に戻す。
	out		(c),h

	ret

; ----
	END
