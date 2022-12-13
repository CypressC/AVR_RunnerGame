;
; FinalProject.asm
;
; Created: 12/2/2022 8:38:44 PM
; Author : Cypress
;================================================================
.org 0
	  JMP MAIN
.org 0x04
	  JMP INT1_ISR
;================================================================
.org $150
MAIN:
	  LDI R30,HIGH(RAMEND)
	  OUT SPH,R30
	  LDI R20,LOW(RAMEND)  
	  OUT SPL,R30			  ;initialize stack

      LDI   R30, 0xF0
      OUT   DDRD, R30         ;set ports D4-D7 o/p for data
	  LDI	R30, 0x03
      OUT   DDRB, R30         ;set port B0 and B1 o/p for command and B2-7 for input
      CBI   PORTB, 0          ;EN = 0
      RCALL delay_ms          ;wait for LCD power on
      ;-----------------------------------------------------
      RCALL LCD_init          ;subroutine to initialize LCD
      ;-----------------------------------------------------
again:RCALL start      ;subroutine to display message
      ;-----------------------------------------------------
      LDI   R30, 0x01         ;clear LCD
      RCALL command_wrt       ;send command code
      RCALL delay_ms
      ;-----------------------------------------------------
      LDI   R17, 4            ;wait 1 second
l1:   RCALL delay_seconds
      DEC   R17
      BRNE  l1
      ;-----------------------------------------------------
      RJMP  again             ;jump to again for another run
;================================================================
LCD_init:
      LDI   R30, 0x33         ;init LCD for 4-bit data
      RCALL command_wrt       ;send to command register
      RCALL delay_ms
      LDI   R30, 0x32         ;init LCD for 4-bit data
      RCALL command_wrt
      RCALL delay_ms
      LDI   R30, 0x28         ;LCD 2 lines, 5x7 matrix
      RCALL command_wrt
      RCALL delay_ms
      LDI   R30, 0x0C         ;disp ON, cursor OFF
      RCALL command_wrt
      LDI   R30, 0x01         ;clear LCD
      RCALL command_wrt
      RCALL delay_ms
      LDI   R30, 0x06         ;shift cursor right
      RCALL command_wrt
      RET  
;================================================================
command_wrt:
      MOV   R27, R30
      ANDI  R27, 0xF0         ;mask low nibble & keep high nibble
      OUT   PORTD, R27        ;o/p high nibble to port D
      CBI   PORTB, 1          ;RS = 0 for command
      SBI   PORTB, 0          ;EN = 1
      RCALL delay_short       ;widen EN pulse
      CBI   PORTB, 0          ;EN = 0 for H-to-L pulse
      RCALL delay_us          ;delay in micro seconds
      ;----------------------------------------------------
      MOV   R27, R30
      SWAP  R27               ;swap nibbles
      ANDI  R27, 0xF0         ;mask low nibble & keep high nibble
      OUT   PORTD, R27        ;o/p high nibble to port D
      SBI   PORTB, 0          ;EN = 1
      RCALL delay_short       ;widen EN pulse
      CBI   PORTB, 0          ;EN = 0 for H-to-L pulse
      RCALL delay_us          ;delay in micro seconds
      RET
;================================================================
data_wrt:
      MOV   R27, R30
      ANDI  R27, 0xF0         ;mask low nibble & keep high nibble
      OUT   PORTD, R27        ;o/p high nibble to port D
      SBI   PORTB, 1          ;RS = 1 for data
      SBI   PORTB, 0          ;EN = 1
      RCALL delay_short       ;make wide EN pulse
      CBI   PORTB, 0          ;EN = 0 for H-to-L pulse
      RCALL delay_us          ;delay in micro seconds
      ;----------------------------------------------------
      MOV   R27, R30
      SWAP  R27               ;swap nibbles
      ANDI  R27, 0xF0         ;mask low nibble & keep high nibble
      OUT   PORTD, R27        ;o/p high nibble to port D
      SBI   PORTB, 0          ;EN = 1
      RCALL delay_short       ;widen EN pulse
      CBI   PORTB, 0          ;EN = 0 for H-to-L pulse
      RCALL delay_us          ;delay in micro seconds
      RET
