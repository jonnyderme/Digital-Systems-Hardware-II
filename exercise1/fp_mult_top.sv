// Deirmentzoglou Ioannis 10015
// deirmentz@ece.auth.gr


//This module is given for the exercises
module fp_mult_top (
     clk, rst, round, a, b, z, status
);

  input logic [31:0] a, b ;    // Floating-Point numbers	 
  input logic [2:0] round ;    // Rounding signal
  input logic clk, rst ; 
    
  output logic [31:0] z ;      // a ± b
  output logic [7:0] status ;  // Status Flags 
    
  logic [31:0] a1, b1 ;  // Floating-Point numbers
  logic [2:0] round1 ; // Rounding signal
  logic [31:0] z1 ;    // a ± b
  logic [7:0] status1;  // Status Flags 
          
  // Instantiation of Main module 
  fp_mult multiplier(.a(a1),.b(b1),.z(z1),.status(status1),.round(round1)) ;
    
  always @(posedge clk)
    if (rst == 1)
      begin 
        a1 <= '0 ;
        b1 <= '0 ;
	    round1 <= '0 ;
        z <= '0;
        status <= '0;
      end
     
     else
       begin
         a1 <= a ;
         b1 <= b ;
	     round1 <= round ;
         z <= z1 ; 
         status <= status1;
       end

endmodule