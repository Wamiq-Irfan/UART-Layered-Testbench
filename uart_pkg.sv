package uart_pkg;

class uart_transaction;
    rand bit [7:0] tx_data;
         bit [7:0] rx_data;
    function void display(string msg);
        $display("------------------------------------");
        $display("%s",msg);
        $display("TX DATA = %h",tx_data);
        $display("RX DATA = %h",rx_data);
        $display("------------------------------------");
    endfunction
endclass

class uart_generator;
    mailbox #(uart_transaction) gen2drv;
    function new(mailbox #(uart_transaction) gen2drv);
        this.gen2drv = gen2drv;
    endfunction
    task run();
        uart_transaction tr;
        repeat(10)
        begin
            tr = new();
            assert(tr.randomize());
            $display("[%0t] GEN : DATA = %h",$time,tr.tx_data);
            gen2drv.put(tr);
        end
    endtask
endclass

class uart_driver;
    virtual uart_if vif;
    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) drv2scb;
    function new(
        virtual uart_if vif,
        mailbox #(uart_transaction) gen2drv,
        mailbox #(uart_transaction) drv2scb
    );
        this.vif     = vif;
        this.gen2drv = gen2drv;
        this.drv2scb = drv2scb;
    endfunction
    task reset();
        vif.reset        <= 1;
        vif.tx_start     <= 0;
        vif.data_in      <= 0;
        repeat(5)
            @(posedge vif.clk);
        vif.reset <= 0;
        $display("[%0t] DRIVER : RESET DONE",$time);
    endtask
    task run();
        uart_transaction tr;
        forever
        begin
            gen2drv.get(tr);
            drv2scb.put(tr);
            @(posedge vif.clk);
            vif.data_in  <= tr.tx_data;
            vif.tx_start <= 1;
            @(posedge vif.clk);
            vif.tx_start <= 0;
            $display("[%0t] DRIVER : SENT = %h",
                     $time,
                     tr.tx_data);
            wait(vif.tx_done);
            repeat(5)
                @(posedge vif.clk);
        end
    endtask
endclass

class uart_monitor;
    virtual uart_if vif;
    mailbox #(uart_transaction) mon2scb;
    function new(
        virtual uart_if vif,
        mailbox #(uart_transaction) mon2scb
    );
        this.vif = vif;
        this.mon2scb = mon2scb;
    endfunction
    task run();
        uart_transaction tr;
        forever
        begin
            @(posedge vif.rx_done);
            tr = new();
            tr.rx_data = vif.rx_data;
            $display("[%0t] MONITOR : RECEIVED = %h",
                     $time,
                     tr.rx_data);
            mon2scb.put(tr);
        end
    endtask
endclass

class uart_scoreboard;
    mailbox #(uart_transaction) drv2scb;
    mailbox #(uart_transaction) mon2scb;
    uart_transaction exp;
    uart_transaction act;
    integer pass_cnt = 0;
    integer fail_cnt = 0;
    function new(
        mailbox #(uart_transaction) drv2scb,
        mailbox #(uart_transaction) mon2scb
    );
        this.drv2scb = drv2scb;
        this.mon2scb = mon2scb;
    endfunction
    task run();
        forever
        begin
            drv2scb.get(exp);
            mon2scb.get(act);
            if(exp.tx_data == act.rx_data)
            begin
                pass_cnt++;
                $display("--------------------------------------");
                $display("[%0t] SCOREBOARD : PASS",$time);
                $display("Expected = %h",exp.tx_data);
                $display("Received = %h",act.rx_data);
                $display("--------------------------------------");
            end
            else
            begin
                fail_cnt++;
                $display("--------------------------------------");
                $display("[%0t] SCOREBOARD : FAIL",$time);
                $display("Expected = %h",exp.tx_data);
                $display("Received = %h",act.rx_data);
                $display("--------------------------------------");
            end
        end
    endtask
endclass

class uart_environment;
    uart_generator  gen;
    uart_driver     drv;
    uart_monitor    mon;
    uart_scoreboard scb;
    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) drv2scb;
    mailbox #(uart_transaction) mon2scb;
    virtual uart_if vif;
    function new(virtual uart_if vif);
        this.vif = vif;
        gen2drv = new();
        drv2scb = new();
        mon2scb = new();
        gen = new(gen2drv);
        drv = new(
                    vif,
                    gen2drv,
                    drv2scb
                 );
        mon = new(
                    vif,
                    mon2scb
                 );
        scb = new(
                    drv2scb,
                    mon2scb
                 );
    endfunction
    task run();
        drv.reset();
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_none
    endtask
endclass

class uart_test;
    uart_environment env;
    function new(virtual uart_if vif);
        env = new(vif);
    endfunction
    task run();
        env.run();
    endtask
endclass

endpackage
