    .org $0200
start:
    lda #0
    lda #$7f
    lda #$80
    lda #$ff
    lda #1
@forever:
    jmp @forever