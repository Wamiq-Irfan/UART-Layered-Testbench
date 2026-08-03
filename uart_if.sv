interface uart_if(input logic clk);

    logic reset;

    logic tx_start;
    logic [7:0] data_in;

    logic rx_serial_in;
    logic tx_serial_out;

    logic tx_done;
    logic [7:0] rx_data;
    logic rx_done;
    logic error_flag;

endinterface
