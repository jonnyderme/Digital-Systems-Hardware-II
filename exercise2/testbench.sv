// Deirmentzoglou Ioannis 10015
// deirmentz@ece.auth.gr

// Testbench Module 

module TestBench ; 
  
  logic [31:0] a, b ;        // 32-bit Floating Point numbers
  logic [31:0] z, z_check ;  // Multiplication Results
  logic [7:0] status ;       // Status Flag 
  logic [2:0] round ;        // Round Parameter
  logic [11:0][31:0] corner_cases ;  // Array containing all corner cases 
  logic [3:0]counter_a,counter_b;

  logic clk ;
  logic rst ;
  logic part_select ;
  logic diaf ; 
  
  
  // Modules for design and verification
  fp_mult_top multiplier(.*)  ;
  check_mult dut_c(.*) ;
  bind fp_mult_top test_status_z_combinations dutbound(.*) ;
  bind fp_mult_top test_status_bits dutbound2(.*) ;
  
  // Clock Implementation
  always #7.5ns clk = ~clk ; 
  
  // Enum type covering all possible corner cases 
  typedef enum logic [3:0] {positive_zero = 4'b0001, negative_zero, positive_inf, 
                            negative_inf, positive_snan, negative_snan, 
                            positive_qnan, negative_qnan, positive_norm,
                            negative_norm, positive_denorm, negative_denorm} corner_type ; 
  
  
  
  // *******
  // Function to generate various 32-bit floating-point corner cases
  function logic [31:0] corner_case_generator( input corner_type corner ) ; 
    
    logic corner_sign ; 
    logic [7:0] corner_exponent ;
    logic [22:0] corner_mantissa ; 
    // Return number of the function
    logic [31:0] corner_num ; 
    
    int random_value ;
    logic [21:0] fraction_qnan ; 
    logic [22:0] fraction_denorm ; 

    
    unique case (corner)
      
      positive_zero: begin // Positive Zero 
        corner_sign = 0 ; 
        corner_exponent = 8'b00000000 ; 
        corner_mantissa = 23'b00000000000000000000000 ;
      end  
      
      negative_zero: begin // Negative Zero
        corner_sign = 1 ; 
        corner_exponent = 8'b00000000 ; 
        corner_mantissa = 23'b00000000000000000000000 ;
      end 
      
      positive_inf: begin // Positive Infinity 
        corner_sign = 0 ; 
        corner_exponent = 8'b11111111 ; 
        corner_mantissa = 23'b00000000000000000000000 ;
      end
      
      negative_inf: begin // Negative Infinity
        corner_sign = 1 ; 
        corner_exponent = 8'b11111111 ; 
        corner_mantissa = 23'b00000000000000000000000 ;
      end
      
      // Generation of NaN numbers
      // Signaling NaN 
      positive_snan: begin // Positive Signaling NaN 
        corner_sign = 0 ; 
        corner_exponent = 8'b11111111 ; 
        corner_mantissa[22] = 0 ; 
        do begin
           random_value = $urandom ;
           corner_mantissa[21:0] = random_value[21:0] ; 
        end while (corner_mantissa == 23'b0) ;
      end 
      
      negative_snan: begin // Negative Signaling NaN
        corner_sign = 1 ; 
        corner_exponent = 8'b11111111 ; 
        corner_mantissa[22] = 0 ; 
        do begin
           random_value = $urandom ;
           corner_mantissa[21:0] = random_value[21:0] ; 
        end while (corner_mantissa == 23'b0) ;
      end 
      
      // Quiet NaN 
      positive_qnan: begin // Positive Quiet NaN
        corner_sign = 0 ; 
        corner_exponent = 8'b11111111 ; 
        corner_mantissa[22] = 1 ; 
        do begin
           random_value = $urandom ;
           fraction_qnan = random_value[21:0] ;
           corner_mantissa[21:0] = random_value[21:0] ; 
        end while (fraction_qnan == 22'b0) ;
      end 
      
      negative_qnan: begin // Negative Quiet NaN
        corner_sign = 1 ; 
        corner_exponent = 8'b11111111 ; 
        corner_mantissa[22] = 1 ; 
        do begin
           random_value = $urandom ;
           fraction_qnan = random_value[21:0] ;
           corner_mantissa[21:0] = random_value[21:0] ; 
        end while (fraction_qnan == 22'b0) ;
      end
      
      // Generation of Denormal numbers 
      positive_denorm: begin // Positive Denormal number 
        corner_sign = 0 ; 
        corner_exponent = 8'b00000000 ;
        do begin
           random_value = $urandom ;
           fraction_denorm = random_value[22:0] ;
           corner_mantissa[22:0] = random_value[22:0] ; 
        end while (fraction_denorm == 23'b0) ;
      end
      
      negative_denorm: begin // Negative Denormal number 
        corner_sign = 1 ; 
        corner_exponent = 8'b00000000 ;
        do begin
           random_value = $urandom ;
           fraction_denorm = random_value[22:0] ;
           corner_mantissa[22:0] = random_value[22:0] ; 
        end while (fraction_denorm == 23'b0) ;
      end
      
      // Generation of Normal numbers 
      positive_norm: begin // Positive Normal number
        corner_sign = 0 ; 
        do begin 
          random_value = $urandom ;
          corner_exponent = random_value[31:23] ; 
          corner_mantissa = random_value[22:0] ;
        end while ( (corner_exponent == 8'b0) || (corner_exponent == 8'b11111111) || (corner_mantissa == 23'b0) ) ;
        
      end
       
      negative_norm: begin // Negative Normal number 
        corner_sign = 1 ; 
        do begin 
          random_value = $urandom ;
          corner_exponent = random_value[31:23] ; 
          corner_mantissa = random_value[22:0] ;
        end while ( (corner_exponent == 8'b0) || (corner_exponent == 8'b11111111) || (corner_mantissa == 23'b0) ) ;
      end
      
    endcase
     
    // Combine sign, exponent, and fraction into a single 32-bit value
    assign corner_num = {corner_sign, corner_exponent, corner_mantissa} ;
    return corner_num ;  
    
    
  endfunction 
  //*******
  
  // Creation of Corner Cases 
  initial 
    begin
      clk =1 ;
      part_select = 0 ; // Checks which part is executed
    
      // 12 Corner Cases
      corner_cases[0]  = corner_case_generator(positive_zero) ;    // Positive Zero
      corner_cases[1]  = corner_case_generator(negative_zero) ;	   // Negative Zero
      corner_cases[2]  = corner_case_generator(positive_inf)  ;    // Positve Infinity
      corner_cases[3]  = corner_case_generator(negative_inf)  ;	   // Negative Infinity
      corner_cases[4]  = corner_case_generator(positive_snan) ;    // Positive Signaling NaN
      corner_cases[5]  = corner_case_generator(negative_snan) ;	   // Negative Signaling NaN
      corner_cases[6]  = corner_case_generator(positive_qnan) ;    // Positive Quiet NaN
      corner_cases[7]  = corner_case_generator(negative_qnan) ;	   // Negative Quiet NaN
      corner_cases[8]  = corner_case_generator(positive_norm) ;    // Positive Normal 
      corner_cases[9]  = corner_case_generator(negative_norm) ;	   // Negative Normal
      corner_cases[10] = corner_case_generator(positive_denorm) ;  // Positive Denormal
      corner_cases[11] = corner_case_generator(negative_denorm) ;  // Negative Denormal
      

      // Gives reset for initialization
      rst = 1 ;
      #2ns rst = 0 ;
  end
  
  // Select Round Input 
  typedef enum logic [2:0]{IEEE_zero=3'b001, IEEE_pinf, IEEE_ninf, IEEE_near, away_zero, near_up}    round_input ;
  
  assign round = IEEE_near ; 
  assign round_v = round_input'(round) ;
  
  
  always_comb
    begin
      // Comparison of the 2 results
      if (z == z_check)
        begin
          diaf = 1 ;
          $display($stime,,," z result calculated correct") ;
        end
      else
        begin
          diaf = 0 ;
          $display($stime,,," z result failed") ;      
        end     
    end // End of always_comb
  
  
  
  always_ff @(posedge clk)
    begin
      
      // Display values of the variables in each round
      $display($stime,,,"clk=%b status=%b a=%b b=%b z=%b z_check=%b", clk,status,a,b,z, z_check);
      
      //****First part of testing, Random values assigned to a,b inputs****//
      if(part_select == 0)
        begin
          a = $urandom() ;
          b = $urandom() ;
        end
      
      else
        begin
          if(rst)
            begin
               counter_a <= 0 ;
    		   counter_b <= 0 ;
               a = corner_cases[0] ;
               b = corner_cases[0] ;             
            end
          
          //****Second part of testing, corner cases assigned to a,b inputs (144 combinations)****//
          else	
            begin            
              if (counter_b == 11)
                begin
                  counter_b <= 0 ;
                  if (counter_a == 11)
                      counter_a <= 0 ;
                  else
                      counter_a <= counter_a + 1 ;
                 end
               else
                  counter_b <= counter_b + 1 ;
              
              a = corner_cases[counter_a] ;
              b = corner_cases[counter_b] ;
          
          end	// End of if rst
        end // End of if condition for the 2 parts
    end // End of always_ff block
  
  
  // Run time for the simulation   
  initial
    begin
      #5000 $finish ; 
    end
    
  initial
    begin
      $dumpfile("dump.vcd"); 
      $dumpvars;
    end
   
endmodule 
