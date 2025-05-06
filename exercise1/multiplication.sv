// Deirmentzoglou Ioannis 10015
// deirmentz@ece.auth.gr

// Checking Module 

module check_mult( 
    input  logic [31:0] a, b,    // Floating-Point numbers
    input  logic [2:0] round,      // Round Parameter
    input  logic clk,            // Clock 
    input  logic rst,            // Reset Signal
    
    output logic [31:0] z_check    // Multiplication Result using multiplication() function
);
    
  
  logic [31:0] a_num, b_num ;  // Floating-Point numbers
  logic [31:0] z_num ;           // a Β± b
  
  string roundString ; 

  
  // Definition of round string based on the parameter round
  initial
    begin
       if (round == 1)
         roundString = "IEEE_zero" ; 
      
       else if (round == 2)
         roundString = "IEEE_pinf" ;
      
       else if (round == 3)
         roundString = "IEEE_ninf" ;
      
       else if (round ==  6)
         roundString = "near_up" ;
      
       else if (round == 5)
         roundString = "away_zero" ;
      
       else 
         roundString = "IEEE_near" ;
    end 
   

  // Works as registers
  always @(posedge clk)
    if ( rst == 1 )       // Initialization with the Reset signal
        begin 
          a_num <= '0 ;
          b_num <= '0 ;
          z_check <= '0 ;
         end
    else
         begin
           a_num <= a;
           b_num <= b;
           z_check <= multiplication (roundString, a_num, b_num ); // Use of the function below 
          end



////// 
// Please consider this function a black box. DO NOT try to copy any part of this function in your code. 
////// 

function [31:0] multiplication (string round, logic [31:0] a, logic [31:0] b);
    bit [31:0] result;
    if(a[30:23] == '0) a[22:0] = '0; 
    if(b[30:23] == '0) b[22:0] = '0; 
    if(a[30:23] == '1) a[22:0] = '0;
    if(b[30:23] == '1) b[22:0] = '0; 
    
    if((a[30:23] == '1 && b[30:23] == '0) || (a[30:23] == '0 && b[30:23] == '1)) result = {1'b0, {8{1'b1}}, {23{1'b0}}}; 
    else begin
        result = $shortrealtobits($bitstoshortreal(a) * $bitstoshortreal(b)); 
        case (round)
            //IEEE_NEAR ROUNDING
            "IEEE_near": begin
                if(result[30:23] == '1) result[22:0] = '0;
                if(result[30:23] == '0) result[22:0] = '0;
            end
            //IEEE_ZERO ROUNDING
            "IEEE_zero": begin
                //Round towards zero instead if rounded up and positive
                if($bitstoshortreal(result) > ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                    begin 
                        if($bitstoshortreal(result) > 0) 
                            begin
                                result = result - 1; 
                            end
                    end
                //Round towards zero instead if rounded down and negative
                if($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                    begin
                        if($bitstoshortreal(result) < 0) 
                            begin
                                result = result - 1; 
                            end
                    end
                if(result[30:23] == '0) result[22:0] = '0;
            end
            //AWAY_ZERO ROUNDING
            "away_zero": begin
                //Check if the result is denormal and round to minNormal
                if((result[30:23] == '0 && result[22:0] != '0) || (a[30:23] != '0 && b[30:23] != '0 && result[30:23] == '0 && result[22:0] == '0)) begin
                    result = {result[31], {7{1'b0}}, 1'b1, {23{1'b0}}};
                end
                else begin
                    //Round away from zero instead if rounded up and negative
                    if($bitstoshortreal(result) > ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin 
                            if($bitstoshortreal(result) < 0) 
                                begin
                                    result = result + 1; 
                                end
                        end
                    //Round away from zero instead if rounded down and positive
                    if($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin
                            if($bitstoshortreal(result) > 0) 
                                begin
                                    result = result + 1; 
                                end
                        end
                end
                if(result[30:23] == '1) result[22:0] = '0;
            end
            //IEEE_PINF ROUNDING
            "IEEE_pinf": begin
                //Check if the result is denormal and round to minNormal, but only for positives
                if((result[31] == 0 && result[30:23] == '0 && result[22:0] != '0) || (result[31] == 0 &&  a[30:23] != '0 && b[30:23] != '0 && result[30:23] == '0 && result[22:0] == '0)) begin
                    result = {{8{1'b0}}, 1'b1, {23{1'b0}}};
                end
                else begin
                    //Round towards positive infinity instead if rounded down and positive
                    if($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin 
                            if($bitstoshortreal(result) > 0) 
                                begin
                                    result = result + 1; 
                                end
                        end
                    //Round towards positive infinity instead if rounded down and negative
                    if($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin
                            if($bitstoshortreal(result) < 0) 
                                begin
                                    result = result - 1; 
                                end
                        end
                end
                if(result[30:23] == '0) result[22:0] = '0;
            end
            //IEEE_NINF ROUNDING
            "IEEE_ninf": begin
                //Check if the result is denormal and round to minNormal, but only for negatives
                if((result[31] == 1 && result[30:23] == '0 && result[22:0] != '0) || (result[31] == 1 &&  a[30:23] != '0 && b[30:23] != '0 && result[30:23] == '0 && result[22:0] == '0)) begin
                    result = {1'b1, {7{1'b0}}, 1'b1, {23{1'b0}}};
                end
                else begin
                    //Round towards negative infinity instead if rounded up and positive
                    if($bitstoshortreal(result) > ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin 
                            if($bitstoshortreal(result) > 0) 
                                begin
                                    result = result - 1; 
                                end
                        end
                    //Round towards negative infinity instead if rounded up and negative
                    if($bitstoshortreal(result) > ($bitstoshortreal(a) * $bitstoshortreal(b))) 
                        begin
                            if($bitstoshortreal(result) < 0) 
                                begin
                                    result = result + 1; 
                                end
                        end
                end
                if(result[30:23] == '0) result[22:0] = '0;
            end
            //NEAR_UP ROUNDING
            "near_up": begin
                //Round towards positive infinity if rounded down, negative and in the middle
                if(($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b)))) 
                    begin
                        if(($bitstoshortreal(result) - ($bitstoshortreal(a) * $bitstoshortreal(b))) == (($bitstoshortreal(a) * $bitstoshortreal(b)) - $bitstoshortreal(result-1))) 
                            begin
                                if($bitstoshortreal(result) < 0) 
                                    begin
                                        result = result - 1;
                                    end
                            end
                    end
                
                //Round towards positive infinity if rounded down, positive and in the middle
                if(($bitstoshortreal(result) < ($bitstoshortreal(a) * $bitstoshortreal(b)))) 
                    begin
                        if(($bitstoshortreal(result+1) - ($bitstoshortreal(a) * $bitstoshortreal(b))) == (($bitstoshortreal(a) * $bitstoshortreal(b)) - $bitstoshortreal(result))) 
                            begin
                                if($bitstoshortreal(result) > 0) 
                                    begin
                                        result = result + 1;
                                    end
                            end
                    end
                
                if(result[30:23] == '1) result[22:0] = '0;
                if(result[30:23] == '0) result[22:0] = '0;
            end
    endcase
    end
    
    return result;
endfunction

endmodule