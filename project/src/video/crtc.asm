;//---------------------------------------------------------------;
;//	CRTC�ݒ�
;//		in: HLreg:	CRTC�f�[�^
;//---------------------------------------------------------------;
set_crtc40:
	ld		hl, crtc40_L

	call	set_crtc_sub
;
	; 40/80���̐؂�ւ�
	ld		a,(hl)			; 40/80���̐؂�ւ�
	inc		hl
	ld		bc,01a03h
	out		(c),a

	; ��ʊǗ��|�[�g: ��𑜓x/25���C��
	ld		a,(hl)
	ld		bc,01fd0h
	out		(c),a

	ret

;//---------------------------------------------------------------;
;;	CRTC R00�`R13�܂ł�ݒ肷��B
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
;	CRTC R9���Z�b�g�B
;---------------------------------------------------------------;
set_crtc_r9:
	ld		bc, CRTC_ADRS
	ld		d,09h
	out		(c),d
	inc		c
	out		(c),a
	ret

;---------------------------------------------------------------;
;	CRTC R5���Z�b�g�B
;---------------------------------------------------------------;
set_crtc_r5:
	ld		bc, CRTC_ADRS
	ld		d,05h
	out		(c),d
	inc		c
	out		(c),a
	ret

;//---------------------------------------------------------------;
;//		CRTC�ݒ�f�[�^ 40��/80��
;//---------------------------------------------------------------;
crtc40_L:
	db	37h,28h,2dh,34h
	db  31 ;31	;R4 ������������ (-1)
	db  02h		;R5 �����X�^����
	db  25 ;25	;R6 �����\��������
	db  28 ;28	;R7 ���������ʒu (-1)
	db  00h		;R8 �C���^���[�X,�X�L���[
	db  07h		;R9 �ő僉�X�^�A�h���X
	db  00h,00h,00h,00h,0dh
	;01fd0 - PCG�����A�N�Z�X���[�h ON
	db	CRTC_1FD0

crtc40_H:
	db	35h,28h,2dh,84h,1bh,00h,19h,1ah,00h,0fh,00h,00h,00h,00h,0dh
	;01fd0 - PCG�����A�N�Z�X���[�h On
	db	CRTC_1FD0

crtc80_L:
	db	6bh,50h,59h,38h,1fh,02h,19h,1ch,00h,07h,00h,00h,00h,00h,0ch
	db	00h

crtc80_H:
	db	6bh,50h,59h,88h,1bh,00h,19h,1ah,00h,0fh,00h,00h,00h,00h,0ch
	db	03h


;//---------------------------------------------------------------;
;	��ʃt���b�v (�T���v���Ƃ͒��ڊ֌W�Ȃ�)
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
;	�X�N���[�����ĕ\������ė���X�N���[����`��
;	���t���[���`�悵�Ă��邪�A�{���́A��ʃV�t�g�ʂ����ĕ`�悷��B
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

	; �e�L�X�g�J���[�� 01h�`07h�̌J��Ԃ��ɂ��Ă���B
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
	; �e�L�X�g�������ށB
	out		(c),d

	; ATTR�ɐF�������ށB
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
;//		CRTC R12,R13���g���ĕ\���J�n�ʒu��ݒ肷��B
;//---------------------------------------------------------------;
flip_screen:
	;flip_w(�\���y�[�W)�� xor 04h �Ŕ��]����B
	;flip_render_w �́A���̔��]�Ȃ̂ŁA�P�ɃR�s�[���邾���ŃI�P�[�B

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
	;�\���y�[�W���i�[����B
	;000h�̎� �`��y�[�W1,�\���y�[�W0
	;004h�̎� �`��y�[�W0,�\���y�[�W1
	db	000h

flip_render_w:
	;�`��y�[�W���i�[����Bflip_w �Ƃ͔��΂̏�ԁB
	;000h�̎� �`��y�[�W0
	;004h�̎� �`��y�[�W1
	db	004h

flip_delchr_w:
	;�폜�L�����o�b�t�@�y�[�W���i�[����B
	;000h �̎� �폜�L�����o�b�t�@������ 0,�폜�L�����o�b�t�@�Ǐo�� 1
	;001h �̎� �폜�L�����o�b�t�@������ 1,�폜�L�����o�b�t�@�Ǐo�� 0
	db	000h

	;�t���[�����Ƃ̃J�E���^
frame_cnt:
	ds	1

align 2
vsync_w:
	db	000h

vsync_state:
	db	000h

;//---------------------------------------------------------------;
;		VSync�J�n��҂B
;//---------------------------------------------------------------;
wait_vsync_start:
	; 1a01h pb7 ����������ԐM��
	ld		bc, 1a01h

	; ����������ԐM���̊J�n (H��L��҂�)
	; VBlank�̊J�n��҂B
wa_vs_1:
	in		a,(c)			; 12
	jp		m, wa_vs_1
;
	ret


;//---------------------------------------------------------------;
;	VSync�����݃J�E���g��҂B
;//---------------------------------------------------------------;
wait_vsync_frame:

wvf_1:
	; vsync_frame_count�͖�VSync���ƂɃJ�E���g�A�b�v�����B
	ld		a,(vsync_frame_count)
	or		a
	jr		z, wvf_1
;
	di
	; vsync_frame_count�����Z�b�g����B
	; �����݋֎~���čs���B
	xor		a
	ld		(vsync_frame_count),a
    ei

	ret

;//---------------------------------------------------------------;
;		VSync�I����҂B
;//---------------------------------------------------------------;
wait_vsync_end:
	; 1a01h pb7 ����������ԐM��
	ld		bc, 1a01h

	; ����������ԐM���̏I�� (L��H��҂�)
	; VBlank�̏I����҂B
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
