IMAGE = sistem.img

SECTOR_SIZE := 512
STAGE2_FIRST_SECTOR := 2
STAGE2_SECTORS := 4

KERNEL_FIRST_SECTOR := 6
KERNEL_SECTORS := 8

STAGE2_BYTES := $(shell echo $$(( $(STAGE2_SECTORS) * $(SECTOR_SIZE))))
KERNEL_BYTES := $(shell echo $$(( $(KERNEL_SECTORS) * $(SECTOR_SIZE))))

STAGE2_OFFSET := $(shell echo $$(( ($(STAGE2_FIRST_SECTOR) - 1) * $(SECTOR_SIZE))))
KERNEL_OFFSET := $(shell echo $$(( ($(KERNEL_FIRST_SECTOR) - 1) * $(SECTOR_SIZE))))

FLOPPY_SIZE := 1474560

CFLAGS = \
	-m32 \
	-std=c11 \
	-ffreestanding \
	-fno-builtin \
	-fno-pie \
	-fno-stack-protector \
	-fno-asynchronous-unwind-tables \
	-fno-unwind-tables \
	-Wall \
	-Wextra \
	-Os 

all: $(IMAGE) verify

boot.bin: boot.asm Makefile
	nasm \
		-f bin \
		-DSTAGE2_SECTORS=$(STAGE2_SECTORS) \
		-DSTAGE2_FIRST_SECTOR=$(STAGE2_FIRST_SECTOR) \
		-DKERNEL_SECTORS=$(KERNEL_SECTORS) \
		-DKERNEL_FIRST_SECTOR=$(KERNEL_FIRST_SECTOR) \
		boot.asm \
		-o boot.bin

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
	@test $$(stat -c%s boot.bin) -eq $(SECTOR_SIZE) || \
		(echo "ERROR: boot.bin bukan 512 byte" && false)
	@echo "cek ukuran stage 2"
	@test $$(stat -c%s stage2.bin) -le $(STAGE2_BYTES) || \
		(echo "ERROR: stage2.bin lebih besar dari 2048 byte" && false)
	@echo "cek ukuran kernel"
	@test $$(stat -c%s kernel.bin) -le $(KERNEL_BYTES) || \
		(echo "ERROR: kernel.bin lebih besar dari 4096 byte" && false)
	cp stage2.bin stage2-padded.bin
	truncate -s $(STAGE2_BYTES) stage2-padded.bin

	cp kernel.bin kernel-padded.bin
	truncate -s $(KERNEL_BYTES) kernel-padded.bin
	
	cat boot.bin stage2-padded.bin kernel-padded.bin > $(IMAGE)
	truncate -s $(FLOPPY_SIZE) $(IMAGE)

run: $(IMAGE)
	qemu-system-i386 \
		-drive format=raw,file=$(IMAGE),if=floppy

debug: $(IMAGE)
	qemu-system-i386 \
		-drive format=raw,file=$(IMAGE),if=floppy \
		-s \
		-S

verify: $(IMAGE)
	@echo "verif dari imagenya"

	@test $$(stat -c%s $(IMAGE)) -eq $(FLOPPY_SIZE) || \
		(echo "[ERROR]: ukuran image salah" && false)

	@test "verif stage 2 di offset $(STAGE2_OFFSET)"
	@dd \
		if=$(IMAGE) \
		bs=1 \
		skip=$(STAGE2_OFFSET) \
		count=$(STAGE2_BYTES) \
		status=none | \
		cmp - stage2-padded.bin

	@test "verif kernel di offset $(KERNEL_OFFSET)"
	@dd \
		if=$(IMAGE) \
		bs=1 \
		skip=$(KERNEL_OFFSET) \
		count=$(KERNEL_BYTES) \
		status=none | \
		cmp - kernel-padded.bin

	@echo "layout imagenya valid"

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



.PHONY: all run debug info verify clean
