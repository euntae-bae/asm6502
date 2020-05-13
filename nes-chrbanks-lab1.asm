    .inesprg 1  ; 1 x 16KB PRG code
    .ineschr 2  ; 2 x 8KB CHR data
    .inesmap 3  ; mapper 3 = CNROM, 8KB CHR bank swapping
    .inesmir 1  ; background mirroring

    .bank 0
    .org $c000
RESET:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010

vblankwait1:
    bit $2002
    bpl vblankwait1 ; bit 7: VBlank Flag

clrmem:
    lda #$00
    sta $0000, x
    sta $0100, x
    sta $0200, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #$fe
    sta $0300, x
    inx
    bne clrmem

vblankwait2:
    bit $2002
    bpl vblankwait2

; $2006: PPUADDR, $2007: PPUDATA
loadPalettes:
    lda $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    ldx #$00
.loop:
    lda palette, x
    sta $2007
    inx
    cpx #$20
    bne .loop

loadSprites:
    ldx #$00
.loop:
    lda sprites, x
    sta $0200, x
    inx
    cpx #$20
    bne .loop

    lda #$80    ; VBlank(NMI) enable, Sprite Pattern Table Address: $0000
    sta $2000

    lda #$10
    sta $2001   ; enable sprite

Forever:
    jmp Forever

NMI:
    lda #$00
    sta $2003
    lda #$02
    sta $4014

latchController:
    lda #$01
    sta $4016
    lda #$00
    sta $4016

readA:
    lda $4016
    and #$01
    beq .done

    lda $0203
    clc
    adc #$01
    sta $0203
.done:

readB:
    lda $4016
    and #$01
    beq .done

    lda $0203
    sec
    sbc #$01
    sta $0203
.done:

readSelect:
    lda $4016
    and #$01
    beq .done
    lda #$00
    ; change to graphics bank 0
    lda #$00
    sta $9000
.done:

readStart:
    lda $4016
    and #$01
    beq .done
    ; change to graphics bank 1
    lda #$01
    sta $a000
.done:

    rti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bankSwitch:
    tax
    sta bankValues, x   ; new bank to use
    rts

bankValues: ; bank numbers
    .db $00, $01, $02, $03


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .bank 1
    .org $e000
palette:
    .db $22, $29, $1a, $0f, $0f, $36, $17, $0f, $0f, $30, $21, $0f, $0f, $27, $17, $0f
    .db $22, $16, $27, $18, $0f, $1a, $30, $27, $0f, $16, $30, $27, $0f, $0f, $36, $17

sprites:
    .db $80, $32, $00, $80  ; sprite 0
    .db $80, $33, $00, $88  ; sprite 1
    .db $88, $34, $00, $80  ; sprite 2
    .db $88, $35, $00, $88  ; sprite 3

    .org $fffa
    .dw NMI
    .dw RESET
    .dw 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .bank 2
    .org $0000
    .incbin "mario0.chr"

    .bank 3
    .org $0000
    .incbin "mario1.chr"