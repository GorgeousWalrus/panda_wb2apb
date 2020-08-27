// ------------------------ Disclaimer -----------------------
// No warranty of correctness, synthesizability or 
// functionality of this code is given.
// Use this code under your own risk.
// When using this code, copy this disclaimer at the top of 
// Your file
//
// (c) Luca Hanel 2020
//
// ------------------------------------------------------------
//
// Module name: wb2apb
// 
// Functionality: Wishbone to APB bridge
//                For now, the bridge expects both the wb and
//                apb bus to have an address and data width of
//                32 bit.
//                In the future, this will be changed, such
//                That the wb bus can also have 64 bits and
//                trigger 2 32bit operations on the apb bus
//
// TODO: 
//
//
//
// ------------------------------------------------------------

module wb2apb#(
  parameter APB_DATA_WIDTH = 32,
  parameter APB_ADDR_WIDTH = 32,
  parameter WB_ADDR_WIDTH = 32,
  parameter WB_DATA_WIDTH = 32,
  parameter WB_TAGSIZE = 1
)(
  input logic                   clk,
  input logic                   rstn_i,
  wb_bus_t.slave                wb_bus,
  apb_bus_t.master              apb_bus
);

logic                       PSEL;
logic                       PWRITE;
logic                       PENABLE_n, PENABLE_q;
logic [APB_ADDR_WIDTH-1:0]  PADDR;
logic [APB_ADDR_WIDTH-1:0]  PWDATA;

logic                       wb_ack_n, wb_ack_q;

// Assign apb signals to apb bus
assign apb_bus.PCLK    = clk;
assign apb_bus.PRESETn = rstn_i;
assign apb_bus.PSEL    = PSEL;
assign apb_bus.PADDR   = PADDR;
assign apb_bus.PWDATA  = PWDATA;
assign apb_bus.PWRITE  = PWRITE;
assign apb_bus.PENABLE = PENABLE_q;

// Assign wb signals to wb bus
assign wb_bus.wb_ack    = wb_ack_q;
assign wb_bus.wb_dat_sm = apb_bus.PRDATA;
assign wb_bus.wb_err    = apb_bus.PSLVERR;

always_comb
begin
  wb_ack_n  = 'b0;
  PSEL      = 'b0;
  PADDR     = 'b0;
  PWRITE    = 'b0;
  PWDATA    = 'b0;
  PENABLE_n = 'b0;

  // if wb wants to talk forward the signals
  if(wb_bus.wb_cyc) begin
    PSEL = 1'b1;
    PADDR = wb_bus.wb_adr;
    PWRITE = wb_bus.wb_we;
    PWDATA = wb_bus.wb_dat_ms;
    PENABLE_n = 1'b1;
    if(apb_bus.PREADY)
      PENABLE_n = 1'b0;
      wb_ack_n = 1'b1;
  end
end

always_ff @(posedge clk, negedge rstn_i)
begin
  if(!rstn_i) begin
  end else begin
    PENABLE_q <= PENABLE_n;
    wb_ack_q  <= wb_ack_n;
  end
end

endmodule