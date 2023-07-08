`include "BaudRateGenerator.sv"
`include "Receiver.sv"
`include "Transmitter.sv"

module UART (
  input wire clk,
  input wire reset,
  input wire rx,
  input wire tx_start,
  input wire parity_type,
  input wire parity_en,
  input wire stop2,
  input wire [1:0] baud,
  input wire [3:0] frame_length,
  input wire [7:0] tx_data_in,
  output reg correct,
  output reg rx_done,
  output reg tx_done,
  output reg tx,
  output reg [7:0] rx_data_out
);
  
  wire tick;
  
  BaudRateGenerator brg(
    .clk(clk),
    .reset(reset),
    .baud(baud),
    .tick(tick)
  );
  
  Transmitter transmitter(
    .tx_tick(tick),
    .tx_start(tx_start),
    .reset(reset),
    .frame_length(frame_length),
    .tx_din(tx_data_in),
    .parity_type(parity_type),
    .parity_en(parity_en),
    .stop2(stop2),
    .tx(tx),
    .tx_done(tx_done)
  );
  
  Receiver receiver(
    .rx(rx),
    .rx_tick(tick),
    .reset(reset),
    .frame_length(frame_length),
    .parity_type(parity_type),
    .parity_en(parity_en),
    .stop2(stop2),
    .rx_dout(rx_data_out),
    .rx_done(rx_done),
    .correct(correct)
  );
endmodule
