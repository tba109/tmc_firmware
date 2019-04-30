////////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Sat Feb  6 11:13:15 EST 2016
//
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
#include <fcntl.h>
#include <string.h>
#include "i2c_opencores.h"

////////////////////////////////////////////////////////////////////////////////////////
// Tue Mar 12 14:33:06 EDT 2019
// For NEID, per emails from Paul Robertson starting February 19, 2019:
// The cold finger on the detector has the ability to cool it to dangerous levels. The 
// idea here is to use a warmup heater on the detector in order to make sure this can't 
// happen. 
#define DO_NEID_EMERGENCY_CHECK
// 1.) If the temperature reading goes **above** 15053189 (because temperature is 
//     negatively correlated to voltage), we enter the emergency state. ADC = 1 and 
//     CH = 4. 
#define NEID_EMERGENCY_ADC_LEVEL 15053189
#define NEID_EMERGENCY_ADC 1
#define NEID_EMERGENCY_CH 4
// 2.) Any time the temperature is below this value, we set DAC=3,4,5, 
//     CADX0 = GND, CADX1 = Float, CADX2 = GND (LTC2605 DS: board = 0x13, 19)
//     heat, 65535 for the 16b ADC. 
#define NEID_EMERGENCY_HEATER_BRD 19
#define NEID_EMERGENCY_HEATER_CH0 3
#define NEID_EMERGENCY_HEATER_CH1 4
#define NEID_EMERGENCY_HEATER_CH2 5
///////////////////////////////////////////////////////////////////////////////////////

#define DO_COMMANDS
#define DO_CALIBRATION
#define MAJOR_VERSION_NUMBER 1
#define MINOR_VERSION_NUMBER 21

#define N_ADC 12 // 3 ADC/board x 4 boards
#define N_CHAN 6 // 6 channels/board
#define N_BRD 4 // 4 boards

// For the RX FIFO
#define RX_EOC 0x0A // RX end of command

// For i2c_opencores
#define I2C_SCL_SPEED 100000

// For receive character buffer size
#define RX_BUF_SIZE 1024

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
#define USLEEP_20MS 20*1000

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

unsigned char read_chan(unsigned int *data_arr, unsigned int reg,unsigned char nbytes)
{
  unsigned char i = 0;
  unsigned int data = 0;
  for(i = 0; i<N_ADC; i++)
    {
      data = 0;
      ad7124_read_reg(i,reg,&data,nbytes);
      data_arr[i] = data;
    }
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

unsigned char setup_conv(unsigned char adc,
			 unsigned char pchan,
			 unsigned char nchan, 
			 unsigned char pga, 
			 unsigned short fs, 
			 unsigned char pmode, 
			 unsigned char mode, 
			 unsigned char init_offs)
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
  // data = 0;
  // usleep(1000);
  // ad7124_read_reg(adc,AD7124_CH0_MAP_REG,&data,2);
  // printf("ADC_%d CHAN_%d: channel register has 0x%04X\n",adc,chan,data);
  
  // Configuration register: input and ref bufs enabled, 
  // set the PGA for 4, bipolar mode
  data =
    // Fri Nov 11 14:34:22 EST 2016
    // TBA_NOTE: Change from bipolar to unipolar operator
    // Fri Nov 11 16:28:48 EST 2016
    // TBA_NOTE: I was getting lots of zeros which seem weird, so change it back to bipolar
    AD7124_CFG_REG_BIPOLAR |
    AD7124_CFG_REG_REF_BUFP |
    AD7124_CFG_REG_REF_BUFM |
    AD7124_CFG_REG_AIN_BUFP |
    AD7124_CFG_REG_AIN_BUFM |
    AD7124_CFG_REG_PGA(pga);
  ad7124_write_reg(adc,AD7124_CFG0_REG,data,2);
  // read it back
  // data = 0;
  // usleep(1000);
  // ad7124_read_reg(adc,AD7124_CFG0_REG,&data,2);
  // printf("ADC_%d CHAN_%d: filter register has 0x%04X\n",adc,chan,data);
  
  // Filter register: select defaults, except go for a 7.5Hz zero lantency measurement. 
  data = 
    AD7124_FILT_REG_FILTER(0) |
    AD7124_FILT_REG_REJ60 |
    AD7124_FILT_REG_POST_FILTER(3) |
    AD7124_FILT_REG_FS(fs);
  ad7124_write_reg(adc,AD7124_FILT0_REG,data,3);
  // read it back
  // data = 0;
  // usleep(1000);
  // ad7124_read_reg(adc,AD7124_FILT0_REG,&data,3);
  // printf("ADC_%d CHAN_%d: filter register has 0x%04X\n",adc,chan,data);

  if(init_offs)
    {
      // Write 0x800000 to the offset register
      data = 0x800000;
      ad7124_write_reg(adc,AD7124_OFFS0_REG,data,3);
    }

  // Wed Mar  9 13:25:48 EST 2016
  // For debugging purposes: enable error checking
  data =
    AD7124_ERR_REG_ADC_CAL_ERR |
    AD7124_ERR_REG_ADC_CONV_ERR |
    AD7124_ERR_REG_ADC_SAT_ERR |
    AD7124_ERR_REG_REF_DET_ERR |
    AD7124_ERR_REG_SPI_READ_ERR |
    AD7124_ERR_REG_SPI_WRITE_ERR;
  ad7124_write_reg(adc,AD7124_ERREN_REG,data,3);
  // read it back
  // data = 0;
  // usleep(1000);
  // ad7124_read_reg(adc,AD7124_ERREN_REG,&data,3);
  // printf("ADC_%d CHAN_%d: error enable register has 0x%04X\n",adc,chan,data);

  // Control register: full power mode, single conversion
  data = 
    AD7124_ADC_CTRL_REG_POWER_MODE(pmode) | 
    AD7124_ADC_CTRL_REG_MODE(mode);
  ad7124_write_reg(adc,AD7124_ADC_CTRL_REG,data,2);
  // read it back
  // data = 0;
  // usleep(1000);
  // ad7124_read_reg(adc,AD7124_ADC_CTRL_REG,&data,2);
  // printf("ADC_%d CHAN_%d: control register has 0x%04X\n",adc,chan,data); 

  // Wed Mar  9 17:38:21 EST 2016
  // DS-p65: the REF_DET_ERR flag may be set when exiting standby mode. 
  // Therefore, read the error register after exiting standby mode in order
  // to reset this flag to 0. 
  ad7124_read_reg(adc,AD7124_ERR_REG,&data,3); 

  return 0;
}

