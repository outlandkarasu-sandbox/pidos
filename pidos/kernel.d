module kernel;

import ldc.llvmasm;
import core.bitop: volatileLoad, volatileStore;

/**
 *  original AA
 *  simdnyan/d-man.aa
 *  https://gist.github.com/simdnyan/20e8fa2a2736c315e2c1
 */
immutable DMAN_AA = `
  _   _
 (_) (_)
/______ \
\\(O(O \/
 | | | |
 | |_| |
/______/
 <   >
(_) (_)
`;

/**
 *  translated from OSDev.org RPi bare bones C kernel to D.
 *  http://wiki.osdev.org/Raspberry_Pi_Bare_Bones
 */

// Memory-Mapped I/O output
void mmio_write(uint reg, uint data) {
    volatileStore(cast(uint*)reg, data);
}
 
// Memory-Mapped I/O input
uint mmio_read(uint reg) {
    return volatileLoad(cast(uint*)reg);
}
 
// Loop <delay> times in a way that the compiler won't optimize away
void delay(int count) {
    __asm(`
        1: subs $0, $0, #1;
        bne 1b
        `, "r,~{cpsr}", count);
}
 
enum
{
    // The GPIO registers base address.
    GPIO_BASE = 0x3F200000, // for raspi2 & 3, 0x20200000 for raspi1
 
    // The offsets for reach register.
 
    // Controls actuation of pull up/down to ALL GPIO pins.
    GPPUD = (GPIO_BASE + 0x94),
 
    // Controls actuation of pull up/down for specific GPIO pin.
    GPPUDCLK0 = (GPIO_BASE + 0x98),
 
    // The base address for UART.
    UART0_BASE = 0x3F201000, // for raspi2 & 3, 0x20201000 for raspi1
 
    // The offsets for reach register for the UART.
    UART0_DR     = (UART0_BASE + 0x00),
    UART0_RSRECR = (UART0_BASE + 0x04),
    UART0_FR     = (UART0_BASE + 0x18),
    UART0_ILPR   = (UART0_BASE + 0x20),
    UART0_IBRD   = (UART0_BASE + 0x24),
    UART0_FBRD   = (UART0_BASE + 0x28),
    UART0_LCRH   = (UART0_BASE + 0x2C),
    UART0_CR     = (UART0_BASE + 0x30),
    UART0_IFLS   = (UART0_BASE + 0x34),
    UART0_IMSC   = (UART0_BASE + 0x38),
    UART0_RIS    = (UART0_BASE + 0x3C),
    UART0_MIS    = (UART0_BASE + 0x40),
    UART0_ICR    = (UART0_BASE + 0x44),
    UART0_DMACR  = (UART0_BASE + 0x48),
    UART0_ITCR   = (UART0_BASE + 0x80),
    UART0_ITIP   = (UART0_BASE + 0x84),
    UART0_ITOP   = (UART0_BASE + 0x88),
    UART0_TDR    = (UART0_BASE + 0x8C),
};
 
void uart_init() {
    // Disable UART0.
    mmio_write(UART0_CR, 0x00000000);
    // Setup the GPIO pin 14 && 15.
 
    // Disable pull up/down for all GPIO pins & delay for 150 cycles.
    mmio_write(GPPUD, 0x00000000);
    delay(150);
 
    // Disable pull up/down for pin 14,15 & delay for 150 cycles.
    mmio_write(GPPUDCLK0, (1 << 14) | (1 << 15));
    delay(150);
 
    // Write 0 to GPPUDCLK0 to make it take effect.
    mmio_write(GPPUDCLK0, 0x00000000);
 
    // Clear pending interrupts.
    mmio_write(UART0_ICR, 0x7FF);
 
    // Set integer & fractional part of baud rate.
    // Divider = UART_CLOCK/(16 * Baud)
    // Fraction part register = (Fractional part * 64) + 0.5
    // UART_CLOCK = 3000000; Baud = 115200.
 
    // Divider = 3000000 / (16 * 115200) = 1.627 = ~1.
    mmio_write(UART0_IBRD, 1);
    // Fractional part register = (.627 * 64) + 0.5 = 40.6 = ~40.
    mmio_write(UART0_FBRD, 40);
 
    // Enable FIFO & 8 bit data transmissio (1 stop bit, no parity).
    mmio_write(UART0_LCRH, (1 << 4) | (1 << 5) | (1 << 6));
 
    // Mask all interrupts.
    mmio_write(UART0_IMSC, (1 << 1) | (1 << 4) | (1 << 5) | (1 << 6) |
               (1 << 7) | (1 << 8) | (1 << 9) | (1 << 10));
 
    // Enable UART0, receive & transfer part of UART.
    mmio_write(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
}
 
void uart_putc(ubyte c) {
    // Wait for UART to become ready to transmit.
    while ( mmio_read(UART0_FR) & (1 << 5) ) {
        delay(1);
    }
    mmio_write(UART0_DR, c);
}
 
ubyte uart_getc() {
    // Wait for UART to have received something.
    while ( mmio_read(UART0_FR) & (1 << 4) ) {
        delay(1);
    }
    return cast(ubyte) mmio_read(UART0_DR);
}
 
void uart_puts(string str) {
    foreach(c; str) {
        uart_putc(cast(ubyte)c);
    }
}
 
extern(C) void kernel_main(uint r0, uint r1, uint atags) {
    uart_init();
    while ( mmio_read(UART0_FR) & (1 << 5) ) {
        delay(1);
    }
    for(;;) {
        switch(uart_getc()) {
        case 'd':
        case 'D':
            uart_puts(DMAN_AA);
            break;
        default:
            break;
        }
    }
}
