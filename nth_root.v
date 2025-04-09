// ============ MODULE: float16_unpack ==============
module float16_unpack (
    input  wire [15:0] in,
    output wire sign,
    output wire [4:0] exponent,
    output wire [9:0] fraction
);
    assign sign     = in[15];
    assign exponent = in[14:10];
    assign fraction = in[9:0];
endmodule

// ============ MODULE: log2_pwl ==============
module log2_pwl (
    input  wire [13:0] x,           // Q4.10
    output reg  signed [15:0] y     // Q4.12
);
    reg [13:0] xn [0:8];    
    reg signed [13:0] k  [0:9];    
    reg signed [13:0] b  [0:9];
    integer i;
    reg found;

    initial begin
        xn[0] = 14'd4096;
        xn[1] = 14'd4395;
        xn[2] = 14'd4729;
        xn[3] = 14'd5095;
        xn[4] = 14'd5498;
        xn[5] = 14'd5939;
        xn[6] = 14'd6424;
        xn[7] = 14'd6955;
        xn[8] = 14'd7536;

        k[0]  = 14'd5706;   b[0]  = -14'sd5702;
        k[1]  = 14'd5302;   b[1]  = -14'sd5282;
        k[2]  = 14'd4933;   b[2]  = -14'sd4920;
        k[3]  = 14'd4594;   b[3]  = -14'sd4418;
        k[4]  = 14'd4278;   b[4]  = -14'sd4000;
        k[5]  = 14'd3986;   b[5]  = -14'sd3573;
        k[6]  = 14'd3719;   b[6]  = -14'sd3148;
        k[7]  = 14'd3472;   b[7]  = -14'sd2719;
        k[8]  = 14'd3240;   b[8]  = -14'sd2297;
        k[9]  = 14'd3057;   b[9]  = -14'sd1952;
    end

    always @(*) begin
        found = 0;
        for (i = 0; i < 9; i = i + 1) begin
            if (!found && x < xn[i+1]) begin
                y = (k[i] * $signed(x)) >> 12 + b[i];
                found = 1;
            end
        end
        if (!found)
            y = (k[9] * $signed(x)) >> 12 + b[9];
    end
endmodule

// ============ MODULE: pow2_pwl ==============
module pow2_pwl (
    input  wire [15:0] x,          
    output reg  [15:0] y           
);
    reg [15:0] xn [0:8];
    reg [15:0] k  [0:9];
    reg [15:0] b  [0:9];
    integer i;
    reg found;

    initial begin
        xn[0] = 16'd0;
        xn[1] = 16'd497;
        xn[2] = 16'd975;
        xn[3] = 16'd1435;
        xn[4] = 16'd1876;
        xn[5] = 16'd2299;
        xn[6] = 16'd2705;
        xn[7] = 16'd3094;
        xn[8] = 16'd3466;

        k[0] = 16'd2963; b[0] = 16'd4094;
        k[1] = 16'd3216; b[1] = 16'd4066;
        k[2] = 16'd3488; b[2] = 16'd4000;
        k[3] = 16'd3761; b[3] = 16'd3906;
        k[4] = 16'd4041; b[4] = 16'd3785;
        k[5] = 16'd4329; b[5] = 16'd3624;
        k[6] = 16'd4624; b[6] = 16'd3432;
        k[7] = 16'd4926; b[7] = 16'd3200;
        k[8] = 16'd5234; b[8] = 16'd2939;
        k[9] = 16'd5500; b[9] = 16'd2620;
    end

    always @(*) begin
        found = 0;
        for (i = 0; i < 9; i = i + 1) begin
            if (!found && x < xn[i+1]) begin
                y = (k[i] * x) >> 12 + b[i];
                found = 1;
            end
        end
        if (!found)
            y = (k[9] * x) >> 12 + b[9];
    end
endmodule

// ============ MODULE: root_float16 ==============
module root_float16 #(parameter N = 2)(
    input  wire [15:0] x_in,
    output wire [15:0] out
);
    wire sign;
    wire [4:0] exponent;
    wire [9:0] fraction;
    wire [13:0] mantissa_norm;
    wire signed [15:0] log_m;
    wire signed [15:0] log_x, divn, pf;
    wire [3:0]  pi;
    wire [15:0] pow2_frac;
    wire [15:0] final_mantissa;
    wire [4:0]  final_exp;

    float16_unpack unpack (.in(x_in), .sign(sign), .exponent(exponent), .fraction(fraction));
    assign mantissa_norm = 14'd4096 + (fraction << 2);

    log2_pwl log2block (.x(mantissa_norm), .y(log_m));
    assign log_x = log_m + ((exponent - 5'd15) <<< 12);
    assign divn  = log_x / N;

    assign pi = divn[15:12];           // Integer part
    assign pf = divn & 16'h0FFF;       // Fractional part

    pow2_pwl pow2block (.x(pf), .y(pow2_frac));
    assign final_exp = pi + 5'd15;
    assign final_mantissa = (pow2_frac - 16'd4096) >> 2

    assign out = {1'b0, final_exp, final_mantissa[9:0]};
endmodule
