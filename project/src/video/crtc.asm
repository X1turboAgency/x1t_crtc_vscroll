;//---------------------------------------------------------------;
;//	CRTC設定
;//		in: HLreg:	CRTCデータ
;//---------------------------------------------------------------;
set_crtc40:
	ld		hl, crtc40_L

	call	set_crtc_sub
;
	; 40/80桁の切り替え
	ld		a,(hl)			; 40/80桁の切り替え
	inc		hl
	ld		bc,01a03h
	out		(c),a

	; 画面管理ポート: 低解像度/25ライン
	ld		a,(hl)
	ld		bc,01fd0h
	out		(c),a

	ret

;//---------------------------------------------------------------;
;;	CRTC R00～R13までを設定する。
;//---------------------------------------------------------------;
set_crtc_sub:
	ld		de,000eh
	ld		bc,CRTC_ADRS
sc_1:
	out		(c),d
	inc		c

	ld		a,(hl)
	inc		hl

	out		(c),a
	dec		c

	inc		d
	dec		e
	jr		nz,sc_1
;
	ret

;---------------------------------------------------------------;
;	CRTC R9をセット。
;---------------------------------------------------------------;
set_crtc_r9:
	ld		bc, CRTC_ADRS
	ld		d,09h
	out		(c),d
	inc		c
	out		(c),a
	ret

;---------------------------------------------------------------;
;	CRTC R5をセット。
;---------------------------------------------------------------;
set_crtc_r5:
	ld		bc, CRTC_ADRS
	ld		d,05h
	out		(c),d
	inc		c
	out		(c),a
	ret

;//---------------------------------------------------------------;
;//		CRTC設定データ 40桁/80桁
;//---------------------------------------------------------------;
crtc40_L:
	db	37h,28h,2dh,34h
	db  31 ;31	;R4 垂直総文字数 (-1)
	db  02h		;R5 総ラスタ調整
	db  25 ;25	;R6 垂直表示文字数
	db  28 ;28	;R7 垂直同期位置 (-1)
	db  00h		;R8 インタレース,スキュー
	db  07h		;R9 最大ラスタアドレス
	db  00h,00h,00h,00h,0dh
	;01fd0 - PCG高速アクセスモード ON
	db	CRTC_1FD0

crtc40_H:
	db	35h,28h,2dh,84h,1bh,00h,19h,1ah,00h,0fh,00h,00h,00h,00h,0dh
	;01fd0 - PCG高速アクセスモード On
	db	CRTC_1FD0

crtc80_L:
	db	6bh,50h,59h,38h,1fh,02h,19h,1ch,00h,07h,00h,00h,00h,00h,0ch
	db	00h

crtc80_H:
	db	6bh,50h,59h,88h,1bh,00h,19h,1ah,00h,0fh,00h,00h,00h,00h,0ch
	db	03h


;//---------------------------------------------------------------;
;	画面フリップ (サンプルとは直接関係ない)
;//---------------------------------------------------------------;
init_flip:
	xor		a
	ld		( flip_w ),a
	ld		( flip_delchr_w ),a
	ld		( vsync_state), a
	ld		( vsync_w ),a

	ld		a, 04h
	ld		( flip_render_w ),a

	ret


;//---------------------------------------------------------------;
;	スクロールして表示されて来るスクリーンを描画
;	毎フレーム描画しているが、本来は、画面シフト量を見て描画する。
;//---------------------------------------------------------------;
render_scroll_line:
	ld		hl,(scroll_v_adrs)
	ld		bc, TEXT_VRAM_ADRS - 0028h
	add		hl,bc
	ld		a,h
	and		037h
	ld		b,a
	ld		c,l

	ld		a,(scroll_v_work)
	rrca
	rrca
	rrca
	and		01fh
	ld		e,a
	add		a,041h
	ld		d,a

	; テキストカラーを 01h～07hの繰り返しにしている。
	ld		a,e
	ld		h,07h
