module stack_controller(
    input [31:0] sp_val,      // Stack Pointer ($sp - R14)
    input [31:0] spba_val,    // Base Address ($spba - R12)
    input [31:0] alu_result,  // Value coming from ALU (new SP value)
    input [3:0] write_reg,    // Register address to write
    input reg_write_en,       // Register write enable
    input mem_write_en,       // Memory write enable
    
    output overflow,          // Error signals
    output underflow,
    output safe_reg_write,    // Safe register write signal
    output safe_mem_write     // Safe memory write signal
    );

    // Is there a stack-related operation?
    // If the target register is R14 ($sp), the SP is being updated.
    wire is_sp_update;
    assign is_sp_update = (write_reg == 4'd14) && reg_write_en;

    // If SP is being updated, take the new value, otherwise keep the old one.
    wire [31:0] next_sp_val;
    assign next_sp_val = is_sp_update ? alu_result : sp_val;

    // Calculate the actual physical address: Base + SP
    wire [31:0] next_ram_addr;
    assign next_ram_addr = spba_val + next_sp_val;

    // Error Checking [cite: 63, 64, 87-103]:
    // 1. Underflow: If SPBA (40) is exceeded (i.e., popping from an empty stack)
    assign underflow = is_sp_update && (next_ram_addr > 40);

    // 2. Overflow: If it goes below Limit (32) (i.e., pushing when stack is full)
    assign overflow  = is_sp_update && (next_ram_addr < 32);

    // Gating
    // If there is an error, we prevent the operation by setting the write signals to "0".
    assign safe_reg_write = reg_write_en & ~overflow & ~underflow;
    assign safe_mem_write = mem_write_en & ~overflow & ~underflow;

endmodule