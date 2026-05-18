[bits 16]
[org 0x7C00]

start:

  CLI
  XOR AX, AX
  MOV DS, AX
  MOV ES, AX
  MOV SS, AX
  MOV SP, 0x7C00
  CLD
  STI

  MOV AH, 0x00
  MOV AL, 0x12
  INT 0x10

  MOV SI, message
  print:
    LODSB
    CMP AL, 0
    JE done_
    MOV AH, 0x0E
    MOV BH, 0x00  ; page no set to 0
    MOV BL, 0x0F  ; set color white (0x0F)
    INT 0x10
    JMP print

  done_:
    CLI
    HLT

message DB "Message in Graphics Mode", 0

times 510 - ($ - $$) db 0
dw 0xAA55

