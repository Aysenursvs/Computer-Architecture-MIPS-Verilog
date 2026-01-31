module alucont(aluop1, aluop2, f, gout);
    
    // --- 1. Inputs & Outputs ---
    // aluop1: Comes from Control Unit. 1 if R-Type.
    // aluop2: Comes from Control Unit. 1 if Subtract needed (beq, blt, subi).
    input aluop1, aluop2;
    
    // f: The Function Field from the instruction. 
    input [5:0] f; 
    
    // gout: The 3-bit command sent to the ALU.
    output reg [2:0] gout; 

    // --- 2. Logic Block ---
    always @(*) 
    begin
        //Concatenate {aluop1, aluop2} to create a 2-bit mode selector.
        case ({aluop1, aluop2})
            
            // --- Mode 00: ADD ---
            // Instructions: lw, sw, addi
            // Logic: Ignore 'f', just output ADD (010).
            2'b00: gout = 3'b010; 

            // --- Mode 01: SUBTRACT ---
            // Instructions: beq, blt, subi, beqi
            // Logic: Ignore 'f', just output SUB (110).
            2'b01: gout = 3'b110; 

            // --- Mode 10: R-TYPE ---
            // Instructions: sll, move, nand, or, add
            // Logic: Look at the Function Field 'f' to decide.
            2'b10: begin
                case (f)
                    6'd1: gout = 3'b100; // Function 1: SLL (Shift Left Logical) - NEW
                    6'd2: gout = 3'b101; // Function 2: MOVE - NEW
                    6'd3: gout = 3'b000; // Function 3: NAND - NEW (Using 000)
                    6'd4: gout = 3'b001; // Function 4: OR
                    6'd5: gout = 3'b010; // Function 5: ADD
                    default: gout = 3'b010; // Default to ADD if unknown
                endcase
            end

            // --- Default Safety ---
            default: gout = 3'b010; 
        endcase
    end
endmodule
