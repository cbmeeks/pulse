sprite_inits:
player_init:
    .byte 02, 81, 0, cyan,     <ship, <player_fun, >player_fun, 0
laser_init:
    .byte 18, 80, 1, white+8,  <laser, <laser_fun,  >laser_fun, 0
laser_up_init:
    .byte 18, 80, 1, yellow,  <laser_up, <laser_up_fun,  >laser_up_fun, 0
laser_down_init:
    .byte 18, 80, 1, yellow,  <laser_down, <laser_down_fun,  >laser_down_fun, 0
bullet_init:
    .byte 22*8, 89, 64+2, yellow+8, <bullet, <bullet_fun, >bullet_fun, 0
scout_init:
    .byte 22*8, 89, 64+3, yellow+8, <scout, <scout_fun, >scout_fun, 0
sniper_init:
    .byte 22*8, 89, 64+3, white, <sniper, <sniper_fun, >sniper_fun, 0
bonus_init:
    .byte 22*8, 89, 4, green, <scout, <bonus_fun, >bonus_fun, 0
star_init:
    .byte 22*8, 89, 32, white, <star, <star_fun, >star_fun, 0

sinetab:
    .byte 0, 0, 1, 2, 3, 5, 7, 7
    .byte 7, 7, 5, 3, 2, 1, 0, 0
    .byte 0, 0, $ff, $fe, $fc, $fa, $f8, $f8
    .byte $f8, $f8, $fa, $fc, $fe, $ff, 0, 0

hit_formation:
.(
    dec formation_left_unhit
    bne e
    lda sprites_x,y
    sta bonus_init
    lda sprites_y,y
    sta bonus_init+1
    txa
    pha
    tya
    pha
    ldy #bonus_init-sprite_inits
    jsr add_sprite
    pla
    tay
    pla
    tax
e:  stc
    rts
.)

hit_enemy:
.(
    jsr find_hit
    bcc n2
    lda sprites_i,y
    and #%00111111
    cmp #3
    beq hit_formation
    cmp #2
    bne n1
    stc
    rts
n1: clc
n2:
.)
return:
    rts

test_foreground_collision:
    lda sprites_i,x
    and #128
    rts

energize_color:
.(
    lda framecounter
    lsr
    bcc n1
    tya
    and #%1000
    ora #white
    tay
n1: sty sprites_c,x
    rts
.)

bonus_fun:
.(
    ldy #green
    lda framecounter
    and #%10
    beq n1
    tya
    and #%1000
    ora #white
    tay
n1: sty sprites_c,x
    lda #1
    jmp move_left
.)

star_fun:
    lda framecounter
    lsr
    bcc return
    lda #1
move_left:
    jsr sprite_left
    jmp remove_if_sprite_is_out

bullet_fun:
.(
    lda #sprites_x
    sta si+1
    lda #sprites_y
    sta sw+1
    lda #$f6
    sta si
    sta sw
    lda sprites_i,x
    and #step_y
    beq n2
    lda #sprites_y
    sta si+1
    lda #sprites_x
    sta sw+1
n2: lda sprites_i,x
    and #dec_x
    beq n3
    lda #$d6
    sta si
n3: lda sprites_i,x
    and #dec_y
    beq n4
    lda #$d6
    sta sw
n4:
si: inc sprites_y,x
    lda sprites_d,x
    lsr
    lsr
    lsr
    lsr
    sta tmp
    lda sprites_d,x
    and #%1111
    sec
    sbc tmp
    bcs n1
sw: inc sprites_x,x
n1: and #%1111
    sta tmp
    lda sprites_d,x
    and #%11110000
    ora tmp
    sta sprites_d,x
    jsr test_foreground_collision
    bne remove_sprite2
    jmp remove_if_sprite_is_out
.)

scout_fun:
.(
    lda random
    and #%01111111
    bne l2
    jsr add_bullet
    jsr update_random
l2: ldy #yellow+8
    jsr energize_color
    lda #4
    jsr sprite_left
    lda framecounter_high
    cmp #3
    bcc l1
    lda sprites_x,x
    lsr
    lsr
    clc
    adc scrolled_chars
    and #%00011111
    tay
    lda scout_formation_y
    clc
    adc sinetab,y
    clc
    adc sinetab,y
    sta sprites_y,x
l1: jmp remove_if_sprite_is_out
.)

