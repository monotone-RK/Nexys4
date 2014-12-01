/******************************************************************************/
/* Clock & Reset Generator                                                    */
/******************************************************************************/
`default_nettype none
  
`include "define.v"

/* Clock & Reset Generator for Nexys4                                         */
/******************************************************************************/
module CLKGEN(input  wire CLK_I, 
              input  wire RST_X_I, 
              output wire CLK_O, 
              output wire RST_X_O);

  wire LOCKED;
  clockgen clkgen(CLK_I, CLK_O, LOCKED);
  resetgen rstgen(CLK_O, (RST_X_I & LOCKED), RST_X_O);
endmodule 

/* ==================================================== */
/* Clock Generator : 100MHz input clock -> output clock */
/* Note : this module uses DCM_SP just for Xilinx FPGA  */
/* ==================================================== */
module clockgen(input  wire CLK_IN,
                output wire CLK_OUT,
                output wire LOCKED);

  wire   CLK_IBUF, CLK_OBUF, CLK0, CLK0_OUT;
  
  IBUFG  ibuf (.I(CLK_IN), .O(CLK_IBUF));   // input buffer
  BUFG   fbuf (.I(CLK0), .O(CLK0_OUT));     // feedback buffer
  BUFG   obuf (.I(CLK_OBUF), .O(CLK_OUT));  // output buffer
  DCM_SP dcm  (.CLKIN(CLK_IBUF), .CLKFX(CLK_OBUF), .CLK0(CLK0), .CLKFB(CLK0_OUT), 
               .LOCKED(LOCKED), .RST(1'b0), .DSSEN(1'b0), .PSCLK(1'b0), 
               .PSEN(1'b0), .PSINCDEC(1'b0));
  defparam dcm.CLKIN_PERIOD   = `DCM_CLKIN_PERIOD;
  defparam dcm.CLKFX_MULTIPLY = `DCM_CLKFX_MULTIPLY;
  defparam dcm.CLKFX_DIVIDE   = `DCM_CLKFX_DIVIDE;
endmodule

/******************************************************************************/
/* Reset Generator :  generate about 100 cycle reset signal                   */
/******************************************************************************/
module resetgen(input  wire CLK, 
                input  wire RST_X_I, 
                output wire RST_X_O);
  
  reg [7:0] cnt;
  assign RST_X_O = cnt[7];

  always @(posedge CLK) begin
    if      (!RST_X_I) cnt <= 0;
    else if (~RST_X_O) cnt <= (cnt + 1'b1);
  end
endmodule

`default_nettype wire
