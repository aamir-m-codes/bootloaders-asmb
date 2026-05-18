[bits 16]
[org 0x7C00]

CLI
XOR AX, AX
MOV DS, AX
MOV SS, AX
MOV SP, 0x7C00
MOV AX, 0x8000
MOV ES, AX
MOV DI, 0x0000
STI
CLD

MOV SI, message
print:
  LODSB
  CMP AL, 0
  JE done_
  MOV AH, 0x0E
  INT 0x10
  JMP print

done_:
XOR EBX, EBX
next_entry:
  MOV EAX, 0xE820
  MOV ECX, 20
  MOV EDX, 0x534D4150
  INT 0x15
  JC exit_
  ADD DI, 20
  CMP EBX, 0
  JNZ next_entry

MOV SI, header
print_header:
  LODSB
  CMP AL, 0
  JE done1_
  MOV AH, 0x0E
  INT 0x10
  JMP print_header

done1_:
XOR SI, SI
MOV AX, ES
print_entry:
  MOV EAX, ES:[SI + 16]
  test EAX, EAX
  JZ exit_
  
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
  JMP print_entry


exit_:
CLI
HLT

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

  JMP exit_type_

free_:
  MOV SI, free_msg
  JMP print_loop

reser_:
  MOV SI, reserved_msg

print_loop:
  LODSB
  CMP AL, 0
  JE exit_type_
  MOV AH, 0x0E
  INT 0x10
  JMP print_loop

exit_type_:
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

message DB "Memory Layout:", 0Dh, 0Ah, 0
header DB "Base Address        Length              Type", 0Dh, 0Ah, 0
free_msg DB "Free Memory (1)", 0
reserved_msg DB "Reserved Memory (2)", 0

TIMES 510 - ($ - $$) DB 0
DW 0xAA55
