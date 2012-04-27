;~ Sileem Farghaly
;~ FILES.ASM
; Open_close_files.asm
; The begining and end of Processing files
; Open and close files

; Open Files
OpenFileI PROC
        MOV AH, 3DH					; Value needed for INT 21h to recognize you want to open a file
		MOV AL,0					; Value indicating you want to READ from it
		MOV DX,Offset FilenameInput ;Address of the Name of the data file
		INT 21H
	OpenSuccessInput:
	    MOV HandleInput,Ax			; INT 21H returns a numeric value to AX that associates it to your file
									; Need to save that value because AX may be needed later
		RET
OpenFileI ENDP

; Close Files
CloseFileInput Proc
		MOV BX,HandleInput
		MOV AH,3EH
		INT 21H
		RET
CloseFileInput ENDP

; Writing to a file
CreateFileOutput Proc
		MOV AH,3CH
		MOV DX, Offset OutputFileName
		MOV CX,0						; 0 means a regular file not a system or hidden file
		INT 21H
		RET
CreateFileOutput ENDP

OpenFileOutput Proc
		MOV AH, 3DH
		MOV AL,1						; 1 in AL means you want to WRITE to this file
		MOV DX, Offset OutputFileName
		INT 21H
		JNC OpenSuccess					; A put in an ERROR check, if the Carry Flag is not set we are OK
		MOV Dx,Offset FileErrorMessage
		MOV AH,9
		INT 21H 
		Jmp Returnback2
				
	OpenSuccess:
			MOV HandleOutput,Ax			; Save the Numeric value of the output file 
	ReturnBack2:
		RET
OpenFileOutput ENDP

CloseFileOutput Proc
		MOV BX,HandleOutput
		MOV AH,3EH
		INT 21H
		RET
CloseFileOutput ENDP
