`timescale 1ns / 1ps

module tb_control_unit ();

    reg clk;
    reg rst;
    reg btnL;
    reg btnD;
    reg btnU;
    reg btnR;
    reg ascii_4;  // btnL
    reg ascii_2;  // btnD
    reg ascii_8;  // btnU
    reg ascii_6;  // btnR
    reg sw0;  // stopwatch <-> watch, SR04 <-> DHT11
    reg sw1;  // Hour/Min <-> sec/msec
    reg sw2;  // watch Set Mode <-> IDLE RUN
    reg ascii_s;  // current status
    wire [2:0] o_sel;  // watch, sel hour or min or sec
    wire o_digit;  // watch, sel 1digit or 10digit
    wire o_up_down;  // watch, 0 : up, 1 : down
    wire o_mode;  // stopwatch,  change up_mode or down_mode
    wire o_run_stop;  // stopwatch, run or stop
    wire o_clear;  // stopwatch, clear
    wire sr04_start;  // start sr04 for checking distance
    wire dht11_start;  // start dht11 for checking Temperature and Humidity
    wire [1:0] datapath_sel;  // select datapath
    wire fnd_controller_sel;  // select fnd hour,min or sec,msec
    wire sel_watch_status;  // start ascii_sender about watch_status
    wire sel_sw_status;  // start ascii_sender about stopwatch_status
    wire sel_sr04_status;  // start ascii_sender about sr04_status
    wire sel_dht11_status;  // start ascii_sender about dht11_status 
    wire [6:0] led0;
    wire [1:0] led1;

    control_unit dut (
        .clk(clk),
        .rst(rst),
        .btnL(btnL),
        .btnD(btnD),
        .btnU(btnU),
        .btnR(btnR),
        .ascii_4(ascii_4),  // btnL
        .ascii_2(ascii_2),  // btnD
        .ascii_8(ascii_8),  // btnU
        .ascii_6(ascii_6),  // btnR
        .sw0(sw0),  // stopwatch <-> watch, SR04 <-> DHT11
        .sw1(sw1),  // Hour/Min <-> sec/msec
        .sw2(sw2),  // watch Set Mode <-> IDLE RUN
        .ascii_s(ascii_s),  // current status
        .o_sel(o_sel),  // watch, sel hour or min or sec
        .o_digit(o_digit),  // watch, sel 1digit or 10digit
        .o_up_down(o_up_down),  // watch, 0 : up, 1 : down
        .o_mode(o_mode),  // stopwatch,  change up_mode or down_mode
        .o_run_stop(o_run_stop),  // stopwatch, run or stop
        .o_clear(o_clear),  // stopwatch, clear
        .sr04_start(sr04_start),  // start sr04 for checking distance
        .dht11_start(dht11_start),  // start dht11 for checking Temperature and Humidity
        .datapath_sel(datapath_sel),  // select datapath
        .fnd_controller_sel(fnd_controller_sel),  // select fnd hour,min or sec,msec
        .sel_watch_status(sel_watch_status),  // start ascii_sender about watch_status
        .sel_sw_status(sel_sw_status),  // start ascii_sender about stopwatch_status
        .sel_sr04_status(sel_sr04_status),  // start ascii_sender about sr04_status
        .sel_dht11_status(sel_dht11_status),  // start ascii_sender about dht11_status 
        .led0(led0),
        .led1(led1)
    );

    always #5 clk = ~clk;

    // for reset
    task reset();
        begin
            rst     = 1;
            btnL    = 0;
            btnD    = 0;
            btnU    = 0;
            btnR    = 0;
            ascii_4 = 0;
            ascii_2 = 0;
            ascii_8 = 0;
            ascii_6 = 0;
            sw0     = 0;
            sw1     = 0;
            sw2     = 0;
            ascii_s = 0;

            #10;
            rst = 0;

            #10;
        end
    endtask


    // for o_sel generate
    task o_sel_gen();
        begin
            @(negedge clk);
            btnL    = 1;
            btnD    = 0;
            btnU    = 0;
            btnR    = 0;
            ascii_4 = 0;
            ascii_2 = 0;
            ascii_8 = 0;
            ascii_6 = 0;
            sw0     = 0;
            sw1     = 0;
            sw2     = 1;
            ascii_s = 0;

            @(negedge clk);
            btnL = 0;
            ascii_2 = 1;

            @(negedge clk);
            ascii_2 = 0;
            sw2  = 0;

            @(negedge clk);
            ascii_s = 1;

            @(negedge clk);
            ascii_s = 0;

        end
    endtask

    task stopwatch_control_gen();
        begin
            @(negedge clk);
            btnL    = 0;
            btnD    = 0;
            btnU    = 0;
            btnR    = 0;
            ascii_4 = 0;
            ascii_2 = 0;
            ascii_8 = 1;
            ascii_6 = 0;
            sw0     = 1;
            sw1     = 0;
            sw2     = 0;
            ascii_s = 0;

            @(negedge clk);
            ascii_8 = 0;

            @(negedge clk);
            btnU = 1;

            @(negedge clk);
            btnU = 0;

            @(negedge clk);
            ascii_4 = 1;

            @(negedge clk);
            ascii_4 = 0;

            @(negedge clk);
            btnD = 1;

            @(negedge clk);
            ascii_s = 1;
            btnD = 0;

            @(negedge clk);
            ascii_s = 0;

            @(negedge clk);
            sw0 = 0;

        end
    endtask

    task sr04_control_gen();
        begin
            @(negedge clk);
            btnL    = 0;
            btnD    = 0;
            btnU    = 0;
            btnR    = 0;
            ascii_4 = 0;
            ascii_2 = 0;
            ascii_8 = 0;
            ascii_6 = 1;
            sw0     = 0;
            sw1     = 0;
            sw2     = 0;
            ascii_s = 0;

            @(negedge clk);
            ascii_6 = 0;

            @(negedge clk);
            btnL = 1;

            @(negedge clk);
            btnL = 0;

            @(negedge clk);
            ascii_s = 1;

            @(negedge clk);
            ascii_s = 0;


        end
    endtask

    task dht11_control_gen();
        begin
            @(negedge clk);
            btnL    = 0;
            btnD    = 0;
            btnU    = 0;
            btnR    = 0;
            ascii_4 = 0;
            ascii_2 = 0;
            ascii_8 = 0;
            ascii_6 = 0;
            sw0     = 1;
            sw1     = 0;
            sw2     = 0;
            ascii_s = 0;

            @(negedge clk);
            btnL = 1;

            @(negedge clk);
            btnL = 0;

            @(negedge clk);
            ascii_s = 1;

            @(negedge clk);
            ascii_s = 0;

        end
    endtask

    initial begin
        clk = 0;

        reset();

        o_sel_gen();

        stopwatch_control_gen();

        sr04_control_gen();

        dht11_control_gen();

        #10;
        $stop;

    end


endmodule
