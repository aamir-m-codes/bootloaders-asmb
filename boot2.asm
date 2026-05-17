[bits 16]
[org 0x7C00]

start:
  CLI
  XOR AX, AX
  MOV DS, AX
  MOV SS, AX
  MOV SP, 0x7C00
  STI
  CLD

  PUSH message

  CALL func
  ADD SP, 2

  CLI
  HLT


func:
  PUSH BP
  MOV BP, SP

  MOV SI, [BP + 4]

  MOV AX, 0xB800
  MOV ES, AX
  MOV DI, 0x0000
  MOV AH, 0x01

  print:
    LODSB
    CMP AL, 0
    JE done_
    MOV [ES:DI], AX
    INC DI
    INC DI
    JMP print

  done_:
    MOV SP, BP
    POP BP
    RET



message DB "Control", 0

TIMES 510 - ($ - $$) DB 0
DW 0xAA55



