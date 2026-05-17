# Bootloaders - Assembly Language

This repository have some basic **`bootloader`** that not even run on virtual machine but also in real hardware **`bare metal`**.

## `What is Bootloader` ?

**`Bootloader`** in system is the program that executed first (initiate program) after system start.

## `Purpose for this repository` ?

To explore the hidden journey of program **`Bootloader`** that execute from our sight every time we start computer or any system.

## Types of Bootloader in this repository:
```
1. Minimal Bootloader
2. Clean Environment Bootloader
3. Multi-Sector Bootloader
4. Memory-Aware Bootloader
5. A20 & High Memory Loader
```

## 🛠️ How to Run

### 1. Clone the Repository:
```bash
  git clone https://github.com/aamir-m-codes/bootloaders-asmb.git

  cd bootloaders-asmb
```

### 2. Assemble any bootloader:
```bash
  # Must be assemble in bin file

  nasm boot.asm -f bin -o boot.bin
```

### 3. Run on Virtual Machine e.g **`Qemu`**:
```bash
  # To just execute

  qemu-system-i386 -drive format=raw,file=boot.bin
```
> To download or install *[Qemu](https://www.qemu.org/download/)*

---
*Maintain by [@aamir-m-codes](https://github.com/aamir-m-codes)*


