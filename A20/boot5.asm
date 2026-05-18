;NOTE
;KBC (Keyboard Controller) Method is not much reliable
;because modern hardware already enable A20 line before any bootloader
;so when i detect A20 from status register (0x64) it work good in qemu
;but in real hardware 0x64 status register don't know that BIOS or hardware already enable A20 
;so when i detect it show it disable
;but when i detect A20 from memory it verify that A20 line is enable


[bits 16]
[org 0x7C00]

JMP 0x0000:start

db 'MSWIN4.1'
dw 512
db 1
dw 1
db 2
dw 224
dw 2880
db 0xf0
dw 9
dw 18
dw 2
dd 0
dd 0

start:

CLI
CLD

XOR AX, AX
MOV DS, AX
MOV ES, AX
MOV SS, AX
MOV SP, 0x7C00
STI

CALL A20wait
MOV AL, 0xAD
OUT 0x64, AL

CALL A20wait
MOV AL, 0xD0
OUT 0x64, AL

CALL wait_2
IN AL, 0x60
PUSH AX

CALL A20wait
MOV AL, 0xD1
OUT 0x64, AL

CALL A20wait
POP AX
PUSH AX
CALL check_A20
CALL check_A20_mem

POP AX

OR AL, 2
OUT 0x60, AL

IN AL, 0x64
CALL print_hex

; detect after enabling
CALL A20wait
MOV AL, 0xD0
OUT 0x64, AL

CALL wait_2
IN AL, 0x60

CALL check_A20

CALL check_A20_mem

CALL A20wait
MOV AL, 0xAE
OUT 0x64, AL


CLI
HLT

A20wait:
  IN AL, 0x64
  TEST AL, 2
  JNZ A20wait
  RET

wait_2:
  IN AL, 0x64
  TEST AL, 1
  JZ wait_2
  RET

print:
  PUSH AX
  PUSH BX
  MOV BH, 0x00
  MOV BL, 0x07
  MOV AH, 0x0E
L1:
  LODSB
  TEST AL, AL
  JZ done_
  INT 0x10
  JMP L1

done_:
  POP BX
  POP AX
  RET

check_A20:

AND AL, 2
JZ A20_dis_
JMP A20_en_

A20_en_:
  MOV SI, A20EnMsg
  CALL print
  JMP exit_

A20_dis_:
  MOV SI, A20DisMsg
  CALL print

exit_:
  RET

print_hex:
    pusha               ; Save all registers
    mov cx, 2           ; We want to print 2 hex digits
.loop:
    rol al, 4           ; Rotate AL left by 4 bits (get high nibble)
    mov bl, al          ; Copy to BL
    and bl, 0x0F        ; Mask out the high 4 bits
    add bl, '0'         ; Convert 0-9 to ASCII '0'-'9'
    cmp bl, '9'         ; Is it > 9?
    jbe .print_it
    add bl, 7           ; Convert to 'A'-'F'
.print_it:
    push ax             ; Save AL (the rotated value)
    mov al, bl          ; Put char in AL for BIOS
    mov ah, 0x0E        ; BIOS Teletype
    int 0x10            ; Print character
    pop ax              ; Restore AL
    loop .loop          ; Do the second digit
    popa                ; Restore all registers
    ret

check_A20_with_mem:
  PUSH DS
  PUSH ES
  PUSH SI
  PUSH DI

  XOR AX, AX
  MOV DS, AX
  MOV SI, 0x0500

  NOT AX
  MOV ES, AX
  MOV DI, 0x0510

  MOV AL, [DS:SI]
  MOV BL, [ES:DI]

  MOV BYTE [DS:SI], 0x00
  MOV BYTE [ES:DI], 0xFF

  CMP BYTE [DS:SI], 0xFF

  MOV CX, 0
  JE end_func_
  MOV CX, 1

end_func_:
  MOV [DS:SI], AL
  MOV [ES:DI], BL

  MOV AX, CX

  POP DI
  POP SI
  POP ES
  POP DS
  RET

check_A20_mem:
  CALL check_A20_with_mem
  CMP AX, 1
  JE A20_On_

  MOV SI, A20_d_msg
  CALL print
  JMP exit_func_

A20_On_:
  MOV SI, A20_e_msg
  CALL print

exit_func_:
  RET

A20EnMsg DB " A20 is enabled", 0Dh, 0Ah, 0
A20DisMsg DB " A20 is disabled", 0Dh, 0Ah, 0
A20_e_msg DB "A20 is enabled (MEM)", 0x0D, 0x0A, 0
A20_d_msg DB "A20 is disabled (MEM)", 0x0D, 0x0A, 0


TIMES 510 - ($ - $$) DB 0
DW 0xAA55
