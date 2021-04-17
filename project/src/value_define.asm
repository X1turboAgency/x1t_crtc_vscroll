;---------------------------------------------------------------;
;		シンボル宣言
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
PLANE_SIZE				equ	04000h		; 1プレーンのサイズ

FLIP_ADRS				equ	04h	; VRAMアドレスフリップ値

PCG_BLUE				equ	015h
PCG_RED					equ	016h
PCG_GREEN				equ	017h

CRTC_ADRS				equ	1800h

;;CRTC_1FD0				equ	(023h | 08h)	; PCG高速アクセスモード + 24KHz + 2ラスタ
CRTC_1FD0				equ	020h	; PCG高速アクセスモード + 15KHz

CRTC_R5_DEFAULT			equ	002h

;パレットデータ
GAME_PALET_B			equ	046h
GAME_PALET_R			equ	070h
GAME_PALET_G			equ	024h


;---------------------------------------------------------------;
;	割込みベクタ / スタック領域
;---------------------------------------------------------------;
INT_VECTOR_BUFF			equ	0ae00h

STACK_BUFF				equ INT_VECTOR_BUFF+0100h	; スタックポインタ


;---------------------------------------------------------------;
;		ジョイパッド関連
;---------------------------------------------------------------;
; ジョイパッド (上)
BIT_A_0_KEY_UP MACRO
	bit	0,a
ENDM

; ジョイパッド (下)
BIT_A_1_KEY_DOWN MACRO
	bit	1,a
ENDM

; ジョイパッド (左)
BIT_A_2_KEY_LEFT MACRO
	bit	2,a
ENDM

; ジョイパッド (右)
BIT_A_3_KEY_RIGHT MACRO
	bit	3,a
ENDM

; ジョイパッド (トリガ1)
BIT_A_5_KEY_TRG1 MACRO
	bit	5,a
ENDM

; ジョイパッド (トリガ2)
BIT_A_6_KEY_TRG2 MACRO
	bit	6,a
ENDM


	END

