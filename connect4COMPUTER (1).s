;BY TANMAY KAUSHIK
;CS1022 Introduction to Computing II 2018/2019
; Mid-Term Assignment - Connect 4 - SOLUTION
;
; get, put and puts subroutines provided by jones@scss.tcd.ie
;

PINSEL0	EQU	0xE002C000
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014
	
SPACES EQU 42;
ROW  	EQU 6
COLUMNS EQU 7;		

	AREA	globals, DATA, READWRITE
BOARD	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0

;NEW_BOARD	SPACE	SPACES		; N words (4 bytes each)
	
	AREA	RESET, CODE, READONLY
	ENTRY

	; initialise SP to top of RAM
	LDR	R13, =0x40010000	; initialse SP

	; initialise the console
	BL	inithw

	;
	; your program goes here
	;
	;INITIALIZATION OF BOARD
IN	LDR	R4, =BOARD
	;LDR	R5, =NEW_BOARD
	LDR	R6, =0
whInit	CMP	R6,#42
	BHS	eWhInit
	LDR R7,="0";
	;LDRB	R7, [R5, R6]
	STRB	R7, [R4, R6]
	ADD	R6, R6, #1
	B	whInit
eWhInit
	
	
	
	
	; MAIN LINE
	LDR R0,=str_new;
	BL puts;
	LDR R0,=str_go;
	BL puts;
	BL PRINT;
	

	LDR R3,=BOARD;
	MOV R9,#0;R9=CHANCE COUNTER

RES		MOV R11,#0x31; COUNTER;
		
L2		CMP R11,#0x36;COUNTER==MAX COLUMN
		BGT RES;
		CMP R9,#0;if R9(chance counter)=0 chance for red
		BEQ L1;else chance for yellow
		LDR R0,=str_yellow;
		BL puts;
		LDR R0,=str_new;
	    BL puts;
		BL COMPUTER
		MOV R1,R0;	R1 - USER COLUMN INPUT
		BL put
		MOV R5,#0x0059;
		;BL MOVE
		LDR R0,=str_new;
	    BL puts;
		BL PRINT;
		BL CHECKD
		BL CHECKV
		BL CHECKH
		ADD R11,R11,#1;counter++
		LDR R6,=1;
	
	
		MOV R9,#0;changing the chance counter to 0(red)
		B L2
L1
PQ		LDR R0,=str_red;
		BL puts;
		LDR R0,=str_new;
	    BL puts;
		BL get
		CMP R0,#'q';
		BEQ IN;
		CMP R0,#'Q';
		BEQ IN;
		CMP R0,#0x38;
		BHS PQ;
		;MOV R1,R0;R1 - USER COLUMN INPUT
		BL put
		
		MOV R5,#0x0052;
		BL MOVE
		LDR R0,=str_new;
	    BL puts;
		BL PRINT;
		BL CHECKD
		BL CHECKV
		BL CHECKH
		LDR R6,=2;
	    MOV R9,#1;changing the chance counter to 1(YELLOW)
		B L2
				
GAME_OVER
stop	B	stop


;
; your subroutines go here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
COMPUTER
;PARAMETER: NONE
;RETURN: R0-ASCII CODE FOR COLUMN NUMBER

;COMPUTER PLAYER
	
		PUSH{R1-R10,LR}
		
		MOV R10,#0x0052;R10="R"
		MOV R2,#0;LENGTH=0

		LDR R3,=BOARD;
		MOV R4,#0;COLUMN
		MOV R7,#0; ROW
		ADD R4,R3,R4;R4=BOARD+COLUMN
		ADD R4,R4,R7;R4 += ROW
		
CLP		LDRB R5,[R4];loading from board index0
		

		CMP R5,R10;r5=='R'
		BEQ CRHZ
		
		
		; IF index!=R AND index!=Y
CRADD	ADD R4,R4,#1;INDEX++
		ADD R8,R3,#41; last index of board
		CMP R4,R8;column==index(6,7)
		BEQ CHEND
		B CLP
			

CRHZ		MOV R6,R4; copy of R4
		ADD R2,R2,#1;length++
CCHK		ADD R6,R6,#1;index+=1
		LDRB R5,[R6];
		CMP R5,R10;r5=='R'?
		BEQ CH1
		;if next index !=0
		MOV R2,#0;LENGTH=0
		B CRADD;
		
