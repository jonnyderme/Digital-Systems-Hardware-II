// Deirmentzoglou Ioannis 10015
// deirmentz@ece.auth.gr

// Immediate Assertions Module
module test_status_bits(
  input logic [7:0] status,
  input logic clk, rst);
  
  always_ff @(posedge clk)
  begin
    if(rst==0) begin
    imCheck: assert (!((((status[0] || status[3]) && (status[1] || status[2]||status[4])))||(((status[5]) && (status[0] || status[1] || status[2]||status[3] ||status[4]))))) $display($stime,,," status test PASS");
    else
      $display($stime,,," status test FAIL");
  end
  end
  
endmodule

//CONCURRENT ASSERTIONS
module test_status_z_combinations(
  input logic [31:0] a,b,z,
  input logic [7:0] status,
  input logic clk
);
  
  
  property p1;
    @ (posedge clk) status[0] |-> !z[30:23];
  endproperty
  
  aP1: assert property (p1) $display($stime,,," p1 PASS");
    else $display($stime,,," p1 FAIL");
  
  property p2;
    @ (posedge clk) status[1] |-> z[30:23]==255;
  endproperty
    
    aP2: assert property (p2) $display($stime,,," p2 PASS");
      else $display($stime,,," p2 FAIL");
  
  property p3;
    @ (posedge clk) status[2] |-> $past((a[30:23]==255 && b[30:23]==0)||(b[30:23]==255 && a[30:23]==0),2);
  endproperty
      
      aP3: assert property (p3) $display($stime,,," p3 PASS");
        else $display($stime,,," p3 FAIL");
  
  property p4;
    @ (posedge clk) status[4] |-> (z[30:23]==255 || (z[30:23]==254 && z[22:0]==8388607));
  endproperty
      
      aP4: assert property (p4) $display($stime,,," p4 PASS");
        else $display($stime,,," p4 FAIL");
  
  property p5;
    @ (posedge clk) status[3] |-> (z[30:23]==0 || (z[30:23]==1 && z[22:0]==0));
  endproperty
  
        aP5: assert property (p5) $display($stime,,," p5 PASS");
          else $display($stime,,," p5 FAIL");

  
endmodule

