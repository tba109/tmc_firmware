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

#define N_ADC 12 // 3 ADC/board x 4 boards
#define N_CHAN 6 // 6 channels/board

// Write nbytes bytes from data to the ADC with CSN corresponding to adc, reg 
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
  const unsigned char pchan_b[6] = {12,10,8,5,3,1};
  const unsigned char nchan_c[6] = {7,7,7,7,7,7};
  unsigned char sys_chan[4][6];
  unsigned int data_arr[4][6];
  unsigned char adc = 0;
  unsigned char chan = 0;

  for(adc=0;adc<4;adc++)
    for(chan=0;chan<6;chan++)
      sys_chan[adc][chan] = chan+6*adc;

  ////////////////////////////////////
  // Startup
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x)); // enable I/O interface
  printf("-----------------------------------------------------\n\n");
  printf("Hello, welcome to the TMC temperature readout program!\n");
  nbytes = ad7124_read_reg(0,AD7124_ID_REG,&data,1);
  printf("ADC %d ID register has 0x%2X\n",0,data);
  usleep(160*1000);
  
  /////////////////////////////////////
  // Measurement loop
  while(1)
    {      
      // Flip LED1
      IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x));
      x ^= 1 << 7;
      for(chan = 0; chan < N_CHAN; chan++)
      	{
	  // usleep(1000*1000);

	  for(adc = 0; adc < N_ADC; adc++)
	    {
	      // Enable channel register 0, set positive and negative and
	      // map to setup 0
	      data = 
		AD7124_CH_MAP_REG_CH_ENABLE |
		AD7124_CH_MAP_REG_SETUP(0)  |
		AD7124_CH_MAP_REG_AINP(pchan_b[chan])  |
		AD7124_CH_MAP_REG_AINM(nchan_c[chan]);
	      ad7124_write_reg(adc,AD7124_CH0_MAP_REG,data,2);
	      // read it back
	      data = 0;
	      usleep(1000);
	      // ad7124_read_reg(adc,AD7124_CH0_MAP_REG,&data,2);
	      // printf("ADC_%d CHAN_%d: channel register has 0x%04X\n",adc,chan,data);
	      
	      // Configuration register: input and ref bufs enabled, 
	      // set the PGA for 4, bipolar mode
	      data = 
		AD7124_CFG_REG_BIPOLAR |
		AD7124_CFG_REG_REF_BUFP |
		AD7124_CFG_REG_REF_BUFM |
		AD7124_CFG_REG_AIN_BUFP |
		AD7124_CFG_REG_AIN_BUFM |
		AD7124_CFG_REG_PGA(2);
	      ad7124_write_reg(adc,AD7124_CFG0_REG,data,2);
	      // read it back
	      data = 0;
	      usleep(1000);
	      // ad7124_read_reg(adc,AD7124_CFG0_REG,&data,2);
	      // printf("ADC_%d CHAN_%d: filter register has 0x%04X\n",adc,chan,data);
	      
	      // Filter register: select defaults, except go for a 7.5Hz zero lantency measurement. 
	      data = 
		AD7124_FILT_REG_FILTER(0) |
		AD7124_FILT_REG_REJ60 |
		AD7124_FILT_REG_POST_FILTER(3) |
		AD7124_FILT_REG_FS(640);
	      
	      // full power mode, single acquisition
	      data = AD7124_ADC_CTRL_REG_POWER_MODE(0x3) | AD7124_ADC_CTRL_REG_MODE(0x1);
	      ad7124_write_reg(adc,AD7124_ADC_CTRL_REG,data,2);
	      // read it back
	      data = 0;
	      usleep(1000);
	      // ad7124_read_reg(adc,AD7124_ADC_CTRL_REG,&data,2);
	      // printf("ADC_%d CHAN_%d: control register has 0x%04X\n",adc,chan,data); 
	    }
	  
	  // Read the data conversion register
	  // Conversion should take 133ms
	  usleep(160*1000);
	  for(adc = 0; adc < N_ADC; adc++)
	    {
	      data = 0;
	      ad7124_read_reg(adc,AD7124_DATA_REG,&data,3);
	      // printf("ADC%d, CHAN%d conversion register has 0x%06X\n",adc,chan,data);
	      data_arr[adc][chan] = data;
	    }
	  
	}
      
      // Here's the printing section
      printf("---------------------------------\n");
      printf("        ");
      for(adc=0; adc < N_ADC; adc++)
	printf("    ADC_%02d",adc);
      printf("\n");
      
      for(chan=0; chan < N_CHAN; chan++)
	{
	  printf("CHAN_%d  ",chan);
	  for(adc=0; adc < N_ADC; adc++)
	    printf("  0x%06X",data_arr[adc][chan] & 0x00FFFFFF);
	  printf("\n");
	}
    }
  return 0;
}
      
