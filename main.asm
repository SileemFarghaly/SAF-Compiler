;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ Sileem Farghaly
;~ 12/21/2011
;~ Compiler project
;~ 
;~ Instructions: This will write out the hex code for a set of instructions
;~ 				 loaded from 'CODE.TXT' and create 'PROG1.COM'
;~ 				 Variable names are stored into one large array, which
;~               is split into two other semi-parrallel arrays.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TITLE Simple Compiler

Code Segment 'CODE'

ASSUME CS:CODE,DS:DATA,SS:STACK

ASMBY PROC

	MOV AX,DATA
	MOV DS,AX
	
;================ Pass1 ================;
	CALL OpenFileI		    ; Open file (CODE.TXT)
	CALL READ_DATA			; Read all the data
	CALL CloseFileInput		; Close file

	CALL PRINT_DATA			; Displays location counter and variable info
							; to the Screen
	
;================ Pass2 ================;
	CALL CreateFileOutput	; Create output file
	CALL CloseFileOutput
	CALL OpenFileOutput		; Open the newly created file
	CALL WriteAddition		; Begins writing the add statements
	CALL WRITE_DATA			; Write the variables to the output file
	CALL CloseFileOutput
	
	JMP FINISH				; Confirms the program finishing and terminates

	READ_DATA PROC
		MOV SI,0
		MOV DI,0

		BEGIN_WHILE:
			MOV AH,3Fh
			MOV BX,HandleInput
			MOV Dx,Offset LineOfData
			MOV Cx,18					; Number of bytes read in (18)
			INT 21H

			; Check if it is a variable statement
			CMP LineOfData[0],76h
			JE VAR_STATEMENT
			
			; Check to see if it is an addition statement
		  	CMP LineOfData[0],61h
		  	JE ADD_STATEMENT
			JMP END_WHILE
			
		END_WHILE:
		; Determine if there are still records to be read
			CMP AX,CX
			JE BEGIN_WHILE
			RET

		VAR_STATEMENT:
			; Store the variable name into var_name
			MOV DL,LineOfData[8] ; MOVe the variable name to AL (Assuming it is the 9th character)
			MOV var_name[SI],DL  ; Store the variable name to memory
			
			; Store the value into var_val
			MOV DL,LineOfData[15]
			MOV var_val[SI],DL
			
			INC numVar ; Increment number of variables
			INC SI
			JMP END_WHILE
			
		ADD_STATEMENT:
			PUSH SI
			MOV SI,SIStore
			; Add is called
			; MOVe the Addends and sum into variables
			MOV DL,LineOfData[4]
			MOV ADDENDS[DI],DL
			INC DI
			MOV DL,LineOfData[6]
			MOV ADDENDS[DI],DL
			INC DI
			; Store the SUM variable
			MOV DL,LineOfData[15]
			MOV SUM[SI],DL
			; Add 12 to the location counter
			ADD TempLocation,12
			INC numAdd	; Increment the number of ADD statements
			INC SI
			MOV SIStore,SI
			POP SI
			JMP END_WHILE

	READ_DATA ENDP
	
	PRINT_DATA PROC
		MOV CX,SI			               ; Tell the loop how many lines there are.
		MOV CXStore,CX
		MOV SI,0
		MOV DI,0

		HEADING:
			MOV AH,9h
			MOV DX, Offset HEADINGTITLE    ; Print title
			MOV CX,3h
			INT 21h
			MOV DX, Offset TABLE           ; Print table headings
			INT 21h
			MOV CX,CXStore
			
		PRINTLOCATION:
			MOV CXStore,CX
			MOV CX,0
			; Display Location Counter
			MOV BX,TempLocation
			MOV LocationCounter[DI],BX ; Increment and save location counter.
			MOV AH,9h
			MOV DX,LocationCounter[DI]
			MOV CX,4h
			CALL DSPHEX
			
			MOV AH,9
			MOV DX, Offset Space1	; This should leave a space inbetween counter and variable
			INT 21h
		
		PRINTSYMBOL:
			; Display the Symbol
			MOV AH,9h
			MOV DL, var_name[SI]
			MOV Store, DL
			MOV DX, Offset Store
			INT 21h

			MOV DX, Offset Space2	; This should leave a - inbetween counter and variable
			INT 21h
		PRINTVALUE:
			MOV AH,9h
			MOV DL, var_val[SI]
			MOV Store, DL
			MOV DX, Offset Store
			INT 21h
			
		LOOPWRITE:
			INC SI
			INC DI
			INC DI 					; Incrememnt DI twice to reach the next location
			MOV DX,Offset NEWLINE	; Leave a space
			INT 21h
			INC TempLocation
			MOV CX, CXStore
			Loop PRINTLOCATION
		
		ENDLOOP:
			RET
	PRINT_DATA ENDP
	
	WriteAddition PROC
		MOV SI,0
		MOV CL,numAdd
		CALL PUSHAX_OP	

		AddLoop:
			MOV CXStore,CX
			; Search for the first addend
			SEARCHL_PRIME:
				MOV AL,ADDENDS[SI]
				MOV DI,0
			SEARCHL_LOOP:
				Cmp AL,var_name[DI]
				JE MOVOPERANDTOAL
				INC DI
				JMP SEARCHL_LOOP
			
			; Move the addened into AL
			MOVOPERANDTOAL:
				CALL MOVAL_OP
				CALL WriteAdr
						
			; Search for the second addend
			SEARCHR_PRIME:
				MOV AL,ADDENDS[SI+1]
				MOV DI,0
			SEARCHR_LOOP:
				Cmp AL,var_name[DI]
				JE WRITE_ADD
				INC DI
				JMP SEARCHR_LOOP
				
			; Add the two addends
			WRITE_ADD:
				CALL ADD_OP
				CALL WriteAdr
			
			; Search for the sum variable
			SEARCHSUM_PRIME:
				PUSH SI
				MOV SI,SumIDX
				MOV DI,0
				MOV AL,SUM[SI]
			SEARCHSUM_LOOP:
				Cmp AL,var_name[DI]
				JE MOVALTOVAR
				INC DI
				JMP SEARCHSUM_LOOP
			
			; Move AL into the sum
			MOVALTOVAR:
				CALL MOVINTOVAR_OP
				CALL WriteAdr
		INC SI		
		MOV SumIDX, SI
		POP SI
		add SI,2		; Add two to the SI counter
		MOV CX,CXStore
		LOOP AddLoop	; Loop for all add statements
		CALL POPAX_OP	; POP AX
		CALL EXIT_OP	; Write CD 20/INT 21h
		RET
	WriteAddition ENDP
	
	WRITE_DATA PROC
	; Writes all the VALUES for each LOCATION
		MOV CL, numVar
		MOV SI, 0
			WriteValues:
				; Writes the data
				PUSH CX
				MOV AH, 40H
				MOV BX, HandleOutput
				MOV DL, var_val[SI]
				SUB DL, 30H				; Convert hex to binary
				MOV tempbyte, DL
				MOV DX, Offset tempbyte
				MOV CX, 01H
				Int 21H
				Inc SI
				POP CX
				LOOP WriteValues
			EndWrite:
				RET
	WRITE_DATA ENDP
		 
	FINISH:
	; Confirms the termination of the program.
		MOV AH,9h
		MOV DX,Offset DONE
		INT 21h
		; EXIT
		MOV AX,4C00h
		INT 21h
		INT 20h

