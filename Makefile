IMAGE = sistem.img
CFLAGS = \
	-m32 \
	-std=c11 \
	-ffreestanding \
	-fno-pie \
	-fno-stack-protector \
	-fno-asynchronous-unwind-tables \
	-fno-unwind-tables \
	-Os 

all: $(IMAGE)

boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

bootloader.o: bootloader.c
	gcc \
		$(CFLAGS) \
		-c bootloader.c \
		-o bootloader.o
		

stage2.bin: bootloader.o linker_bootloader.ld
	ld \
		-m elf_i386 \
		-T linker_bootloader.ld \
		--oformat binary \
		bootloader.o \
		-o stage2.bin

kernel.o: kernel.c
	gcc \
		$(CFLAGS) \
		-c kernel.c \
		-o kernel.o

kernel.bin: kernel.o linker_kernel.ld
	ld \
		-m elf_i386 \
		-T linker_kernel.ld \
		--oformat binary \
		kernel.o \
		-o kernel.bin



$(IMAGE): boot.bin stage2.bin kernel.bin
	@echo "cek ukuran dari stage 1"
	@test $$(stat -c%s boot.bin) -eq 512 || \
		(echo "ERROR: boot.bin bukan 512 byte" && false)
	@echo "cek ukuran stage 2"
	@test $$(stat -c%s stage2.bin) -le 2048 || \
		(echo "ERROR: stage2.bin lebih besar dari 2048 byte" && false)
	@echo "cek ukuran kernel"
	@test $$(stat -c%s kernel.bin) -le 4096 || \
		(echo "ERROR: kernel.bin lebih besar dari 4096 byte" && false)
	cp stage2.bin stage2-padded.bin
	truncate -s 4048 stage2-padded.bin

	cp kernel.bin kernel-padded.bin
	truncate -s 4096 kernel-padded.bin
	
	cat boot.bin stage2-padded.bin kernel-padded.bin > $(IMAGE)
	truncate -s 1474560 $(IMAGE)

run: $(IMAGE)
	qemu-system-i386 \
		-drive format=raw,file=$(IMAGE),if=floppy

debug: $(IMAGE)
	qemu-system-i386 \
		-drive format=raw,file=$(IMAGE),if=floppy \
		-s \
		-S

info: boot.bin stage2.bin kernel.bin
	@echo "ukuran stage1: "
	@stat -c%s boot.bin
	
	@echo "ukuran stage2: "
	@stat -c%s stage2.bin

	@echo "kernel: "
	@stat -c%s kernel.bin

clean:
	rm -f \
		boot.bin \
		bootloader.o \
		stage2.bin \
		stage2-padded.bin \
		kernel.o \
		kernel.bin \
		kernel-padded.bin \
		$(IMAGE)



.PHONY: all run debug info clean
