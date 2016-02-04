/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <unistd.h>
#include "altera_avalon_pio_regs.h"
#include "system.h"
int main()
{
  unsigned short x = 0xFFFF;
  while(1)
    {
      usleep(1000*1000);
      printf("Hello, I've done it again!\n");
      IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x));
      x = ~x;
    }
  return 0;
}
