module baud_gen(
    input  logic clk,
    input  logic reset,
    output logic tick
);
    parameter CLOCK_FREQ = 50_000_000; 
    parameter BAUD_RATE  = 9600;
    localparam integer DIVISOR = CLOCK_FREQ / BAUD_RATE;

    integer count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            tick <= 0;
        end else begin
            if (count == DIVISOR-1) begin
                count <= 0;
                tick <= 1;
            end else begin
                count <= count + 1;
                tick <= 0;
            end
        end
    end
endmodule

module uart_tx(
    input  logic clk,
    input  logic reset,
    input  logic tick,
    input  logic tx_start,
    input  logic [7:0] data_in,
    output logic tx_serial_out,
    output logic tx_done
);
    logic [9:0] shift_reg;
    logic [3:0] bit_count;
    logic sending;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 10'b1111111111;
            bit_count <= 0;
            tx_done <= 0;
            sending <= 0;
            tx_serial_out <= 1; // idle high
        end else begin
            tx_done <= 0;
            if (tx_start && !sending) begin
                shift_reg <= {1'b1, data_in, 1'b0}; // stop + data + start
                sending <= 1;
                bit_count <= 0;
            end else if (sending && tick) begin
                tx_serial_out <= shift_reg[0];
                shift_reg <= shift_reg >> 1;
                bit_count <= bit_count + 1;
                if (bit_count == 9) begin
                    sending <= 0;
                    tx_done <= 1;
                    tx_serial_out <= 1;
                end
            end
        end
    end
endmodule

module uart_rx(
    input  logic clk,
    input  logic reset,
    input  logic tick,           
    input  logic rx_serial_in,   
    output logic [7:0] rx_data, 
    output logic rx_done,       
    output logic error_flag     
);

    // States
    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [3:0] bit_count;
    logic [7:0] buffer;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_count <= 0;
            buffer <= 0;
            rx_data <= 0;
            rx_done <= 0;
            error_flag <= 0;
        end else begin
            rx_done <= 0;
            error_flag <= 0;

            case (state)
                IDLE: begin
                    if (rx_serial_in == 0) begin
                        state <= START;  
                        bit_count <= 0;
                    end
                end

                START: begin
                    if (tick) begin
                        state <= DATA;   
                    end
                end

                DATA: begin
                    if (tick) begin
                        buffer <= {rx_serial_in, buffer[7:1]}; 
                        bit_count <= bit_count + 1;
                        if (bit_count == 7)
                            state <= STOP; 
                    end
                end

                STOP: begin
                    if (tick) begin
                        if (rx_serial_in == 1) begin
                            rx_data <= buffer; 
                            rx_done <= 1;
                        end else begin
                            error_flag <= 1; 
                        end
                        state <= IDLE; 
                    end
                end
            endcase
        end
    end
endmodule


module uart_top(
    input  logic clk,
    input  logic reset,
    input  logic tx_start,
    input  logic [7:0] data_in,
    input  logic rx_serial_in,
    output logic tx_serial_out,
    output logic tx_done,
    output logic [7:0] rx_data,
    output logic rx_done,
    output logic error_flag
);
    logic tick;

    baud_gen #(50_000_000, 9600) baud_inst(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    uart_tx tx_inst(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx_serial_out(tx_serial_out),
        .tx_done(tx_done)
    );

    uart_rx rx_inst(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rx_serial_in(rx_serial_in),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .error_flag(error_flag)
    );
endmodule
