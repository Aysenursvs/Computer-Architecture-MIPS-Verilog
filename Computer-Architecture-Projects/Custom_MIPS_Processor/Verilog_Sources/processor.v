// MODÜL 2: PROCESSOR (MAIN)
module processor;

    // 1. SYSTEM SIGNALS
    reg system_clock;
    reg [31:0] current_pc; 

    // 2. MEMORY ARRAYS
    reg [7:0] data_memory_array [0:63]; 
    reg [7:0] instruction_memory_array [0:63]; 
    reg [31:0] register_file_array [0:15]; 

    // Loop variable (for display)
    integer i;

    // 3. WIRES & DECODING
    wire [31:0] fetched_instruction;
    wire [7:0] opcode_bits;       
    wire [3:0] rs_addr_bits;      
    wire [3:0] rt_addr_bits;      
    wire [3:0] rd_addr_bits;      
    wire [5:0] shamt_bits;        
    wire [5:0] funct_bits;        
    wire [15:0] immediate_16bits; 
    wire [23:0] jump_target_bits; 

    // Control Signals
    wire ctrl_reg_dest, ctrl_alu_src, ctrl_mem_to_reg, ctrl_reg_write;
    wire ctrl_mem_read, ctrl_mem_write, ctrl_branch_enable, ctrl_jump_enable;
    wire ctrl_aluop_r_type, ctrl_aluop_sub;
    wire [2:0] alu_operation_code;
    wire ctrl_blt_enable, ctrl_beqi_enable;

    // Datapath Wires
    wire [31:0] reg_read_data_1; 
    wire [31:0] reg_read_data_2; 
    wire [3:0]  write_reg_addr;  
    wire [31:0] final_write_back_data; 
    wire [31:0] extended_16bit_standard; 
    wire [31:0] extended_8bit_imm;      
    wire [31:0] extended_8bit_addr;      
    wire [31:0] alu_operand_b;           
    wire [31:0] final_branch_offset;     
    wire [31:0] final_alu_immediate;     
    wire [31:0] alu_result;
    wire alu_zero_flag;      
    wire [31:0] mem_read_data_packed; 
    
    // PC Wires
    wire [31:0] pc_plus_4;
    wire [31:0] offset_shifted_by_2;
    wire [31:0] branch_target_address;
    wire [31:0] jump_address_final;
    wire [31:0] next_pc_after_branch_decision;
    wire [31:0] next_pc_final;
    wire should_take_branch;

    // STACK PROTECTION SIGNALS
    wire stack_overflow;
    wire stack_underflow;
    wire safe_reg_write;  
    wire safe_mem_write;  

    // STAGE 1: INSTRUCTION FETCH
    assign fetched_instruction = {
        instruction_memory_array[current_pc[5:0]], 
        instruction_memory_array[current_pc[5:0]+1], 
        instruction_memory_array[current_pc[5:0]+2], 
        instruction_memory_array[current_pc[5:0]+3]
    };

    assign opcode_bits      = fetched_instruction[31:24];
    assign rs_addr_bits     = fetched_instruction[23:20];
    assign rt_addr_bits     = fetched_instruction[19:16];
    assign rd_addr_bits     = fetched_instruction[15:12];
    assign shamt_bits       = fetched_instruction[11:6];
    assign funct_bits       = fetched_instruction[5:0];
    assign immediate_16bits = fetched_instruction[15:0];
    assign jump_target_bits = fetched_instruction[23:0];


    // STAGE 2: CONTROL UNIT & REGISTER READ
    control main_control_unit (
        .in(opcode_bits),
        .f(funct_bits),
        .regdest(ctrl_reg_dest),
        .alusrc(ctrl_alu_src),
        .memtoreg(ctrl_mem_to_reg),
        .regwrite(ctrl_reg_write),
        .memread(ctrl_mem_read),
        .memwrite(ctrl_mem_write),
        .branch(ctrl_branch_enable),
        .aluop1(ctrl_aluop_r_type),
        .aluop2(ctrl_aluop_sub),
        .jump(ctrl_jump_enable),
        .blt(ctrl_blt_enable),
        .beqi(ctrl_beqi_enable)
    );

    assign reg_read_data_1 = register_file_array[rs_addr_bits];
    assign reg_read_data_2 = register_file_array[rt_addr_bits];

    mult2_to_1_4 mux_reg_dest (
        .out(write_reg_addr),
        .i0(rt_addr_bits), 
        .i1(rd_addr_bits), 
        .s0(ctrl_reg_dest)
    );

    // STAGE 3: EXTENSIONS & MUXES
    signext_16 extender_standard (.in1(immediate_16bits), .out1(extended_16bit_standard));
    signext_8 extender_beqi_imm (.in1(fetched_instruction[15:8]), .out1(extended_8bit_imm));
    signext_8 extender_beqi_addr (.in1(fetched_instruction[7:0]), .out1(extended_8bit_addr));

    mult2_to_1_32 mux_beqi_imm_switch (
        .out(final_alu_immediate), 
        .i0(extended_16bit_standard), 
        .i1(extended_8bit_imm), 
        .s0(ctrl_beqi_enable)
    );

    mult2_to_1_32 mux_beqi_offset_switch (
        .out(final_branch_offset), 
        .i0(extended_16bit_standard), 
        .i1(extended_8bit_addr), 
        .s0(ctrl_beqi_enable)
    );

    // STAGE 4: EXECUTION (ALU)
    alucont alu_control_unit (
        .aluop1(ctrl_aluop_r_type), 
        .aluop2(ctrl_aluop_sub), 
        .f(funct_bits), 
        .gout(alu_operation_code)
    );

    mult2_to_1_32 mux_alu_src (
        .out(alu_operand_b), 
        .i0(reg_read_data_2), 
        .i1(final_alu_immediate), 
        .s0(ctrl_alu_src)
    );

    alu32 main_alu (
        .alu_out(alu_result), 
        .a(reg_read_data_1), 
        .b(alu_operand_b), 
        .shamt(shamt_bits), 
        .zout(alu_zero_flag), 
        .alu_control(alu_operation_code)
    );

    // STAGE 5: STACK PROTECTION (MODULAR INTEGRATION)
    stack_controller stack_guard (
        .sp_val(register_file_array[14]),     // R14 (Current Stack Pointer)
        .spba_val(register_file_array[12]),   // R12 (Base Address - 40)
        .alu_result(alu_result),              // Calculated potential new SP
        .write_reg(write_reg_addr),           // Target register to write
        .reg_write_en(ctrl_reg_write),        // Raw command from control unit
        .mem_write_en(ctrl_mem_write),        
        
        // Outputs
        .overflow(stack_overflow),              // Error signal
        .underflow(stack_underflow),            // Error signal
        .safe_reg_write(safe_reg_write),        // Filtered write signal
        .safe_mem_write(safe_mem_write)         // Filtered memory write signal
    );

    // STAGE 6: MEMORY ACCESS
    assign mem_read_data_packed = {
        data_memory_array[alu_result[5:0]], 
        data_memory_array[alu_result[5:0]+1], 
        data_memory_array[alu_result[5:0]+2], 
        data_memory_array[alu_result[5:0]+3]
    };

    always @(posedge system_clock) begin
        if (safe_mem_write) begin 
            data_memory_array[alu_result[5:0]]   <= reg_read_data_2[31:24];
            data_memory_array[alu_result[5:0]+1] <= reg_read_data_2[23:16];
            data_memory_array[alu_result[5:0]+2] <= reg_read_data_2[15:8];
            data_memory_array[alu_result[5:0]+3] <= reg_read_data_2[7:0];
        end
    end

    // STAGE 7: WRITE BACK
    mult2_to_1_32 mux_mem_to_reg (
        .out(final_write_back_data), 
        .i0(alu_result), 
        .i1(mem_read_data_packed), 
        .s0(ctrl_mem_to_reg)
    );

    always @(posedge system_clock) begin
        if (safe_reg_write && write_reg_addr != 0) begin 
            register_file_array[write_reg_addr] <= final_write_back_data;
        end
    end

    // STAGE 8: NEXT PC LOGIC
    adder adder_pc_plus_4 (
        .a(current_pc), .b(32'd4), .out(pc_plus_4)
    );

    shift shift_left_2_unit (
        .shout(offset_shifted_by_2), .shin(final_branch_offset) 
    );

    adder adder_branch_target (
        .a(pc_plus_4), .b(offset_shifted_by_2), .out(branch_target_address)
    );

    assign should_take_branch = (ctrl_branch_enable & alu_zero_flag) | 
                                (ctrl_blt_enable & alu_result[31]) | 
                                (ctrl_beqi_enable & alu_zero_flag);

    mult2_to_1_32 mux_branch_decision (
        .out(next_pc_after_branch_decision), 
        .i0(pc_plus_4), 
        .i1(branch_target_address), 
        .s0(should_take_branch)
    );

    assign jump_address_final = {pc_plus_4[31:28], jump_target_bits, 2'b00};

    mult2_to_1_32 mux_jump_decision (
        .out(next_pc_final), 
        .i0(next_pc_after_branch_decision), 
        .i1(jump_address_final), 
        .s0(ctrl_jump_enable)
    );

    always @(posedge system_clock) begin
        current_pc <= next_pc_final;
    end

    // INITIALIZATION & DISPLAY 
    initial begin
        $readmemh("data_memory.dat", data_memory_array);
        $readmemh("instruction_memory1.dat", instruction_memory_array);
        $readmemh("register_file.dat", register_file_array);

        current_pc = 0;
        #200 $finish; 
    end

    // Clock Generator
    initial begin
        system_clock = 0;
        forever #10 system_clock = ~system_clock;
    end

    // *** DISPLAY BLOCK ***
    always @(negedge system_clock) begin
        if (fetched_instruction !== 32'bx) begin
            
            // 1. Part: Time, PC, ALU, Inst
            $write("%3d PC %h [%4d] SUM %h INST %h ", 
                   $time, current_pc, current_pc, alu_result, fetched_instruction);

            // 2. Part: Binary Decoding
            $write("[%b %b %b %b %b %b] ", 
                   opcode_bits, rs_addr_bits, rt_addr_bits, rd_addr_bits, shamt_bits, funct_bits);

            // 3. Part: REGISTER FILE
            $write("REGISTER '{");
            for (i = 0; i < 15; i = i + 1) begin
                $write("%0d, ", register_file_array[i]);
            end
            $write("%0d} ", register_file_array[15]); 

            // 4. Part: DATA MEMORY
            $write("DATA MEMORY '{");
            for (i = 0; i < 39; i = i + 1) begin 
                $write("%0d, ", data_memory_array[i]);
            end
            $write("%0d...} ", data_memory_array[39]); 

            // 5. Part: Error Signals
            $write("OVERFLOW: %b UNDERFLOW: %b", stack_overflow, stack_underflow);
            
            $write("\n"); 
        end
    end

endmodule