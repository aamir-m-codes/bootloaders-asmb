[bits 16]
[org 0x7C00]

start:
  MOV [BOOT_DRIVE], DL
  XOR AX, AX
  MOV ES, AX
  MOV BX, 0x8000

  MOV AH, 0x02
  MOV AL, 1
  MOV CH, 0
  MOV CL, 2
  MOV DH, 0
  MOV DL, [BOOT_DRIVE]
  INT 0x13

  JC disk_error_

  JMP 0x0000:0x8000

  disk_error_:
    MOV AH, 0x0E
    MOV AL, 'E'
    INT 0x10
    CLI
    HLT

BOOT_DRIVE: DB 0

TIMES 510 - ($ - $$) DB 0
DW 0xAA55


MOV AH, 0x0E
MOV AL, 'S'
INT 0x10
CLI
HLT

TIMES 512 - (($ - $$) % 512) DB 0
