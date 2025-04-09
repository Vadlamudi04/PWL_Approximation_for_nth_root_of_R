module pwl(
  input signed [13:0] x,  // Input operand x  
  input signed [13:0] x0, // Input operand xn	
  input signed [13:0] x1,
  input signed [13:0] x2,
  input signed [13:0] x3,
  input signed [13:0] x4,
  input signed [13:0] x5,
  input signed [13:0] x6,
  input signed [13:0] x7,
  input signed [13:0] x8,
  input signed [13:0] k0,  // Input operand k
  input signed [13:0] k1,
  input signed [13:0] k2,
  input signed [13:0] k3,
  input signed [13:0] k4,
  input signed [13:0] k5,
  input signed [13:0] k6,
  input signed [13:0] k7,
  input signed [13:0] k8,
  input signed [13:0] k9,
  input signed [13:0] b0,  // Input operand b
  input signed [13:0] b1,
  input signed [13:0] b2,
  input signed [13:0] b3,
  input signed [13:0] b4,
  input signed [13:0] b5,
  input signed [13:0] b6,
  input signed [13:0] b7,
  input signed [13:0] b8,
  input signed [13:0] b9,
  input clk,
  output reg signed [27:0] out
);

//reg signed [13:0] xn [0:8];
//reg signed [13:0] k [0:9];
//reg signed [13:0] b [0:9];

reg signed [13:0] x_reg;

always @(posedge clk) begin
    x_reg <= x;
end

wire [8:0] z;
assign z[0] = ((x-x0) < 0);
assign z[1] = ((x-x1) < 0);
assign z[2] = ((x-x2) < 0);
assign z[3] = ((x-x3) < 0);
assign z[4] = ((x-x4) < 0);
assign z[5] = ((x-x5) < 0);
assign z[6] = ((x-x6) < 0);
assign z[7] = ((x-x7) < 0);
assign z[8] = ((x-x8) < 0);

reg [13:0] kx, bx;

always @(*) begin
    case(z)
        9'b111111111: begin
            kx = k0; 
            bx = b0;
        end
        9'b011111111: begin
            kx = k1; 
            bx = b1;
        end
        9'b001111111: begin
            kx = k2; 
            bx = b2;
        end
        9'b000111111: begin
            kx = k3; 
            bx = b3;
        end
        9'b000011111: begin
            kx = k4; 
            bx = b4;
        end
        9'b000001111: begin
            kx = k5; 
            bx = b5;
        end
        9'b000000111: begin
            kx = k6; 
            bx = b6;
        end
        9'b000000011: begin
            kx = k7; 
            bx = b7;
        end
        9'b000000001: begin
            kx = k8; 
            bx = b8;
        end
        9'b000000000: begin
            kx = k9; 
            bx = b9;
        end
    endcase
end

  reg [27:0] mul_out;

  reg signed [13:0] P_reg1_high, P_reg2_high;
  reg signed [13:0] P_reg1_low, P_reg2_low;
 
  always @(posedge clk) begin
    P_reg1_high <= kx[13:7] * x_reg[13:7];
    P_reg1_low <= kx[6:0] * x_reg[6:0];
    P_reg2_high <= kx[13:7] * x_reg[6:0];
    P_reg2_low <= kx[6:0] * x_reg[13:7];
  end
  always @(posedge clk) begin
    mul_out <= P_reg1_low + (P_reg1_high << 14) + (P_reg2_high << 7) + (P_reg2_low << 7);
  end

reg [13:0] bx1,bx2;

always @(posedge clk) begin
    bx1 <= bx;
    bx2 <= bx1;
end

always @(posedge clk) begin
    out <= (mul_out+bx2);
end

endmodule




