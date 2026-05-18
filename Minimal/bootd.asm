[bits 16]
[org 0x7C00]

start:
  CLI
  HLT

TIMES 510 - ($ - $$) DB 0
DW 0xAA55
