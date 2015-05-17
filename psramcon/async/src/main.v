/******************************************************************************/
/* PSRAM Controller Test module                        monotone-RK 2015.05.17 */
/******************************************************************************/
`default_nettype none

`include "define.v"
  
module main(input  wire        CLK_IN, 
            input  wire        RST_X_IN, 
            output wire        PSRAM_CLK,
            output wire        PSRAM_ADV_X,
            output wire        PSRAM_CE_X,
            output wire        PSRAM_OE_X,
            output wire        PSRAM_WE_X,
            output wire        PSRAM_LB_X,
            output wire        PSRAM_UB_X,
            inout  wire [15:0] PSRAM_DATA,
            output wire [22:0] PSRAM_ADDR,
            output wire [15:0] ULED);
    
  wire CLK, RST_X;
  CLKRSTGEN clkrstgen(CLK_IN, ~RST_X_IN, CLK, RST_X);
    
  // for PSRAM
  reg  [22:0] waddr;
  reg  [22:0] raddr;
  reg  [15:0] din;
  reg         w_req;
  reg         r_req;
  wire        busy;
  wire [15:0] dout;
  wire        douten;
  
  // for test
  reg [1:0]  state;
  reg [15:0] rdchk_val;
  reg        err;
  
  localparam MEM_WRITE  = 0;
  localparam MEM_READ   = 1;
  localparam READ_CHECK = 2;
  
  assign ULED = (state == MEM_WRITE) ? {waddr[19:16], 12'h00a} : {raddr[22:8], err};

  /* PSRAM Controller Instantiation                                           */
  /****************************************************************************/
  PSRAMCON psramcon(CLK, RST_X, waddr, raddr, din, w_req, r_req, busy, dout, douten,
                    PSRAM_CLK, PSRAM_ADV_X, PSRAM_CE_X, PSRAM_OE_X, PSRAM_WE_X, 
                    PSRAM_LB_X, PSRAM_UB_X, PSRAM_DATA, PSRAM_ADDR);
  
  /* User Logic                                                               */
  /****************************************************************************/
  always @(posedge CLK) begin
    if (!RST_X) begin
      waddr     <= 0;
      raddr     <= 0;
      din       <= 0;
      w_req     <= 0;
      r_req     <= 0;
      state     <= MEM_WRITE;
      rdchk_val <= 0;
      err       <= 0;
    end else begin
      case (state)
        MEM_WRITE: begin    /////// WRITE
          if (w_req) begin
            waddr <= (waddr == `MEM_LAST_ADDR) ? 0 : waddr + 1;
            w_req <= 0;
            if (waddr == `MEM_LAST_ADDR) state <= MEM_READ;
          end else if (!busy) begin 
            din   <= din + 1;
            w_req <= 1;
          end
        end
        MEM_READ: begin     /////// READ 
          if (r_req) begin 
            raddr <= (raddr == `MEM_LAST_ADDR) ? 0 : raddr + 1;
            r_req <= 0;
            state <= READ_CHECK;
          end else if (!busy) begin 
            r_req     <= 1;
            rdchk_val <= rdchk_val + 1;
          end
        end
        READ_CHECK: begin   /////// CHECK READ DATA
          if (douten) begin
            state <= MEM_READ;
            err   <= (dout != rdchk_val);
          end
        end
      endcase
    end
  end
    
endmodule
`default_nettype wire
