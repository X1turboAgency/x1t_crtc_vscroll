;---------------------------------------------------------------;
;	CRTCを使った縦スクロールサンプル
;
;	date: 2021/04/11
;	auther: @x1turbo.agency
;---------------------------------------------------------------;
START_MAIN:
	di
	im		2

	; 以前の割込み環境を保存
	ld		a,i
	ld		(prev_ireg+1),a
	ld		(prev_spreg+1),sp

	; 割込みベクタ設定
	ld		a, INT_VECTOR_BUFF >> 8
	ld		i,a

	ld		sp, STACK_BUFF


	call	init_main
	ei

	; メインループ
idle_loop_v:
	; 入力情報の更新
	call	update_input

	; スクロール処理
	; スクロール値からVOfsを求める。
	call	update_screen

	call	wait_vsync_frame

	; TRG2(Bボタン)を押すとプログラム終了
	ld		a,(trg_w)
	BIT_A_6_KEY_TRG2
	jp		nz, exit_prog

	jp		idle_loop_v


;---------------------------------------------------------------;
;---------------------------------------------------------------;
update_screen:
	; VSync毎に 1/4ドットでスクロール。
	ld		a,(scroll_v_work_l)
	add		a, 040h
	ld		(scroll_v_work_l),a

	ld		hl,(scroll_v_work)
	ld		bc, 0000h
	adc		hl,bc
	ld		(scroll_v_work),hl

	ret

scroll_v_work_l:
	db		000h

scroll_v_work:
	dw		0000h

scroll_v_adrs:
	dw		0000h

;---------------------------------------------------------------;
;	プログラムを終了して呼び出し元に帰る。
;---------------------------------------------------------------;
exit_prog:
	di

	; CTC設定のリセット
	call	reset_ctc

prev_ireg:
	ld		a,00h
	ld		i,a

prev_spreg:
	ld		sp, 0000h
	ei

	ret


;---------------------------------------------------------------;
;	CRTCスクロール値ワーク
;---------------------------------------------------------------;
; スクロールラスタ (0-7)
crtc_opt_value0:
	db  0		; update_value

; VSync開始からのCTC割込みCh0定数
crtc_opt_value3:
	db  16

; VSync開始からのCTC割込みCh3定数
crtc_opt_value4:
	db	0bah

; VSync開始から終了までのCTC割込みCh3定数
crtc_opt_value6:
	db	037h

crtc_opt_end:


;---------------------------------------------------------------;
;	初期化
;---------------------------------------------------------------;
init_main:
	call	clear_text_vram

	ld		d,07h
	call	fill_attr_vram
	call	write_sample_ascii

	call	clear_kanji_vram

	call	set_crtc40
	call	vram_priority
	call	init_vram_palette

	call	clear_graphic_vram_b
	call	clear_graphic_vram_r
	call	clear_graphic_vram_g

	call	init_input

	xor		a
	ld		(vsync_frame_count),a

	; VSYNC中のフラグを下げる。
	xor		a
	ld		(vsync_flag),a

	; ここでVSyncタイミングをチェック
	; (現在VSync中かもなので)VSync終了→VSync開始を検知
	call	wait_vsync_end
	call	wait_vsync_start

	call	init_ctc_vsync_over

	ret

;---------------------------------------------------------------;
;	CTC割込みを設定する。
;---------------------------------------------------------------;
init_ctc:
	; 割込み処理先
	ld		hl, ctc_int_0
	ld		(INT_VECTOR_BUFF+00h),hl
	ld		(INT_VECTOR_BUFF+02h),hl
	ld		(INT_VECTOR_BUFF+04h),hl
	ld		(INT_VECTOR_BUFF+06h),hl

	ld		bc, CTC_ADRS

	; 00000000
	; ch0: 割込みなし,カウンタモード,割込みベクタ(00h)指定
	; bit0=0 時は割り込みベクタを指定する。
	ld		a,00h
	out		(c),a

	call	reset_ctc

	ret

;---------------------------------------------------------------;
; VSync終了からVSync開始の割込み。
; BCreg,HLregのみ破壊
;---------------------------------------------------------------;
init_ctc_vsync_start:
	ld		bc, CTC_ADRS

	; CTC ch0 リセット
	ld		a,03h
	out		(c),a

	; 00010101
	; ch0: 割込みなし,タイマーモード,プリスケーラ16,タイムコンスタントあり
	ld		a,015h
	out		(c),a

	; タイマーコンスタント (16)
	ld		a, (crtc_opt_value3)
	out		(c),a

	; ch0: タイマーモード 250ns x 16 x 16 = 64usec
	; 15KHz時のほぼ走査線1本分の時間。

	; ch3アドレス( 01fa3)
	ld		c, (CTC_ADRS+3) & 0ffh

	; CTCリ ch3 セット
	ld		a,03h
	out		(c),a

	; 11010101
	; ch3: 割込みあり,カウンタモード
	; タイムコンスタントあり,
	ld		a,0d5h
	out		(c),a

	; タイマーコンスタント
	; VSync終了からVSync開始への時間。
	ld		a,(crtc_opt_value4)
	out		(c),a

	; 割込み先アドレス
	ld		hl, ctc_vsync_start
	ld		(INT_VECTOR_BUFF+06h),hl

	ret

