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
#include "altera_avalon_timer_regs.h"

#define N_ADC 12 // 3 ADC/board x 4 boards
#define N_CHAN 6 // 6 channels/board
#define N_BRD 4 // 4 boards

#define MAJOR_VERSION_NUMBER 1

#define MINOR_VERSION_NUMBER 0

// Number of calibration and housekeeping operations to perform
#define N_CAL_HK 8

// Board temperature
#define HK_BD_TEMP 0

// ADC on-chip temperature sensor
#define HK_ADC_TEMP 1

// Currents 
#define HK_CURRENT_MIN 2
#define HK_CURRENT_MAX 7

// Calibration 
#define CALIBRATE 8

// Constants
const unsigned char pchan_2n2222[N_CHAN] = {12,10,8,5,3,1};
const unsigned char nchan_2n2222 = 7;
const unsigned char pchan_current[N_CHAN] = {13,11,9,6,4,2};
const unsigned char nchan_current[N_CHAN] = {12,10,8,5,3,1};
const unsigned char pchan_board_temp = 14;
const unsigned char nchan_board_temp = 15;
const unsigned char pchan_adc_temp = 0x10; // temperature sensor
const unsigned char nchan_adc_temp = 0x11; // VSS

// This keeps track of when the loop is done
volatile unsigned char loop_done;

// 160us wait
#define USLEEP_160MS 115*1000  // oddly, this seems to give the ~160ms delay

////////////////////////////////////////////////////////////////////////////////////////
// Handle timer interrupts
static void handle_timer_interrupts(void* context)
{
  IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_0_BASE,0);//Clear TO(timeout) bit)
  loop_done = 1;
}

////////////////////////////////////////////////////////////////////////////////////////
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
  *data = 0; // Missing this was a frustrating bug!
  for(i=0; i<nbytes; i++)
    {
      // printf("%x\n",read_data[i]);
      *data |= ((unsigned int)read_data[i] << 8*(nbytes-i-1));
    }
  // printf("read reg data = %d\n",*data);
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

unsigned char print_table(unsigned int (*data_arr)[N_CHAN])
{
  unsigned char adc = 0;
  unsigned char chan = 0;

  printf("\n"); // this one sends the one for the measurement loop to the screen
  printf("---------------------------------\n");

  // Here's the printing section
  printf("        ");
  for(adc=0; adc < N_ADC; adc++)
    printf("    ADC_%02d",adc);
  printf("\n");
  
  for(chan=0; chan < N_CHAN; chan++)
    {
      printf("CHAN_%d  ",chan);
      for(adc=0; adc < N_ADC; adc++)
	// printf("  0x%06X",data_arr[adc][chan] & 0x00FFFFFF);
	// printf("  %08X",data_arr[adc][chan] & 0xFFFFFFFF);
	printf("  %8d",data_arr[adc][chan] & 0x00FFFFFF);
      
      // Do this in the ISR, let's you know the measurement loop is done
      printf("\n");
    }

  return 0;
}

unsigned char print_list(unsigned int(*data_arr)[N_CHAN])
{
  unsigned char adc = 0;
  unsigned char chan = 0;

  // Here's the printing section
  for(adc=0; adc < N_ADC; adc++)
    for(chan=0; chan < N_CHAN; chan++)
      printf("ADC_CHAN_%02d_%02d: %8d\n",adc,chan,data_arr[adc][chan] & 0x00FFFFFF);

  return 0;
}

void flip_led()
{
  static unsigned char x = 0xFF;
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x));
  x ^= 1 << 7;    
}

void set_led()
{
  unsigned char x = 0x7F;
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x));
}

void clear_led()
{
  unsigned char x = 0xFF;
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x));
}

unsigned char setup_2n2222(unsigned char adc,unsigned char pchan,unsigned char nchan)
{
  unsigned int data = 0;

  // Enable channel register 0, set positive and negative and
  // map to setup 0
  data = 
    AD7124_CH_MAP_REG_CH_ENABLE |
    AD7124_CH_MAP_REG_SETUP(0)  |
    AD7124_CH_MAP_REG_AINP(pchan)  |
    AD7124_CH_MAP_REG_AINM(nchan);
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
  
  // Control register: full power mode, single acquisition
  data = 
    AD7124_ADC_CTRL_REG_POWER_MODE(0x3) | 
    AD7124_ADC_CTRL_REG_MODE(0x1);
  
  ad7124_write_reg(adc,AD7124_ADC_CTRL_REG,data,2);
  // read it back
  data = 0;
  usleep(1000);
  // ad7124_read_reg(adc,AD7124_ADC_CTRL_REG,&data,2);
  // printf("ADC_%d CHAN_%d: control register has 0x%04X\n",adc,chan,data); 

  return 0;
}

