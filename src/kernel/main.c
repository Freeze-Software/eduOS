#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include <limine.h>

__attribute__((used, section(".limine_requests")))
static volatile LIMINE_BASE_REVISION(3);

__attribute__((used, section(".limine_requests")))
static volatile struct limine_terminal_request terminal_request = {
    .id = LIMINE_TERMINAL_REQUEST,
    .revision = 0,
    .response = 0
};

__attribute__((used, section(".limine_requests_start")))
static volatile LIMINE_REQUESTS_START_MARKER;

__attribute__((used, section(".limine_requests_end")))
static volatile LIMINE_REQUESTS_END_MARKER;

static void halt_forever(void) {
    for (;;) {
        __asm__ volatile ("hlt");
    }
}

static void debugcon_putc(char ch) {
    __asm__ volatile ("outb %0, $0xe9" : : "a"(ch));
}

static void debugcon_write(const char *text, uint64_t length) {
    for (uint64_t i = 0; i < length; i++) {
        debugcon_putc(text[i]);
    }
}

void _start(void) {
    if (!LIMINE_BASE_REVISION_SUPPORTED) {
        halt_forever();
    }

    if (terminal_request.response == 0 || terminal_request.response->terminal_count < 1) {
        halt_forever();
    }

    struct limine_terminal *terminal = terminal_request.response->terminals[0];
    void (*terminal_write)(struct limine_terminal *, const char *, uint64_t) = terminal_request.response->write;

    const char *banner =
        "eduOS kernel booted!\\n"
        "Welcome to a real educational operating system prototype.\\n"
        "Next: memory manager, scheduler, and student-friendly userland.\\n";
    uint64_t banner_len = 0;
    while (banner[banner_len] != '\0') {
        banner_len++;
    }

    terminal_write(terminal, banner, banner_len);
    debugcon_write(banner, banner_len);

    halt_forever();
}
