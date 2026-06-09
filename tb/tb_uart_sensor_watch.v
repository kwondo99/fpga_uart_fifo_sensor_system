`timescale 1ns / 1ps

module tb_uart_sensor_watch ();


    reg        clk;
    reg        rst;
    reg        btnR;
    reg        btnL;
    reg        btnU;
    reg        btnD;
    reg        echo;  // to sr04 
    reg  [2:0] sw;
    reg        rx;
    wire       tx;
    wire       trig;  // from sr04
    wire [7:0] fnd_data;
    wire [3:0] fnd_com;
    wire [6:0] led;
    wire       dht11;

    parameter BTN_PERIOD = (1_000_000_000 / 100_000) * 8;
    parameter ASCII_S = 8'h73, ASCII_2 = 8'h32, ASCII_4 = 8'h34, ASCII_6 = 8'h36, ASCII_8 = 8'h38;
    parameter BAUD_DELAY = 2_000;
    parameter BAUD_PERIOD = ((100_000_000 / 9600) * 10) - BAUD_DELAY;

    integer i;

    uart_sensor_watch dut (
        .clk     (clk),
        .rst     (rst),
        .btnR    (btnR),
        .btnL    (btnL),
        .btnU    (btnU),
        .btnD    (btnD),
        .echo    (echo),      // to sr04 
        .sw      (sw),
        .rx      (rx),
        .tx      (tx),
        .trig    (trig),      // from sr04
        .fnd_data(fnd_data),
        .fnd_com (fnd_com),
        .led     (led),
        .dht11   (dht11)
    );

    task reset();
        begin
            btnR = 0;
            btnL = 0;
            btnU = 0;
            btnD = 0;
            echo = 0;
            sw   = 3'b0;
            rx   = 1;
        end
    endtask

    task press_btnU();
        begin
            @(negedge clk);
            btnU = 1;
            #(BTN_PERIOD);
            #1000;

            btnU = 0;
            @(negedge clk);

        end
    endtask

    task press_btnD();
        begin
            @(negedge clk);
            btnD = 1;
            #(BTN_PERIOD);
            #1000;

            btnD = 0;
            @(negedge clk);

        end
    endtask

    task press_btnR();
        begin
            @(negedge clk);
            btnR = 1;
            #(BTN_PERIOD);
            #1000;

            btnR = 0;
            @(negedge clk);

        end
    endtask

    task press_btnL();
        begin
            @(negedge clk);
            btnL = 1;
            #(BTN_PERIOD);
            #1000;

            btnL = 0;
            @(negedge clk);

        end
    endtask

    task sender_uart(input [7:0] send_data);  // task can delay, function no
        begin
            //pc tx
            //start
            rx = 0;
            //start bit
            #(BAUD_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                // rx, send_data[0]~[7]
                rx = send_data[i];
                #(BAUD_PERIOD);
            end
            rx = 1;
            #(BAUD_PERIOD);
        end
    endtask

    task watch_control();
        begin
            sw[2] = 1'b1;
            press_btnL();
            sender_uart(ASCII_2);
            #(BAUD_PERIOD * 110);
            sender_uart(ASCII_S);
            sw[2] = 1'b0;
        end
    endtask

    task stopwatch_control();
        begin
            sw[0] = 1'b1;
            sw[1] = 1'b1;
            press_btnD();
            sender_uart(ASCII_8);
            #10_500_000;
            press_btnU();
            #1_000_000;
            sender_uart(ASCII_S);
            #(BAUD_PERIOD * 110);
            sw[1] = 1'b0;
            sw[0] = 1'b0;
        end
    endtask

    task sr04_control();
        begin
            sender_uart(ASCII_6);
            press_btnL();
            echo = 1;
            #130_000;
            echo = 0;
            sender_uart(ASCII_S);
            #(BAUD_PERIOD * 100);
        end
    endtask

    parameter [7:0] HUMI_INT = 8'd60;  // 습도 정수부
    parameter [7:0] TEMP_INT = 8'd25;  // 온도 정수부
    parameter [39:0] DATA_STREAM = {
        HUMI_INT, 8'h00, TEMP_INT, 8'h00, HUMI_INT + TEMP_INT
    };

    reg dht_sensor_data;
    reg io_oe;
    assign dht11 = (io_oe) ? dht_sensor_data : 1'bz;

    task dht11_control();
        begin
            sw[0] = 1;
            io_oe = 0;
            sender_uart(ASCII_4);
            wait (!dht11);
            // 18msec 대기
            wait (dht11);
            #30000;
            // 입력 모드로 변환
            io_oe = 1;
            dht_sensor_data = 1'b0;
            #80000;
            dht_sensor_data = 1'b1;
            #80000;
            for (i = 39; i >= 0; i = i - 1) begin
                dht_sensor_data = 0;
                #50000;
                dht_sensor_data = 1'b1;
                #(DATA_STREAM[i] ? 70000 : 26000);

            end
            dht_sensor_data = 0;
            #50000;
            io_oe = 0;
            force dut.w_dht11_data = {{8'd30}, {8'd25}};  
            sender_uart(ASCII_S);
            #(BAUD_PERIOD * 150);
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10;

        rst = 0;

        reset();

        watch_control();

        stopwatch_control();

        sr04_control();

        dht11_control();

        #1000000;

        $stop;
    end

endmodule

