    .org $0200
start:
    jsr init

    ; test multa, mult
    lda #10
    sta num1
    lda #7
    sta num2
    
    ; call multa
    lda #$12
    ldx #$34
    jsr multa

    ; call mult
    lda #$56
    ldx #$78
    jsr mult

    ; create multiplication table (9x9)
    ; for (num1 = 1; i <= 9; i++) {
    ;    for (num2 = 1; j <= 9; j++) {
    ;        arr[x] = result;
    ;        ++x;
    ;    }
    ; }
    lda #1
    ldx #0
    sta num1
    sta num2
L1:
L2:
    jsr mult
    lda result
    sta resultArr, x
    inc num2
    inx
    lda num2
    cmp #10
    bne L2
    lda #1
    sta num2
    inc num1
    lda num1
    cmp #10
    bne L1

    ;jmp start
forever:
    jmp forever

init:
    lda #0
    ldx #0
    ldy #0
    sta num1
    sta num2
    sta result
clrMem:
    sta resultArr, x
    inx
    cpx #ARR_LENGTH
    bne clrMem
    ldx #0
    rts ; end of init

multa:
    clc
    lda #0
    ldx #0
multaLoop:
    adc num1
    inx
    cpx num2
    bne multaLoop
    rts

mult:
    pha ; push a
    txa ; push x
    pha
    jsr multa
    sta result
    pla ; pop x
    tax
    pla ; pop a
    rts


; data definition
ARR_LENGTH = 81
num1:
    .db 0
num2:
    .db 0
result:
    .db 0
resultArr:
    .dsb ARR_LENGTH - 1
    .db $ff
boundTest: ; for boundary check
    .db $ab, $cd, $ef