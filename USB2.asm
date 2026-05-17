[bits 16]
[org 0x8000]

MOV [SAVED_DRIVE], DL

XOR AX, AX
MOV DS, AX

MOV AX, 0x7000
MOV ES, AX
XOR BX, BX

POP DX
MOV AH, 0x03
MOV AL, 1
MOV CL, 4
MOV CH, 0
MOV DH, 0
MOV DL, [SAVED_DRIVE]
INT 0x13

JC disk_error_

; Print a message so you know it's finished
mov si, reboot_msg
CALL print_message

; Wait for a keypress (BIOS INT 16h)
xor ah, ah
int 0x16

; Cold Reboot via Keyboard Controller
mov al, 0xFE
out 0x64, al

; If that fails, jump to BIOS reset vector
jmp 0xFFFF:0x0000

disk_error_:
  MOV SI, disk_error_msg
  CALL print_message
  CLI
  HLT


print_message:
  MOV AH, 0x0E
.l_:
  LODSB
  TEST AL, AL
  JZ .d_
  INT 0x10
  JMP .l_
.d_:
  RET


SAVED_DRIVE DB 0
disk_error_msg DB "Error in disk operation", 0Dh, 0Ah, 0
reboot_msg DB 0Dh, 0Ah, "key to reboot", 0

TIMES 512 - ($ - $$) DB 0
