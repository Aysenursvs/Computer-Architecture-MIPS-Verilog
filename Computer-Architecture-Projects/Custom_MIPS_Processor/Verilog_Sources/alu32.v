module alu32(alu_out, a, b, shamt, zout, alu_control);
    
    output reg [31:0] alu_out; // 32-bit Result
    output zout;               // Zero Flag
    
    input [31:0] a;            // Input A (Source 1 / rs)
    input [31:0] b;            // Input B (Source 2 / rt or Imm)
    input [5:0] shamt;         // Shift Amount (New Input from Instruction[11:6])
    input [2:0] alu_control;   // Control Signal

    reg [31:0] less;

    // Use @(*) for combinational logic (automatically detects all inputs)
    always @(*)
    begin
        case(alu_control)
            // --- Logic Operations ---
            3'b000: alu_out = ~(a & b);  // NAND 
            3'b001: alu_out = a | b;     // OR

            // --- Arithmetic Operations ---
            3'b010: alu_out = a + b;     // ADD (Used for add, lw, sw)
            3'b110: alu_out = a - b;     // SUB (Used for beq, blt, subi, beqi)
            
            // --- Set Less Than ---
            3'b111: begin                // SLT
                        if (a < b) alu_out = 32'd1;
                        else alu_out = 32'd0;
                    end

            // --- NEW INSTRUCTIONS ---
            
            // SLL (Shift Left Logical)
            // Shift Input A ($rs) by the amount in 'shamt'.
            3'b100: alu_out = a << shamt; 

            // MOVE
            //Pass Input A ($rs) through to the output.
            3'b101: alu_out = a;         

            // Default Case
            default: alu_out = 32'b0;
        endcase
    end

    // Zero Output Logic
    // zout is 1 if the result is exactly 0.
    assign zout = (alu_out == 32'd0);

endmodule