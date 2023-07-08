// Code your design here
module BaudRateGenerator (
  input wire clk,
  input wire reset,
  input wire [1:0] baud,
  output reg tick
);

  reg [31:0] counter;
  reg [31:0] divisor;
  reg [31:0] baudrate;
  
  initial begin
    tick <= 0;
    counter <= 0;
  end

  always @(posedge clk, negedge reset) begin
    if(~reset) begin
      counter <= 0;
      tick <= 0;
    end else begin
      counter <= counter + 1;
      if (counter >= divisor) begin
        counter <= 0;
        tick <= ~tick;
      end
    end
  end
  
  always @(baud) begin
    counter <= 0;
    tick <= 0;
    case(baud)
      2'b00: baudrate <= 4800;
      2'b01: baudrate <= 9600;
      2'b10: baudrate <= 14400;
      2'b11: baudrate <= 19200;
    endcase
  end
  
  assign divisor = 5000000 / (2 * baudrate);

endmodule
