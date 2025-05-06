// Deirmentzoglou Ioannis 10015
// deirmentz@ece.auth.gr

// Normalization Module 

module normalize_mult(
  input  logic [47:0] mult_result_P,  // Multiplication Result 48 bits
  input  logic [9:0]  exponents_sum,  // Sum of exponents substracted by the bias
  
  output logic [9:0]  norm_exponent,  // Normalized Exponent
  output logic guard_bit, sticky_bit, // Guard and Sticky bit 
  output logic [22:0] norm_mantissa   // Normalized Mantissa
);
  
  logic size_st ;
  assign MSB_mult_mantissa = mult_result_P[47] ; // MSB of the mantissa multiplication result P
  
  always_comb 
    begin
    
     //Checks if it needs normalization
     unique if(MSB_mult_mantissa==1)	//Checks MSB value
       begin
        norm_exponent = exponents_sum+1 ;		//Calculation of normalized exponent
        norm_mantissa = mult_result_P[46:24] ;	//Calculation of normalized mantissa
        guard_bit = mult_result_P[23] ;		//Calculation of guard bit
       end
     
     else
       begin
        norm_exponent = exponents_sum ;         //Calculation of normalized exponent
        norm_mantissa = mult_result_P[45:23] ;  //Calculation of normalized mantissa
        guard_bit = mult_result_P[22] ;         //Calculation of guard bit
       end
    
     //Calculation of sticky bit
     size_st = 22 + MSB_mult_mantissa ;
     sticky_bit = 0 ;
    
     for(int i=0; i<=size_st; i++)
       begin
         sticky_bit=  sticky_bit | mult_result_P[i] ;
       end //for
   
    
    end //end of always block
  
endmodule