#ifdef DO_CALIBRATION
///////////////////////////////////////////////////////////////////////////////////////////
// Calibrate the ADC
unsigned char calibrate_ad7124_8(void)
{
  unsigned int data = 0;
  unsigned char i = 0;
  printf("        ");
  printf("\n            ADC_00    ADC_01    ADC_02    ADC_03    ADC_04    ADC_05    ADC_06    ADC_07    ADC_08    ADC_09    ADC_10    ADC_11\n");
  
  for(i = 0; i < N_ADC; i++)
  	{
  	  // AIN8 and 7, PGA=2 (x4), FS = 2047, mid-power, gain cal, init offset  
	  setup_conv(i,8,7,2,2047,0x1,0x6,1);
  	}
  usleep(8000*1000);
  for(i = 0; i < N_ADC; i++)
  	{
	  // AIN8 and 7, PGA=2 (x4), FS = 2047, mid-power, offset cal  
	  setup_conv(i,8,7,2,2047,0x1,0x5,0);
  	}
  usleep(3000*1000);

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
  printf("\n");
  return 0;
}
#endif
 
#ifdef DO_COMMANDS     
// Read a single character from the RX FIFO
char read_rx_fifo_char()
{
  unsigned char x = 1;
  char c;
  IOWR_ALTERA_AVALON_PIO_DATA(RX_FIFO_READ_BASE, (unsigned char)(x)); // set read signal (note: FPGA internally positive edge clocks this)
  x = 0;
  IOWR_ALTERA_AVALON_PIO_DATA(RX_FIFO_READ_BASE, (unsigned char)(x)); // clear read signal (note: FPGA internally positive edge clocks this)
  c = IORD_ALTERA_AVALON_PIO_DATA(RX_CHAR_BASE);
#ifdef DO_CALIBRATION
  if( c == 'a')
    calibrate_ad7124_8();
#endif
  return c;
  // TBA_NOTE: was here!
}

