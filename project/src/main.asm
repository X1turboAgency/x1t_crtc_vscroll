;---------------------------------------------------------------;
;	CRTC���g�����c�X�N���[���T���v��
;
;	date: 2021/04/11
;	auther: @x1turbo.agency
;---------------------------------------------------------------;
START_MAIN:
	di
	im		2

	; �ȑO�̊����݊���ۑ�
	ld		a,i
	ld		(prev_ireg+1),a
	ld		(prev_spreg+1),sp

	; �����݃x�N�^�ݒ�
	ld		a, INT_VECTOR_BUFF >> 8
	ld		i,a

	ld		sp, STACK_BUFF


	call	init_main
	ei

	; ���C�����[�v
idle_loop_v:
	; ���͏��̍X�V
	call	update_input

	; �X�N���[������
	; �X�N���[���l����VOfs�����߂�B
	call	update_screen

	call	wait_vsync_frame

	; TRG2(B�{�^��)�������ƃv���O�����I��
	ld		a,(trg_w)
	BIT_A_6_KEY_TRG2
	jp		nz, exit_prog

	jp		idle_loop_v


;---------------------------------------------------------------;
;---------------------------------------------------------------;
update_screen:
	; VSync���� 1/4�h�b�g�ŃX�N���[���B
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
;	�v���O�������I�����ČĂяo�����ɋA��B
;---------------------------------------------------------------;
exit_prog:
	di

	; CTC�ݒ�̃��Z�b�g
	call	reset_ctc

prev_ireg:
	ld		a,00h
	ld		i,a

prev_spreg:
	ld		sp, 0000h
	ei

	ret


;---------------------------------------------------------------;
;	CRTC�X�N���[���l���[�N
;---------------------------------------------------------------;
; �X�N���[�����X�^ (0-7)
crtc_opt_value0:
	db  0		; update_value

; VSync�J�n�����CTC������Ch0�萔
crtc_opt_value3:
	db  16

; VSync�J�n�����CTC������Ch3�萔
crtc_opt_value4:
	db	0bah

; VSync�J�n����I���܂ł�CTC������Ch3�萔
crtc_opt_value6:
	db	037h

crtc_opt_end:


;---------------------------------------------------------------;
;	������
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

	; VSYNC���̃t���O��������B
	xor		a
	ld		(vsync_flag),a

	; ������VSync�^�C�~���O���`�F�b�N
	; (����VSync�������Ȃ̂�)VSync�I����VSync�J�n�����m
	call	wait_vsync_end
	call	wait_vsync_start

	call	init_ctc_vsync_over

	ret

;---------------------------------------------------------------;
;	CTC�����݂�ݒ肷��B
;---------------------------------------------------------------;
init_ctc:
	; �����ݏ�����
	ld		hl, ctc_int_0
	ld		(INT_VECTOR_BUFF+00h),hl
	ld		(INT_VECTOR_BUFF+02h),hl
	ld		(INT_VECTOR_BUFF+04h),hl
	ld		(INT_VECTOR_BUFF+06h),hl

	ld		bc, CTC_ADRS

	; 00000000
	; ch0: �����݂Ȃ�,�J�E���^���[�h,�����݃x�N�^(00h)�w��
	; bit0=0 ���͊��荞�݃x�N�^���w�肷��B
	ld		a,00h
	out		(c),a

	call	reset_ctc

	ret

;---------------------------------------------------------------;
; VSync�I������VSync�J�n�̊����݁B
; BCreg,HLreg�̂ݔj��
;---------------------------------------------------------------;
init_ctc_vsync_start:
	ld		bc, CTC_ADRS

	; CTC ch0 ���Z�b�g
	ld		a,03h
	out		(c),a

	; 00010101
	; ch0: �����݂Ȃ�,�^�C�}�[���[�h,�v���X�P�[��16,�^�C���R���X�^���g����
	ld		a,015h
	out		(c),a

	; �^�C�}�[�R���X�^���g (16)
	ld		a, (crtc_opt_value3)
	out		(c),a

	; ch0: �^�C�}�[���[�h 250ns x 16 x 16 = 64usec
	; 15KHz���̂قڑ�����1�{���̎��ԁB

	; ch3�A�h���X( 01fa3)
	ld		c, (CTC_ADRS+3) & 0ffh

	; CTC�� ch3 �Z�b�g
	ld		a,03h
	out		(c),a

	; 11010101
	; ch3: �����݂���,�J�E���^���[�h
	; �^�C���R���X�^���g����,
	ld		a,0d5h
	out		(c),a

	; �^�C�}�[�R���X�^���g
	; VSync�I������VSync�J�n�ւ̎��ԁB
	ld		a,(crtc_opt_value4)
	out		(c),a

	; �����ݐ�A�h���X
	ld		hl, ctc_vsync_start
	ld		(INT_VECTOR_BUFF+06h),hl

	ret

;---------------------------------------------------------------;
; VSync�J�n����VSync�I���̊����݁B
; BCreg,HLreg�̂ݔj��
;---------------------------------------------------------------;
init_ctc_vsync_over:
	ld		bc, CTC_ADRS

	; CTC���Z�b�g
	ld		a,03h
	out		(c),a

	; 00010101
	; ch0: �����݂Ȃ�,�^�C�}�[���[�h,�v���X�P�[��16,�^�C���R���X�^���g����
	ld		a,015h
	out		(c),a

	; �^�C�}�[�R���X�^���g (16)
	ld		a, 16
	out		(c),a

	; ch0: �^�C�}�[���[�h 250ns x 16 x 16 = 64usec
	; 15KHz���̂قڑ�����1�{���̎��ԁB

	; ch3�A�h���X( 01fa3)
	ld		c, (CTC_ADRS+3) & 0ffh

	; CTC���Z�b�g
	ld		a,03h
	out		(c),a

	; 11010101
	; ch3: �����݂���,�J�E���^���[�h
	; �^�C���R���X�^���g����,
	ld		a,0d5h
	out		(c),a

	; �^�C�}�[�R���X�^���g
	; VSync�J�n����I�����ւ̎��ԁB
	ld		a,(crtc_opt_value6)
	out		(c),a

	; �����ݐ�A�h���X
	ld		hl, ctc_vsync_over
	ld		(INT_VECTOR_BUFF+06h),hl

	ret

;---------------------------------------------------------------;
;	CTC��������
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

; VSync�J�n������
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
	; VSync�I�����Ɉ�x HSync��҂B
	; ���̏������s��Ȃ���VSync�I���̃^�C�~���O������Ă��܂��B
	ld		bc,1400h
	in		a,(c)

;;	call	set_palet_red

	; VSync�I������VSync�J�n�̊����݂��Z�b�g�B
	call	init_ctc_vsync_start

	; VSYNC���̃t���O��������B
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
;	VSync�J�n����
;---------------------------------------------------------------;
proc_vsync_start:
	; �ŉ��s�̃��X�^�����X�N���[���I�t�Z�b�g�l�ɍ��킹�ďo�͂���B
	; 07h�̎��̓^�C�~���O�������̂Ŏb��I��06h�Ɠ����ɂ��Ă���B

	ld		a,(crtc_opt_value0)
	cp		07h
	jr		nz,pr_vs_st_1
;
	dec		a
pr_vs_st_1:

	; 0 �� 7
	; 1 �� 6
	; 6 �� 1
	xor		07h			; 7-Areg

	ld		l,09h		; CRTC R9�ԍ�
	ld		bc,CRTC_ADRS
	out		(c),l		; R9��ݒ�
	inc		c
	out		(c),a

pr_vs_st_2:
	call	wait_vsync_start

	; VSync�J�n����VSync�I���̊����݂��Z�b�g�B
	call	init_ctc_vsync_over

	; CRTC R9��07h���o�́B
	ld		a,07h
	call	set_crtc_r9

	; VSync�t���[���J�E���^���X�V����B
	ld		hl,vsync_frame_count
	inc		(hl)

	call	flip_screen

	call	render_scroll_line

	; R5���o�͂���B
	ld		a,(crtc_opt_value0)
	add		a,CRTC_R5_DEFAULT
	call	set_crtc_r5

	; VSYNC���̃t���O�𗧂Ă�B
	ld		a,01h
	ld		(vsync_flag),a

	; Palet0�����ɖ߂��B
;;	ld		bc,01000h
;;	ld		a, GAME_PALET_B
;;	out		(c),a

	ret

;---------------------------------------------------------------;
	END