CH1		ADD R2,R2,#1;length++
		CMP R2,#3;lenght==3?
		BEQ CCPOS;
		B CCHK


CCPOS 	ADD R6,R6,#1;load next adress.
LF		LDRB R10,[R6];
		CMP R10,#0x30
		BNE LE
		MOV R0,#0x0059;
		strb R0,[R6]; 
		
		B CEND
LE		SUB R6,R6,#7;
		CMP R3,R6;comparing address to board stating address. if less than skip to CHEND
		BLE CHEND
		B LF
		
CHEND
	BL COMPH
BACK
	CMP R1,#"T";if COMPH returns true.
	BEQ CEND;
	MOV R0,R11;R0=counter(defined in main line)	
	MOV R5,#0x0059
	BL MOVE
CEND	POP{R1-R10,PC}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;COMPUTER HORIZONTAL CHECK
COMPH
		
		MOV R1,#"F";R11 = FALSE
		MOV R10,#0x0052;R10="R"
		MOV R2,#0;LENGTH=0

		LDR R3,=BOARD;
		MOV R4,#0;COLUMN
		MOV R7,#0; ROW
		ADD R4,R3,R4;R4=BOARD+COLUMN
		ADD R4,R4,R7;R4 += ROW
		
CLPCH		LDRB R5,[R4];loading from board index0
		

		CMP R5,R10;r5=='R'
		BEQ CRHZCH
		
		
		; IF index!=R AND index!=Y
CRADDCH	ADD R4,R4,#1;INDEX++
		ADD R8,R3,#41; last index of board
		CMP R4,R8;column==index(6,7)
		BEQ CENDCH
		B CLPCH
			

CRHZCH		MOV R6,R4; copy of R4
		ADD R2,R2,#1;length++
CCHKCH		ADD R6,R6,#7;index+=7
		LDRB R5,[R6];
		CMP R5,R10;r5=='R'?
		BEQ CH1CH
		;if next index !=0
		MOV R2,#0;LENGTH=0
		B CRADDCH;
		
CH1CH		ADD R2,R2,#1;length++
		CMP R2,#3;lenght==3?
		BEQ CCPOSCH;
		B CCHKCH


CCPOSCH 	SUB R6,R6,#7;load next adress.
			CMP R6,R3;
			BLE CHENDCH;
			ADD R7,R3,#42;
			CMP R6,R7
			BGT CHENDCH
LFCH		LDRB R10,[R6];
		CMP R10,#0x30
		BNE LECH
		MOV R0,#0x0059;
		strb R0,[R6]; 
		MOV R1,#"T";
		
		B CENDCH
LECH		SUB R6,R6,#7;
		CMP R3,R6;comparing address to board stating address. if less than skip to CHEND
		BGT CHENDCH
		B LFCH
		
CHENDCH
		
CENDCH	B BACK



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRINT
;PARAMETERS: NONE
;RETURN: NONE
;It prints the board.
;
;
PRINT PUSH{R4-R10,LR}
	  
	  LDR R0,=str_count;
	  BL puts;
	  
	  LDR R10,=0;over all space
	  LDR R6,=0;COUNTER
	  LDR R4,=BOARD;
	  ;LDR R4,=0x40000100;
	  LDR R5,=0; row=0;
	  LDR R6,=7;SIZE=7
	  LDR R7,=0;column=0
LO	  
	  ;MOV R0,R6;
	  ;BL put;
	  MUL R8,R5,R6;row*row size
	  ADD R8,R8,R7;
	  LDRB R0,[R4,R8];
	  ;add R0,R0,#0x30;	
	  BL put
	  LDR R0,=" ";
	  BL put;
	;  ADD R4,R4,#1
	  ADD R10,R10,#1;over all counter ++
	  CMP R10,#42;
	  BHS skipL;
	  ADD R7,R7,#1;COLUMN++	
	  CMP R7,#7;	
	  BEQ N1;	
	  B LO	


N1
	  LDR R0,=str_new;
	  BL puts;
      LDR R7,=0;column=0
	  ADD R5,R5,#1;rows++
	 ; ADD R7,R7,#1;
	  ;LDR R6,=0;column COUNTER
	  B LO;	
skipL POP {R4-R10,PC};
;
;
;
;

