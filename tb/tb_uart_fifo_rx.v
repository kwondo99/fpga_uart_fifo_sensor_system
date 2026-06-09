`timescale 1ns / 1ps

module tb_uart_fifo_rx();

    parameter BAUD_PERIOD = (100_000_000/9600) * 10;

	reg clk, rst, rx;
	wire [2:0] o_sel;
    wire o_digit;
    wire o_up_down;

	uart_fifo_rx dut_tx(
	    .clk(clk),
	    .rst(rst),
	    .rx(rx), //from PC
	    .o_sel(o_sel),
        .o_digit(o_digit),
        .o_up_down(o_up_down) 
	    );


	always #5 clk = ~clk;

	integer i;

    task SENDER_UART(input [7:0] send_data);
    begin
        // pc tx
        // start
        rx = 0;
        // start bit
        #(BAUD_PERIOD);
        // data bit
        for (i = 0; i < 8; i = i + 1 ) begin
            // rx , send_data[0] ~ [7]
            rx = send_data[i];
            #(BAUD_PERIOD);
        end
        rx = 1;
        #(BAUD_PERIOD);
    end
    endtask


	initial begin
        clk = 0;
        rst = 1;
        rx  = 1;
        @(negedge clk);
        @(negedge clk);

        rst = 0;
        SENDER_UART(8'h30);


        #(BAUD_PERIOD*10);
        #1000;

        SENDER_UART(8'h31);

        #(BAUD_PERIOD*10);
        #1000;

        SENDER_UART(8'h32);

        #(BAUD_PERIOD*10);
        #1000;

        SENDER_UART(8'h33);

        #(BAUD_PERIOD*10);
        #1000;

        SENDER_UART(8'h34);

        #(BAUD_PERIOD*10);
        #1000;
		$stop;
	end

endmodule

