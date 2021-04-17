;---------------------------------------------------------------;
;		�V���{���錾
;---------------------------------------------------------------;


CTC_ADRS				equ	01fa0h

ATTR_VRAM_ADRS			equ	02000h
TEXT_VRAM_ADRS			equ	03000h

TEXT_VRAM0_ADRS			equ	03000h
TEXT_VRAM1_ADRS			equ	03400h

TEXT_VRAM19_SIZE		equ	(19*40)
TEXT_VRAM14_SIZE		equ	(14*40)
TEXT_VRAM7_SIZE			equ	(7*40)

KANJI_VRAM_ADRS			equ	03800h

B_VRAM_ADRS				equ	04000h
R_VRAM_ADRS				equ	08000h
G_VRAM_ADRS				equ	0c000h
PLANE_SIZE				equ	04000h		; 1�v���[���̃T�C�Y

FLIP_ADRS				equ	04h	; VRAM�A�h���X�t���b�v�l

PCG_BLUE				equ	015h
PCG_RED					equ	016h
PCG_GREEN				equ	017h

CRTC_ADRS				equ	1800h

;;CRTC_1FD0				equ	(023h | 08h)	; PCG�����A�N�Z�X���[�h + 24KHz + 2���X�^
CRTC_1FD0				equ	020h	; PCG�����A�N�Z�X���[�h + 15KHz

CRTC_R5_DEFAULT			equ	002h

;�p���b�g�f�[�^
GAME_PALET_B			equ	046h
GAME_PALET_R			equ	070h
GAME_PALET_G			equ	024h


;---------------------------------------------------------------;
;	�����݃x�N�^ / �X�^�b�N�̈�
;---------------------------------------------------------------;
INT_VECTOR_BUFF			equ	0ae00h

STACK_BUFF				equ INT_VECTOR_BUFF+0100h	; �X�^�b�N�|�C���^


;---------------------------------------------------------------;
;		�W���C�p�b�h�֘A
;---------------------------------------------------------------;
; �W���C�p�b�h (��)
BIT_A_0_KEY_UP MACRO
	bit	0,a
ENDM

; �W���C�p�b�h (��)
BIT_A_1_KEY_DOWN MACRO
	bit	1,a
ENDM

; �W���C�p�b�h (��)
BIT_A_2_KEY_LEFT MACRO
	bit	2,a
ENDM

; �W���C�p�b�h (�E)
BIT_A_3_KEY_RIGHT MACRO
	bit	3,a
ENDM

; �W���C�p�b�h (�g���K1)
BIT_A_5_KEY_TRG1 MACRO
	bit	5,a
ENDM

; �W���C�p�b�h (�g���K2)
BIT_A_6_KEY_TRG2 MACRO
	bit	6,a
ENDM


	END

