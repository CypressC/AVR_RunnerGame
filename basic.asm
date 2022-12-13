;================================================================
.org 0
	  JMP MAIN
.org 0x04
	  JMP INT1_ISR
;================================================================
.org $150
MAIN:
	  LDI R16,HIGH(RAMEND)
	  OUT SPH,R16
	  LDI R20,LOW(RAMEND)  
	  OUT SPL,R16			  ;initialize stack

      LDI   R16, 0xF0
      OUT   DDRD, R16         ;set ports D4-D7 o/p for data
	  LDI	R16, 0x03
      OUT   DDRB, R16         ;set port B0 and B1 o/p for command and B2-7 for input
      CBI   PORTB, 0          ;EN = 0
      RCALL delay_ms          ;wait for LCD power on
      ;-----------------------------------------------------
      RCALL LCD_init          ;subroutine to initialize LCD
      ;-----------------------------------------------------
	  ;LDI R20,0				  ;holds the scene
	  ;-----------------------------------------------------
again:RCALL start      ;subroutine to display message
      ;-----------------------------------------------------
      LDI   R16, 0x01         ;clear LCD
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
      LDI   R16, 0x33         ;init LCD for 4-bit data
      RCALL command_wrt       ;send to command register
      RCALL delay_ms
      LDI   R16, 0x32         ;init LCD for 4-bit data
      RCALL command_wrt
      RCALL delay_ms
      LDI   R16, 0x28         ;LCD 2 lines, 5x7 matrix
      RCALL command_wrt
      RCALL delay_ms
      LDI   R16, 0x0C         ;disp ON, cursor OFF
      RCALL command_wrt
      LDI   R16, 0x01         ;clear LCD
      RCALL command_wrt
      RCALL delay_ms
      LDI   R16, 0x06         ;shift cursor right
      RCALL command_wrt
      RET  
;================================================================
command_wrt:
      MOV   R27, R16
      ANDI  R27, 0xF0         ;mask low nibble & keep high nibble
      OUT   PORTD, R27        ;o/p high nibble to port D
      CBI   PORTB, 1          ;RS = 0 for command
      SBI   PORTB, 0          ;EN = 1
      RCALL delay_short       ;widen EN pulse
      CBI   PORTB, 0          ;EN = 0 for H-to-L pulse
      RCALL delay_us          ;delay in micro seconds
      ;----------------------------------------------------
      MOV   R27, R16
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
      MOV   R27, R16
      ANDI  R27, 0xF0         ;mask low nibble & keep high nibble
      OUT   PORTD, R27        ;o/p high nibble to port D
      SBI   PORTB, 1          ;RS = 1 for data
      SBI   PORTB, 0          ;EN = 1
      RCALL delay_short       ;make wide EN pulse
      CBI   PORTB, 0          ;EN = 0 for H-to-L pulse
      RCALL delay_us          ;delay in micro seconds
      ;----------------------------------------------------
      MOV   R27, R16
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
      LDI   R16, 'P'          ;start screen
      RCALL data_wrt          ;via data register
      RCALL delay_seconds     ;delay 0.25s
      LDI   R16, 'r'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 'e'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 's'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 's'
	  RCALL data_wrt
      RCALL delay_seconds
      ;----------------
      LDI   R16, ' '
      RCALL data_wrt
      ;----------------
      LDI   R16, 'b'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 'u'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 't'
      RCALL data_wrt
	  RCALL delay_seconds
	  LDI   R16, 't'
      RCALL data_wrt
	  RCALL delay_seconds
	  LDI   R16, 'o'
      RCALL data_wrt
	  RCALL delay_seconds
	  LDI   R16, 'n'
      RCALL data_wrt
      RCALL delay_seconds
      ;----------------
      LDI   R16, 0xC0         ;cursor beginning of 2nd line
      RCALL command_wrt
      RCALL delay_ms
      ;----------------
      LDI   R16, 't'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 'o'
      RCALL data_wrt
      RCALL delay_seconds
	  ;----------------
      LDI   R16, ' '
      RCALL data_wrt
      ;----------------
      LDI   R16, 'b'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 'e'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 'g'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 'i'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 'n'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, '!'
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
	  LDI   R16, ' '
      RCALL data_wrt
      ;----------------
	  LDI   R16, ' '
      RCALL data_wrt
      ;----------------
	  LDI   R16, ' '
      RCALL data_wrt
      ;----------------
	  LDI   R16, 'G'
      RCALL data_wrt
	  LDI   R16, 'A'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'M'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'E'
      RCALL data_wrt
      RCALL delay_seconds
	  ;-------------------
	  LDI   R16, ' '
      RCALL data_wrt
      RCALL delay_seconds
	  ;-------------------
	  LDI   R16, 'O'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'V'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'E'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'R'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, '!'
      RCALL data_wrt
      RCALL delay_seconds
	  ;----------------
      LDI   R16, 0xC0         ;cursor beginning of 2nd line
      RCALL command_wrt
      RCALL delay_ms
	  ;----------------
      LDI   R16, 'H'
      RCALL data_wrt
      RCALL delay_seconds
      LDI   R16, 'i'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, ' '
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'S'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'c'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'o'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'r'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, 'e'
      RCALL data_wrt
      RCALL delay_seconds
	  LDI   R16, ':'
      RCALL data_wrt
      RCALL delay_seconds
	  RCALL read_EEPROM
	  RCALL data_wrt

	  LDI   R17, 12           ;wait 3 seconds
