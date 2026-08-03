`include "uart_if.sv"
`include "uart_pkg.sv"

import uart_pkg::*;

module tb_top;
logic clk;
always #10 clk = ~clk;
uart_if intf(clk);
uart_top DUT(
    .clk(clk),
    .reset(intf.reset),
    .tx_start(intf.tx_start),
    .data_in(intf.data_in),
    .rx_serial_in(intf.rx_serial_in),
    .tx_serial_out(intf.tx_serial_out),
    .tx_done(intf.tx_done),
    .rx_data(intf.rx_data),
    .rx_done(intf.rx_done),
    .error_flag(intf.error_flag)
);
assign intf.rx_serial_in = intf.tx_serial_out;
uart_test test;
initial
begin
    clk = 0;
    test = new(intf);
    test.run();
    #12000000;
    $display("--------------------------------");
    $display("Simulation Finished");
    $display("--------------------------------");
    $finish;
end
endmodule














