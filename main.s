#include <xc.inc>

global	pulse_length1, pulse_length2, best_high_word,best_low_word
    
extrn	motor_Setup, move_motor1, move_motor2	    ; external motor subroutines
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex ; external LCD subroutines
extrn	ADC_Setup, ADC_Read			    ; exernal anolog to digital conveter subroutines

psect	udata_acs   ; reserve data space in access ram
counter:       ds 1 ; reserve one byte for a counter variable
delay_count:   ds 1 ; reserve one byte for counter in the delay routine
best_low_word: ds 1 ; reserve one byte for the best high word
best_high_word:ds 1 ; reserve one byt for the byte low word
high_word:     ds 1 ; reserve one byte for high word of LDR input
low_word:      ds 1 ; reserve one byte for low word of LDR input
pulse_length1: ds 1 ; reserve 1 byte for duty cycl of motor 1  
pulse_length2:	ds 1	; reserve 1 byte for duty cycle of motor 2
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call	motor_Setup	; setup motors
	call	LCD_Setup	; setup UART
	call	ADC_Setup	; setup ADC
	goto	start
	
	
; ******* Main programme ****************************************
start:
	movlw	14
	movwf	pulse_length1, A
	call	move_motor1
	movlw	14
	movwf	pulse_length2, A
	call	move_motor2
	call	ADC_Read
	call	start_LDR
	call	ADC_Setup
	call	ADC_Read
	call	LDR_compare_loop

	
    
    
start_LDR:		; read in value of LDR from port RA0
	movf	ADRESH, W, A		; read in high word
	movwf	best_high_word, A
	movf	ADRESL, W, A
	movwf	best_low_word, A
	return
	
LDR_compare_loop:
	
	movf	ADRESH, W, A
	cpfslt	best_high_word, A
	call	high_word_comp
	cpfseq	best_high_word, A
	return
	call	low_word_comp
	return
	

high_word_comp:
	movwf	best_high_word, A
	movf	ADRESL, W, A
	movwf	best_low_word, A
	return
low_word_comp:
	
	movf	ADRESL, W, A
	cpfslt	best_low_word, A
	movwf	best_low_word, A
	return
	
	end	 rst
