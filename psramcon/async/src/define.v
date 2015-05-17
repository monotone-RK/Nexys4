/******************************************************************************/
/* Clock Frequency Definition                                                 */
/* Clock Freq = (CLKIN_FREQ) * (CLKFBOUT_MULT) / (CLKOUT_DIVIDE)              */
/******************************************************************************/
`define CLKIN_FREQ         100   // 100 MHz
`define CLKIN_PERIOD       10.0  // 10.0 ns
`define CLKFBOUT_MULT      10    // Do not change  
`define CLKOUT_DIVIDE0     20    //  50MHz (20ns)
`define CLKOUT_DIVIDE1     10    // 100MHz (10ns)
`define CLKOUT_DIVIDE2      5    // 200MHz ( 5ns)

/******************************************************************************/
/* PSRAM Definition                                                           */
/******************************************************************************/
`define MEM_LAST_ADDR   23'h7fffff
`define REQUIRED_CYCLES ((70/`CLKOUT_DIVIDE0)+1)