;================================================================
start:
      LDI   R30, 'P'          ;start screen
      RCALL data_wrt          ;via data register
      RCALL delay_seconds     ;delay 0.25s
      LDI   R30, 'r'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 'e'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 's'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 's'
	  RCALL data_wrt
      RCALL delay_seconds
      ;----------------
      LDI   R30, ' '
      RCALL data_wrt
      ;----------------
      LDI   R30, 'b'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 'u'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 't'
      RCALL data_wrt
	  RCALL delay_seconds
	  LDI   R30, 't'
      RCALL data_wrt
	  RCALL delay_seconds
	  LDI   R30, 'o'
      RCALL data_wrt
	  RCALL delay_seconds
	  LDI   R30, 'n'
      RCALL data_wrt
      RCALL delay_seconds
      ;----------------
      LDI   R30, 0xC0         ;cursor beginning of 2nd line
      RCALL command_wrt
      RCALL delay_ms
      ;----------------
      LDI   R30, 't'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 'o'
      RCALL data_wrt
      RCALL delay_seconds
	  ;----------------
      LDI   R30, ' '
      RCALL data_wrt
      ;----------------
      LDI   R30, 'b'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 'e'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 'g'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 'i'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 'n'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, '!'
      RCALL data_wrt
	  RCALL delay_seconds
	  
      ;----------------
      LDI   R17, 12           ;wait 3 seconds
l2:   RCALL delay_seconds
	  SBIC PIND,2			  ;check if button is pressed
	  RCALL gameplay		  ; IF button is pressed jump to next screen
      DEC   R17
      BRNE  l2
      RET

	  ;=====================================================
end_game:
	  CLI
	  RCALL LCD_init
	  LDI   R30, ' '
      RCALL data_wrt
      ;----------------
	  LDI   R30, ' '
      RCALL data_wrt
      ;----------------
	  LDI   R30, ' '
      RCALL data_wrt
      ;----------------
	  LDI   R30, 'G'
      RCALL data_wrt
	  LDI   R30, 'A'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'M'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'E'
      RCALL data_wrt
      RCALL delay_seconds
	  ;-------------------
	  LDI   R30, ' '
      RCALL data_wrt
      RCALL delay_seconds
	  ;-------------------
	  LDI   R30, 'O'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'V'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'E'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'R'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, '!'
      RCALL data_wrt
      RCALL delay_seconds
	  ;----------------
      LDI   R30, 0xC0         ;cursor beginning of 2nd line
      RCALL command_wrt
      RCALL delay_ms
	  ;----------------
      LDI   R30, 'H'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R30, 'i'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, ' '
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'S'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'c'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'o'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'r'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, 'e'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R30, ':'
      RCALL data_wrt
      RCALL delay_seconds
	  RCALL read_EEPROM
	  RCALL data_wrt

	  LDI   R17, 120           ;wait
	  
loop1:RCALL delay_seconds
	  SBIC PIND,2			  ;check if button is pressed
	  RCALL MAIN		  ; IF button is pressed jump to next screen
	  DEC   R17
      BRNE  loop1
	  RCALL MAIN
	  RET