loop1:RCALL delay_seconds
	  SBIC PIND,2			  ;check if button is pressed
	  RCALL MAIN		  ; IF button is pressed jump to next screen
      DEC   R17
      BRNE  loop1
	  RET
;========================================================================
gameplay:
      ;-----------------------------------------------------
      RCALL LCD_init          ;subroutine to initialize LCD
	 ;-----------------------------------------------------
	  LDI R20, 0
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
	  STS TIMSK1,R20 ;enable Timer1 compare match interrupt  
	  LDI R23, (1<<ISC11)
	  STS EICRA, R23 ;check
	  SBI PORTD, 2
	  LDI R23,1<<INT1 ; EDGE TRIGGERED
	  OUT EIMSK, R23 ; check
	  SEI ;set I (enable interrupts globally) 
	  RCALL generate_terrain
	  LDI R16, 0x80
	  RCALL command_wrt

return:				;subroutine to display message
	  
	  ;RCALL generate_bro
	  LDI R16, 0x18
	  RCALL command_wrt
	  LDI R16, 0x14
	  RCALL command_wrt
	  RCALL delay_seconds
	  INC R20
HERE: 
	  SBIC PIND,2			  ;check if button is pressed
	  RCALL end_game
	  RCALL return		  ; IF button is pressed jump to next screen
	  RET

generate_bro:
	  MOV R16,R23
	  RCALL command_wrt
	  LDI R16,' '
	  RCALL data_wrt
	  INC R23
	  MOV R16,R23
	  RCALL command_wrt
	  LDI R16,0b10101011
	  RCALL data_wrt
	  RET

generate_terrain:
	  LDI R16, 0xC8
	  RCALL command_wrt
      LDI   R16, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;----------------------------------------------------------------
	  LDI R16, 0xC9
	  RCALL command_wrt
      LDI   R16, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;-----------------------------------------------------------------
	  LDI R16, 0xCA
	  RCALL command_wrt
      LDI   R16, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;-----------------------------------------------------------------
	  LDI R16, 0xCB
	  RCALL command_wrt
      LDI   R16, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;------------------------------------------------------------------
	  LDI R16, 0x84
	  RCALL command_wrt
      LDI   R16, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;------------------------------------------------------------------
	  LDI R16, 0x85
	  RCALL command_wrt
      LDI   R16, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;------------------------------------------------------------------
	  LDI R16, 0x86
	  RCALL command_wrt
      LDI   R16, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
      ;------------------------------------------------------------------
	  LDI R16, 0x87
	  RCALL command_wrt
      LDI   R16, 0b11111111          ;display characters
      RCALL data_wrt          ;via data register
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
    ;LDI   R16, 0b11001101   ;byte to be written to EEPROM
    OUT   EEDR, R16         ;via data reg
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
    IN    R16, EEDR         ;get byte from data register
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
.org $300
INT1_ISR:
	MOV R16, R24
	RCALL command_wrt
	LDI R16, ' '
	RCALL data_wrt
	;RCALL delay_seconds
	MOV R16, R25
	RCALL command_wrt
	LDI R16, 0b10101011
	RCALL data_wrt
	LDI R26, (1<<ISC11)
	STS EICRA, R26 ;CHECK
	SBI PORTD, 2
	LDI R23,1<<INT1 ; EDGE TRIGGERED
	OUT EIMSK, R26 ; CHECK
	SEI ; ENABLE INTERUPTS
	MOV R26, R24
	MOV R24, R25 
	MOV R25, R26 ;SWAP POSITION
	RCALL delay_seconds
	RETI

;---ISR for Timer1 (It comes here after elapse of 1 second time)  
T1_CM_ISR:  
	   
	  RETI ;return from interrupt
