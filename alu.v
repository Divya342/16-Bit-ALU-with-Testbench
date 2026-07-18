`timescale 1ns / 1ps

// ========================================================
// 1. TESTBENCH (Moved to top so the compiler runs it first)
// ========================================================
module alu_tb;

    reg [15:0] a;
    reg [15:0] b;
    reg [3:0] op;
    wire [15:0] x;
    wire [15:0] y;

    // Instantiate the ALU (the compiler will look down and find it)
    alu uut (
        .a(a),
        .b(b),
        .op(op),
        .x(x),
        .y(y)
    );

    integer i;

    // This block automatically creates your VCD graph file
    initial begin
        $dumpfile("alu_tb.vcd");      
        $dumpvars(0, alu_tb);         
    end

    initial begin
        $display("Time\t\tOP\tA\tB\tX\tY");
        $display("--------------------------------------------------");

        a = 16'h1234; 
        b = 16'h0002; 
        op = 4'b0000;
        #10;

        for (i = 0; i < 16; i = i + 1) begin
            op = i[3:0];
            #10; 
            $display("%g\t\t%b\t%h\t%h\t%h\t%h", $time, op, a, b, x, y);
        end

        $display("--------------------------------------------------");
        $display("Testing Addition Carry-out:");
        a = 16'hFFFF;
        b = 16'h0001;
        op = 4'b0000; 
        #10;
        $display("%g\t\t%b\t%h\t%h\t%h\t%h", $time, op, a, b, x, y);

        #10;
        $finish;
    end

endmodule


// ========================================================
// 2. ALU DESIGN MODULE (Safely located below the testbench)
// ========================================================
module alu(
    input  wire [15:0] a, b,    
    input  wire [3:0]  op,      
    output reg  [15:0] x,
    output reg  [15:0] y
);

// Explicit intermediate nets for safe bit-width arithmetic
wire [16:0] add_res = {1'b0, a} + {1'b0, b};
wire [16:0] sub_res = {1'b0, a} - {1'b0, b};

always @(*) begin
   // Mandatory full reset to prevent latches across ALL 16 bits of X and Y
   x = 16'h0000;
   y = 16'h0000;

   case(op)
   // --- Arithmetic & Logical Operations ---
   4'b0000: begin 
       x = add_res[15:0]; 
       y = {15'b0, add_res[16]}; // Explicit 16-bit assignment for Y (Carry-out)
   end
   4'b0001: x = a | b;                    
   4'b0010: x = ~(a | b);                   
   4'b0011: x = ~(a ^ b);                   
   4'b0100: x = ~(a & b);                   
   4'b0101: x = a & b;                    
   4'b0110: x = a ^ b;                    
   4'b0111: x = ~a;                       

   // --- Shift Operations ---
   4'b1000: begin 
       x = {a[14:0], 1'b0};  // Native shift left logic
       y = {15'b0, a[15]};   // Capture MSB carry out safely into a full 16-bit reg
   end       
   4'b1001: begin 
       x = {1'b0, a[15:1]};  // Native shift right logic
       y = {15'b0, a[0]};    // Capture LSB carry out safely into a full 16-bit reg
   end       
   4'b1010: x = a << b[3:0];              
   4'b1011: x = a >> b[3:0];              
   4'b1100: x = $signed(a) >>> b[3:0];    

   // --- Advanced Math & Comparison ---
   4'b1101: begin
       x = sub_res[15:0];
       y = {15'b0, sub_res[16]}; // Captures borrow-out flag explicitly
   end                    
   4'b1110: begin
       x = a;                // REPLACED: Yosys will fail synthesis on non-constant '/' operators.
       y = 16'hFFFF;         // Changed to an error/bypass state for synthesis compliance.
   end
   4'b1111: x = 16'h0000; 

   default: begin
       x = 16'h0000;
       y = 16'h0000;
   end
   endcase
end                              
endmodule