MOVE 
	PUSH {R2-R7,LR}
	MOV R7,R5;R or Y

M1	LDR R2, =0;counter
	SUB R0,R0,#0x30;converting ascii to number
	MOV R4,R0;R4=input from the user
	SUB R4,R4,#1;column(USER) = column(board)
	LDR R3,=BOARD;
	MOV R5,#0;
	ADD R5,R4,R3;R5=BOARD+COLUMN
	LDRB R6,[R5]
	CMP R6,#"0";
	BNE end1
L3	ADD R4,R4,#7;
	ADD R2,R2,#1;counter++
	CMP R2,#6;
	BEQ end2
	MOV R5,#0;
	ADD R5,R4,R3;R5=BOARD+COLUMN
	LDRB R6,[R5]
	CMP R6,#"0";
	BNE store
	B L3
	
end1 LDR R0,=str_full;
	 BL puts;
	 BL get;
	 B M1; 

store SUB R4,R4,#7;
	MOV R5,#0;
	ADD R5,R4,R3;R5=BOARD+COLUMN
	
	STRB R7,[R5]	

end2
	STRB R7,[R5]
	POP {R2-R7,PC}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;VERTICAL CHECKING
;PARAMETERS: NONE
;RETURN: NONE
;checks for 4 lined up Rs or Ys together verticaly.
CHECKV
	
		PUSH{R2-R10,LR}
	
		MOV R9,#0x0059;R9="Y"
		MOV R10,#0x0052;R10="R"
		MOV R2,#0;LENGTH=0

		LDR R3,=BOARD;
		MOV R4,#0;COLUMN
		MOV R7,#0; ROW
		ADD R4,R3,R4;R4=BOARD+COLUMN
		ADD R4,R4,R7;R4 += ROW
		
LPV		LDRB R5,[R4];loading from board index0
		

		CMP R5,R10;r5=='R'
		BEQ RHZV
		
		CMP R5,R9;r5=='Y'
		BEQ YHZV
		
		
		; IF index!=R AND index!=Y
RADDV	ADD R4,R4,#1;INDEX++
		ADD R8,R3,#41; last index of board
		CMP R4,R8;column==index(6,7)
		BEQ HENDV
		B LPV
			

RHZV		MOV R6,R4; copy of R4
		ADD R2,R2,#1;length++
CHKV		ADD R6,R6,#7;index+=1
		LDRB R5,[R6];
		CMP R5,R10;r5=='R'?
		BEQ H1V
		;if next index !=0
		MOV R2,#0;LENGTH=0
		B RADDV;
		
H1V		ADD R2,R2,#1;length++
		CMP R2,#4;lenght==4?
		BEQ HWINRV;
		B CHKV


YHZV		MOV R6,R4; copy of R4
		ADD R2,R2,#1;length++
CHKYV	ADD R6,R6,#7;index+=1
		LDRB R5,[R6];
		CMP R5,R9;r5=='Y'?
		BEQ H1YV
		;if next index !=0
		MOV R2,#0;LENGTH=0
		B RADDV;

H1YV		ADD R2,R2,#1;length++
		CMP R2,#4;lenght==4?
		BEQ HWINYV;
		B CHKYV

HWINRV 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_X
		BL puts;
		B stop

HWINYV 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_Y
		BL puts;
		B stop
		
HENDV	POP{R2-R10,PC}
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	



;HORIZONTAL CHECKING
;PARAMETERS: NONE
;RETURN: NONE
;checks for 4 lined up Rs or Ys together horizontally.



CHECKH	PUSH{R2-R11,LR}
		MOV R9,#0x0059;R9="Y"
		MOV R10,#0x0052;R10="R"
		MOV R2,#0;LENGTH=0

		LDR R3,=BOARD;
		MOV R4,#0;COLUMN
		MOV R7,#0; ROW
		ADD R4,R3,R4;R4=BOARD+COLUMN
		ADD R4,R4,R7;R4 += ROW
		
LP		LDRB R5,[R4];loading from board index0
		

		CMP R5,R10;r5=='R'
		BEQ RHZ
		
		CMP R5,R9;r5=='Y'
		BEQ YHZ
		
		
		; IF index!=R AND index!=Y
