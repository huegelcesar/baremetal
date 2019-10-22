#include <stdint.h>
#define UART0_BASE 0x1c090000

void start() {
    *(volatile uint32_t *)(UART0_BASE) = 'A';
    *(volatile uint32_t *)(UART0_BASE) = 'B';
    *(volatile uint32_t *)(UART0_BASE) = 'C';
    *(volatile uint32_t *)(UART0_BASE) = 'D';
}