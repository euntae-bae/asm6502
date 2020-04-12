; 코드 출처: Nerdy Nights - background.asm
    .inesprg 1  ; 1 x 16KB PRG(프로그램 코드) 데이터
    .ineschr 1  ; 1 x 8KB CHR(그래픽) 데이터
    .inesmap 0  ; 매퍼 0 = NROM, 뱅크 전환 없음
    .inesmir 1  ; 배경 미러링

    .bank 0
    .org $c000
RESET:
    sei
    cld
    ldx #$40
    stx $4017   ; disable APU from IRQ
    ldx #$ff
    txs         ; set up stack
    inx         ; X = 0
    stx $2000   ; disable NMI ($2000: PPUCTRL)
    stx $2001   ; disable rendering ($2001: PPUMASK)
    stx $4010   ; disable DMC IRQs

vblankwait1:    ; PPU가 준비상태임을 확실하게 하기 위해 첫 번째 VBlank를 대기한다.
    bit $2002   ; $2002: PPUSTATUS, PPU상태 레지스터의 bit 7(VBlank flag)을 확인한다. 
                ; VBlank 상태라면 CPU 상태 레지스터의 N(Negative, 부호) 비트가 1이 될 것이다.
    bpl vblankwait1 ; N 비트가 0인 경우에는 다시 대기를 위해 vblankwait1로 점프한다.

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
    bne clrmem  ; X 레지스터가 다시 0이 될 때까지 반복한다.

vblankwait2:    ; 다시 VBlank를 기다린다. PPU는 이 다음부터 준비상태가 된다.
    bit $2002
    bpl vblankwait2

    lda #%10000000  ; 청색을 강조한다.
    sta $2001       ; $2001: PPUMASK

Forever:
    jmp Forever

NMI:
    rti

    ; bank 1에는 인터럽트 벡터를 기술한다.
    .bank 1
    .org $fffa
    .dw NMI     ; NMI
    .dw RESET   ; RESET
    .dw 0       ; IRQ

    .bank 2
    .org $0000
    .incbin "mario.chr" ; 슈퍼마리오 브라더스1에 있는 8KB 그래픽 파일을 포함시킨다.