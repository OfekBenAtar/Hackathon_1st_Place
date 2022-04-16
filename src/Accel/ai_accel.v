`timescale 1ns/1ps

// multiplier returns 16 bit output, used for variance (pow)
module multiplier_no_cut
(
	a,b, c
);

	input [7:0] a;
	input [7:0] b;
	output [15:0] c;

	assign c = a*b;
endmodule


// multiplier returns 16 bit output, cutoff
module multiplier
(
	a,b, c
);

	input [7:0] a;
	input [7:0] b;
	output [7:0] c;
	wire[15:0] my_c;
	assign my_c = a*b;
	
	
	assign c = (my_c[15:8] != 8'h0) ? 16'hff : my_c[7:0] ;

endmodule



// multiply matrix\vector a by matrix\vector b, dot product
module multiplier9by9
(
	a1, a2, a3, a4, a5, a6, a7, a8, a9,
	b1, b2, b3, b4, b5, b6, b7, b8, b9,
	res
);
	input [7:0] a1;
	input [7:0] a2;
	input [7:0] a3;
	input [7:0] a4;
	input [7:0] a5;
	input [7:0] a6;
	input [7:0] a7;
	input [7:0] a8;
	input [7:0] a9;
	
	input [7:0] b1;
	input [7:0] b2;
	input [7:0] b3;
	input [7:0] b4;
	input [7:0] b5;
	input [7:0] b6;
	input [7:0] b7;
	input [7:0] b8;
	input [7:0] b9;
	
	// saving 1 by 1 multiply results
	wire [7:0] mult1, mult2, mult3, mult4, mult5, mult6, mult7, mult8, mult9;
	output [7:0] res;
	
	//performing dot product
	multiplier mul1(.a(a1), .b(b1), .c(mult1));
	multiplier mul2(.a(a2), .b(b2), .c(mult2));
	multiplier mul3(.a(a3), .b(b3), .c(mult3));
	multiplier mul4(.a(a4), .b(b4), .c(mult4));
	multiplier mul5(.a(a5), .b(b5), .c(mult5));
	multiplier mul6(.a(a6), .b(b6), .c(mult6));
	multiplier mul7(.a(a7), .b(b7), .c(mult7));
	multiplier mul8(.a(a8), .b(b8), .c(mult8));
	multiplier mul9(.a(a9), .b(b9), .c(mult9));
	
	//used for cutoff
	wire[15:0] my_res;
	assign my_res = (mult1 + mult2 + mult3 + mult4 + mult5 + mult6 + mult7 + mult8 + mult9 );
	
	//cutoff checking if larger than 0xff
	assign res = (my_res[15:8] != 8'h0) ? 16'hff : my_res[7:0] ;

endmodule


//this module receives four 8 bit inputs and returns their average (used for normalization)
module average 
(
	in1,in2,in3,in4, out
);
input[7:0] in1;
input[7:0] in2;
input[7:0] in3;
input[7:0] in4;

output[7:0] out;

wire[15:0] sum;
assign sum = in1 + in2 + in3 + in4;

assign out = sum[9:2]; //shift right

endmodule

//this module receives four 16-bit inputs and returns their average with cutoff over 0xff
//(used for variance)
module average_in15bit 
(
	in1,in2,in3,in4, out
);
input[15:0] in1;
input[15:0] in2;
input[15:0] in3;
input[15:0] in4;

output[7:0] out;

// sum without cutoff
wire[23:0] sum;
assign sum = in1 + in2 + in3 + in4;
wire[23:0] avg = {2'b00,sum[23:2]} ; // shift right 2

// cutoff
assign out = (avg[23:8] != 16'h00) ? 8'hff : avg[7:0] ;

endmodule


//this module receives the output and normalizes it using the average module
module normallize
(
	in1,in2,in3,in4,
	out1,out2,out3,out4
);

input [7:0] in1;
input [7:0] in2;
input [7:0] in3;
input [7:0] in4;
output [7:0] out1;
output [7:0] out2;
output [7:0] out3;
output [7:0] out4;


wire[7:0] avg;

average my_avg(.in1(in1), .in2(in2), .in3(in3), .in4(in4), .out(avg));

assign out1 = (in1 > avg) ? (in1-avg) : 8'h00;
assign out2 = (in2 > avg) ? (in2-avg) : 8'h00;
assign out3 = (in3 > avg) ? (in3-avg) : 8'h00;
assign out4 = (in4 > avg) ? (in4-avg) : 8'h00;

endmodule

module variance
(
	in1, in2, in3, in4, out
);
input [7:0] in1;
input [7:0] in2;
input [7:0] in3;
input [7:0] in4;
output [7:0] out;

wire [7:0] avg;
average my_avg(.in1(in1), .in2(in2), .in3(in3), .in4(in4), .out(avg));

wire[7:0] arg1;
wire[7:0] arg2;
wire[7:0] arg3;
wire[7:0] arg4;

assign arg1 = (in1 > avg) ? (in1-avg) : (avg-in1);
assign arg2 = (in2 > avg) ? (in2-avg) : (avg-in2);
assign arg3 = (in3 > avg) ? (in3-avg) : (avg-in3);
assign arg4 = (in4 > avg) ? (in4-avg) : (avg-in4);

wire[15:0] arg1_squared;
wire[15:0] arg2_squared;
wire[15:0] arg3_squared;
wire[15:0] arg4_squared;

multiplier_no_cut my_mult1(.a(arg1), .b(arg1), .c(arg1_squared));
multiplier_no_cut my_mult2(.a(arg2), .b(arg2), .c(arg2_squared));
multiplier_no_cut my_mult3(.a(arg3), .b(arg3), .c(arg3_squared));
multiplier_no_cut my_mult4(.a(arg4), .b(arg4), .c(arg4_squared));

average_in15bit var_avg(.in1(arg1_squared), .in2(arg2_squared), .in3(arg3_squared), .in4(arg4_squared), .out(out));

endmodule


// Module Declaration
module ai_accel
(
        rst_n		,  // Reset Neg
        clk,             // Clk
        addr		,  // Address
		  wr_en,		//Write enable
		  accel_select,
		  data_in,
		  ctr,
        data_out,   // Output Data
		  output_case,
		  filter_controller
    );
	 
	 input rst_n;
	 input clk;
	 input [31:0] addr;
	 input wr_en;
	 input accel_select;
	 input [1:0] output_case;
	 input filter_controller;
	 input [31:0] data_in;
	 output [31:0] data_out;
	 output [15:0] ctr;
	 
	 
	 reg [31:0] data_out;
 
	 reg go_bit;
	 wire go_bit_in;
	 reg done_bit;
	 wire done_bit_in;

	 reg [15:0] counter;
	 
	 reg [31:0] matrix_row1;
	 reg [31:0] matrix_row2;
	 wire [31:0] output_wire;
	 reg [31:0] matrix_row3;
	 reg [31:0] matrix_row4;
	 reg [31:0] filter_row1;
	 reg [31:0] filter_row2;
	 reg [31:0] filter_row3;
	 

	 reg [31:0] result;

	 wire[15:0] out;

	 assign ctr = counter;
	 
	 always @(addr[6:2], matrix_row1, matrix_row2, output_wire,matrix_row3,matrix_row4,filter_row1,filter_row2,filter_row3, counter, done_bit, go_bit, counter) begin
		case(addr[6:2])
		5'b01000: data_out = {done_bit, 30'b0, go_bit};
		5'b01001: data_out = {16'b0, counter}; 
		5'b01010: data_out = matrix_row1;
		5'b01011: data_out = matrix_row2;
		5'b01100: data_out = output_wire;
		5'b01101: data_out = matrix_row3;
		5'b01110: data_out = matrix_row4;
		5'b01111: data_out = filter_row1;
		5'b10000: data_out = filter_row2;
		5'b10001: data_out = filter_row3;
		default: data_out = 32'b0;
		endcase
	 end
	 
	 assign go_bit_in = (wr_en & accel_select & (addr[6:2] == 5'b01000));
	
	 always @(posedge clk or negedge rst_n)
		if(~rst_n) go_bit <= 1'b0;
		else go_bit <=  go_bit_in ? 1'b1 : 1'b0;
		
	 always @(posedge clk or negedge rst_n)
		if(~rst_n) begin
			counter <=16'b0;
			matrix_row1 <= 32'b0;
			matrix_row2 <= 32'b0;
			matrix_row3 <= 32'b0;
			matrix_row4 <= 32'b0;
			filter_row1 <= 32'b0;
			filter_row2 <= 32'b0;
			filter_row3 <= 32'b0;

		end
		else begin
			if (wr_en & accel_select) begin
				matrix_row1 <= (addr[6:2] == 5'b01010) ? data_in : matrix_row1;
				matrix_row2 <= (addr[6:2] == 5'b01011) ? data_in : matrix_row2;
				matrix_row3 <= (addr[6:2] == 5'b01101) ? data_in : matrix_row3;
				matrix_row4 <= (addr[6:2] == 5'b01110) ? data_in : matrix_row4;
				filter_row1 <= (addr[6:2] == 5'b01111) ? data_in : filter_row1;
				filter_row2 <= (addr[6:2] == 5'b10000) ? data_in : filter_row2;
				filter_row3 <= (addr[6:2] == 5'b10001) ? data_in : filter_row3;

			end
			else begin
				matrix_row1 <= matrix_row1;
				matrix_row2 <= matrix_row2;
				matrix_row3 <= matrix_row3;
				matrix_row4 <= matrix_row4;
				filter_row1 <= filter_controller ?32'h01010101 :filter_row1;
				filter_row2 <= filter_controller ? 32'h01010101 :filter_row2;
				filter_row3 <= filter_controller ? 32'h01010101 :filter_row3; 
			end
			counter <= go_bit_in? 16'h00 : done_bit_in ? counter : counter +16'h01;
		end
	 
	reg [31:0] result_in;
	
	wire [7:0] res00;
	wire [7:0] res01;
	wire [7:0] res10;
	wire [7:0] res11;
	
	wire [7:0] norm_res00;
	wire [7:0] norm_res01;
	wire [7:0] norm_res10;
	wire [7:0] norm_res11;
	
	wire [7:0] avg;
	
	wire[7:0] var;
	
	
	//First
	multiplier9by9 mul1(.a1(matrix_row1[7:0]), .a2(matrix_row1[15:8]), .a3(matrix_row1[23:16]),
						.a4(matrix_row2[7:0]), .a5(matrix_row2[15:8]), .a6(matrix_row2[23:16]),
						.a7(matrix_row3[7:0]), .a8(matrix_row3[15:8]), .a9(matrix_row3[23:16]),
						.b1(filter_row1[7:0]), .b2(filter_row1[15:8]), .b3(filter_row1[23:16]),
						.b4(filter_row2[7:0]), .b5(filter_row2[15:8]), .b6(filter_row2[23:16]),
						.b7(filter_row3[7:0]), .b8(filter_row3[15:8]), .b9(filter_row3[23:16]),
						.res(res00)
						);
						
	//Second
	multiplier9by9 mul2(.a1(matrix_row1[15:8]), .a2(matrix_row1[23:16]), .a3(matrix_row1[31:24]),
						.a4(matrix_row2[15:8]), .a5(matrix_row2[23:16]), .a6(matrix_row2[31:24]),
						.a7(matrix_row3[15:8]), .a8(matrix_row3[23:16]), .a9(matrix_row3[31:24]),
						.b1(filter_row1[7:0]), .b2(filter_row1[15:8]), .b3(filter_row1[23:16]),
						.b4(filter_row2[7:0]), .b5(filter_row2[15:8]), .b6(filter_row2[23:16]),
						.b7(filter_row3[7:0]), .b8(filter_row3[15:8]), .b9(filter_row3[23:16]),
						.res(res01)
						);
						
	//Third
	multiplier9by9 mul3(.a1(matrix_row2[7:0]), .a2(matrix_row2[15:8]), .a3(matrix_row2[23:16]),
						.a4(matrix_row3[7:0]), .a5(matrix_row3[15:8]), .a6(matrix_row3[23:16]),
						.a7(matrix_row4[7:0]), .a8(matrix_row4[15:8]), .a9(matrix_row4[23:16]),
						.b1(filter_row1[7:0]), .b2(filter_row1[15:8]), .b3(filter_row1[23:16]),
						.b4(filter_row2[7:0]), .b5(filter_row2[15:8]), .b6(filter_row2[23:16]),
						.b7(filter_row3[7:0]), .b8(filter_row3[15:8]), .b9(filter_row3[23:16]),
						.res(res10)
						);
						
	//Fourth
	multiplier9by9 mul4(.a1(matrix_row2[15:8]), .a2(matrix_row2[23:16]), .a3(matrix_row2[31:24]),
						.a4(matrix_row3[15:8]), .a5(matrix_row3[23:16]), .a6(matrix_row3[31:24]),
						.a7(matrix_row4[15:8]), .a8(matrix_row4[23:16]), .a9(matrix_row4[31:24]),
						.b1(filter_row1[7:0]), .b2(filter_row1[15:8]), .b3(filter_row1[23:16]),
						.b4(filter_row2[7:0]), .b5(filter_row2[15:8]), .b6(filter_row2[23:16]),
						.b7(filter_row3[7:0]), .b8(filter_row3[15:8]), .b9(filter_row3[23:16]),
						.res(res11)
						);
						
	normallize my_normallize(	.in1(res00), .in2(res01), .in3(res10), .in4(res11),
					.out1(norm_res00), .out2(norm_res01), .out3(norm_res10), .out4(norm_res11)
					);	
	average my_avg(.in1(res00),.in2(res01),.in3(res10),.in4(res11),.out(avg));			
	
	variance my_var(.in1(res00), .in2(res01), .in3(res10), .in4(res11), .out(var));
	
	
	//assign result_in = {norm_res11, var, norm_res01, norm_res00} ;
							 
	 always @(posedge clk or negedge rst_n)
		if(~rst_n) result <=32'h0;
		else result <= result_in;
	 	 
	 assign output_wire = result;
	 
	 assign done_bit_in = (counter == 16'd1);
	 
	 always @(posedge clk or negedge rst_n)
		if(~rst_n) done_bit <= 1'b0;
		else done_bit <= go_bit_in ? 1'b0 : done_bit_in;
	 
	 always @(output_case,res11,res10,res01,res00,norm_res11,norm_res10,norm_res01,norm_res00,avg,var )
	 begin
		case(output_case)
		2'b00 : result_in = {res11,res10,res01,res00};
		2'b01 : result_in = {norm_res11,norm_res10,norm_res01,norm_res00};
		2'b10 : result_in = {24'h00, avg};
		2'b11 : result_in = {24'h00, var};
		default : result_in = {res11,res10,res01,res00};
		endcase
	 end
endmodule