ASMBY ENDP

INCLUDE FILES.ASM			; All file handling procedures
INCLUDE DSPLINE.ASM			; NOTE DSPHEX is consolidated into DSPLINE.ASM
INCLUDE Op_Codes.asm		; Stores the procedures for writing the op codes

CODE ENDS

DATA SEGMENT
;======= Define data section ========================

; Text Stuff
DONE    DB "END",'$'
NEWLINE DB " ", 0DH, 0AH, '$'
; Formatting
Space1  DB "                 ",'$'
Space2  DB "          ",'$'
FileErrorMessage DB "Cant find file",'$'

; Output stuff
HEADINGTITLE DB "Sileem Farghaly Assembler Symbol Table",0DH,0AH,'$'
TABLE DB "Location Counter     Symbol     Value",0DH,0AH, '$'

; Counting
numVar DB 0			; Store the number of Variables
numAdd DB 0			; Store the number of add statements

; Location
LocationCounter  DW 6 DUP(0)			   ; Location Counter
TempLocation     DW 0					   ; Temporarily store counter

; Arrays
LineOfData DB 18 Dup(?)			   ; Store read in line.
var_name   DB 9 DUP(0) 		       ; Store the name of the variables
var_val    DB 9 DUP(0) 			   ; Store the value of the Variables
AddrStore  DB 2 DUP(0)			   ; Stores each byte of the address

; Addition variables
ADDENDS DB 6 DUP(0)			; Store the things being adding
SUM 	DB 3 DUP(0)			; Stores each sum variable
SumIDX  DW 0				; Stores the index of the sum

; Input and output
FileNameInput  DB "CODE.TXT",0    ; Input file name	
OutputFileName DB "PROG1.COM",0	   ; Output file name

; Opcodes
OP_PushAX  DB 50h			; Opcode for PUSH AX, X
OP_MOVAL   DB 0A0h			; Opcode for MOV AL, X
OP_MOVINAL DB 0A2H		    ; Opcode for MOV X, AL
OP_Add     DB 02h,06h		; Opcode for ADD AL, X
OP_POPAX   DB 58h			; Opcode for POP AX
OP_EXIT    DB 0CDh,20h		; Opcode for INT 21h

; File Handles
HandleInput  DW ?	; Input file handle
HandleOutput DW ?	; Output file handle

; MISC
tempbyte DB ?	  ; Temporary byte storage 
SIStore  DW 0	  ; Store SI when push isn't working
CXStore  DW 0	  ; Store CX when push isn't working
Store    DB ?,'$' ; Store the variable with an end
						


;====== End of data definition section =============
DATA ENDS

STACK SEGMENT STACK
	DB 32 DUP("STACK ")
STACK ENDS

END ASMBY
