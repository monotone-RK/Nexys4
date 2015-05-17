/******************************************************************************/
/* PSRAM Controller (async mode)                       monotone-RK 2015.05.17 */
/******************************************************************************/
`default_nettype none
  
`include "define.v"

module PSRAMCON(input  wire        CLK,
                input  wire        RST_X,
                ////////// User logic interface ports //////////
                input  wire [22:0] WADDR,     // input write address
                input  wire [22:0] RADDR,     // input read  address
                input  wire [15:0] D_IN,      // input data
                input  wire        W_REQ,     // write request
                input  wire        R_REQ,     // read request
                output wire        BUSY,      // it's busy during operation
                output reg  [15:0] RDOUT,     // read data
                output reg         RDOUT_EN,  // read data is enable
                ////////// Memory interface ports //////////
                output wire        MCLK,      // PSRAM_CLK
                output wire        ADV_X,     // PSRAM_ADV_X
                output reg         CE_X,      // PSRAM_CE_X
                output reg         OE_X,      // PSRAM_OE_X
                output reg         WE_X,      // PSRAM_WE_X
                output wire        LB_X,      // PSRAM_LB_X
                output wire        UB_X,      // PSRAM_UB_X
                inout  wire [15:0] D_OUT,     // PSRAM_DATA
                output reg  [22:0] A_OUT);    // PSRAM_ADDR

  localparam IDLE  = 0;
  localparam WRITE = 1;
  localparam READ  = 2;

  reg [1:0]  state;
  reg [15:0] D_KEPT;
  reg [3:0]  cycle;
  
  assign BUSY  = (state != IDLE);
  assign MCLK  = 0;
  assign ADV_X = 0;
  assign LB_X  = 0;
  assign UB_X  = 0;
  assign D_OUT = (state == WRITE) ? D_KEPT : 16'hzzzz;

  always @(posedge CLK) begin
    if (!RST_X) begin
      RDOUT    <= 0;
      RDOUT_EN <= 0;
      CE_X     <= 1;
      OE_X     <= 1;
      WE_X     <= 1;
      A_OUT    <= 0;
      state    <= IDLE;
      D_KEPT   <= 0;
      cycle    <= 0;
    end else begin
      case (state)
        //////////////////////////////////////////////////////////// idle
        IDLE: begin
          RDOUT    <= 0;
          RDOUT_EN <= 0;
          case ({W_REQ, R_REQ})
            2'b10: begin
              A_OUT  <= WADDR;
              state  <= WRITE;
              D_KEPT <= D_IN;
            end
            2'b01: begin
              A_OUT  <= RADDR;
              state  <= READ;
              D_KEPT <= 0;
            end
            default: begin
              A_OUT  <= 0;
              state  <= state;
              D_KEPT <= 0;
            end
          endcase
        end
        //////////////////////////////////////////////////////////// write
        WRITE: begin
          CE_X   <= (cycle == `REQUIRED_CYCLES);
          WE_X   <= (cycle == `REQUIRED_CYCLES);
          if (cycle == `REQUIRED_CYCLES) state <= IDLE;
          cycle  <= (cycle == `REQUIRED_CYCLES) ? 0 : cycle + 1;
        end
        //////////////////////////////////////////////////////////// read
        READ: begin
          if (cycle == `REQUIRED_CYCLES) begin
            RDOUT     <= D_OUT;
            RDOUT_EN  <= 1;
          end
          CE_X   <= (cycle == `REQUIRED_CYCLES);
          OE_X   <= (cycle == `REQUIRED_CYCLES);
          if (cycle == `REQUIRED_CYCLES) state <= IDLE;
          cycle  <= (cycle == `REQUIRED_CYCLES) ? 0 : cycle + 1;
        end
      endcase
    end
  end

endmodule
`default_nettype wire
