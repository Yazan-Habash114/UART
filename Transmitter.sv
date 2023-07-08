module Transmitter (
  input wire tx_tick,
  input wire tx_start,
  input wire reset,
  input wire [3:0] frame_length,
  input wire [7:0] tx_din,
  input wire parity_type,
  input wire parity_en,
  input wire stop2,
  output reg tx,
  output reg tx_done
);
  
  // Define state enumeration
  typedef enum logic [3:0] {
    IDLE,
    START,
    DATA,
    STOP
  } state;

  state current_state, next_state;
  
  reg [7:0] bits;
  reg [3:0] data_counter, stop_bits_counter;
  reg parity;
  
  // Sequential block
  always @(posedge tx_tick or negedge reset)
    if (~reset) current_state = IDLE;
    else current_state = next_state;

  // Combinational logic for next state
  always @(posedge tx_tick or current_state) begin
    case (current_state)
      IDLE: begin
        if(~tx_start) begin
          next_state = IDLE;
          data_counter = 0;
          stop_bits_counter = 0;
          tx_done = 0;
          bits = tx_din;
          tx = 1;
          parity = tx_din[0];
        end else next_state = START;
      end
      
      START: begin
        next_state = (tx_tick) ? DATA : START;
        tx = 0;   // Start bit
      end
      
      DATA: begin
        if(!tx_tick) next_state = DATA;
        else begin
          if(data_counter == frame_length) begin
            data_counter = 0;
            next_state = STOP;
            if(parity_en) begin
              parity = (parity_type) ? ~parity : parity; // If 1 odd
              tx = parity;
            end else tx = 1;
          end else begin
            next_state = DATA;
            tx = bits[0];
            bits = bits >> 1;   // Shifting right
          	data_counter = data_counter + 1;
            parity = parity ^ bits[0];
          end
        end
      end
      
      STOP: begin
        tx = 1;
        if(!tx_tick) next_state = STOP;
        else begin
          if(stop_bits_counter == (stop2 + parity_en)) begin
            tx_done = 1;
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
  
endmodule