RADD	ADD R4,R4,#1;INDEX++
		;SKIPS IF ADDRESS HAS REACHED LAST COLUMN
		ADD R11,R3,#34;
		CMP R4,R11;
		BEQ RADD;
		ADD R11,R3,#27;
		CMP R4,R11;
		BEQ RADD;
		ADD R11,R3,#20;
		CMP R4,R11;
		BEQ RADD;
		ADD R11,R3,#13;
		CMP R4,R11;
		BEQ RADD;
		
		ADD R8,R3,#41; last index of board
		CMP R4,R8;column==index(6,7)
		BEQ HEND
		B LP
			

RHZ		MOV R6,R4; copy of R4
		ADD R2,R2,#1;length++
CHK		ADD R6,R6,#1;index+=1
		LDRB R5,[R6];
		CMP R5,R10;r5=='R'?
		BEQ H1
		;if next index !=0
		MOV R2,#0;LENGTH=0
		B RADD;
		
H1		ADD R2,R2,#1;length++
		CMP R2,#4;lenght==4?
		BEQ HWINR;
		B CHK


YHZ		MOV R6,R4; copy of R4
		ADD R2,R2,#1;length++
CHKY	ADD R6,R6,#1;index+=1
		LDRB R5,[R6];
		CMP R5,R9;r5=='Y'?
		BEQ H1Y
		;if next index !=0
		MOV R2,#0;LENGTH=0
		B RADD;

H1Y		ADD R2,R2,#1;length++
		CMP R2,#4;lenght==4?
		BEQ HWINY;
		B CHKY

HWINR 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_X
		BL puts;
		B stop

HWINY 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_Y
		BL puts;
		B stop
		
HEND	
	POP{R2-R11,PC}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;DIAGONAL CHECKING
;PARAMETERS: NONE
;RETURN: NONE
;checks for 4 lined up Rs or Ys DIAGONALLY.

CHECKD
		PUSH{R2-R11,LR}
		MOV R9,#0x0059;R9="Y"
		MOV R10,#0x0052;R10="R"
		MOV R2,#0;LENGTH=0
		MOV R8,#0; counter
		LDR R3,=BOARD;
		MOV R4,#0;COLUMN
		MOV R7,#0; ROW
		ADD R4,R3,R4;R4=BOARD+COLUMN
		ADD R4,R4,R7;R4 += ROW
		
LPD		LDRB R5,[R4];loading from board index0
		

		CMP R5,R10;r5=='R'
		BEQ RHZD
		
		CMP R5,R9;r5=='Y'
		BEQ YHZD
		
		
		; IF index!=R AND index!=Y
RADDD		
		ADD R4,R4,#1;INDEX++
		ADD R8,R8,#1;counter++
		ADD R8,R3,#21; index of board (4,1)
		CMP R4,R8;column==index(4,1)
		BEQ HENDD
		B LPD
			
;checks for diagonal left  to right for R
RHZD	MOV R6,R4; copy of R4
		ADD R11,R3,#4;
		CMP R6,R3;
		BHS Z2
		ADD R2,R2,#1;length++
CHKD		ADD R6,R6,#8;index+=8
		LDRB R5,[R6];
		CMP R5,R10;r5=='R'?
		BEQ H1D
		;if next index !=0
Z2		MOV R2,#0;LENGTH=0
		B REVDR;
		
H1D		ADD R2,R2,#1;length++
		CMP R2,#4;lenght==4?
		BEQ HWINRD;
		B CHKD

;checks for diagonal left  to right for Y
YHZD	MOV R6,R4; copy of R4
		ADD R11,R3,#4;
		CMP R6,R3;
		BHS Z1
		ADD R2,R2,#1;length++
CHKYD	ADD R6,R6,#8;index+=8
		LDRB R5,[R6];
		CMP R5,R9;r5=='Y'?
		BEQ H1YD
		;if next index !=0
Z1		MOV R2,#0;LENGTH=0
		B REVDY;

H1YD		ADD R2,R2,#1;length++
		CMP R2,#4;lenght==4?
		BEQ HWINYD;
		B CHKYD

REVDR	;checks for diagonal right to left for R
		MOV R6,R4; copy of R4
		ADD R2,R2,#1;length++
CHKD2	ADD R6,R6,#6;index+=8
		LDRB R5,[R6];
		CMP R5,R10;r5=='R'?
		BEQ H2D
		;if next index !=0
		MOV R2,#0;LENGTH=0
		B RADDD;
		
