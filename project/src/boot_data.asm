;---------------------------------------------------------------; 
;	�v���O�����u�[�g�f�[�^
;	LOADM�`���ɂ��邽�߁A�擪�ɊJ�n�A�h���X�ƁA����(-1)��t�^����B
;---------------------------------------------------------------; 

PROG_TOP	equ	06000h
PROG_LENG	equ PROG_END - PROG_TOP

	ORG PROG_TOP-4
	dw	PROG_TOP
	dw	PROG_END

	jp	START_MAIN

	END
