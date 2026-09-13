BOOTLOADER = bootloader.img

all: $(BOOTLOADER)

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

bootloader.o: bootloader.c
	gcc \
		-m32 \
		-std=c11 \
		-ffreestanding \
		-fno-pie \
		-fno-stack-protector \
		-fno-asynchronous-unwind-tables \
		-fno-unwind-tables \
		-Os \
		-c bootloader.c \
		-o bootloader.o

tahap2.bin: bootloader.o linker.ld
	ld \
		-m elf_i386 \
		-T linker.ld \
		--oformat binary \
		bootloader.o \
		-o tahap2.bin

run: $(BOOTLOADER)
	qemu-system-i386 \
		-drive format=raw,file=$(BOOTLOADER),if=floppy

$(BOOTLOADER): boot.bin tahap2.bin
	cp tahap2.bin tahap2-padded.bin
	truncate -s 4096 tahap2-padded.bin
	
	cat boot.bin tahap2-padded.bin > $(BOOTLOADER)
	truncate -s 1474560 $(BOOTLOADER)

clean:
	rm -f \
		boot.bin \
		bootloader.o \
		tahap2.bin \
		tahap2-padded.bin \
		bootloader.img

.PHONY: all run clean
