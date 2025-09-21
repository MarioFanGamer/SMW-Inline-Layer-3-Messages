macro repoint_level(id, layer_1_data, layer_2_data, sprite_data, ...)
org $05E000+(<id>*3)
dl <layer_1_data>

org $05E600+(<id>*3)
dl <layer_2_data>

org $05EC00+(<id>*2)
dw <sprite_data>

for i = 0..sizeof(...)
    org $05F000+<id>+(!i*$200)
    db <...[!i]>
endfor

endmacro

%repoint_level($8, $06887D, $0CE674, $07C4C0, $2B, $10, $0A, $00, $00, $00, $00, $00)
