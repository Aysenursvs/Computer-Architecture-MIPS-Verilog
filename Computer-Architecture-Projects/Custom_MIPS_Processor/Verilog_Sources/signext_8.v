module signext_8(in1,out1);
input [7:0] in1;
output [31:0] out1;
assign 	 out1 = {{ 24 {in1[7]}}, in1};
endmodule
