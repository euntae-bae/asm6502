    .org $0200
    ; Set IRQ/BRK Interrupt Vector
    lda #<ISR ; ISR의 하위 바이트
    sta $FFFE
    lda #>ISR ; ISR의 상위 바이트
    sta $FFFF

start:
    jsr init
    jsr setNum
    lda #$12
    jsr addNum
    ldx result
    lda #$34
    jsr subNum
    ldy result

    brk

    jmp start

init:
    lda #0
    ldx #0
    ldy #0
    sta num1
    sta num2
    sta result
    rts

setNum:
    pha
    lda #$10
    sta num1
    lda #$20
    sta num2
    pla
    rts

addNum:
    pha
    lda num1
    clc
    adc num2
    sta result
    pla
    rts

subNum:
    pha
    lda num1
    sec
    sbc num2
    sta result
    pla
    rts

num1:
    .db 0
num2:
    .db 0
result:
    .db 0

ISR:
    lda #$aa
    ldx #$bb
    ldy #$cc
    rti

; BRK Interrupt Vector ($FFFE-$FFFF)
;    .org $fffe
;    .dw ISR