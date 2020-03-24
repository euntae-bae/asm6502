    .org $0200
start:
    jsr clrMem

    clc         ; C=0
    lda #$10
    adc #$20    ; A=$30, C=0
    sta add1
    
    sec         ; C=1
    lda #$10
    adc #$20    ; A=$31, C=0
    sta adc1

    clc         ; C=0
    lda #$f0
    adc #$30    ; A=$20, C=1
    sta add2

    sec         ; C=1
    lda #$f0
    adc #$30    ; A=$21, C=1
    sta adc2

    sec         ; C=1
    lda #$a
    sbc #$5     ; A=$5, C=1
    sta sub1

    clc         ; C=0
    lda #$a
    sbc #$5     ; A=$4, C=1
    sta sbc1

    sec         ; C=1
    lda #$5
    sbc #$a     ; A=$fb, C=0
    sta sub2

    clc         ; C=0
    lda #$5
    sbc #$a     ; A=$fa, C=0
    sta sbc2

    jmp start

clrMem:
    pha
    txa
    pha
    lda #0
    ldx #(sbc2-add1) ; A2 07
@loop:
    sta add1, x
    dex
    bpl @loop
    pla
    tax
    pla
    rts ; 60

add1 .db $ff
adc1 .db $ff
add2 .db $ff
adc2 .db $ff
sub1 .db $ff
sbc1 .db $ff
sub2 .db $ff
sbc2 .db $ff