sniper_fun:
.(
    lda framecounter
    and #%01001111
    bne n
    jsr add_bullet
n:  lda #1
    jmp move_left
.)

laser_fun:
    jsr hit_enemy
    bcs remove_sprite_xyf
    jsr test_foreground_collision
    bne remove_spritef
    lda #11
    jsr sprite_right
remove_if_sprite_is_out:
    jsr test_sprite_out
    bcc return3
remove_sprite2:
    jmp remove_sprite
remove_spritef:
    lda #0
    sta is_firing
    jmp remove_sprite
return3:
    rts

remove_sprite_xyf:
    lda #0
    sta is_firing
remove_sprite_xy:
    jsr remove_sprite
    tya
    tax
    jmp remove_sprite
return2:
    rts

laser_side:
.(
    ldy #yellow
    jsr energize_color
    jsr hit_enemy
    bcs remove_sprite_xy
    jsr test_foreground_collision
    bne remove_sprite2
    lda #8
    jsr sprite_right
    jsr test_sprite_out
    bcs remove_sprite2
    rts
.)

laser_up_fun:
.(
    lda #8
    jsr sprite_up
    jmp laser_side
.)

laser_down_fun:
.(
    lda #8
    jsr sprite_down
    jmp laser_side
.)

player_fun:
.(
    lda death_timer
    beq d1
    lda random
    sta sprites_l,x
    sta sprites_c,x
    dec death_timer
    bne return2
    lda #<ship
    sta sprites_l,x
    dec lifes
    beq g1
    jmp restart
g1: jmp game_over
d1: lda is_invincible
    beq d2
    ldy #red
    jsr energize_color
    dec is_invincible
    jmp d3

d2: lda #cyan
    sta sprites_c,x
    jsr test_foreground_collision
    bne die
d3: jsr find_hit
    bcc c1
    lda sprites_i,y
    and #%00111111
    cmp #4              ; Bonus.
    bne c2
    txa
    pha
    tya
    tax
    jsr remove_sprite
    pla
    tax
    dec fire_interval
    dec fire_interval
    lda fire_interval
    cmp #4
    bcs c1
    lda has_double_laser
    bne c3
    lda #6
    sta fire_interval
    lda #1
    sta has_double_laser
    jmp c1
c3: lda #4
    sta fire_interval
    lda #$ff
    sta is_invincible
c2: lda sprites_i,y
    and #64
    beq c1
    lda is_invincible
    bne c1
die:
#ifdef INVINCIBLE
jmp c1
#endif
    lda #120
    sta death_timer
    rts

c1: lda #0              ; Fetch joystick status.
    sta $9113
    lda $9111
    tay
    and #%00100000
    bne n1
    lda has_autofire
    bne a1
    lda is_firing
    bne n1
a1: lda framecounter    ; Little ramdomness to give the laser some action.
    lsr
    lsr
    and #7
    adc sprites_x,x
    sta laser_init
    lda sprites_x,x
    sta laser_up_init
    sta laser_down_init
    lda sprites_y,x
    sta laser_init+1
    sta laser_up_init+1
    sta laser_down_init+1
    inc laser_init+1
    lda fire_interval
    sta is_firing
    lda #white
    sta sprites_c,x
    tya
    pha
    lda has_double_laser
    beq s1
    ldy #laser_up_init-sprite_inits
    jsr add_sprite
    ldy #laser_down_init-sprite_inits
    jsr add_sprite
s1: ldy #laser_init-sprite_inits
    jsr add_sprite
    pla
    tay
n1: lda is_firing
    beq i1
    dec is_firing
i1: tya
    and #%00000100
    bne n2
    lda sprites_y,x
    cmp #$100-8
    bcs n2
    lda #4
    jsr sprite_up
n2: tya
    and #%00001000
    bne n3
    lda sprites_y,x
    cmp #$100-8
    bcs n6
    cmp #22*8
    bcs n3
n6: lda #4
    jsr sprite_down
n3: tya
    and #%00010000
    bne n4
    lda sprites_x,x
    beq n4
    lda #2
    jsr sprite_left
n4: lda #0              ;Fetch rest of joystick status.
    sta $9122
    lda $9120
    and #%10000000
    bne n5
    lda sprites_x,x
    cmp #21*8
    bcs n5
    lda #2
    jmp sprite_right
n5: rts
.)