// Readout the rx fifo contents
unsigned int read_rx_fifo(char * str1)
{
  unsigned int nbytes = 0;
  str1[0] = '\0';
  if(!IORD_ALTERA_AVALON_PIO_DATA(RX_FIFO_EMPTY_BASE)) // Check receive fifo not empty
    {
      while(1)
  	{
	  if(!IORD_ALTERA_AVALON_PIO_DATA(RX_FIFO_EMPTY_BASE)) // Check receive fifo not empty
	    {
	      str1[nbytes] = read_rx_fifo_char();
	      nbytes++;
	      if(nbytes == RX_BUF_SIZE)
		{
		  printf("ERROR::read_rx_fifo: Buffer full\n");
		  return nbytes;
		}
	      else if(str1[nbytes-1] == RX_EOC)
		{
		  str1[nbytes] = '\0';
		  return nbytes;
		}
	    }
	  if(loop_done)
	    {
	      // printf("ERROR::read_rx_fifo: Timeout\n");
	      return nbytes;
	    }
	}
    }
  str1[nbytes] = '\0';
  return nbytes;
}

//////////////////////////////////////////////////////////////////////////////////////////
// Write the DAC word to the I2C bus.
//
volatile unsigned char emergency_state; 
unsigned char write_ltc2605(unsigned char board, unsigned char dac, unsigned short data)
{
  // printf("--Write the start\n");
  I2C_start(I2C_OPENCORES_0_BASE,board,0);
  // printf("--Write first byte\n");
  I2C_write(I2C_OPENCORES_0_BASE,(0x03 << 4) | (dac & 0x0F),0); // write/update register
  // printf("--Write second byte\n");
  I2C_write(I2C_OPENCORES_0_BASE,(data & 0xFF00)>>8,0);
  // printf("--write third byte\n");
  I2C_write(I2C_OPENCORES_0_BASE,(data & 0x00FF),1);
  // Thu Mar 14 15:14:30 EDT 2019
#ifdef DO_NEID_EMERGENCY_CHECK
  if(
     (board == NEID_EMERGENCY_HEATER_BRD) && 
     (
      (dac == NEID_EMERGENCY_HEATER_CH0) || 
      (dac == NEID_EMERGENCY_HEATER_CH1) || 
      (dac == NEID_EMERGENCY_HEATER_CH2)
      )
     )
    emergency_state = 0; 
#endif

  return 0;
}


////////////////////////////////////////////////////////////////////////////////////////
// Execute charaters commands on the I2C bus
unsigned int execute_cmd(char * str1,unsigned int nbytes)
{
  unsigned char board = 0;
  unsigned char dac = 0;
  unsigned short data = 0;
  char * token;
  char delim[2] = " "; // Command chunks and commands are separted by ' ' and '\n'
  // 0: expect 'c',
  // 1: expect the board address
  // 2: expect the dac register address
  // 3: expect the data

  unsigned char chunk_type = 0;
  unsigned int ncmds = 0;
  
  // http://www.tutorialspoint.com/c_standard_library/c_function_strtok.htm
  token = strtok(str1,delim);
  while(token != NULL)
    {
      // The first byte of any command should be 'c'
      if(chunk_type == 0)
	{
	  if(*token != 'c')
	    chunk_type = 0;
	  else
	    chunk_type = 1;
	}
      else if(chunk_type == 1)
	{
	  board = atoi(token);
	  chunk_type = 2;
	}
      else if(chunk_type == 2)
	{
	  dac = atoi(token);
	  chunk_type = 3;
	}
      else if(chunk_type == 3)
	{
	  data = atoi(token);
	  write_ltc2605(board,dac,data);
	  // printf("execute\n");
	  ncmds++;
	  chunk_type = 0;
	}
      token = strtok(NULL,delim);
    }

  return ncmds;
}
#endif