;========================================================================
gameplay:
      ;-----------------------------------------------------
      RCALL LCD_init          ;subroutine to initialize LCD
	 ;-----------------------------------------------------
	  LDI R24, 0xC0
	  LDI R25, 0x80 ;set start position
	  LDI R23,0x80			;set player origin
	  ;LDI R18 , 10 
	  LDI R20,HIGH(7812) ;the high byte  
	  STS OCR1AH,R20 ;Temp = 0x3D (high byte of 15624)  
	  LDI R20,LOW(7812) ;the low byte  
	  STS OCR1AL,R20 ;OCR1A = 15624  
	  LDI R20,0x00  
	  STS TCCR1A,R20  
	  LDI R20,0xD  
	  STS TCCR1B,R20 ;prescaler 1:1024, CTC mode  
	  LDI R20,(1<<OCIE1A)  
	  ;STS TIMSK1,R20 ;enable Timer1 compare match interrupt  
	  LDI R23, (1<<ISC11)
	  STS EICRA, R23 ;check
	  SBI PORTD, 2
	  LDI R23,1<<INT1 ; EDGE TRIGGERED
	  OUT EIMSK, R23 ; check
	  SEI ;set I (enable interrupts globally) 
	  LDI R17,0x15		 ;keeps offset
	  LDI R29,0x0		 ;keeps score
reset:	
	  LDI R18, 0
	  
return:				;subroutine to display message  
	  RCALL generate_top
	  RCALL delay_seconds
	  RCALL delay_seconds
	  INC R18		 ;increment location
	  INC R29		 ;increment score
	  CP R17,R18	 ;checks if obstacles are clear of screen
	  BREQ reset	 ;resets counter
	  SBIC PIND,2			  ;check if button is pressed
	  RCALL end_game ; IF button is pressed jump to next screen  
	  RCALL return

generate_top:
	  LDI R30, 0x8F
	  SUB R30,R18
	  RCALL collision
	  RCALL command_wrt
      LDI   R30, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;------------------------------------------------------------------
	  LDI R30, 0x91
	  SUB R30,R18
	  RCALL collision
	  RCALL command_wrt
      LDI   R30, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;------------------------------------------------------------------
	  LDI R30, 0x92
	  SUB R30,R18
	  RCALL collision
	  RCALL command_wrt
      LDI   R30, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;------------------------------------------------------------------
	  LDI R30, 0x93
	  SUB R30,R18
	  RCALL collision
	  RCALL command_wrt
      LDI   R30, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
	  ;-----------------------------------------------------------------
	  LDI R30, 0x94
	  SUB R30,R18
	  RCALL command_wrt
	  LDI R30, ' '
	  RCALL data_wrt
	  ;-----------------------------------------------------------------
	  LDI R30, 0x95
	  SUB R30,R18
	  RCALL command_wrt
	  LDI R30, ' '
	  RCALL data_wrt
	  ;-----------------------------------------------------------------
	  RET

generate_bot:
	  LDI R30, 0xD0
	  SUB R30,R18
	  RCALL collision
	  RCALL command_wrt
      LDI   R30, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;----------------------------------------------------------------
	  LDI R30, 0xD1
	  SUB R30,R18
	  RCALL collision
	  RCALL command_wrt
      LDI   R30, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;-----------------------------------------------------------------
	  LDI R30, 0xD2
	  SUB R30,R18
	  RCALL collision
	  RCALL command_wrt
      LDI   R30, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;-----------------------------------------------------------------
	  LDI R30, 0xD3
	  SUB R30,R18
	  RCALL collision
	  RCALL command_wrt
      LDI   R30, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;-----------------------------------------------------------------
	  LDI R30, 0xD4
	  SUB R30,R18
	  RCALL command_wrt
	  LDI R30, ' '
	  RCALL data_wrt
	  ;-----------------------------------------------------------------
	  LDI R30, 0xD5
	  SUB R30,R18
	  RCALL command_wrt
	  LDI R30, ' '
	  RCALL data_wrt
	  ;-----------------------------------------------------------------
	  RET

collision:
	  CP R30,R24
	  BRNE safe
	  RCALL end_game
safe:
	  RET