////////////////////////////////////////////////////////////////////////////////////////
// This handles ad7124 gain calibration
// 
unsigned char ad7124_gain_cal(unsigned char adc)
{
  unsigned char nbytes = 0;
  unsigned int data = 0;
  
  // For debugging, read and print the values of the offset register and gain register
  // nbytes = ad7124_read_reg(adc,AD7124_GAIN0_REG,&data,3);
  // printf("ADC_GAIN_%02d: %8d\n",adc,data);
   
  // Enable channel register 0, set positive and negative and
  // map to setup 0
  // I'm going to setup for 
  data = 
    AD7124_CH_MAP_REG_CH_ENABLE |
    AD7124_CH_MAP_REG_SETUP(0)  |
    AD7124_CH_MAP_REG_AINP(12)  |
    AD7124_CH_MAP_REG_AINM(7);
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
  
  // Write 0x800000 to the offset register
  data = 0x800000;
  ad7124_write_reg(adc,AD7124_OFFS0_REG,data,3);
 
  // Start a full scale internal calibration
  // Set the power mode to mid (can't calibrate in full power mode)
  data = 
    AD7124_ADC_CTRL_REG_POWER_MODE(0x1) | 
    AD7124_ADC_CTRL_REG_MODE(0x6);
  ad7124_write_reg(adc,AD7124_ADC_CTRL_REG,data,2);
  
  // For debugging, read and print the values of the offset register and gain register
  // nbytes = ad7124_read_reg(adc,AD7124_GAIN0_REG,&data,3);
  // printf("ADC_GAIN_%02d: %8d\n",adc,data);
  
  return data;
}

////////////////////////////////////////////////////////////////////////////////////////
// This handles ad7124 offset calibration
// 
unsigned char ad7124_offset_cal(unsigned char adc)
{
  unsigned char nbytes = 0;
  unsigned int data = 0;
  
  // For debugging, read and print the values of the offset register and gain register
  // nbytes = ad7124_read_reg(adc,AD7124_OFFS0_REG,&data,3);
  // printf("ADC_OFFS_%02d: %8d\n",adc,data);

  // Write 0x800001 to the offset register (debugging, assure it's actually changing!)
  // data = 0x800001;
  // ad7124_write_reg(adc,AD7124_OFFS0_REG,data,3);

  
  // Start a zero scale internal calibration
  // Set the power mode to mid (can't calibrate in full power mode)
  data = 
    AD7124_ADC_CTRL_REG_POWER_MODE(0x1) | 
    AD7124_ADC_CTRL_REG_MODE(0x5);
  ad7124_write_reg(adc,AD7124_ADC_CTRL_REG,data,2);
  
  // For debugging, read and print the values of the offset register and gain register
  // nbytes = ad7124_read_reg(adc,AD7124_OFFS0_REG,&data,3);
  // printf("ADC_OFFS_%02d: %8d\n",adc,data);

  return data;
}

////////////////////////////////////////////////////////////////////////////////////////
// This handles calibration and housekeeping
// 
unsigned char switch_cal_hk(unsigned char cal_type)
{
  unsigned int data = 0;
  unsigned char i = 0;
  
  if(cal_type == HK_BD_TEMP)
    {
      for(i = 0; i < N_BRD; i++)
	{
	  // The only difference between a board temperature and a 2N2222 is the channel
	  // So, we can just call setup_2n2222 with a bit of translation.  
	  setup_2n2222(i*3,pchan_board_temp,nchan_board_temp);
	}  
      usleep(USLEEP_160MS);
      printf("\n               BD0       BD1       BD2       BD3\nTemp:   ");
      for(i = 0; i < N_BRD; i++)
	{
	  ad7124_read_reg(i*3,AD7124_DATA_REG,&data,3);
	  printf("  %8d",data);
	}
    }
  else if(cal_type == HK_ADC_TEMP)
    {
      for(i = 0; i < N_ADC; i++)
	{
	  // The only difference between a current and a 2N2222 is the channel
	  // So, we can just call setup_2n2222 with a bit of translation.  
	  setup_2n2222(i,pchan_adc_temp,nchan_adc_temp);
	}
      usleep(USLEEP_160MS);
      printf("        ");
      printf("\n            ADC_00    ADC_01    ADC_02    ADC_03    ADC_04    ADC_05    ADC_06    ADC_07    ADC_08    ADC_09    ADC_10    ADC_11\n");
      printf("Temp:   ");
      for(i = 0; i<N_ADC; i++)
	{
	  data = 0;
	  ad7124_read_reg(i,AD7124_DATA_REG,&data,3);
	  printf("  %8d",data & 0x00FFFFFF);
	}
    }
  else if(cal_type >= HK_CURRENT_MIN && cal_type <= HK_CURRENT_MAX)
    {
      for(i = 0; i < N_ADC; i++)
	{
	  // The only difference between a current and a 2N2222 is the channel
	  // So, we can just call setup_2n2222 with a bit of translation.  
	  setup_2n2222(i,pchan_current[cal_type-HK_CURRENT_MIN],nchan_current[cal_type-HK_CURRENT_MIN]);
	}
      usleep(USLEEP_160MS);
      printf("        ");
      printf("\n            CUR_00    CUR_01    CUR_02    CUR_03    CUR_04    CUR_05    CUR_06    CUR_07    CUR_08    CUR_09    CUR_10    CUR_11\n");
      printf("CHAN_%d  ",cal_type-HK_CURRENT_MIN);
      for(i = 0; i<N_ADC; i++)
	{
	  data = 0;
	  ad7124_read_reg(i,AD7124_DATA_REG,&data,3);
	  printf("  %8d",data & 0x00FFFFFF);
	}
    }
  else if(cal_type == CALIBRATE) // We're not doing this right now
    {
      printf("        ");
      printf("\n            ADC_00    ADC_01    ADC_02    ADC_03    ADC_04    ADC_05    ADC_06    ADC_07    ADC_08    ADC_09    ADC_10    ADC_11\n");
      
      /* for(i = 0; i < N_ADC; i++) */
      /* 	{ */
      /* 	  ad7124_gain_cal(i); */
      /* 	} */
      /* usleep(1000*1000); */
      /* for(i = 0; i < N_ADC; i++) */
      /* 	{ */
      /* 	  ad7124_offset_cal(i); */
      /* 	} */
      /* usleep(1000*1000); */
      printf("GAIN    ");
      for(i = 0; i < N_ADC; i++)
      	{
      	  ad7124_read_reg(i,AD7124_GAIN0_REG,&data,3);
      	  printf("  %8d",data & 0x00FFFFFF);
      	}          
      printf("\nOFFS    ");
      for(i = 0; i < N_ADC; i++)
      	{
      	  ad7124_read_reg(i,AD7124_OFFS0_REG,&data,3);
      	  printf("  %8d",data & 0x00FFFFFF);
      	}
    }

  printf("\n");
  return 0;
}

