add_sprite:
.(
    txa
    pha
    ldx #15
l1: lda sprites_h,x
    bne l2
    lda sprite_inits,y
    sta sprites_x,x
    iny
    lda sprite_inits,y
    sta sprites_y,x
    iny
    lda sprite_inits,y
    sta sprites_i,x
    iny
    lda sprite_inits,y
    sta sprites_c,x
    iny
    lda sprite_inits,y
    sta sprites_l,x
    iny
    lda sprite_inits,y
    sta sprites_h,x
    iny
    lda sprite_inits,y
    sta sprites_fl,x
    iny
    lda sprite_inits,y
    sta sprites_fh,x
    pla
    tax
    rts
l2: dex
    bpl l1
    pla
    tax
    rts
.)

remove_sprite:
    lda #0
    sta sprites_h,x
    rts

sprite_up:
.(
    lda sprites_y,x
    beq e1
    dec sprites_y,x
e1: rts
.)

sprite_down:
.(
    lda sprites_y,x
    cmp #18*8
    bcs e1
    inc sprites_y,x
e1: rts
.)

sprite_left:
.(
    lda sprites_x,x
    beq e1
    dec sprites_x,x
e1: rts
.)

sprite_right:
.(
    lda sprites_x,x
    cmp #21*8
    bcs e1
    inc sprites_x,x
e1: rts
.)

find_hit:
.(
    txa
    pha
    stx tmp
    ldy #numsprites-1
l1: cpy tmp
    beq n1
    lda sprites_h,y
    beq n1

    lda sprites_x,x     ; Get X distance.
    sec
    sbc #8
    sec
    sbc sprites_x,y
    bpl l2
    clc                 ; Make it positive.
    eor #$ff
    adc #1
l2: and #%11110000
    bne n1
    lda sprites_y,x
    clc
    adc #8
    sec
    sbc sprites_y,y
    bpl l3
    clc
    eor #$ff
    adc #1
l3: and #%11110000
    beq c1
n1: dey
    bpl l1
    pla
    tax
    clc
    rts
c1: pla
    tax
    stc
    rts
.)

draw_sprites:
.(
    ldx #0
l1: lda sprites_h,x     ; Skip unallocated sprites.
    beq n1

    sta spr+1
    lda sprites_l,x
    sta spr

#ifdef TIMING
    txa
    and #7
    ora #8
    sta $900f
#endif

    txa
    pha
    jsr draw_sprite
    pla
    tax

n1: inx
    cpx #numsprites
    bne l1
.)

    ; Remove leftover chars.
.(
    ldx #numsprites-1
l1: lda sprites_ox,x
    cmp #$ff
    beq n2
    sta scrx
    lda sprites_oy,x
    sta scry
    jsr clear_char
    inc scrx
    jsr clear_char
    dec scrx
    inc scry
    jsr clear_char
    inc scrx
    jsr clear_char
    lda #$ff
    sta sprites_ox,x
n2: lda sprites_h,x
    beq n1
    lda sprites_x,x
    clc
    lsr
    lsr
    lsr
    sta sprites_ox,x
    lda sprites_y,x
    clc
    lsr
    lsr
    lsr
    sta sprites_oy,x
n1: dex
    bpl l1
.)

    inc framecounter
    rts

; Draw a single sprite.
draw_sprite:
.(
    lda spr
    sta spr_u

    lda sprites_c,x
    sta curcol

    ; Get position on screen.
    lda sprites_x,x
    clc
    lsr
    lsr
    lsr
    sta scrx
    lda sprites_y,x
    clc
    lsr
    lsr
    lsr
    sta scry

    ; Get shifts
    lda sprites_x,x
    and #%111
    sta sprshiftx
    sta sprshiftxl
    lda sprites_y,x
    and #%111
    sta sprshifty

    ; Draw upper left half of char.
    jsr get_char
    lda d
    clc
    adc sprshifty
    sta d
    lda #7
    sec
    sbc sprshifty
    sta counter_u
    tay
    jsr blit_left

    lda sprshifty       ; No lower half to draw...
    beq n1

    ; Draw lower half of char.
    inc scry            ; Prepare next line.
    jsr get_char
    lda spr
    stc
    adc counter_u
    sta spr
    sta spr_l
    ldy sprshifty
    dey
    jsr blit_left
    dec scry

n1:lda sprshiftx        ; No right halves to draw...
    beq n2

    ; Get shift for the right half.
    lda #8
    sec
    sbc sprshiftx
    sta sprshiftx

    ; Draw upper right
    inc scrx            ; Prepare next line.
    jsr get_char
    lda d
    clc
    adc sprshifty
    sta d
    lda spr_u
    sta spr
    ldy counter_u
    jsr blit_right

    lda sprshifty       ; No lower half to draw...
    beq n2

    ; Draw lower left
    inc scry
    jsr get_char
    lda spr_l
    sta spr
    ldy sprshifty
    dey
    jmp blit_right

n2: rts
.)
