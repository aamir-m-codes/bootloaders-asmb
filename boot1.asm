[bits 16]
[org 0x7C00]

start:
  MOV SI, message
  print:
    LODSB
    CMP AL, 0
    JE done_
    MOV AH, 0x0E
    INT 0x10
    JMP print

  done_:
    CLI
    HLT

message db "Lets Start", 0

times 510 - ($ - $$) db 0
dw 0xAA55

