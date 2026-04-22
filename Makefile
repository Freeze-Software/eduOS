KERNEL := build/eduos.elf
ISO := build/eduos.iso
LIMINE_DIR := .limine

CC ?= x86_64-elf-gcc
LD ?= x86_64-elf-ld
CFLAGS := -std=gnu11 -ffreestanding -fno-stack-protector -fno-pic -m64 -mno-red-zone -O2 -Wall -Wextra
LDFLAGS := -T linker.ld -nostdlib

KERNEL_SRC := $(shell find src -name '*.c')
KERNEL_OBJ := $(patsubst src/%.c,build/%.o,$(KERNEL_SRC))

.PHONY: all kernel iso run run-gui run-headless clean toolchain limine

all: iso

kernel: limine $(KERNEL)

$(KERNEL): $(KERNEL_OBJ) linker.ld
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_OBJ)

build/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -I$(LIMINE_DIR) -c $< -o $@

limine:
	@if [ ! -d "$(LIMINE_DIR)" ]; then \
		git clone --depth=1 https://github.com/limine-bootloader/limine.git $(LIMINE_DIR); \
	fi
	$(MAKE) -C $(LIMINE_DIR)

iso: kernel limine
	@mkdir -p build/iso_root/boot
	cp $(KERNEL) build/iso_root/boot/eduos.elf
	cp config/limine.conf build/iso_root/boot/limine.conf
	cp $(LIMINE_DIR)/limine-bios.sys build/iso_root/boot/
	cp $(LIMINE_DIR)/limine-bios-cd.bin build/iso_root/boot/
	cp $(LIMINE_DIR)/limine-uefi-cd.bin build/iso_root/boot/
	xorriso -as mkisofs \
		-b boot/limine-bios-cd.bin \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		--efi-boot boot/limine-uefi-cd.bin \
		-efi-boot-part \
		--efi-boot-image \
		--protective-msdos-label \
		build/iso_root -o $(ISO)
	$(LIMINE_DIR)/limine bios-install $(ISO)

run: run-gui

run-gui: iso
	qemu-system-x86_64 -m 256M -cdrom $(ISO)

run-headless: iso
	qemu-system-x86_64 -m 256M -cdrom $(ISO) -display none -serial none -monitor none -debugcon stdio -global isa-debugcon.iobase=0xe9

toolchain:
	@echo "Install a cross-compiler named x86_64-elf-gcc and x86_64-elf-ld before building."
	@echo "If you use clang/lld, run: make CC=clang LD=ld.lld CFLAGS='$(CFLAGS) --target=x86_64-elf'"

clean:
	rm -rf build