unsigned char print_table(unsigned int* bsln, 
			  unsigned int* zero, 
			  unsigned int (*stat)[N_ADC],
			  unsigned int (*erro)[N_ADC],
			  unsigned int (*curr)[N_ADC],
			  unsigned int (*tsig)[N_ADC],
			  unsigned int* atemp,
			  unsigned int* btemp)
{
  unsigned char adc = 0;
  unsigned char chan = 0;

  // Print the header
  printf("\n");
  // printf("---------------------------------\n");
  // Fri Nov 11 15:01:50 EST 2016
  // TBA_NOTE: This allows me to make sure we are using the right revision
  printf("---------------------------------V%d.%d\n",MAJOR_VERSION_NUMBER,MINOR_VERSION_NUMBER);
  printf("        ");
  for(adc=0; adc < N_ADC; adc++)
    printf("    ADC_%02d",adc);
  printf("\n");
  
  printf("BSLN    ");
  for(adc = 0; adc < N_ADC; adc++)
    printf("  %8d",bsln[adc] & 0x00FFFFFF);
  printf("\n");

  printf("ZERO    ");
  for(adc = 0; adc < N_ADC; adc++)
    printf("  %8d",zero[adc] & 0x00FFFFFF);
  printf("\n");

  // usleep(USLEEP_20MS);

  for(chan = 0; chan < N_CHAN; chan++)
    {
      printf("CURR%d   ",chan);
      for(adc = 0; adc < N_ADC; adc++)
	printf("  %8d",curr[chan][adc] & 0x00FFFFFF);
      printf("\n");
    }

  // usleep(USLEEP_20MS);

  for(chan = 0; chan < N_CHAN; chan++)
    {
      printf("STAT%d   ",chan);
      for(adc = 0; adc < N_ADC; adc++)
  	printf("    %06X",stat[chan][adc] & 0x00FFFFFF);
      printf("\n");
    }
  // usleep(USLEEP_20MS);

  for(chan = 0; chan < N_CHAN; chan++)
    {
      printf("TSIG%d   ",chan);
      for(adc = 0; adc < N_ADC; adc++)
	printf("  %8d",tsig[chan][adc] & 0x00FFFFFF);
      printf("\n");
    }
  
  // usleep(USLEEP_20MS);

  for(chan = 0; chan < N_CHAN; chan++)
    {
      printf("ERRO%d   ",chan);
      for(adc = 0; adc < N_ADC; adc++)
  	printf("    %06X",erro[chan][adc] & 0x00FFFFFF);
      printf("\n");
    }

  // usleep(USLEEP_20MS);

  printf("ATEMP   ");
  for(adc = 0; adc < N_ADC; adc++)
    printf("  %8d",atemp[adc] & 0x00FFFFFF);
  printf("\n");

  printf("BTEMP   ");
  for(adc = 0; adc < N_ADC; adc++)
    printf("  %8d",btemp[adc] & 0x00FFFFFF);
  printf("\n");
  
  // usleep(USLEEP_20MS);

  return 0;
}

int main()
{
  unsigned char x = 0xFF;
  unsigned char adc = 0;
  unsigned char chan = 0;
  int *ptr;
  unsigned int bsln[N_ADC];
  unsigned int zero[N_ADC];
  unsigned int stat[N_CHAN][N_ADC];
  unsigned int erro[N_CHAN][N_ADC];
  unsigned int curr[N_CHAN][N_ADC];
  unsigned int tsig[N_CHAN][N_ADC];
  unsigned int atemp[N_ADC];
  unsigned int btemp[N_ADC];
  emergency_state = 0; 

#ifdef DO_COMMANDS
  unsigned int nbytes = 0;
  unsigned int nbytes_total = 0;
  unsigned int ncmd = 0;
  unsigned int ncmd_total = 0;
  char str1[RX_BUF_SIZE];  
#endif
  ptr = NULL;
  loop_done = 0;
  
  ////////////////////////////////////
  // Startup
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_1_BASE, (unsigned char)(x)); // enable I/O interface
  printf("-----------------------------------------------------\n");
  printf("TMC firmware version %d.%d\n",MAJOR_VERSION_NUMBER,MINOR_VERSION_NUMBER);

  // This can be used to see if an ADC is connected
  // nbytes = ad7124_read_reg(0,AD7124_ID_REG,&data,1);
  // printf("ADC %d ID register has 0x%2X\n",0,data);
  
  // Enable to loop timer (3 second period, by default)
  // STOP, generate IRQ
  IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE, (1<<3) | (1 << 0));  
  // Clear the timemout bit
  IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_0_BASE,0);
  // Setup the ISR
  alt_ic_isr_register(TIMER_0_IRQ_INTERRUPT_CONTROLLER_ID,
		      TIMER_0_IRQ,
		      handle_timer_interrupts,
		      ptr,
		      0x00);
  // RUN, generate IRQ on timeout
  IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE,(1<<2) | (1 << 0) );

#ifdef DO_COMMANDS
  // Setup the i2c_opencores interface
  I2C_init(I2C_OPENCORES_0_BASE,ALT_CPU_FREQ,I2C_SCL_SPEED);
  // printf("I2C initialized\n");
