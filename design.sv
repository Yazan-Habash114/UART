`include "BaudRateGenerator.sv"
`include "Receiver.sv"
`include "Transmitter.sv"

module UART #(parameter DATA_BITS = 8, SB_TICKS = 1, IS_PARITY = 0, PARITY = 0) (
  input wire clk,
  input wire reset,
  input wire [31:0] ticks_per_bit,
  input wire rx,
  input wire tx_start,
  input wire [DATA_BITS - 1:0] tx_data_in,
  output reg correct,
  output reg rx_done,
  output reg tx_done,
  output reg tx,
  output reg [DATA_BITS - 1:0] rx_data_out
);
  wire tick;
  
  BaudRateGenerator brg(
    .clk(clk),
    .ticks_per_bit(ticks_per_bit),
    .tick(tick)
  );
  
  Transmitter #(DATA_BITS, SB_TICKS, IS_PARITY, PARITY) transmitter(
    .tx_tick(tick),
    .tx_start(tx_start),
    .reset(reset),
    .tx_din(tx_data_in),
    .tx(tx),
    .tx_done(tx_done)
  );
  
  Receiver #(DATA_BITS, SB_TICKS, IS_PARITY, PARITY) receiver(
    .rx(rx),
    .rx_tick(tick),
    .reset(reset),
    .rx_dout(rx_data_out),
    .rx_done(rx_done),
    .correct(correct)
  );
endmodule