AS = as
LD = ld

ASF = --32
LDF = -m elf_i386 -s -Ttext 0x0

BOOT_BIN=boot/boot.bin
BOOT_SRC=boot/bootsect.s
BOOT_O=boot/bootsect.o
BOOT=boot/bootsect.out

ALL : $(BOOT_BIN)
	dd if=/dev/zero of=a.img bs=512 count=1440
	dd if=$(BOOT_BIN) of=a.img bs=512 count=1 conv=notrunc
$(BOOT_BIN): $(BOOT_SRC)
	$(AS) $(ASF) -o $(BOOT_O) $<
	$(LD) $(LDF) -o $(BOOT) $(BOOT_O) 
	objcopy -O binary $(BOOT) $@
	

