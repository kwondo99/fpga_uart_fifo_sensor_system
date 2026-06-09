`timescale 1ns / 1ps

module control_unit (
    input clk,
    input rst,
    input btnL,
    input btnD,
    input btnU,
    input btnR,
    input ascii_4,  // btnL
    input ascii_2,  // btnD
    input ascii_8,  // btnU
    input ascii_6,  // btnR
    input sw0,  // stopwatch <-> watch, SR04 <-> DHT11
    input sw1,  // Hour/Min <-> sec/msec
    input sw2,  // watch Set Mode <-> IDLE RUN
    input ascii_s,  // current status
    output [2:0] o_sel,  // watch, sel hour or min or sec
    output o_digit,  // watch, sel 1digit or 10digit
    output o_up_down,  // watch, 0 : up, 1 : down
    output o_mode,  // stopwatch,  change up_mode or down_mode
    output o_run_stop,  // stopwatch, run or stop
    output o_clear,  // stopwatch, clear
    output sr04_start,  // start sr04 for checking distance
    output dht11_start,  // start dht11 for checking Temperature and Humidity
    output [1:0] datapath_sel,  // select datapath
    output fnd_controller_sel,  // select fnd hour,min or sec,msec
    output sel_watch_status,  // start ascii_sender about watch_status
    output sel_sw_status,  // start ascii_sender about stopwatch_status
    output sel_sr04_status,  // start ascii_sender about sr04_status
    output sel_dht11_status,  // start ascii_sender about dht11_status 
    output [6:0] led0,
    output [1:0] led1
);

    wire w_btnL, w_btnD, w_btnU, w_btnR;
    wire w_watch_btnL, w_watch_btnU, w_watch_btnD, w_watch_sw_display, w_watch_sw_btn;
    wire w_stwatch_btnL, w_stwatch_btnD, w_stwatch_btnU;
    wire w_sensor_btnL, w_sensor_sw;
    wire w_sr04_status, w_dht11_status, w_watch_status, w_stwatch_status;

    btn_select U_BTN_SEL (
        .btnL     (btnL),
        .btnD     (btnD),
        .btnU     (btnU),
        .btnR     (btnR),
        .ascii_4  (ascii_4),  // btnL
        .ascii_2  (ascii_2),  // btnD
        .ascii_8  (ascii_8),  // btnU
        .ascii_6  (ascii_6),  // btnR
        .btn_left (w_btnL),
        .btn_down (w_btnD),
        .btn_up   (w_btnU),
        .btn_right(w_btnR)
    );

    select_control_unit U_SEL_CNTL (
        .clk             (clk),
        .rst             (rst),
        .btnL            (w_btnL),
        .btnD            (w_btnD),
        .btnU            (w_btnU),
        .btnR            (w_btnR),              // change watch/st_watch <-> THD
        .sw0             (sw0),                 // 1'b0 : watch or 
        .sw1             (sw1),
        .sw2             (sw2),
        .watch_btnL      (w_watch_btnL),
        .watch_btnU      (w_watch_btnU),
        .watch_btnD      (w_watch_btnD),
        .watch_sw_display(w_watch_sw_display),
        .watch_sw_btn    (w_watch_sw_btn),
        .stwatch_btnL    (w_stwatch_btnL),
        .stwatch_btnD    (w_stwatch_btnD),
        .stwatch_btnU    (w_stwatch_btnU),
        .sensor_btnL     (w_sensor_btnL),
        .sensor_sw       (w_sensor_sw),
        .SR04_status     (w_sr04_status),
        .DHT11_status    (w_dht11_status),
        .watch_status    (w_watch_status),
        .stwatch_status  (w_stwatch_status)
    );

    control_unit_watch U_WATCH_CNTL (
        .clk       (clk),
        .rst       (rst),
        .btnL      (w_watch_btnL),
        .btnR      (1'b0),
        .btnU      (w_watch_btnU),
        .btnD      (w_watch_btnD),
        .sw_display(w_watch_sw_display),  //sw[1]
        .sw_btn    (w_watch_sw_btn),      // sw[2]
        .o_led     (led0),
        .o_sel     (o_sel),
        .o_digit   (o_digit),
        .o_up_down (o_up_down)
    );

    control_unit_st_watch U_ST_WATCH_CNTL (
        .clk       (clk),
        .rst       (rst),
        .i_mode    (w_stwatch_btnD),  //down
        .i_clear   (w_stwatch_btnL),  //left
        .i_run_stop(w_stwatch_btnU),  // UP
        .i_btnu    (1'b0),            // undefined
        .sw        (2'b00),           // not use
        .o_mode    (o_mode),
        .o_run_stop(o_run_stop),
        .o_clear   (o_clear),
        .o_led     (led1)
    );

    sensor_control_unit U_SENSOR_CNTL (
        .btnL       (w_sensor_btnL),
        .sw0        (w_sensor_sw),
        .sr04_start (sr04_start),
        .dht11_start(dht11_start)
    );

    fnd_control_unit U_FND_CNTL (
        .clk               (clk),
        .rst               (rst),
        .sw0               (sw0),
        .sw1               (sw1),
        .btnR              (w_btnR),
        .datapath_sel      (datapath_sel),
        .fnd_controller_sel(fnd_controller_sel)
    );

    status_control_unit U_STATUS_CNTL (
        .clk               (clk),
        .rst               (rst),
        .sr04_status       (w_sr04_status),
        .dht11_status      (w_dht11_status),
        .watch_status      (w_watch_status),
        .stwatch_status    (w_stwatch_status),
        .ascii_s           (ascii_s),
        .sel_watch_status  (sel_watch_status),
        .sel_stwatch_status(sel_sw_status),
        .sel_sr04_status   (sel_sr04_status),
        .sel_dht11_status  (sel_dht11_status)
    );

endmodule

module status_control_unit (
    input      clk,
    input      rst,
    input      sr04_status,
    input      dht11_status,
    input      watch_status,
    input      stwatch_status,
    input      ascii_s,
    output reg sel_watch_status,
    output reg sel_stwatch_status,
    output reg sel_sr04_status,
    output reg sel_dht11_status
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            sel_watch_status <= 1'b0;
            sel_stwatch_status <= 1'b0;
            sel_sr04_status <= 1'b0;
            sel_dht11_status <= 1'b0;
        end else begin
            sel_watch_status <= 1'b0;
            sel_stwatch_status <= 1'b0;
            sel_sr04_status <= 1'b0;
            sel_dht11_status <= 1'b0;
            if (ascii_s) begin
                sel_watch_status <= watch_status;
                sel_stwatch_status <= stwatch_status;
                sel_sr04_status <= sr04_status;
                sel_dht11_status <= dht11_status;
            end
        end
    end

endmodule

module fnd_control_unit (
    input            clk,
    input            rst,
    input            sw0,
    input            sw1,
    input            btnR,
    output     [1:0] datapath_sel,
    output reg       fnd_controller_sel
);

    reg mode_watch_THD;  // 1'b0 : watch or stopwatch, 1'b1 : THD

    assign datapath_sel = {mode_watch_THD, sw0};

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            //datapath_sel <= 2'b00;
            fnd_controller_sel <= 1'b0;
            mode_watch_THD <= 1'b0;
        end else begin
            // btnR -> change mode
            if (btnR) begin
                mode_watch_THD <= ~mode_watch_THD;
            end
            //datapath_sel <= {mode_watch_THD, sw0};
            // THD_mode -> fnd_controller_sel = 0;
            if (mode_watch_THD) fnd_controller_sel = 1'b1;
            // watch/stopwatch
            else begin
                fnd_controller_sel <= sw1;
            end
        end
    end

endmodule

module sensor_control_unit (
    input  btnL,
    input  sw0,
    output sr04_start,
    output dht11_start
);

    assign sr04_start  = (btnL && (!sw0)) ? 1'b1 : 1'b0;
    assign dht11_start = (btnL && (sw0)) ? 1'b1 : 1'b0;

endmodule

module btn_select (
    input  btnL,
    input  btnD,
    input  btnU,
    input  btnR,
    input  ascii_4,   // btnL
    input  ascii_2,   // btnD
    input  ascii_8,   // btnU
    input  ascii_6,   // btnR
    output btn_left,
    output btn_down,
    output btn_up,
    output btn_right
);

    assign btn_left  = btnL || ascii_4;
    assign btn_down  = btnD || ascii_2;
    assign btn_up    = btnU || ascii_8;
    assign btn_right = btnR || ascii_6;

endmodule

module select_control_unit (
    input      clk,
    input      rst,
    input      btnL,
    input      btnD,
    input      btnU,
    input      btnR,              // change watch/st_watch <-> THD
    input      sw0,               // 1'b0 : watch or 
    input      sw1,
    input      sw2,
    output reg watch_btnL,
    output reg watch_btnU,
    output reg watch_btnD,
    output reg watch_sw_display,
    output reg watch_sw_btn,
    output reg stwatch_btnL,
    output reg stwatch_btnD,
    output reg stwatch_btnU,
    output reg sensor_btnL,
    output reg sensor_sw,
    output reg SR04_status,
    output reg DHT11_status,
    output reg watch_status,
    output reg stwatch_status
);

    reg mode_watch_THD;  // 1'b0 : watch/st_watch, 1'b1 : sensor

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            mode_watch_THD <= 0;
        end else if (btnR) mode_watch_THD <= ~mode_watch_THD;
    end

    always @(*) begin
        watch_btnL       = 0;
        watch_btnU       = 0;
        watch_btnD       = 0;
        watch_sw_display = 0;
        watch_sw_btn     = 0;
        stwatch_btnL     = 0;
        stwatch_btnD     = 0;
        stwatch_btnU     = 0;
        sensor_btnL      = 0;
        sensor_sw        = 0;
        SR04_status      = 0;
        DHT11_status     = 0;
        watch_status     = 0;
        stwatch_status   = 0;  // to sensor output 
        if (mode_watch_THD) begin
            sensor_btnL = btnL;
            sensor_sw   = sw0;
            if (sw0) DHT11_status = 1'b1;
            else SR04_status = 1'b1;
        end else begin
            case (sw0)
                // to watch output 
                1'b0: begin
                    watch_btnL = btnL;
                    watch_btnU = btnU;
                    watch_btnD = btnD;
                    watch_sw_display = sw1;
                    watch_sw_btn = sw2;
                    watch_status = 1'b1;
                end
                // to stopwatch output
                1'b1: begin
                    stwatch_btnL   = btnL;
                    stwatch_btnD   = btnD;
                    stwatch_btnU   = btnU;
                    stwatch_status = 1'b1;
                end
            endcase
        end
    end



endmodule

module control_unit_st_watch (
    input            clk,
    input            rst,
    input            i_mode,      //down
    input            i_clear,     //left
    input            i_run_stop,  // right
    input            i_btnu,      // undefined
    input      [1:0] sw,
    output           o_mode,
    output reg       o_run_stop,
    output reg       o_clear,
    output     [1:0] o_led
);

    parameter [1:0] STATE_STP = 2'b00;
    parameter [1:0] STATE_RUN = 2'b01;
    parameter [1:0] STATE_CLR = 2'b10;
    parameter [1:0] STATE_MOD = 2'b11;
    //parameter [1:0] STATE_STP = 0, STATE_RUN = 1, STATE_CLR = 2, STATE_MOD = 3;

    reg [1:0] current_state, next_state;
    reg mode_reg, mode_next;

    assign o_mode = mode_reg;

    assign o_led  = sw;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= STATE_STP;
            mode_reg      <= 1'b0;
        end else begin
            current_state <= next_state;
            mode_reg      <= mode_next;
        end
    end

    // next, output CL

    always @(*) begin
        next_state = current_state;
        mode_next = mode_reg;
        o_clear = 1'b0;
        o_run_stop = 1'b0;

        case (current_state)
            STATE_STP: begin
                o_run_stop = 1'b0;
                o_clear    = 1'b0;
                if (i_run_stop) next_state = STATE_RUN;
                else if (i_clear) next_state = STATE_CLR;
                else if (i_mode) next_state = STATE_MOD;
                else next_state = current_state;
            end
            STATE_RUN: begin
                o_run_stop = 1'b1;
                if (i_run_stop) next_state = STATE_STP;
                //else             next_state = current_state;
            end
            STATE_CLR: begin
                o_clear    = 1'b1;
                next_state = STATE_STP;
            end
            STATE_MOD: begin
                next_state = STATE_STP;
                mode_next  = ~mode_reg;
            end
        endcase
    end

endmodule

module control_unit_watch (
    input            clk,
    input            rst,
    input            btnL,
    input            btnR,
    input            btnU,
    input            btnD,
    input            sw_display,  //sw[1]
    input            sw_btn,      // sw[2]
    output reg [6:0] o_led,
    output reg [2:0] o_sel,
    output reg       o_digit,
    output reg       o_up_down
);

    parameter RUN_HOUR_MIN = 0;
    parameter RUN_SEC_MSEC = 1;
    parameter SET_10_HOUR = 2;
    parameter CH_10U_HOUR = 3;
    parameter CH_10D_HOUR = 4;
    parameter SET_1_HOUR = 5;
    parameter CH_1U_HOUR = 6;
    parameter CH_1D_HOUR = 7;
    parameter SET_10_MIN = 8;
    parameter CH_10U_MIN = 9;
    parameter CH_10D_MIN = 10;
    parameter SET_1_MIN = 11;
    parameter CH_1U_MIN = 12;
    parameter CH_1D_MIN = 13;
    parameter SET_10_SEC = 14;
    parameter CH_10U_SEC = 15;
    parameter CH_10D_SEC = 16;
    parameter SET_1_SEC = 17;
    parameter CH_1U_SEC = 18;
    parameter CH_1D_SEC = 19;

    reg [4:0] current_state, next_state;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= RUN_HOUR_MIN;
        end else current_state <= next_state;
    end

    // next state
    always @(*) begin
        o_led[6:0] = 7'b0000000;
        o_sel = 3'b000;  //3'b001 : sec, 3'b010 : min, 3'b100 : hour
        o_digit = 1'b0;  // 1'b1 : digit1, 1'b0 : digit10
        o_up_down = 1'b0;  // 1'b0 : up, 1'b1 : down
        next_state = current_state;
        case (current_state)
            RUN_HOUR_MIN: begin
                o_led = 7'b0000000;
                if (sw_display) next_state = RUN_SEC_MSEC;
                else if (btnR & sw_btn) next_state = SET_10_HOUR;
                else if (btnL & sw_btn) next_state = SET_1_MIN;
            end
            RUN_SEC_MSEC: begin
                o_led = 7'b0000010;
                if (!sw_display) next_state = RUN_HOUR_MIN;
                else if (btnR & sw_btn) next_state = SET_10_SEC;
                else if (btnL & sw_btn) next_state = SET_1_SEC;
            end
            SET_10_HOUR: begin
                o_led = 7'b1000100;
                if (!sw_btn) next_state = RUN_HOUR_MIN;
                else if (btnL) next_state = SET_1_MIN;
                else if (btnR) next_state = SET_1_HOUR;
                else if (btnU) next_state = CH_10U_HOUR;
                else if (btnD) next_state = CH_10D_HOUR;
                else if (sw_display) next_state = SET_10_SEC;
            end
            CH_10U_HOUR: begin
                o_sel = 3'b100;
                o_digit = 1'b0;
                o_up_down = 1'b0;
                next_state = SET_10_HOUR;
            end
            CH_10D_HOUR: begin
                o_sel = 3'b100;
                o_digit = 1'b0;
                o_up_down = 1'b1;
                next_state = SET_10_HOUR;
            end
            SET_1_HOUR: begin
                o_led = 7'b0100100;
                if (!sw_btn) next_state = RUN_HOUR_MIN;
                else if (btnL) next_state = SET_10_HOUR;
                else if (btnR) next_state = SET_10_MIN;
                else if (btnU) next_state = CH_1U_HOUR;
                else if (btnD) next_state = CH_1D_HOUR;
                else if (sw_display) next_state = SET_1_SEC;
            end
            CH_1U_HOUR: begin
                o_sel = 3'b100;
                o_digit = 1'b1;
                o_up_down = 1'b0;
                next_state = SET_1_HOUR;
            end
            CH_1D_HOUR: begin
                o_sel = 3'b100;
                o_digit = 1'b1;
                o_up_down = 1'b1;
                next_state = SET_1_HOUR;
            end
            SET_10_MIN: begin
                o_led = 7'b0010100;
                if (!sw_btn) next_state = RUN_HOUR_MIN;
                else if (btnL) next_state = SET_1_HOUR;
                else if (btnR) next_state = SET_1_MIN;
                else if (btnU) next_state = CH_10U_MIN;
                else if (btnD) next_state = CH_10D_MIN;
                else if (sw_display) next_state = SET_10_SEC;
            end
            CH_10U_MIN: begin
                o_sel = 3'b010;
                o_digit = 1'b0;
                o_up_down = 1'b0;
                next_state = SET_10_MIN;
            end
            CH_10D_MIN: begin
                o_sel = 3'b010;
                o_digit = 1'b0;
                o_up_down = 1'b1;
                next_state = SET_10_MIN;
            end
            SET_1_MIN: begin
                o_led = 7'b0001100;
                if (!sw_btn) next_state = RUN_HOUR_MIN;
                else if (btnL) next_state = SET_10_MIN;
                else if (btnR) next_state = SET_10_HOUR;
                else if (btnU) next_state = CH_1U_MIN;
                else if (btnD) next_state = CH_1D_MIN;
                else if (sw_display) next_state = SET_1_SEC;
            end
            CH_1U_MIN: begin
                o_sel = 3'b010;
                o_digit = 1'b1;
                o_up_down = 1'b0;
                next_state = SET_1_MIN;
            end
            CH_1D_MIN: begin
                o_sel = 3'b010;
                o_digit = 1'b1;
                o_up_down = 1'b1;
                next_state = SET_1_MIN;
            end
            SET_10_SEC: begin
                o_led = 7'b1000110;
                if (!sw_btn) next_state = RUN_SEC_MSEC;
                else if (btnL) next_state = SET_1_SEC;
                else if (btnR) next_state = SET_1_SEC;
                else if (btnU) next_state = CH_10U_SEC;
                else if (btnD) next_state = CH_10D_SEC;
                else if (!sw_display) next_state = SET_10_HOUR;
            end
            CH_10U_SEC: begin
                o_sel = 3'b001;
                o_digit = 1'b0;
                o_up_down = 1'b0;
                next_state = SET_10_SEC;
            end
            CH_10D_SEC: begin
                o_sel = 3'b001;
                o_digit = 1'b0;
                o_up_down = 1'b1;
                next_state = SET_10_SEC;
            end
            SET_1_SEC: begin
                o_led = 7'b0100110;
                if (!sw_btn) next_state = RUN_SEC_MSEC;
                else if (btnL) next_state = SET_10_SEC;
                else if (btnR) next_state = SET_10_SEC;
                else if (btnU) next_state = CH_1U_SEC;
                else if (btnD) next_state = CH_1D_SEC;
                else if (!sw_display) next_state = SET_1_HOUR;
            end
            CH_1U_SEC: begin
                o_sel = 3'b001;
                o_digit = 1'b1;
                o_up_down = 1'b0;
                next_state = SET_1_SEC;
            end
            CH_1D_SEC: begin
                o_sel = 3'b001;
                o_digit = 1'b1;
                o_up_down = 1'b1;
                next_state = SET_1_SEC;
            end
        endcase

        if (sw_btn) o_led[2] = 1'b1;
    end

endmodule
