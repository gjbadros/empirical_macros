#define stdout (&__iob [1])

#define putc(c, fp) _IO_putc(c, fp)

#define putchar(c) putc(c, stdout)

putchar(h)
