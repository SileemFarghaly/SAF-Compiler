;~ Sileem Farghaly
;~ DSPLINE.ASM
;~ DSPLine caused some problems, no longer used.
  
; DSPHEX SubRoutine
; Displays two or four hex digits on the monitor that represent one byte or one word of storage
; To use this subroutine:
;     If you want to display a Byte of memory -- move that Byte to DH and move 2 To CX before you call this subroutine
;     to dispay a Word of memory-- move that WORD into DX and move 4 To CX before you call this subroutine

; For example you may have a value of 4 stored into a Byte of memory that you want to print.  If you simply try to 
; display it on the screen, the program will try to display the ASCII character for the number 4 not the 4 itself

; In your calling program to display a numberic Byte of storage in MyResult 
;===========================================================================
;  Mov DH,MyResult
;  Mov CX,2
;  Call DSPHEX

; For a WORD of storage use DX, and CX instead as described above

DSPHEX PROC

Repeat01:
	Push CX
	Mov CL,4
	ROL DX,CL
	POP CX
	Push DX
	AND DL,0FH
	ADD DL,30H

IF01:
	CMP DL,39H
	JBE ENDIF01

THEN01: 
	ADD DL,7

ENDIF01:
	Mov AH,2
	Int 21H
	Pop DX
	Loop Repeat01
Until01:
	RET
DSPHEX ENDP
	

	