int main()
{
  unsigned char x = 0xFF;
  unsigned int data = 0;
  unsigned char nbytes = 0;
  unsigned int data_arr_2n2222[N_BRD][N_CHAN];
  unsigned char adc = 0;
  unsigned char chan = 0;
  unsigned char cal_type = 0;
  int * ptr;

  loop_done = 0;

  ////////////////////////////////////
  // Startup
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x)); // enable I/O interface
  printf("-----------------------------------------------------\n");
  printf("TMC firmware version %d.%d\n",MAJOR_VERSION_NUMBER,MINOR_VERSION_NUMBER);
  // nbytes = ad7124_read_reg(0,AD7124_ID_REG,&data,1);
  // printf("ADC %d ID register has 0x%2X\n",0,data);
  
  // Enable to loop timer (3 second period, by default)
  // STOP, CONTINUOUS, generate an IRQ 
  // IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, (1<<3) | (1 << 1) |(1 << 0));  
  // STOP, generate IRQ
  IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, (1<<3) | (1 << 0));  
  // Clear the timemout bit
  IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_0_BASE,0);
  alt_ic_isr_register(TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID,
		      TIMER_0_IRQ,
		      handle_timer_interrupts,
		      ptr,
		      0x00);
  // RUN, CONTINUOUS, generate IRQ
  // IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE,(1<<2) | (1 << 1) | (1 << 0) );
  // RUN, generate IRQ
  IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE,(1<<2) | (1 << 1) | (1 << 0) );

  /////////////////////////////////////
  // Measurement loop
  while(1)
    {
      flip_led();
      for(chan = 0; chan < N_CHAN; chan++)
      	{
    	  // Setup the conversions for the 2N2222
    	  for(adc = 0; adc < N_ADC; adc++)
    	    setup_2n2222(adc,pchan_2n2222[chan],nchan_2n2222);
	  
    	  // Wait for the conversions to complete (should take 133ms, wait 160ms)
    	  usleep(USLEEP_160MS);
	  
    	  // Read the data conversion register
    	  for(adc = 0; adc < N_ADC; adc++)
    	    {
    	      data = 0;
    	      ad7124_read_reg(adc,AD7124_DATA_REG,&data,3);
    	      // printf("ADC%d, CHAN%d conversion register has 0x%06X\n",adc,chan,data);
    	      data_arr_2n2222[adc][chan] = data;
    	    }
    	}
      print_table(data_arr_2n2222);
      // print_list(data_arr_2n2222);
      
      // Do calibraiton and housekeeping incrementally
      switch_cal_hk(cal_type);
      cal_type = (cal_type+1 >= N_CAL_HK) ? 0 : cal_type+1;
      
      // This does full housekeeping 
      /* for(cal_type = 0; cal_type < N_CAL_HK; cal_type++) */
      /* 	switch_cal_hk(cal_type); */

      // Read from the I2C bus and set the heater registers

      // Wait for control loop to finish (give yourself 3 seconds every time)
      while(!loop_done); 
      loop_done = 0;
      // printf("---------------------------------\n");
    }
  return 0;
}

