;~ Sileem Farghaly
;~ OpCodes.ASM
; Opcode translations
PUSHAX_OP Proc
	PUSH CX
	; Writes the opcode for PUSH AX
	MOV AH,40H
	MOV BX,HandleOutput
	MOV DX,Offset OP_PushAX
	MOV CX,01h
	INT 21H
	POP CX
	RET
PUSHAX_OP ENDP

MOVAL_OP Proc
;	PUSH CX
	; Writes the opcode to MOV AL,X
	; Will require a memory address (flip)
	MOV AH,40h
	MOV BX,HandleOutput
	MOV Dx,Offset OP_MovAL
	MOV Cx,01h
	INT 21h
;	POP CX
	RET
MOVAL_OP ENDP

MOVINTOVAR_OP Proc
	; Writes the opcode to MOV AL,X
	; Will require a memory address (flip)
	;PUSH CX
	MOV AH,40h
	MOV BX,HandleOutput
	MOV Dx,Offset OP_MOVINAL
	MOV Cx,01h
	INT 21h
	;POP CX
	RET
MOVINTOVAR_OP ENDP

ADD_OP Proc
	; Writes the opcode to ADD AL,Y
	; Will require a memory address (flip)
	MOV AH,40h
	MOV BX,HandleOutput
	MOV DX,Offset OP_Add
	MOV CX,02h
	INT 21h
	RET
ADD_OP ENDP

WriteAdr PROC
	;~ Writes the address of the value
	PUSH DI
	;~ MOV DI,SI
	ADD DI,DI
	MOV CX, LocationCounter[DI]
	ADD CX,100h
	MOV AddrStore[0],CH
	MOV AddrStore[1],CL
	
	; Write the address
	MOV AH,40h
	MOV BX,HandleOutput
	MOV DX,OFFSET AddrStore[1]
	MOV CX,1
	INT 21h
	MOV AH,40h
	MOV BX,HandleOutput
	MOV DX,OFFSET AddrStore[0]
	MOV CX,1
	INT 21h
	POP DI
	RET
WriteAdr ENDP

POPAX_OP Proc
	; Writes the opcode for POP AX
	MOV AH,40h
	MOV BX,HandleOutput
	MOV DX,Offset OP_POPAX
	MOV CX,01h
	INT 21h
	RET
POPAX_OP ENDP

EXIT_OP Proc
	; Writes the opcode for INT 20h
	MOV AH,40h
	MOV BX,HandleOutput
	MOV DX,Offset OP_EXIT
	MOV CX,02h
	INT 21h
	RET
EXIT_OP ENDP



