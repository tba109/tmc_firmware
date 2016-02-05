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
#include "sys/alt_irq.h"
#include <stdlib.h>
#include "alt_types.h"
#include "altera_avalon_spi.h"


int main()
{
  unsigned short x = 0xFFFF;
  unsigned char conn = 0;
  unsigned char write_data[1];
  unsigned char read_data[3];
  unsigned char i = 0;
  unsigned char nrd = 0;

  printf("-----------------------------------------------------\n\n");
  printf("Hello, welcome to the TMC temperature readout program!\n");
  usleep(1000*1000);
  
  // Measurement loop
  while(1)
    {      
      // Check for new connectivity
      IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x));
      if(IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & 0x00000001)
	{
	  if(!conn)
	    {
	      printf("Temperature Board A is connected\n");
	      conn = 1;
	    }
	}  
      // Handle case where connection disappears
      else if(conn)
	{
	  printf("Temperature Board A disconnected\n");
	  conn = 0;
	}

      // Flip LED1
      IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x));
      x = ~(x & 0x80) | (x & 0x7F);

      // Measurement loop
      usleep(1000*1000);
      
      for(i = 0; i < 12; i++)
	{
	  // Let's not blast through
	  usleep(250*1000);

	  // Read from the ID register
	  write_data[0] = 0x45;
	  nrd = alt_avalon_spi_command(
				       SPI_0_BASE,
				       i,
				       sizeof(write_data),
				       (unsigned char *)&write_data,
				       1,
				       (unsigned char *)&read_data,
				       0
				       );
	  printf("ADC %d: Read 0x%02X,%d bytes from register 0x45\n",i,read_data[0],nrd);
	  
	  // Read from the gain register
	  write_data[0] = 0x71;
	  nrd = alt_avalon_spi_command(
				       SPI_0_BASE,
				       i,
				       sizeof(write_data),
				       (unsigned char *)&write_data,
				       sizeof(read_data),
				       (unsigned char *)&read_data,
				       0
				       );
	  printf("ADC %u: Read 0x%02X, 0x%02X, 0x%02X,%d bytes from register 0x71\n",i,read_data[2], read_data[1], read_data[0],nrd);
	  
	  read_data[0] = 0;
	}
    }
  return 0;
}
