// Code your testbench here
// or browse Examples
module UART_Test;
  parameter DATA_BITS = 8, SB_TICKS = 2, IS_PARITY = 1, PARITY = 0;
  
  parameter CLK_PERIOD = 10;
  
  reg clk, reset, rx, tx_start;
  reg [DATA_BITS - 1:0] tx_data_in;
  reg [31:0] ticks_per_bit;
  wire correct, rx_done, tx_done, tx;
  wire [DATA_BITS - 1:0] rx_data_out;
  
  UART #(DATA_BITS, SB_TICKS, IS_PARITY, PARITY) dut(
    clk, reset, ticks_per_bit, rx, tx_start, tx_data_in, correct, rx_done, tx_done, tx, rx_data_out
  );
  
  always #(CLK_PERIOD / 2) clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    
    clk = 0;
    reset = 1;
    ticks_per_bit = 2;   // Tick half cycle = (2+1) * CLK_PERIOD
						 // Hence, cycle = 3 * 10 * 2 = 60ns
    tx_start = 0;
    tx_data_in = 8'hb4;  // Even parity = 0
    rx = 1;
    
    reset = 0;
    #(CLK_PERIOD);
    
    reset = 1;
    
    // Start Receiving (0x9A)
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 0;   // Start bit
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 0;   // D0
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 1;   // D1
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 0;   // D2
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 1;   // D3
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 1;   // D4
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 0;   // D5
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 0;   // D6
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 1;   // D7
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 0;   // Even parity
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 1;   // Stop bit
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 1;   // Stop bit
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD) rx = 1;   // Idle again
    
    // Start Transmitting
    #((ticks_per_bit + 1) * CLK_PERIOD) tx_start = 1;
    #((ticks_per_bit + 1) * 2 * CLK_PERIOD + CLK_PERIOD) tx_start = 0;
    
    #1000 $finish;
  end
endmodule