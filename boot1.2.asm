[bits 16]
[org 0x7C00]

start:
  MOV AX, 0xB800  ; segment
  MOV ES, AX
  MOV DI, 0x0000  ; offset

  MOV AL, 'D'
  MOV AH, 0x0C  ; high bits = 0 (Black Background), low bits 0x_C (red Foreground)
  MOV [ES:DI], AX
  CLI
  HLT

TIMES 510 - ($ - $$) db 0
DW 0xAA55

