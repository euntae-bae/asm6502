; Nerdy Nights - week 6
; background2.asm based nes-controller-lab2.asm
    .inesprg 1
    .ineschr 1
    .inesmap 0
    .inesmir 1

    .rsset $0000
btn     .rs 1
temp    .rs 1

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
    bpl vblankwait1

clrmem:
    lda #$00
    sta $0000, x
    sta $0100, x
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #$fe
    sta $0200, x
    inx
    bne clrmem

vblankwait2:
    bit $2002
    bpl vblankwait2

loadPalettes:
    lda $2002
    lda #$3f
    sta $2006   ; $2006: PPUADDR
    lda #$00
    sta $2006
    ldx #$00
.loop:
    lda palette, x
    sta $2007   ; $2007: PPUDATA
    inx
    cpx #$20    ; 팔레트 데이터: 32비트
    bne .loop

; 복수개의 스프라이트를 RAM 영역 $0200에 저장한다.
loadSprites:
    ldx #$00
.loop:
    lda sprites, x
    sta $0200, x
    inx
    cpx #$10
    bne .loop

loadBackground:
    lda $2002       ; PPU 상태 레지스터를 읽어서 high/low 래치를 리셋한다.
    lda #$20        ; $2000의 상위 바이트
    sta $2006
    lda #$00        ; $2000의 하위 바이트
    sta $2006
    ldx #$00
.loop:
    lda background, x
    sta $2007
    inx
    cpx #$80
    bne .loop

loadAttribute:
    lda $2002       ; PPU 상태 레지스터를 읽어서 high/low 래치를 리셋한다.
    lda #$23        ; $23c0의 상위바이트
    sta $2006
    lda #$c0        ; $23c0의 하위바이트
    sta $2006
    ldx #$00
.loop:
    lda attribute, x
    sta $2007
    inx
    cpx #$08
    bne .loop

    lda #%10010000  ; enable NMI, sprites from pattern table 0, background from pattern table 1
    sta $2000

    lda #%00011110  ; enable sprites, enable background, no clipping on left side
    sta $2001

forever:
    jmp forever

NMI:
    lda #$00
    sta $2003   ; set the low byte of the RAM address ($2003: OAMADDR)
    lda #$02
    sta $4014   ; set the high byte of the RAM address, start the transfer ($4014: OAMDMA)

latchController:
    lda #$01
    sta $4016
    lda #$00
    sta $4016       ; tell both the controllers to latch buttons
    
readA:
    lda $4016       ; player 1 - A
    and #$00000001  ; only look at bit 0
    beq readADone   ; 버튼이 눌리지 않았을 때 (0) readADone으로 분기한다.
    ; 버튼이 눌렸을 때 처리할 명령어들을 여기에 추가한다.
    ; unflip horizontal
    lda btn
    cmp #0          ; if btn == 1 then unflip();
    beq .next
    jsr unflip
.next:
    inc $0203
    inc $0207
    inc $020b
    inc $020f
readADone:

readB:
    lda $4016       ; player 1 - B
    and #%00000001  ; only look at bit 0
    beq readBDone   ; 버튼이 눌리지 않았을 때 (0) readBDone으로 분기한다.
    ; 버튼이 눌렸을 때 처리할 명령어들을 여기에 추가한다.
    ;flip horizontal
    lda btn
    cmp #1          ; if btn == 0 then flip();
    beq .next
    jsr flip
.next:
    dec $0203
    dec $0207
    dec $020b
    dec $020f
readBDone:

    ; PPU clean up section
    lda #%10010000  ; enable NMI, sprites from pattern table 0, background from pattern table 1
    sta $2000
    lda #%00011110
    sta $2001
    lda #$00        ; $2005: PPUSCROLL, PPU에게 배경 스크롤이 없음을 알린다. -> PPUSCROLL은 수평과 수직 스크롤 레지스터로 구성되어있는데, 접근은 둘 다 $2005로 한다(순차적으로 값을 써야 한다).
    sta $2005       ; 수평 스크롤 오프셋 설정
    sta $2005       ; 수직 스크롤 오프셋 설정
    rti

swap:
    ; temp = ($0201)
    lda $0201
    sta <temp
    lda $0205
    sta $0201
    lda <temp
    sta $0205
    lda $0209
    sta <temp
    lda $020d
    sta $0209
    lda <temp
    sta $020d
    rts

flip:
    pha
    jsr swap
    lda #$40    ; horizontal flip
    sta $0202
    sta $0206
    sta $020a
    sta $020e
    lda #$01
    sta <btn
    pla
    rts

unflip:
    pha
    jsr swap
    lda #$00    ; horizontal unflip
    sta $0202
    sta $0206
    sta $020a
    sta $020e
    sta <btn
    pla
    rts

    .bank 1
    .org $e000
palette:
    .db $22, $29, $1a, $0f, $22, $36, $17, $0f, $22, $30, $21, $0f, $22, $27, $17, $0f ; background
    .db $00, $16, $27, $18, $00, $1a, $30, $27, $00, $16, $30, $27, $00, $0f, $36, $17 ; sprite

sprites:
    ;   Ypos tile attr Xpos
    .db $80, $32, $00, $80  ; sprite 0
    .db $80, $33, $00, $88  ; sprite 1
    .db $88, $34, $00, $80  ; sprite 2
    .db $88, $35, $00, $88  ; sprite 3

background:
    .db $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24 ; row 1
    .db $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24 ; all sky

    .db $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24 ; row 2
    .db $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24 ; all sky

    .db $24, $24, $24, $24, $45, $45, $24, $24, $45, $45, $45, $45, $45, $45, $24, $24 ; row 3
    .db $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $53, $54, $24, $24 ; some brick tops

    .db $24, $24, $24, $24, $47, $47, $24, $24, $47, $47, $47, $47, $47, $47, $24, $24 ; row 4
    .db $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $55, $56, $24, $24 ; brick bottoms

attribute:
    .db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000
    .db $24, $24, $24, $24, $47, $47, $24, $24, $47, $47, $47, $47, $47, $47, $24, $24
    .db $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $24, $55, $56, $24, $24

    .org $fffa
    .dw NMI
    .dw RESET
    .dw 0
;;;;;;;;;;;;;

    .bank 2
    .org $0000
    .incbin "mario.chr"