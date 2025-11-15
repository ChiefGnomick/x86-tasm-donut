.model SMALL
.386
.STACK 100h

CLEAR_BUFFER MACRO buffer, size, fill_char
    mov ax, ds
    mov es, ax
    lea di, buffer
    mov cx, size
    mov al, fill_char
    rep stosb
ENDM

.DATA

screen_width dw 80
screen_height dw 25

theta_spacing dd 0.07
phi_spacing dd 0.02

R1 dd 1.0
R2 dd 2.0
K1 dd ?
K2 dd 40.0

M_PI dd 6.28319

A dd 0.0
B dd 0.0
sinA dd ?
sinB dd ?
cosA dd ?
cosB dd ?

output db 2000 dup(' ')
zbuffer dd 2000 dup(0.0)

luminance_chars db '.,-~:;=!*#$@'

theta dd ?
phi dd ?
sintheta dd ?
costheta dd ?
sinphi dd ?
cosphi dd ?
circlex dd ?
circley dd ?
x dd ?
y dd ?
z dd ?
ooz dd ?
xp dd ?
yp dd ?
L dd ?
luminance_index dw ?
temp_zbuffer dd ?

temp dw 8

.CODE

begin:
    mov ax, @data
    mov ds, ax

    fild [screen_width]
    fld [K2]
    fmul
    fld1
    fld1
    fld1
    fadd
    fadd
    fmul
    fld [R1]
    fld [R2]
    fadd
    fild [temp]
    fmul
    fdiv
    fstp [K1]
    
    mov ax, 0003h
    int 10h
    
    main_loop:
        mov ah, 01h
        int 16h
        jnz exit_program

        call render_frame
        call display_output
        
        fld A
        fadd theta_spacing
        fstp A
        
        fld B
        fadd phi_spacing
        fstp B
        
        mov cx, 0
        mov dx, 3000
        mov ah, 86h
        int 15h
        
        jmp main_loop
    
    exit_program:
        mov ah, 00h
        int 16h
        mov ax, 0003h
        int 10h
        mov ah, 4Ch
        int 21h

render_frame proc
    fld A
    fsin
    fstp sinA

    fld A
    fcos
    fstp cosA

    fld B
    fsin
    fstp sinB

    fld B
    fcos
    fstp cosB

    CLEAR_BUFFER output, 2000, ' '
    
    mov ax, ds
    mov es, ax
    lea di, zbuffer
    mov cx, 2000
    xor eax, eax
    rep stosd

    fldz
    fstp theta
    
theta_loop:
    fld theta
    fsin
    fstp sintheta

    fld theta
    fcos
    fstp costheta

    fldz
    fstp phi
    
phi_loop:
    fld phi
    fcos
    fstp cosphi

    fld phi
    fsin
    fstp sinphi

    fld R1
    fld costheta
    fmul
    fld R2
    fadd
    fstp circlex

    fld R1
    fld sintheta
    fmul
    fstp circley

    fld cosB
    fld cosphi
    fmul
    
    fld sinA
    fld sinB
    fmul
    fld sinphi
    fmul
    
    fadd
    
    fld circlex
    fmul
    
    fld circley
    fld cosA
    fmul
    fld sinB
    fmul
    
    fsub
    fstp x

    fld sinB
    fld cosphi
    fmul
    
    fld sinA
    fld cosB
    fmul
    fld sinphi
    fmul
    
    fsub
    
    fld circlex
    fmul
    
    fld circley
    fld cosA
    fmul
    fld cosB
    fmul
    
    fadd
    fstp y

    fld [K2]

    fld cosA
    fld circlex
    fmul
    fld sinphi
    fmul
    
    fld circley
    fld sinA
    fmul
    
    fadd
    fadd
    fstp z

    fld1
    fld z
    fdiv
    fstp ooz

    fild screen_width
    fld1
    fld1
    fadd
    fdiv
    
    fld K1
    fld ooz
    fmul
    fld x
    fmul
    
    fadd
    frndint
    fistp xp

    fild screen_height
    fld1
    fld1
    fadd
    fdiv
    
    fld K1
    fld ooz
    fmul
    fld y
    fmul
    
    fsub
    frndint
    fistp yp

    fld cosphi
    fld costheta
    fmul
    fld sinB
    fmul
    
    fld cosA
    fld costheta
    fmul
    fld sinphi
    fmul
    
    fsub
    
    fld sinA
    fld sintheta
    fmul
    
    fsub
    
    fld cosA
    fld sintheta
    fmul
    
    fld costheta
    fld sinA
    fmul
    fld sinphi
    fmul
    
    fsub
    
    fld cosB
    fmul
    
    fadd
    fstp L

    fld L
    ftst
    fstsw ax
    sahf
    jbe skip_pixel
    
    mov eax, xp
    cmp eax, 0
    jl skip_pixel
    
    mov bx, screen_width
    cmp ax, bx
    jge skip_pixel
    
    mov eax, yp
    cmp eax, 0
    jl skip_pixel
    
    mov bx, screen_height
    cmp ax, bx
    jge skip_pixel
    
    mov ax, word ptr yp
    mov bx, screen_width
    mul bx
    add ax, word ptr xp
    mov si, ax
    shl si, 2
    
    mov eax, zbuffer[si]
    mov dword ptr temp_zbuffer, eax
    
    fld ooz
    fcomp temp_zbuffer
    fstsw ax
    sahf
    jbe skip_pixel
    
    fld ooz
    fstp temp_zbuffer
    mov eax, dword ptr temp_zbuffer
    mov zbuffer[si], eax
    
    fld L
    fld1
    fld1
    fadd
    fld1
    fld1
    fadd
    fadd
    fmul
    fld1
    fld1
    fadd
    fmul
    frndint
    fistp luminance_index
    
    mov ax, luminance_index
    cmp ax, 0
    jge check_upper
    mov ax, 0
    jmp store_char
check_upper:
    cmp ax, 11
    jle store_char
    mov ax, 11
    
store_char:
    mov bx, offset luminance_chars
    add bx, ax
    mov al, [bx]
    
    shr si, 2
    mov output[si], al
    
skip_pixel:
    fld phi
    fadd phi_spacing
    fstp phi
    
    fld phi
    fcomp M_PI
    fstsw ax
    sahf
    jb phi_loop
    
    fld theta
    fadd theta_spacing
    fstp theta
    
    fld theta
    fcomp M_PI
    fstsw ax
    sahf
    jb theta_loop
    
    ret
render_frame endp

display_output proc
    mov ax, 0B800h
    mov es, ax
    xor di, di
    mov si, offset output
    mov cx, 2000
    mov ah, 07h
output_loop:
    mov al, [si]
    mov es:[di], ax
    add di, 2
    inc si
    loop output_loop
    ret
display_output endp

end begin