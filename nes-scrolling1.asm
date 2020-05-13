; Advanced Nerdy Nights 3: Horizontal Scrolling
; scrolling1.asm
    .inesprg 1
    .ineschr 1
    .inesmap 0  ; mapper 0 = NROM, no bank swapping
    .inesmir 1  ; VERT mirroring for HORIZ scrolling

    .rsset $0000
scroll  .rs 1   ; horizontal scroll count


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
    ; PPU 메모리 주소를 팔레트 주소인 $3f00으로 설정
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

; ROM에 기록해둔 스프라이트 데이터를 CPU RAM 영역인 $0200으로 전송한다.
; $0200번지부터 있는 스프라이트 데이터는 이후 DMA를 통해 PPU의 OAM 영역으로 전송된다.
loadSprites:
    ldx #$00
.loop:
    lda sprites, x
    sta $0200, x
    inx
    cpx #$10
    bne .loop

; 네임테이블0 주소: $2000
fillNametables:
    lda $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    ldy #$08
    ldx #$00    ; fill 256 x 8 byte = 2KB, both nametables all full
    lda #$7f
.loop:
    sta $2007
    dex
    bne .loop   ; 256
    dey
    bne .loop   ; 8

; 속성 테이블: 64바이트 크기의 테이블(8x8)
; 각 1바이트 항목은 2비트씩 4개 타일의 색상 그룹을 지정한다.
; 각 타일은 16x16 크기의 영역이다. (8x8 픽셀이 아님에 주의)

; 네임테이블0의 속성 테이블 주소: $23c0
fillAttrib0:
    lda $2002
    lda #$23
    sta $2006
    lda #$c0
    sta $2006
    ldx #$40    ; fill 64 bytes
    lda #$00
.loop:
    sta $2007
    dex
    bne .loop

; 네임테이블1의 속성 테이블 주소: $27c0
fillAttrib1:
    lda $2002
    lda #$27
    sta $2006
    lda #$c0
    sta $2006
    ldx #$40
    lda #$ff    ; fill 64 bytes
.loop:
    sta $2007
    dex
    bne .loop

    ; PPU 설정
    lda #%10010000  ; enable NMI, sprites from pattern table 0, background from pattern table 1
    sta $2000

    lda #%00011110  ; enable sprites, background, no clipping on left side (왼쪽 영역의 배경과 스프라이트 출력)
    sta $2001

Forever:
    jmp Forever

NMI:
    lda #$00
    sta $2003
    lda #$02
    sta $4014

    ; run other game graphics updating code here
    
    ; clean up PPU address register
    lda #$00
    sta $2006
    sta $2006

    ; 수평 스크롤
    inc scroll
    lda scroll
    sta $2005

    ; 수직 스크롤
    lda #$00
    sta $2005

    ; PPU clean up section
    lda #%10010000
    sta $2000
    lda #%00011110
    sta $2001

    rti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .bank 1
    .org $e000
palette:
    .db $22, $29, $1a, $0f,     $22, $36, $17, $0f,     $22, $30, $21, $0f,     $22, $27, $17, $0f  ; background
    .db $22, $1c, $15, $14,     $22, $02, $38, $3c,     $22, $1c, $15, $14,     $22, $02, $38, $3c  ; sprite

sprites:
    .db $80, $32, $00, $80  ; sprite 0
    .db $80, $33, $00, $88  ; sprite 1
    .db $88, $34, $00, $80  ; sprite 2
    .db $88, $35, $00, $88  ; sprite 3

    .org $fffa
    .dw NMI
    .dw RESET
    .dw 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .bank 2
    .org $0000
    .incbin "mario.chr"