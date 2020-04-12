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

LoadPalettes:
    lda $2002   ; PPU 상태 레지스터를 읽어서 high/low 래치를 리셋한다.
    lda #$3f
    sta $2006   ; PPU 메모리 주소로 지정할 $3f00의 상위 바이트를 쓴다. ($2006: PPUADDR)
    lda #$00
    sta $2006   ; $3f00의 하위 바이트를 쓴다.
    ldx #$00
LoadPalettesLoop:
    lda palette, x
    sta $2007   ; PPU에 데이터를 쓴다. ($2007: PPUDATA)
    inx
    cpx #$20    ; 32바이트 데이터(팔레트는 각각 16바이트로, 배경과 스프라이트에 하나씩 사용하여 32($20)바이트 사용)를 모두 썼는지 확인한다.
    bne LoadPalettesLoop    ; 만약 x == $20이고, 32 바이트 데이터가 전부 복사되면 팔레트 데이터 전송(CPU 메모리->PPU)은 완료된 것이다.

    ; 대개 스프라이트 데이터는 내부 RAM이 있는 $0200-$02ff 영역을 사용한다.
    ; 여기 있는 데이터는 DMA를 사용하여 PPU의 OAM(Object Attribute Memory 또는 스프라이트 메모리) 영역으로 복사한다.
    ; 각각의 스프라이트는 4바이트 데이터를 가진다.
    ; 바이트 0: y좌표 / 바이트 1: 타일 인덱스 번호 / 바이트 2: 속성(뒤집기, 우선순위, 팔레트 등) / 바이트 3: x좌표
    
    ; 바이트2
    ; bit 7: flip vertically
    ; bit 6: flip horizontally
    ; bit 5: priority
    ; bit 2, 3, 4: unimplemented
    ; bit 1, 0: palette of sprite (팔레트의 색상그룹 선택)

    ; 수정된 코드
    jsr loadSprites

    lda #%10000000  ; enable NMI, 스프라이트(스프라이트의 타일 패턴)는 패턴테이블 0로부터 가져온다.
    sta $2000

    lda #%00010000  ; enable sprites
    sta $2001

Forever:
    jmp Forever

loadSprites:
    pha
    txa
    pha
    ldx #$00

.loop:
    lda sprites, x
    sta $0200, x
    inx
    cpx #32
    bne .loop

    pla
    tax
    pla
    rts

NMI:
    lda #$00
    sta $2003   ; RAM 주소 $2000의 하위 바이트를 설정하고 DMA 전송 시작 ($2003: OAMADDR)
    lda #$02
    sta $4014   ; RAM 주소 $2000의 상위 바이트를 설정하고 DMA 전송 시작 ($4014: OAMDMA)

    rti
;;;;;;;;;;;;;;;;;;;;;;

    .bank 1
    .org $e000
palette:
    .db $22, $29, $1a, $0f, $22, $35, $36, $37, $22, $39, $3a, $3b, $22, $3d, $3e, $0f  ; background
    .db $0f, $1c, $15, $14, $00, $16, $27, $18, $0f, $1c, $15, $14, $0f, $02, $38, $3c  ; sprite

sprites:
    .db $78, $00, $01, $78
    .db $78, $01, $01, $80
    .db $80, $02, $01, $78
    .db $80, $03, $01, $80
    .db $88, $04, $00, $78
    .db $88, $05, $00, $80
    .db $90, $06, $01, $78
    .db $90, $07, $01, $80

    ; 인터럽트 벡터 설정
    .org $fffa
    .dw NMI
    .dw RESET
    .dw 0

    .bank 2
    .org $0000
    .incbin "mario.chr"