H2D		ADD R2,R2,#1;length++
		CMP R2,#4;lenght==4?
		BEQ HWINRD;
		B CHKD2


REVDY	;checks for diagonal right to left for Y
			MOV R6,R4; copy of R4
		ADD R2,R2,#1;length++
CHKYD2	ADD R6,R6,#6;index+=8
		LDRB R5,[R6];
		CMP R5,R9;r5=='Y'?
		BEQ H1YD2
		;if next index !=0
		MOV R2,#0;LENGTH=0
		B RADDD;

H1YD2		ADD R2,R2,#1;length++
		CMP R2,#4;lenght==4?
		BEQ HWINYD;
		B CHKYD2



;PRINT WHO WON
HWINRD 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_X
		BL puts;
		B stop

HWINYD 	LDR R0,=str_new
		BL puts;
		LDR R0,=str_Y
		BL puts;
		B stop
		
HENDD	
	POP{R2-R11,PC}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;























;
; inithw subroutines
; performs hardware initialisation, including console
; parameters:
;	none
; return value:
;	none
;
inithw
	LDR	R0, =PINSEL0		; enable UART0 TxD and RxD signals
	MOV	R1, #0x50
	STRB	R1, [R0]
	LDR	R0, =U0LCR		; 7 data bits + parity
	LDR	R1, =0x02
	STRB	R1, [R0]
	BX	LR

;
; get subroutine
; returns the ASCII code of the next character read on the console
; parameters:
;	none
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
get	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
get0	LDR	R0, [R1]		; wait until
	ANDS	R0, #0x01		; receiver data
	BEQ	get0			; ready
	LDR	R1, =U0RBR		; R1 -> U0RBR (Receiver Buffer Register)
	LDRB	R0, [R1]		; get received data
	BX	LR			; return

;
; put subroutine
; writes a character to the console
; parameters:
;	R0 - ASCII code of the character to write
; return value:
;	none
;
put	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
	LDRB	R1, [R1]		; wait until transmit
	ANDS	R1, R1, #0x20		; holding register
	BEQ	put			; empty
	LDR	R1, =U0THR		; R1 -> U0THR
	STRB	R0, [R1]		; output charcter
put0	LDR	R1, =U0LSR		; R1 -> U0LSR
	LDRB	R1, [R1]		; wait until
	ANDS	R1, R1, #0x40		; transmitter
	BEQ	put0			; empty (data flushed)
	BX	LR			; return

;
; puts subroutine
; writes the sequence of characters in a NULL-terminated string to the console
; parameters:
;	R0 - address of NULL-terminated ASCII string
; return value:
;	R0 - ASCII code of the character read on teh console (byte)
;
puts	STMFD	SP!, {R4, LR} 		; push R4 and LR
	MOV	R4, R0			; copy R0
puts0	LDRB	R0, [R4], #1		; get character + increment R4
	CMP	R0, #0			; 0?
	BEQ	puts1			; return
	BL	put			; put character
	B	puts0			; next character
puts1	LDMFD	SP!, {R4, PC} 		; pop R4 and PC


;
; hint! put the strings used by your program here ...
str_red
	DCB 0xA,"RED: choose a column for your next move (1-7, q to restart):",0xA, 0xD, 0xA, 0xD, 0

str_yellow
	DCB 0xA,"YELLOW: COMPUTER CHANCE:",0xA, 0xD, 0xA, 0xD, 0
str_game_over
	DCB "GAME OVER",0xA, 0xD, 0xA, 0xD, 0
;

str_go
	DCB	"Let's play Connect4!!",0xA, 0xD, 0xA, 0xD, 0

str_new
	DCB	"",0xA, 0xD, 0x0
str_count
	DCB "1 2 3 4 5 6 7",0xA, 0xD, 0xD, 0
str_full
	DCB "This column is full.Enter a different column number.",0xA, 0xD, 0xD, 0	

str_win DCB	"WIN",0xA, 0xD, 0xA, 0xD, 0

str_Y	DCB "	Y IS THE WINNER.",0xA, 0xD, 0xA, 0xD, 0
str_X	DCB "	R IS THE WINNER.",0xA, 0xD, 0xA, 0xD, 0

	


	END