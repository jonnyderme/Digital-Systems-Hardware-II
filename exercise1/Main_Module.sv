// Deirmentzoglou Ioannis 10015
// deirmentz@ece.auth.gr

// Main Module 

module fp_mult(
  input logic [31:0] a,     // Floating Point number Input
  input logic [31:0] b,     // Floating Point number Input
  input logic [2:0] round,  // Round Input 
  
  output logic [31:0] z,    // Resulting Output 
  output logic [7:0] status // Status flag based on the operations inside the multiplier
);
  
  logic sign ; 
  
  logic [7:0] a_exponent, b_exponent ; // Exponents of a,b
  logic [9:0] add_exponent ;           // Add Result 
  logic [9:0] exponents_sum ;
  int bias ; 
  
  logic [23:0] a_mantissa ;
  logic [23:0] b_mantissa ;
  logic [47:0] mult_result_P ; 
  
  logic guard_bit, sticky_bit;
  logic inexact_bit;
  logic [22:0] norm_mantissa ;
  logic [9:0]  post_exponent ;
  logic [9:0]  norm_exponent ;
  logic [23:0] post_mantissa ;
  logic [31:0] z_calc ;
  
  logic overflow, underflow ;
  logic zero_f,inf_f,nan_f,tiny_f,huge_f,inexact_f ;
  
  // Calculation of sign bit : XOR between signs a,b
  assign sign = a[31] ^ b[31] ; 
  
  // Calculation of exponents for a and b inputs 
  assign a_exponent = a[30:23] ;
  assign b_exponent = b[30:23] ; 
  
  // Addition between exponents and subtrack the bias
  assign bias = 127 ; 
  assign add_exponent = a_exponent + b_exponent - bias ; 
  assign exponents_sum = add_exponent ;
  
  //Calculation of Mantissa with the leading one for the multiplication
  assign a_mantissa = {1'b1, a[22:0]} ;
  assign b_mantissa = {1'b1, b[22:0]} ;
  
  // Multiplication between mantissas
  assign mult_result_P = a_mantissa * b_mantissa ; 
  
  // Calculation of status bits 
  assign status = {1'b0, 1'b0, inexact_f,huge_f, tiny_f, nan_f,inf_f,zero_f} ; 
  
  // Nested modules
  normalize_mult u0(.*) ;
  round_mult u1(.*) ;
  exception_mult u2(.*) ;
  
  always_comb
    begin
      overflow =0 ;
      underflow =0 ;
      
      // Check for overflow and underflow
      if (norm_exponent[9] == 1)
         underflow = 1 ;
      else if (norm_exponent == 0)
        underflow=1;
      else if (norm_exponent[8] == 1)
        overflow = 1 ;
      else if (norm_exponent == 255)
        overflow = 1 ;
           
      // Calculation of the z_calc
      z_calc[31] = sign ;
      z_calc[30:23] = post_exponent ;
      z_calc[22:0] = post_mantissa[22:0] ;
      
    end //End of always block
endmodule