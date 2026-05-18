[bits 16]
[org 0x7C00]

start:
  MOV [Drive], DL

  CLI
  XOR AX, AX
  MOV SS, AX
  MOV DS, AX
  MOV ES, AX
  MOV BX, 0x7E00
  MOV SP, 0x7C00
  STI
  CLD

  MOV SI, message1
  print:
    LODSB
    CMP AL, 0
    JE done_

    MOV AH, 0x0E
    INT 0x10
    JMP print

  done_:
  MOV AL, 1
  MOV AH, 0x02
  MOV CL, 2
  MOV CH, 0
  MOV DL, [Drive]
  MOV DH, 0
  INT 0x13

  JC disk_error_
 
  JMP 0x0000:0x7E00

  disk_error_:
    MOV SI, disk_err_message
    print_err:
      LODSB
      CMP AL, 0
      JE exit_

      MOV AH, 0x0E
      INT 0x10
      JMP print_err

      exit_:
        CLI
        HLT

Drive: db 0
message1 DB "Sector 1", 0Dh, 0Ah, 0
disk_err_message DB "Disk Error", 0Dh, 0Ah, 0
TIMES 510 - ( $ - $$) DB 0
DW 0xAA55

MOV SI, message2
print_mes:
  LODSB
  CMP AL, 0
  JE end_

  MOV AH, 0x0E
  INT 0x10
  JMP print_mes

end_:
  CLI
  HLT

message2 DB "Sector 2", 0Dh, 0Ah, 0

TIMES 512 - (($ - $$) % 512) DB 0

