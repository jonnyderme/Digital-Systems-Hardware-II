// Deirmentzoglou Ioannis 10015
// deirmentz@ece.auth.gr

// Exception Handling Module

module exception_mult(
  input logic [31:0] a, b,    // 32-bit Floating Point numbers
  input logic [31:0] z_calc,  // Result of the Multiplication before Exception Handling
  input logic overflow,       // Overflow Signal      
  input logic underflow,      // Underflow Signal
  input logic inexact_bit,    // Inexact bit of the Rounding Module 
  input logic [2:0] round,    // Round Parameter 
  input logic sign,           // Sign bit
  
  output logic [31:0] z,  // Final Multiplication Result 
  output logic zero_f,    // 6/8 of Status bits
  output logic inf_f,
  output logic nan_f,
  output logic tiny_f, 
  output logic huge_f,
  output logic inexact_f 
);
  
  //Enum with all possible unsigned groups of floating point number 
  typedef enum logic [2:0]{ZERO, INF, NORM, MIN_NORM, MAX_NORM} interp_t ;
  
  // Function that takes 32-bit signal and gives its type--> enum interp_t value
  function interp_t num_interp( input logic [31:0] input_signal) ; 
   
    automatic logic [7:0] signal_exponent = input_signal[30:23] ;
    automatic logic [22:0] signal_mantissa = input_signal[22:0] ;  
    
    if (signal_exponent == 0)
      return ZERO ;
    
    else if (signal_exponent == 8'b11111111)
      return INF ; 
    
    else if ( (signal_exponent == 8'b11111110) && (signal_mantissa == 23'b11111111111111111111111) )
      return MAX_NORM ;
  
    else if ( (signal_exponent == 1) && (signal_mantissa == 23'b00000000000000000000000) )
      return MIN_NORM ; 
	
    else 
      return NORM ; 
 
  endfunction
  
  
  // Function that takes enum interp_t value as input and returns 31-bit unsigned version of the number value
  function logic [31:0] z_num( input interp_t interp_value ) ;
    if (interp_value == INF)
      return 32'b01111111100000000000000000000000 ;
     
    else if (interp_value == MAX_NORM)
      return 32'b01111111011111111111111111111111 ;
    
    else if (interp_value == MIN_NORM)
      return 32'b00000000100000000000000000000000 ;
    
    else 
      return 0 ;
  endfunction
  
  interp_t a_interp ; 
  interp_t b_interp ; 
  interp_t z_calc_interp ; 
  
  always_comb 
    begin
      
      // Initialization of all status bits to zeroes
      zero_f = 0 ;
      inf_f  = 0 ;
      nan_f  = 0 ;
      tiny_f = 0 ;
      huge_f = 0 ;
      inexact_f = 0 ;
      
      // Using num_interp find the type of input signals a,b and z_calc
      a_interp = num_interp(a) ; 
      b_interp = num_interp(b) ;
      z_calc_interp = num_interp(z_calc) ;
      
      // Corner case management based on table 4 
      
      // Case 1 : a=+-Zero, b=+-Inf or vice versa 
      if( (a_interp==INF && b_interp==ZERO) || (a_interp==ZERO && b_interp==INF) )
        begin
          z = z_num(INF) ;
          inf_f = 1 ;
          nan_f = 1 ;
        end
      
      // Case 2 : a=+-Inf, b=+-Inf or a=+-Inf, b=+-Norm or a=+-Norm, b=+-Inf
      else if( a_interp==INF || b_interp==INF )
         begin
           z = z_num(INF) ;
           z[31] = a[31] ^ b[31] ;
       	   inf_f = 1 ; 
         end
      // Case 3 : a=+-Zero, b=+-Zero or a=+-Zero, b=+-Norm or a=+-Norm, b=+-Zero
      else if ( a_interp==ZERO || b_interp==ZERO )
         begin
           z = z_num(ZERO) ;
           z[31] = a[31] ^ b[31] ;
           zero_f = 1 ;
        end
      
      // Case 4 : Normal x Normal combination / a, b Normal type
      else 
        begin
          if (overflow==1) //OVERFLOW
             begin
               huge_f = 1 ;
               
               // Turn the value to max_norm or inf based to round parameter and activates the correct status bits
               unique case (round)
                 3'b001: begin
                   z = z_num(MAX_NORM) ;
                  end
                 
                 3'b010: begin
                    if (sign==0)
                      begin
                        z = z_num(INF) ;
                        inf_f = 1 ;
                      end
                    else
                      z = z_num(MAX_NORM) ;
                  end
                 
                 3'b011: begin
                    if (sign==1) begin
                      z = z_num(INF) ;
                      inf_f = 1 ;
                    end
                    else
                      z = z_num(MAX_NORM) ;  
                 end
      
                 default: 
                    begin
                      z = z_num(INF) ;
                      inf_f = 1 ;
                     end
           
               endcase
               
               z[31] = sign ; 
             end // End of Overflow excpeption
        
          else if (underflow==1) // Underflow case 
            begin
              tiny_f = 1 ;
              
              unique case (round)
                  3'b010: begin
                    if (sign == 0)
                      z = z_num(MIN_NORM) ;
                    else begin
                      z=z_num(ZERO);
                      zero_f=1;
                    end
                  end
                
                  3'b011: begin
                    if (sign==1)
                      z = z_num(MIN_NORM) ;
                    else begin
                      z = z_num(ZERO) ;
                      zero_f = 1 ;
                    end
                  end
                  
                 3'b101: begin
                   z = z_num(MIN_NORM) ;
                 end
        		 
                 default: begin
                   z = z_num(ZERO) ;
                   zero_f = 1 ;
                 end

        		endcase
               z[31] = sign;
            end // End of Underflow exception
               
          else // Neither Underflow or Overflow 
            // Normal case : Result is z = z_calc
            begin
              z = z_calc ; 
              inexact_f = inexact_bit ;
            end                  
               
               
        
        
        end // End of case 4
      
      
    end // End of always_comb block 
  
      
endmodule  