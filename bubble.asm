    .org $0200

start:
    jsr init


init:
    lda #0
    ldx #0
    ldy #0
    rts

bubble:
    ; i: x, j: y
    pha
    txa
    pha
    tya
    pha

    ldx #(LEN - 1)
@L1:
    ldy #0
@L2:
    lda arr1, y
    cmp (arr1 + 1), y
    bmi @next           ; if arr[y] < arr[y + 1] then goto @next
    sta temp            ; temp = arr[y];
    ; arr[y] = arr[y + 1];
    lda (arr1 + 1), y
    sta arr1, y
    ; arr[y + 1] = temp;
    lda temp
    sta (arr1 + 1), y

@next:
    iny                 ; j++
    stx idx
    cpy idx             ; if (j < i) then goto @L2
    bne @L2

    dex                 ; i--
    cpx #0              ; if (i > 0) then goto @L1
    bne @L1

    pla
    tay
    pla
    tax
    pla
    rts

temp    .db 0
idx     .db 0
LEN = 10
dummy   .dsb 4
arr1    .db 5, 39, 11, 57, 4, 26, 92, 67, 0, 10
