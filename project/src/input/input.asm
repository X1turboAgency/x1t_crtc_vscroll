;//---------------------------------------------------------------;
;	���͊֘A
;//---------------------------------------------------------------;

;bit0: ��
;bit1: ��
;bit2: ��
;bit3: �E
;bit5: �{�^��A
;bit6: �{�^��B??

;//---------------------------------------------------------------;
;//		�W���C�X�e�B�b�N�̏�����
;//---------------------------------------------------------------;
init_input:
	xor	a
	ld	(joy_w),a
	ld	(trg_w),a

	ld	(joy_w_2p),a
	ld	(trg_w_2p),a

	ret

;//---------------------------------------------------------------;
;//		�W���C�X�e�B�b�N�̓ǂݍ���
;//	���݂̃W���C�X�e�B�b�N�̃f�[�^�ƁA�g���K�[�����Z�o
;//	�������̂����[�N�ɃZ�b�g����B
;//
;//	joy_w:	���݂̃W���C�X�e�B�b�N
;//	Areg,trg_w:	�g���K�[
;//---------------------------------------------------------------;
update_input:
	di

	ld		bc,01c00h	;1P�W���C�p�b�h

	;1P
	ld		a,(joy_w)
	ld		e,a

	ld		d,14
	out		(c),d
	dec		b
	in		a,(c)
	cpl
	ld		(joy_w),a

	ld		d,a
	xor		e
	and		d
	ld		(trg_w),a

	;01c00h �ɖ߂��B
	inc		b

	;2P
	ld		a,(joy_w_2p)
	ld		e,a

	ld		d,15
	out		(c),d
	dec		b
	in		a,(c)
	cpl
	ld		(joy_w_2p),a

	ld		d,a
	xor		e
	and		d
	ld		(trg_w_2p),a

	ei

	ret

;bit0: ��
;bit1: ��
;bit2: ��
;bit3: �E
;bit4: ���g�p
;bit5: �g���K1
;bit6: �g���K2
;bit7: ���g�p

;1P��
trg_w:
	ds		1

joy_w:
	ds		1

;2P��(�f�o�b�O�p)
trg_w_2p:
	ds		1

joy_w_2p:
	ds		1

	END
