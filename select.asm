    .org $0200
start:
    jsr init
    jsr select

forever:
    jmp forever

init:
    lda #0
    ldx #0
    ldy #0
    rts

maxIdx:
    pha
    txa
    pha

    lda #0
    sta idx
    
    ldx #1          ; x = 1
    lda arr1        ; max = arr[0]
@loop:
    cmp arr1, x
    bpl @next       ; if max >= arr[x] then goto @next
    lda arr1, x
    stx idx
@next:
    inx
    cpx maxIdxLen
    bne @loop       ; if x < len then goto @loop

    pla
    tax
    pla
    rts

select:
    pha
    txa
    pha
    tya
    pha

    ldx #(len - 1)
@loop:
    ; idx = maxIdx(arr, last + 1);
    stx maxIdxLen
    inc maxIdxLen
    jsr maxIdx

    ldy idx         ; y = idx
    lda arr1, x     ; a = arr1[x]
    sta temp        ; temp = arr1[x]
    lda arr1, y     ; a = arr1[y]
    sta arr1, x     ; arr1[x] = arr1[idx]
    lda temp
    sta arr1, y     ; arr1[idx] = temp

    dex
    bne @loop

    pla
    tay
    pla
    tax
    pla
    rts

len = 10
maxIdxLen: .db 0
idx: .db 0 ; maxIdx
temp: .db 0
dummy: .db $0, $0, $0, $0
arr1: .db $11, $08, $01, $40, $22, $67, $7a, $04, $5b, $4f
; 01 04 08 11 22 40, 4f, 5b, 67 7a