;---------------------------------------------------------------;
; VSync開始からVSync終了の割込み。
; BCreg,HLregのみ破壊
;---------------------------------------------------------------;
init_ctc_vsync_over:
	ld		bc, CTC_ADRS

	; CTCリセット
	ld		a,03h
	out		(c),a

	; 00010101
	; ch0: 割込みなし,タイマーモード,プリスケーラ16,タイムコンスタントあり
	ld		a,015h
	out		(c),a

	; タイマーコンスタント (16)
	ld		a, 16
	out		(c),a

	; ch0: タイマーモード 250ns x 16 x 16 = 64usec
	; 15KHz時のほぼ走査線1本分の時間。

	; ch3アドレス( 01fa3)
	ld		c, (CTC_ADRS+3) & 0ffh

	; CTCリセット
	ld		a,03h
	out		(c),a

	; 11010101
	; ch3: 割込みあり,カウンタモード
	; タイムコンスタントあり,
	ld		a,0d5h
	out		(c),a

	; タイマーコンスタント
	; VSync開始から終了時への時間。
	ld		a,(crtc_opt_value6)
	out		(c),a

	; 割込み先アドレス
	ld		hl, ctc_vsync_over
	ld		(INT_VECTOR_BUFF+06h),hl

	ret

;---------------------------------------------------------------;
;	CTCを初期化
;---------------------------------------------------------------;
reset_ctc:
	ld		bc, CTC_ADRS

	ld		a,03h
	out		(c),a
	inc		c
	out		(c),a
	inc		c
	out		(c),a
	inc		c
	out		(c),a

	ret

;---------------------------------------------------------------;
;---------------------------------------------------------------;
ctc_int_0:
	di
	ei
	reti

; VSync開始割込み
ctc_vsync_start:
	di
	push	af
	push	bc
;;	push	de
	push	hl
;;	push	ix
;;	push	iy

	call	proc_vsync_start

;;	pop		iy
;;	pop		ix
	pop		hl
;;	pop		de
	pop		bc
	pop		af

	ei
	reti

;---------------------------------------------------------------;
ctc_vsync_over:
	di
	push	af
	push	bc
;;	push	de
	push	hl
;;	push	ix
;;	push	iy

proc_vsync_over:
	; VSync終了時に一度 HSyncを待つ。
	; この処理を行わないとVSync終了のタイミングがずれてしまう。
	ld		bc,1400h
	in		a,(c)

;;	call	set_palet_red

	; VSync終了からVSync開始の割込みをセット。
	call	init_ctc_vsync_start

	; VSYNC中のフラグを下げる。
	xor		a
	ld		(vsync_flag),a

;;	pop		iy
;;	pop		ix
	pop		hl
;;	pop		de
	pop		bc
	pop		af

	ei
	reti

;---------------------------------------------------------------;
;	VSync開始処理
;---------------------------------------------------------------;
proc_vsync_start:
	; 最下行のラスタ数をスクロールオフセット値に合わせて出力する。
	; 07hの時はタイミングがずれるので暫定的に06hと同じにしている。

	ld		a,(crtc_opt_value0)
	cp		07h
	jr		nz,pr_vs_st_1
;
	dec		a
pr_vs_st_1:

	; 0 → 7
	; 1 → 6
	; 6 → 1
	xor		07h			; 7-Areg

	ld		l,09h		; CRTC R9番号
	ld		bc,CRTC_ADRS
	out		(c),l		; R9を設定
	inc		c
	out		(c),a

pr_vs_st_2:
	call	wait_vsync_start

	; VSync開始からVSync終了の割込みをセット。
	call	init_ctc_vsync_over

	; CRTC R9に07hを出力。
	ld		a,07h
	call	set_crtc_r9

	; VSyncフレームカウンタを更新する。
	ld		hl,vsync_frame_count
	inc		(hl)

	call	flip_screen

	call	render_scroll_line

	; R5を出力する。
	ld		a,(crtc_opt_value0)
	add		a,CRTC_R5_DEFAULT
	call	set_crtc_r5

	; VSYNC中のフラグを立てる。
	ld		a,01h
	ld		(vsync_flag),a

	; Palet0を黒に戻す。
;;	ld		bc,01000h
;;	ld		a, GAME_PALET_B
;;	out		(c),a

	ret

;---------------------------------------------------------------;
	END
