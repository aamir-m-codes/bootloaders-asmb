[bits 16]
[org 0x7C00]

JMP start

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
  XOR AX, AX
  MOV DS, AX
  MOV SS, AX
  MOV SP, 0x7C00
  MOV AX, 0x7000
  MOV ES, AX
  MOV DI, 0
  MOV [DRIVE_LETTER], DL
  STI
  CLD

MOV AX, 0x0003
INT 0x10
MOV AX, 0x1112   ; AH=11h (font), AL=12h (load 8x8 ROM)
MOV BL, 0x00     ; BL=00h (block)
INT 0x10

MOV AH, 0x01
MOV CX, 0x0607   ; Set cursor scan lines
INT 0x10

MOV SI, message
CALL print_message

XOR EBX, EBX
XOR BP, BP
next_entry:
  MOV EAX, 0xE820
  MOV ECX, 20
  MOV EDX, 0x534D4150
  INT 0x15
  INC BP
  JC last_entry_
  ADD DI, 20
  TEST EBX, EBX
  JZ all_done_

  JMP next_entry

last_entry_:
  ADD DI, 20

all_done_:

XOR SI, SI
MOV AX, ES
XOR DX, DX

print_entry:
 test BP, BP
 JZ exit_

 CMP DX, 45
 JNE .skip_pause
 CALL wait_for_key
 XOR DX, DX

.skip_pause:

  CALL print_prefix
  MOV EBX, ES:[SI + 4]
  CALL print_hex_32
  MOV EBX, ES:[SI]
  CALL print_hex_32

  CALL print_space
  CALL print_space

  CALL print_prefix
  MOV EBX, ES:[SI + 12]
  CALL print_hex_32
  MOV EBX, ES:[SI + 8]
  CALL print_hex_32

  CALL print_space
  CALL print_space

  MOV EBX, ES:[SI + 16]
  CALL print_type

  CALL print_newline
  ADD SI, 20
  INC EDX
  DEC BP
  JMP print_entry


exit_:

XOR AX, AX
MOV DL, [DRIVE_LETTER]
INT 0x13
JC Disk_ERR_

MOV AX, 0x0000
MOV ES, AX
MOV BX, 0x8000

MOV AH, 0x02
MOV AL, 1
MOV CL, 2
MOV CH, 0
MOV DH, 0
MOV DL, [DRIVE_LETTER]
INT 0x13

JC Disk_ERR_

JMP 0x0000:0x8000

Disk_ERR_:
  MOV SI, disk_err_msg
  CALL print_message
  CLI
  HLT

wait_for_key:
  MOV SI, pause_msg
  CALL print_message
  XOR AH, AH
  INT 0x16

  CALL print_newline
  RET

print_prefix:
  PUSHAD
  MOV AH, 0x0E
  MOV AL, '0'
  INT 0x10

  MOV AL, 'x'
  INT 0x10
  POPAD
  RET

print_hex_32:
  PUSHAD

  MOV CX, 8
_loop:
  ROL EBX, 4
  MOV AL, BL
  AND AL, 0x0F
  ADD AL, '0'
  CMP AL, '9'
  JBE output_
  ADD AL, 7

output_:
  MOV AH, 0x0E
  INT 0x10
  LOOP _loop

  POPAD
  RET

print_type:
  PUSHAD
  CMP EBX, 1
  JE free_
  CMP EBX, 2
  JE reser_

  MOV SI, other_msg
  JMP show_

free_:
  MOV SI, free_msg
  JMP show_

reser_:
  MOV SI, reserved_msg

show_:
  CALL print_message
  POPAD
  RET

print_space:
  PUSHAD
  MOV AX, 0x0E20
  INT 0x10
  POPAD
  RET

print_newline:
  PUSHAD
  MOV AH, 0x0E
  MOV AL, 0x0D
  INT 0x10
  MOV AL, 0x0A
  INT 0x10
  POPAD
  RET

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

DRIVE_LETTER: DB 0
message DB "Memory Layout:", 0Dh, 0Ah, 0
free_msg DB "[Free]", 0
reserved_msg DB "[Reserved]", 0
other_msg DB "[Other]", 0
pause_msg DB "Press any key for more", 0
disk_err_msg DB "D Err1", 0

TIMES 510 - ($ - $$) DB 0
DW 0xAA55