re_sc_li_2:
	cp		h
	jr		c, re_sc_li_3
;
	sub		h
	jr		re_sc_li_2

re_sc_li_3:
	inc		a
	ld		h,a

	ld		e, 40
re_sc_li_1:
	; テキストを書込む。
	out		(c),d

	; ATTRに色を書込む。
	res		4,b
	out		(c),h
	set		4,b

	inc		bc

	ld		a,b
	and		037h
	ld		b,a

	dec		e
	jp		nz, re_sc_li_1
;
	ret


;//---------------------------------------------------------------;
;//		CRTC R12,R13を使って表示開始位置を設定する。
;//---------------------------------------------------------------;
flip_screen:
	;flip_w(表示ページ)を xor 04h で反転する。
	;flip_render_w は、その反転なので、単にコピーするだけでオケー。

	ld		a,(flip_w)	;0
	ld		(flip_render_w),a	;0
	xor		FLIP_ADRS
	ld		(flip_w),a	;4


	ld		hl,(scroll_v_work)

	ld		a,l
	and		07h
	ld		(crtc_opt_value0),a

	ld		a,l
	and		0f8h
	ld		l,a

	ld		d,h
	ld		e,l
	add		hl,hl
	add		hl,hl
	add		hl,de

	ex		de,hl
	ld		hl,0000h
	or		a
	sbc		hl,de

	ld		bc, CRTC_ADRS
	ld		a, 0dh		;CRTC R13
	out		(c),a

	inc		c
	out		(c),l

	dec		a
	dec		c

	out		(c),a
	inc		c
	ld		a,h
	and		07h
	out		(c),a
	ld		h,a

	ld		(scroll_v_adrs),hl

	ret



flip_w:
	;FlipWork
	;表示ページを格納する。
	;000hの時 描画ページ1,表示ページ0
	;004hの時 描画ページ0,表示ページ1
	db	000h

flip_render_w:
	;描画ページを格納する。flip_w とは反対の状態。
	;000hの時 描画ページ0
	;004hの時 描画ページ1
	db	004h

flip_delchr_w:
	;削除キャラバッファページを格納する。
	;000h の時 削除キャラバッファ書込み 0,削除キャラバッファ読出し 1
	;001h の時 削除キャラバッファ書込み 1,削除キャラバッファ読出し 0
	db	000h

	;フレームごとのカウンタ
frame_cnt:
	ds	1

align 2
vsync_w:
	db	000h

vsync_state:
	db	000h

;//---------------------------------------------------------------;
;		VSync開始を待つ。
;//---------------------------------------------------------------;
wait_vsync_start:
	; 1a01h pb7 垂直基線期間信号
	ld		bc, 1a01h

	; 垂直基線期間信号の開始 (H→Lを待つ)
	; VBlankの開始を待つ。
wa_vs_1:
	in		a,(c)			; 12
	jp		m, wa_vs_1
;
	ret


;//---------------------------------------------------------------;
;	VSync割込みカウントを待つ。
;//---------------------------------------------------------------;
wait_vsync_frame:

wvf_1:
	; vsync_frame_countは毎VSyncごとにカウントアップされる。
	ld		a,(vsync_frame_count)
	or		a
	jr		z, wvf_1
;
	di
	; vsync_frame_countをリセットする。
	; 割込み禁止して行う。
	xor		a
	ld		(vsync_frame_count),a
    ei

	ret

;//---------------------------------------------------------------;
;		VSync終了を待つ。
;//---------------------------------------------------------------;
wait_vsync_end:
	; 1a01h pb7 垂直基線期間信号
	ld		bc, 1a01h

	; 垂直基線期間信号の終了 (L→Hを待つ)
	; VBlankの終了を待つ。
wa_ve_1:
	in		a,(c)			; 12
	jp		p, wa_ve_1
;
	ret

vsync_frame_count:
	db		00h

vsync_flag:
	db		00h

;---------------------------------------------------------------;
	END
