module Receiver (
  input wire rx,
  input wire rx_tick,
  input wire reset,
  input wire [3:0] frame_length,
  input wire parity_type,
  input wire parity_en,
  input wire stop2,
  output reg [7:0] rx_dout,
  output reg rx_done,
  output reg correct
);
  
  // Define state enumeration
  typedef enum logic [1:0] {
    IDLE,
    DATA,
    STOP
  } state;

  state current_state, next_state;
  
  reg [7:0] bits;
  reg [3:0] data_counter, stop_bits_counter;
  reg parity_calculated, parity_received, finish_data;
  
  // Sequential block
  always @(posedge rx_tick or negedge reset)
    if (~reset) current_state = IDLE;
    else current_state = next_state;

  // Combinational logic for next state
  always @(posedge rx_tick or current_state) begin
    case (current_state)
      IDLE: begin
        if(rx) begin
          next_state = IDLE;
          data_counter = 0;
          stop_bits_counter = 0;
          rx_done = 0;
          finish_data = 0;
          parity_calculated = 0;
        end else next_state = DATA;
      end
      
      DATA: begin
        if(!rx_tick) next_state = DATA;
        else if(finish_data) next_state = STOP;
        else begin
          if(data_counter == frame_length) begin
            data_counter = 0;
            finish_data = 1;
            next_state = STOP;
            if(parity_en) begin
              parity_received = rx;
              parity_calculated = (parity_type) ? ~parity_calculated : parity_calculated;   // If 1 odd
            end
          end else begin
            next_state = DATA;
            bits = {rx, bits[7:1]};   // Shifting right
          	data_counter = data_counter + 1;
            parity_calculated = parity_calculated ^ rx;
          end
        end
      end
      
      STOP: begin
        if(!rx_tick) next_state = STOP;
        else begin
          if(stop_bits_counter == stop2) begin
            rx_done = 1;
            rx_dout = bits;
            next_state = IDLE;
          end else begin
            stop_bits_counter = stop_bits_counter + 1;
            next_state = STOP;
          end
        end
      end
      
      default: next_state = IDLE;
    endcase
  end
  
  assign correct = parity_calculated ~^ parity_received;
  
endmodule