;========================================================================
prog_EEPROM:
l8: SBIC EECR, 1
    RJMP l8                 ;wait until EEWE becomes zero
    ;-----------------------------------------------------------
    ;WRITE TO EEPROM
    ;---------------
    LDI   R18, 0x00         ;high byte of address 005FH
    LDI   R17, 0x5F         ;low byte of address 005FH
    OUT   EEARH, R18        ;store high byte of address       
    OUT   EEARL, R17        ;store low byte of address
    ;LDI   R30, 0b11001101   ;byte to be written to EEPROM
    OUT   EEDR, R30         ;via data reg
    SBI   EECR, 2           ;EEMWE = 1
    SBI   EECR, 1           ;EEWE = 1: write byte to EEPROM
    ;----------------------------------------------------------
l9: SBIC EECR, 1
    RJMP l9               ;wait until EEPROM is ready
	RET
	;==========================================================
read_EEPROM:
    ;----------------
    SBI   EECR, 0           ;EERE = 1: read byte from EEPROM
    IN    R30, EEDR         ;get byte from data register
    RET
	;
	
;================================================================
delay_short:
      NOP
      NOP
      RET
;------------------------

delay_us:
      LDI   R20, 90
l3:   RCALL delay_short
      DEC   R20
      BRNE  l3
      RET
;-----------------------
delay_ms:
      LDI   R21, 40
l4:   RCALL delay_us
      DEC   R21
      BRNE  l4
      RET
;================================================================
delay_seconds:        ;nested loop subroutine (max delay 3.11s)
    LDI   R20, 255    ;outer loop counter 
l5: LDI   R21, 255    ;mid loop counter
l6: LDI   R22, 20     ;inner loop counter to give 0.25s delay
l7: DEC   R22         ;decrement inner loop
    BRNE  l7          ;loop if not zero
    DEC   R21         ;decrement mid loop
    BRNE  l6          ;loop if not zero
    DEC   R20         ;decrement outer loop
    BRNE  l5          ;loop if not zero
    RET               ;return to caller


;----------------------------------------------------------------
;------------------- Timer1 delay  
DELAY_1s:  
	 LDI R20,HIGH (15625-1)  
	 STS OCR1AH,R20 ;TEMP = $3D (since 15624 = $3D08)  
	 LDI R20,LOW (15625-1)  
	 STS OCR1AL,R20 ;OCR1AL = $08 (since 15624 = $3D08)  
	 LDI R20,0  STS TCNT1H,R20 ;TEMP = 0x00  
	 STS TCNT1L,R20 ;TCNT1L = 0x00, TCNT1H = TEMP  
	 LDI R20,0x00 
	 STS TCCR1A,R20 ;WGM11:10 = 00  
	 LDI R20,0x5 
	 STS TCCR1B,R20 ;WGM13:12=00, Normal mode, CS=CLK/1024  
AGAIN2:
	 SBIS TIFR1,OCF1A ;if OCF1A is set skip next instruction  
	 RJMP AGAIN2 
	 LDI R19,0  
	 STS TCCR1B,R19 ;stop timer  
	 STS TCCR1A,R19  
	 LDI R20,1<<OCF1A  
	 OUT TIFR1,R20 ;clear OCF1A flag  
	 RET
;-----------------------------------------------------------------
.org $300
INT1_ISR:
	MOV R30, R24
	RCALL command_wrt
	LDI R30, ' '
	RCALL data_wrt
	;RCALL delay_seconds
	MOV R30, R25
	RCALL command_wrt
	LDI R30, 0b10101011
	RCALL data_wrt
	LDI R23, (1<<ISC11)
	STS EICRA, R23 ;CHECK
	SBI PORTD, 2
	LDI R23,1<<INT1 ; EDGE TRIGGERED
	OUT EIMSK, R23 ; CHECK
	;SEI ; ENABLE INTERUPTS
	MOV R23, R24
	MOV R24, R25 
	MOV R25, R23 ;SWAP POSITION
	RCALL delay_seconds
	RETI

;---ISR for Timer1 (It comes here after elapse of 1 second time)  
T1_CM_ISR:  
	   
	  RETI ;return from interrupt
