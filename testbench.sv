// Code your testbench here
// or browse Examples
module UART_Test;
  
  parameter CLK_PERIOD = 10;
  
  reg clk, reset, rx, tx_start, parity_type, parity_en, stop2;
  reg [1:0] baud;
  reg [3:0] frame_length;
  reg [7:0] tx_data_in;
  wire correct, rx_done, tx_done, tx;
  wire [7:0] rx_data_out;
  
  UART dut(
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .tx_start(tx_start),
    .parity_type(parity_type),
    .parity_en(parity_en),
    .stop2(stop2),
    .baud(baud),
    .frame_length(frame_length),
    .tx_data_in(tx_data_in),
    .correct(correct),
    .rx_done(rx_done),
    .tx_done(tx_done),
    .tx(tx),
    .rx_data_out(rx_data_out)
  );
  
  always #(CLK_PERIOD / 2) clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    clk = 0;
    reset = 1;
    baud = 2'b11;
    
    tx_start = 0;
    frame_length = 8;
    tx_data_in = 8'hB4;  // Even parity = 0
    rx = 1;
    parity_en = 1;
    parity_type = 0;
    stop2 = 1;
    
    reset = 0;
    #3000;
    
    reset = 1;
    
    // Start Receiving (0x9A)
    #2620 rx = 0;   // Start bit
    #2620 rx = 0;   // D0
    #2620 rx = 1;   // D1
    #2620 rx = 0;   // D2
    #2620 rx = 1;   // D3
    #2620 rx = 1;   // D4
    #2620 rx = 0;   // D5
    #2620 rx = 0;   // D6
    #2620 rx = 1;   // D7
    #2620 rx = 0;   // Even parity
    #2620 rx = 1;   // Stop bit
    #2620 rx = 1;   // Stop bit
    #2620 rx = 1;   // Idle again
    
    // Start Transmitting
    #2602 tx_start = 1;
    #3000 tx_start = 0;
    
    #50000 $finish;
  end
endmodule
