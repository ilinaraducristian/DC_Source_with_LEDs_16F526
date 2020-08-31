#include "p16f526.inc"

    __CONFIG _FOSC_INTRC_RB4 & _WDTE_OFF & _CP_OFF & _MCLRE_OFF & _IOSCFS_4MHz & _CPDF_OFF

GPR_VAR	    UDATA
c1	    RES	1
time	    RES	1
time_off    RES	1

RES_VECT  CODE    0x0000
    GOTO    START

MAIN_PROG CODE

START

    clrf    TMR0
    movlw   b'11010010'
    option
    
    movlw   b'01111001'
    movwf   ADCON0
    
    movlw   b'01000000'
    movwf   CM1CON0
    movwf   CM2CON0
    
    movlw   b'00001100'
    tris    PORTB
    clrf    PORTB
    
    movlw   .0
    tris    PORTC
    clrf    PORTC

mainloop
    
    call    convert_adc
    
    movf    ADRES,0
; Turn on/off LEDs based on ADRES value
; PORTC<5:0> has ADRES<5:0> and PORTB<5:4> has ADRES<7:6>
    movwf   PORTC

if1
    btfsc   ADRES,6
    goto    else1
    bcf	    PORTB,4
    goto    fi1
else1
    bsf	    PORTB,4
fi1

if2
    btfsc   ADRES,7
    goto    else2
    bcf	    PORTB,5
    goto    fi2
else2
    bsf	    PORTB,5
fi2

; PWM
    
    movf    ADRES,0
    movwf   time_off
    comf    time_off,1
    
    bsf	    PORTB,0
    movwf   time
    call    tm1
    
    bcf	    PORTB,0
    movf    time_off,0
    movwf   time
    call    tm1
    goto mainloop
    
convert_adc
    call adc_wait_time
    bsf     ADCON0, 1
convert_adc_loop
    btfsc   ADCON0, 1
    goto    convert_adc_loop
    retlw   0

adc_wait_time
    movlw   .255
    movwf   c1
adc_wait_time_et1
    decfsz  c1,1
    goto    adc_wait_time_et1
    retlw   0

tm1
    call    tm_timer
    decfsz  time,1
    goto    tm1
    retlw   0
    
tm_timer ; 1ms delay
    movlw   .5
    movwf   TMR0
    bcf	    STATUS,2
    
tm_timer_et1
    movf    TMR0,0
    btfss   STATUS,2
    goto    tm_timer_et1
    retlw   0
    
;tm1 ; 500ms
;    movlw   b'11010111'
;    option
;    movlw   .10
;    movwf   c1
;tm1_et1
;    movlw   .1
;    movwf   TMR0
;    bcf	    STATUS,2
;
;tm1_et2
;    movf    TMR0,0
;    btfss   STATUS,2
;    goto    tm1_et2
;    
;    decfsz  c1,1
;    goto    tm1_et1
;    
;    movlw   b'11010101'
;    option
;    
;    movlw   .21
;    movwf   TMR0
;    bcf	    STATUS,2
;
;tm1_et3
;    movf    TMR0,0
;    btfss   STATUS,2
;    goto    tm1_et3
;    
;    retlw   0
    
    END
    
    
    
    
;__time_on
;    movf    time_on,0
;    movwf   c1
;__et1
;    decfsz  c1,1
;    goto    __et1
;    retlw   0
;    
;__time_off
;    movf    time_off,0
;    movwf   c1
;__et2
;    decfsz  c1,1
;    goto    __et2
;    retlw   0