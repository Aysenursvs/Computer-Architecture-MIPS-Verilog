module control(in,f, regdest, alusrc, memtoreg, regwrite, 
	       memread, memwrite, branch, aluop1, aluop2, jump,blt,beqi);

input [7:0] in;
input [5:0] f;
output regdest, alusrc, memtoreg, regwrite, memread, memwrite, branch, aluop1, aluop2,jump,blt,beqi;

wire rformat,lw,sw,beq,jall,j,jump_reg;

assign rformat = (in == 8'd51); // 00110011 - R-Type (sll, move, nand, or, add)
assign lw      = (in == 8'd52); // 00110100
assign sw      = (in == 8'd53); // 00110101
assign beq     = (in == 8'd54); // 00110110
assign blt     = (in == 8'd55); // 00110111
assign subi    = (in == 8'd56); // 00111000
assign addi    = (in == 8'd57); // 00111001
assign beqi    = (in == 8'd58); // 00111010
assign j       = (in == 8'd59); // 00111011

// JR is a special case of R-type (Function 8). 
// Prevent RegWrite during JR.
wire jr;
assign jr = rformat & (f == 6'd8);

assign regdest = rformat;

assign alusrc = lw | sw | subi | addi | beqi;

assign memtoreg = lw;

assign regwrite = (rformat | lw | subi | addi) & ~jr;

assign memread = lw;
assign memwrite = sw;

assign branch = beq;

assign aluop1 = rformat;
assign aluop2 =beq | blt | subi | beqi; 

assign jump = j;


endmodule
