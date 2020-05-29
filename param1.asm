    .org $0200
start:
    lda #0
    ldx #$ff
    txs

    lda #$10
    pha
    lda #$20
    pha
    jsr func1
    pla
    pla

loop:
    jmp loop

func1:
    pha
    txa
    pha
    tsx
    txa
    clc
    adc #6
    tax
    lda $0100, x
    sta num1
    dex
    lda $0100, x
    sta num2
    pla
    tax
    pla
    rts

; variables
num1 .db 0
num2 .db 0