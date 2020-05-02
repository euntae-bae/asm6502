    .inesprg 1
    .ineschr 1
    .inesmap 0
    .inesmir 1

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

; 패미컴은 2KB 내부 RAM이 있는데, 2KB = 2048 byte = $800 byte
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
    sta $0200, x    ; move all sprites off screen
    inx
    bne clrmem

vblankwait2:
    bit $2002
    bpl vblankwait2

loadPalettes:
    lda $2002   ; PPU 상태 레지스터를 읽어서 high/low 래치를 리셋한다.
    lda #$3f
    sta $2006   ; PPU 메모리 주소로 지정할 $3f00의 상위 바이트를 쓴다. ($2006: PPUADDR)
    lda #$00
    sta $2006   ; $3f00의 하위 바이트를 쓴다.
    ldx #$00
.loop:
    lda palette, x
    sta $2007   ; PPU에 데이터를 쓴다. ($2007: PPUDATA)
    inx
    cpx #$20    ; 32바이트 데이터(팔레트는 각각 16바이트로, 배경과 스프라이트에 하나씩 사용하여 32($20)바이트 사용)를 모두 썼는지 확인한다.
    bne .loop    ; 만약 x == $20이고, 32 바이트 데이터가 전부 복사되면 팔레트 데이터 전송(CPU 메모리->PPU)은 완료된 것이다.

loadSprites:
    ldx #$00
.loop:
    lda sprites, x
    sta $0200, x
    inx
    cpx #40
    bne .loop

    lda #%10000000  ; enable NMI, 스프라이트(스프라이트의 타일 패턴)는 패턴테이블 0로부터 가져온다.
    sta $2000

    lda #%00010000  ; enable sprites
    sta $2001

Forever:
    jmp Forever

NMI:
    lda #$00
    sta $2003   ; RAM 주소 $2000의 하위 바이트를 설정하고 DMA 전송 시작 ($2003: OAMADDR)
    lda #$02
    sta $4014   ; RAM 주소 $2000의 상위 바이트를 설정하고 DMA 전송 시작 ($4014: OAMDMA)

    rti
;;;;;;;;;;;;;;;;;;;;;;

    .bank 1
    .org $e000
sprites:
    ; row 1
    .db $70, $00, $00, $70
    .db $70, $01, $00, $78
    ; row 2
    .db $78, $02, $00, $70
    .db $78, $03, $00, $78
    ; row 3 - 1
    .db $80, $04, $00, $70
    .db $80, $05, $00, $78
    ; row 4
    .db $88, $06, $00, $70
    .db $88, $07, $00, $78
    ; row 3 - 2
    .db $80, $08, $01, $70
    .db $80, $09, $01, $78

palette:
    .db $1c, $2b, $0b, $0f, $22, $35, $36, $37, $22, $39, $3a, $3b, $22, $3d, $3e, $0f  ; background
    .db $1c, $01, $20, $0f, $1c, $29, $27, $0f, $1c, $01, $27, $0f, $1c, $01, $20, $0f  ; sprite

    ; 인터럽트 벡터 설정
    .org $fffa
    .dw NMI
    .dw RESET
    .dw 0

    .bank 2
    .org $0000
    .incbin "asriel.chr"