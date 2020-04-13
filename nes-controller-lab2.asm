; Nerdy Nights - week 5
; sprites.asm
    .inesprg 1
    .ineschr 1
    .inesmap 0
    .inesmir 1

; 변수는 RAM 영역의 $0000 번지부터 시작한다.
;    .rsset $0000
;btn     .rs 1   ; 1바이트 공간 예약
;temp    .rs 1   ; 1바이트 공간 예약
    .org $0500
btn     .ds 1
temp    .ds 1

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
    cpx #$20
    bne .loop

    lda #%10000000  ; enable NMI, sprites from pattern table 0
    sta $2000

    lda #%00010000  ; enable sprites
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
    ;lda $0203       ; 스프라이트 0의 X 좌표를 A 레지스터에 적재
    ;clc
    ;adc #$01        ; A = A + 1
    ;sta $0203       ; 1 추가된 값을 스프라이트 0의 X 좌표에 적용한다.

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
    ;lda $0203       ; 스프라이트 0의 X 좌표를 A 레지스터에 적재한다.
    ;sec
    ;sbc #$01        ; A = A - 1
    ;sta $0203       ; 1 감산된 값을 스프라이트 0의 X 좌표에 적용한다.
    
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

    rti

swap:
    ; temp = ($0201)
    lda $0201
    sta temp
    lda $0205
    sta $0201
    lda temp
    sta $0205
    lda $0209
    sta temp    ; 16비트 절대주소 지정
    lda $020d
    sta $0209
    ;lda <temp   ; 제로페이지 주소 지정
    lda temp
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
    sta btn
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
    ;sta <btn
    sta btn
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

    .org $fffa
    .dw NMI
    .dw RESET
    .dw 0
;;;;;;;;;;;;;

    .bank 2
    .org $0000
    .incbin "mario.chr"