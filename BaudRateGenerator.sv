// Code your design here
module BaudRateGenerator (
  input wire clk,
  input wire [31:0] ticks_per_bit,
  output reg tick
);

  reg [31:0] counter;
  
  initial begin
    tick <= 0;
    counter <= 0;
  end

  always @(posedge clk) begin
    counter <= counter + 1;

    if (counter >= ticks_per_bit) begin
      counter <= 0;
      tick <= ~tick;
    end
  end

endmodule
