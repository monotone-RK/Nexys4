/****************************************************************************************/
/* Clock Frequency Definition                                                           */
/* Clock Freq = (System Clock Freq) * (DCM_CLKFX_MULTIPLY) / (DCM_CLKFX_DIVIDE)         */
/****************************************************************************************/
`define SYSTEM_CLOCK_FREQ  100     //  100 MHz
`define DCM_CLKIN_PERIOD   10.000  //  10.000 ns
`define DCM_CLKFX_MULTIPLY 4       // CLKFX_MULTIPLY must be 2~32
`define DCM_CLKFX_DIVIDE   10      // CLKFX_DIVIDE   must be 1~32

`define CLOCK_FREQ (`SYSTEM_CLOCK_FREQ * `DCM_CLKFX_MULTIPLY / `DCM_CLKFX_DIVIDE)

/****************************************************************************************/
/* UART Definition                                                                      */
/****************************************************************************************/
`define SERIAL_WCNT `CLOCK_FREQ  // 1M baud UART wait count (SERIAL_WCNT = Clock Freq / 1)

/****************************************************************************************/
/* LCD Definition                                                                       */
/****************************************************************************************/
`define DIGIT     4
`define LCD_WIDTH (`DIGIT*4)
