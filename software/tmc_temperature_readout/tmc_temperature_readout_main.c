////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Sat Feb  6 11:13:15 EST 2016
//
// The goal here is to read data from 1 channel
////////////////////////////////////////////////////////////////////////////////////////
#include <stdio.h>
#include <unistd.h>
#include "altera_avalon_pio_regs.h"
#include "system.h"
#include "sys/alt_irq.h"
#include <stdlib.h>
#include "alt_types.h"
#include "altera_avalon_spi.h"
#include "ad7124_regs.h"

// Write nbytes bytes from data to the ADC with CSN corresponding to adc, in register reg. 
unsigned char ad7124_write_reg(unsigned char adc, unsigned char reg, unsigned int data, unsigned char nbytes)
{
  unsigned char write_data[5]; // a byte of command, plus up to 32 bits of data
  unsigned char i = 0;
  
  write_data[0] = AD7124_COMM_REG | AD7124_COMM_REG_WR | AD7124_COMM_REG_RA(reg);
  for(i=0; i<4; i++)
    if(i < nbytes)
      write_data[i+1] = (unsigned char)(data >> 8*(nbytes-i-1));
    else
      write_data[i+1] = 0;
      
  alt_avalon_spi_command(
			 SPI_0_BASE,
			 adc,
			 nbytes+1,
			 (unsigned char *)&write_data,
			 0,
			 NULL,
			 0
			 );
  return 0;
}

unsigned char ad7124_read_reg(unsigned char adc, unsigned char reg, unsigned int *data, unsigned char nbytes)
{
  unsigned char ret_val = 0;
  unsigned char write_data[1];
  unsigned char i = 0;
  unsigned char read_data[4];

  write_data[0] = AD7124_COMM_REG | AD7124_COMM_REG_RD | AD7124_COMM_REG_RA(reg);
  ret_val = alt_avalon_spi_command(
				   SPI_0_BASE,
				   adc,
				   sizeof(write_data),
				   (unsigned char *)&write_data,
				   nbytes,
				   (unsigned char *)&read_data,
				   0
				   );
  for(i=0; i<nbytes; i++)
    {
      // printf("%x\n",read_data[i]);
      *data |= ((unsigned int)read_data[i] << 8*(nbytes-i-1));
    }
  switch(nbytes)
    {
    case 1:
      *data &= 0x000000FF;
      break;
    case 2:
      *data &= 0x0000FFFF;
      break;
    case 3:
      *data &= 0x00FFFFFF;
      break;
    case 4:
      *data &= 0xFFFFFFFF;
      break;
    default:
      *data = 0;
    }

  return ret_val;
}

int main()
{
  unsigned char x = 0xFF;
  unsigned int data = 0;
  unsigned char nbytes = 0;
  
  ////////////////////////////////////
  // Startup
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x)); // enable I/O interface
  printf("-----------------------------------------------------\n\n");
  printf("Hello, welcome to the TMC temperature readout program!\n");
  nbytes = ad7124_read_reg(0,AD7124_ID_REG,&data,1);
  printf("ADC %d ID register has 0x%2X\n",0,data);
  usleep(1000*1000);
  
  /////////////////////////////////////
  // Measurement setup
  
  /* // full power mode, single acquisition */
  /* data = AD7124_ADC_CTRL_REG_POWER_MODE(0x3) | AD7124_ADC_CTRL_REG_MODE(0x1); */
  /* ad7124_write_reg(0,AD7124_ADC_CTRL_REG,data,2); */
  /* // read it back */
  /* data = 0; */
  /* ad7124_read_reg(0,AD7124_ADC_CTRL_REG,&data,2); */
  /* printf("ADC control register has 0x%04X\n",data); */

  // Measurement loop
  while(1)
    {      
      // Flip LED1
      IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x));
      x ^= 1 << 7;

      
      // Enable channel register 0, set for AIN12 as positive and AIN7 as negative
      // map to setup 0
      data = 
	AD7124_CH_MAP_REG_CH_ENABLE |
	AD7124_CH_MAP_REG_SETUP(0)  |
	AD7124_CH_MAP_REG_AINP(12)  |
	AD7124_CH_MAP_REG_AINM(7);
      ad7124_write_reg(2,AD7124_CH0_MAP_REG,data,2);
      // read it back
      data = 0;
      ad7124_read_reg(2,AD7124_CH0_MAP_REG,&data,2);
      printf("ADC channel 0 register has 0x%04X\n",data);
      
      // Configuration register: input and ref bufs enabled, set the PGA for 4, bipolar mode
      data = 
	AD7124_CFG_REG_BIPOLAR |
	AD7124_CFG_REG_REF_BUFP |
	AD7124_CFG_REG_REF_BUFM |
	AD7124_CFG_REG_AIN_BUFP |
	AD7124_CFG_REG_AIN_BUFM |
	AD7124_CFG_REG_PGA(2);
      ad7124_write_reg(2,AD7124_CFG0_REG,data,2);
      // read it back
      data = 0;
      ad7124_read_reg(2,AD7124_CFG0_REG,&data,2);
      printf("ADC filter 0 register has 0x%04X\n",data);
      
      // Filter register: select defaults, except go for a 7.5Hz zero lantency measurement. 
      data = 
	AD7124_FILT_REG_FILTER(0) |
	AD7124_FILT_REG_REJ60 |
	AD7124_FILT_REG_POST_FILTER(3) |
	AD7124_FILT_REG_FS(640);
      
      // full power mode, single acquisition
      data = AD7124_ADC_CTRL_REG_POWER_MODE(0x3) | AD7124_ADC_CTRL_REG_MODE(0x1);
      ad7124_write_reg(2,AD7124_ADC_CTRL_REG,data,2);
      // read it back
      data = 0;
      ad7124_read_reg(2,AD7124_ADC_CTRL_REG,&data,2);
      printf("ADC control register has 0x%04X\n",data); 
            
      // Read the data conversion register
      data = 0;
      ad7124_read_reg(2,AD7124_DATA_REG,&data,3);
      printf("ADC conversion register has 0x%06X\n",data);
      
      // Wait a while
      usleep(250*1000);      
    }
  return 0;
}
