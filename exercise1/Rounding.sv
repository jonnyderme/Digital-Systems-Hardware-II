// Deirmentzoglou Ioannis 10015
// deirmentz@ece.auth.gr

// Rounding Module

module round_mult(
  input logic sign,                   // Sign of the Floating Point number
  input logic [2:0] round,            // Round Paremeter
  input logic [9:0] norm_exponent,    // Normalized Exponent
  input logic guard_bit, sticky_bit,  // Guard and Sticky bit 
  input logic [22:0] norm_mantissa,   // Normalized Mantissa 23 bits (without leading one) 
  
  output logic [9:0]  post_exponent,  // Exponent after the Rounding
  output logic [23:0] post_mantissa,  // Mantissa after the Rounding
  output logic inexact_bit            // Inexact Bit
);
  
  
  // Enumerated type of the round input 
  typedef enum logic [2:0]{IEEE_zero=3'b001, IEEE_pinf, IEEE_ninf, IEEE_near, away_zero, near_up}    round_input ;
  
  assign round_v = round_input'(round) ; 
  
  logic round_bit ; // Stores the value 0 (round down) or 1 (round up)
  // to be added to 23 bits of norm_mantissa
  logic [24:0] post_round_mantissa ; 
  
  always_comb 
   begin
    // Calculation of inexact bit
    inexact_bit = ~(sticky_bit | guard_bit) ;
    
    //Creates mantissa with the leading one
    post_mantissa[22:0] = norm_mantissa[22:0] ;
    post_mantissa[23] = 1 ;
    
    // Rounding based on round parameter
    unique case (round_v)
       IEEE_zero: begin	//IEEE_zero
           round_bit = 0 ;
       end
       
       IEEE_pinf: begin   //IEEE_pinf
         if (sign==0)
            round_bit = 1 ;
          else
            round_bit = 0 ;  
       end
      
       IEEE_ninf: begin   //IEEE_ninf
         if (sign == 0)
            round_bit = 0 ;
          else
            round_bit = 1 ;
       end
      
       away_zero: begin	//away_zero
           round_bit = 1 ;
       end
      
       default: begin //IEEE_near and near_up
         if (guard_bit == 0)
            round_bit = 0 ;   
         else
            round_bit = 1 ;
       end

    endcase
     
    
     //Calculation of the mantissa after the rounding
     post_round_mantissa = post_mantissa + round_bit ;
     
    //Check if new mantissa needs normalization again
    if (post_round_mantissa[24] == 1)
       begin
         post_mantissa = post_round_mantissa[24:1] ; //stores mantissa
         post_exponent = norm_exponent + 1 ;         //stores exponent
       end
    else
       begin
         post_mantissa = post_round_mantissa[23:0] ;
         post_exponent = norm_exponent ;
       end
    
   end //end of always block
  
endmodule