#endif

  /////////////////////////////////////
  // Measurement loop
  while(1)
    {
      // This let's you know that your are measuring
      flip_led();
      
      ////////////////////////////////////////////////////////////////////////////////
      // Tue Mar  8 13:25:04 EST 2016
      // Monitor the baseline voltage. This requires setting up for a gain of 2.
      for(adc = 0; adc < N_ADC; adc++)
	{
	  // PGA=1 (x2), FS = 2047, full-power, single conv  
	  // setup_conv(adc,7,0,1,640,0x3,0x1,0);
	  // Fri Nov 11 16:30:22 EST 2016
	  // TBA_NOTE: Try with PGA = 0, x1
	  // setup_conv(adc,7,0,0,640,0x3,0x1,0);
	  // Sun Nov 27 12:21:58 EST 2016
	  // TBA_NOTE: Try with PGA = 1, x2
	  setup_conv(adc,7,0,1,640,0x3,0x1,0);
	}
      // Wait for the conversions to complete (should take 133ms, wait 160ms)
      usleep(USLEEP_160MS);
      read_chan(bsln,AD7124_DATA_REG,3);
      
      ////////////////////////////////////////////////////////////////////////////////
      // Tue Mar 15 10:37:43 EDT 2016
      // Monitor the zero scale voltage. This requires setting up for a gain of 4.
      for(adc = 0; adc < N_ADC; adc++)
	{
	  // PGA=2 (x4), FS = 2047, full-power, single conv  
	  // setup_conv(adc,7,7,2,640,0x3,0x1,0);
	  // Fri Nov 11 14:26:04 EST 2016
	  // TBA_NOTE: I want to try doing everything with PGA=1 (x2), note that we are
	  // in unipolar mode here
	  // setup_conv(adc,7,7,1,640,0x3,0x1,0);
	  // Fri Nov 11 16:30:56 EST 2016
	  // TBA_NOTE: try with PGA = 0 (x1)
	  // setup_conv(adc,7,7,0,640,0x3,0x1,0);
	  // Sun Nov 27 12:23:16 EST 2016
	  // TBA_NOTE: try with PGA = 1 (x2)
	  setup_conv(adc,7,7,1,640,0x3,0x1,0);
	}
      // Wait for the conversions to complete (should take 133ms, wait 160ms)
      usleep(USLEEP_160MS);      
      read_chan(zero,AD7124_DATA_REG,3);

      ////////////////////////////////////////////////////////////////////////////////
      // Tue Mar 15 10:37:43 EDT 2016
      // Monitor the 2n2222 voltage and currents. Read out the status and error regs.
      for(chan = 0; chan < N_CHAN; chan++)
      	{
      	  // Excitation current
	  for(adc = 0; adc < N_ADC; adc++)
	    {
	      /* // PGA=2 (x4), FS = 640, full-power, single conv */
	      /* setup_conv(adc, */
	      /* 		 pchan_current[chan], */
	      /* 		 nchan_current[chan], */
	      /* 		 2, */
	      /* 		 640, */
	      /* 		 0x3, */
	      /* 		 0x1, */
	      /* 		 0); */
	     
	      // Fri Nov 11 14:43:59 EST 2016
	      // TBA_NOTE: Change over to PGA=1 (gain of 2)
	      /* setup_conv(adc, */
	      /* 		 pchan_current[chan], */
	      /* 		 nchan_current[chan], */
	      /* 		 1, */
	      /* 		 640, */
	      /* 		 0x3, */
	      /* 		 0x1, */
	      /* 		 0); */
	      // Fri Nov 11 16:32:14 EST 2016
	      // TBA_NOTE: Change over to PGA=0 (gain of 1)
	      /* setup_conv(adc, */
	      /* 		 pchan_current[chan], */
	      /* 		 nchan_current[chan], */
	      /* 		 0, */
	      /* 		 640, */
	      /* 		 0x3, */
	      /* 		 0x1, */
	      /* 		 0); */
	      // Sun Nov 27 12:24:10 EST 2016
	      // TBA_NOTE: Change over to PGA=1 (gain of 2)
	      setup_conv(adc,
			 pchan_current[chan],
			 nchan_current[chan],
			 1,
			 640,
			 0x3,
			 0x1,
			 0);


	    }
	  usleep(USLEEP_160MS);
	  read_chan(curr[chan],AD7124_DATA_REG,3);
	  
	  // 2N2222 voltage
	  for(adc = 0; adc < N_ADC; adc++)
	    {
	      // Setup the conversions for the 2N2222
	      // PGA=2 (x4), FS = 640, full-power, single conv  
	      /* setup_conv(adc, */
	      /* 		 pchan_2n2222[chan], */
	      /* 		 nchan_2n2222, */
	      /* 		 2, */
	      /* 		 640, */
	      /* 		 0x3, */
	      /* 		 0x1, */
	      /* 		 0); */
	      // Fri Nov 11 14:45:42 EST 2016
	      // TBA_NOTE: Use PGA = 1 (x2)
	      // Also change over the nchan to 0 (grounded)
	      /* setup_conv(adc, */
	      /* 		 pchan_2n2222[chan], */
	      /* 		 0, */
	      /* 		 1, */
	      /* 		 640, */
	      /* 		 0x3, */
	      /* 		 0x1, */
	      /* 		 0); */
	      // TBA_NOTE: Use PGA = 0 (x1)
	      // Also change over the nchan to 0 (grounded)
	      /* setup_conv(adc, */
	      /* 		 pchan_2n2222[chan], */
	      /* 		 0, */
	      /* 		 0, */
	      /* 		 640, */
	      /* 		 0x3, */
	      /* 		 0x1, */
	      /* 		 0); */
	      // Sun Nov 27 12:25:51 EST 2016
	      // TBA_NOTE: Use PGA = 1 (x2)
	      // Also change over the nchan to 0 (grounded)
	      setup_conv(adc,
	      		 pchan_2n2222[chan],
	      		 0,
	      		 1,
	      		 640,
	      		 0x3,
	      		 0x1,
	      		 0);	      
	    }
	  usleep(USLEEP_160MS);
	  read_chan(stat[chan],AD7124_STATUS_REG,1);
	  read_chan(tsig[chan],AD7124_DATA_REG,3);
	  read_chan(erro[chan],AD7124_ERR_REG,3);
	}

      ////////////////////////////////////////////////////////////////////////////////
      // Tue Mar 15 13:31:04 EDT 2016
      // Read out the ADC temperatures
      for(adc = 0; adc < N_ADC; adc++)
	{
	  // PGA=2 (x4), FS = 640, full-power, single conv
	  setup_conv(adc,
		     pchan_adc_temp,
		     nchan_adc_temp,
		     2,
		     640,
		     0x3,
		     0x1,
		     0);
	}
      usleep(USLEEP_160MS);
      read_chan(atemp,AD7124_DATA_REG,3);

      ////////////////////////////////////////////////////////////////////////////////
      // Tue Mar 15 13:36:18 EDT 2016
      // Read out the board temperatures
      for(adc = 0; adc < N_ADC; adc++)
	{
	  // PGA=2 (x4), FS = 640, full-power, single conv
	  setup_conv(adc,
		     pchan_board_temp,
		     nchan_board_temp,
		     2,
		     640,
		     0x3,
		     0x1,
		     0);
	}
      usleep(USLEEP_160MS);
      read_chan(btemp,AD7124_DATA_REG,3);

      print_table(bsln, 
		  zero, 
		  stat,
		  erro,
		  curr,
		  tsig,
		  atemp,
		  btemp);

#ifdef DO_COMMANDS
      nbytes_total = 0;
      ncmd_total = 0;
      nbytes = 0;
      nbytes_total = 0;
      while((nbytes = read_rx_fifo(str1)))
      	{
      	  // Execute commands
      	  printf("%s",str1);
      	  nbytes_total += nbytes;
      	  ncmd = execute_cmd(str1,nbytes);
      	  ncmd_total += ncmd;
      	}
      printf("Received %d byte(s), Executed %d command(s), emergency_state = %d\n",nbytes_total,ncmd_total,emergency_state);
#endif      

      // Tue Mar 12 15:54:27 EDT 2019
      // This is where we do the emergency check
#ifdef DO_NEID_EMERGENCY_CHECK
      if((tsig[NEID_EMERGENCY_CH][NEID_EMERGENCY_ADC] > NEID_EMERGENCY_ADC_LEVEL) || 
	 emergency_state)
	{
	  write_ltc2605(NEID_EMERGENCY_HEATER_BRD,NEID_EMERGENCY_HEATER_CH0,65535); 
	  write_ltc2605(NEID_EMERGENCY_HEATER_BRD,NEID_EMERGENCY_HEATER_CH1,65535); 
	  write_ltc2605(NEID_EMERGENCY_HEATER_BRD,NEID_EMERGENCY_HEATER_CH2,65535); 
	  emergency_state = 1; 
	}
#endif

      // Wait for control loop to finish (give yourself 3 seconds every time)
      if(loop_done)
	printf("WARNING: Exceeded control loop period.\n");
      else
	while(!loop_done);
      
      loop_done = 0;
      // Run timer and generate IRQ
      IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_0_BASE,(1<<2) | (1 << 0) );
    }
  return 0;
}

