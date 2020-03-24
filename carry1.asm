    .org $0200
start:
    sec
    lda #$8
    sbc #$4

    clc
    lda #$8
    sbc #$4

    jmp start