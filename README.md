# eduOS

eduOS is a real operating system project for kids, starting from a freestanding kernel and boot process.

This repository currently includes:
- A bootable 64-bit kernel (`_start`) built with a linker script.
- Limine bootloader integration.
- ISO image generation for BIOS/UEFI boot.
- QEMU run target for local testing.

## Why eduOS

The long-term goal is an OS where students can:
- Learn core CS concepts by interacting with system components.
- Write tiny programs in a safe sandbox.
- Explore graphics, files, and networking in age-appropriate lessons.

## Current Project Layout

- `src/kernel/main.c`: Kernel entrypoint and first terminal output.
- `linker.ld`: Freestanding kernel memory layout and entry symbol.
- `config/limine.conf`: Boot menu configuration.
- `Makefile`: Build, ISO packaging, and QEMU run commands.

## Prerequisites (Linux)

Install build tools and emulator:

```bash
sudo apt update
sudo apt install -y make git xorriso qemu-system-x86
```

Install or provide a freestanding toolchain:
- Preferred: `x86_64-elf-gcc` and `x86_64-elf-ld`
- Alternative: `clang` + `ld.lld` (see command below)

## Build

Default build (cross-compiler):

```bash
make iso
```

Build with clang/lld targeting freestanding ELF:

```bash
make clean
make CC=clang LD=ld.lld CFLAGS='-std=gnu11 -ffreestanding -fno-stack-protector -fno-pic -m64 -mno-red-zone -O2 -Wall -Wextra --target=x86_64-elf'
```

Output files:
- `build/eduos.elf`
- `build/eduos.iso`

## Run (QEMU Graphic)

```bash
make run-gui
```

You should see a QEMU window, the Limine boot entry, then the eduOS kernel banner.

## Run (QEMU No Graphic / Headless)

```bash
make run-headless
```

This mode uses QEMU debug console output (`port 0xE9`) so the kernel banner appears directly in your terminal.

## Quick Start

```bash
make iso
make run-gui
# or
make run-headless
```

## Development Roadmap

Phase 1: Kernel foundations
- Interrupt descriptor table (IDT) and exception handlers.
- Physical + virtual memory management.
- Timer and simple cooperative scheduler.

Phase 2: Learning-first user environment
- Text-mode shell with kid-friendly commands (`learn`, `draw`, `math`, `code`).
- Tiny bytecode interpreter for beginner coding lessons.
- Virtual file system for lesson packs and saved projects.

Phase 3: Safety and classroom features
- Sandboxed app model.
- Teacher control panel and lesson deployment.
- Activity logs and progress tracking.

Phase 4: Hardware and polish
- Graphics mode with educational UI.
- Input/audio/network drivers.
- Installer image and release process.

## Notes

- The repository clones Limine into `.limine/` during build.
- This is an early kernel prototype intended to grow into a complete OS.
