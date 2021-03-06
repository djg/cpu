//  ============================================================================
//  Copyright (C) 2018 Dan Glastonbury <dan.glastonbury@gmail.com>
//  ============================================================================

/////////////////////////////////////////////////////
// Module interface
/////////////////////////////////////////////////////

module cpu_top (// ------ Inputs ------
                clk_i,
                rst_i,
                // ------ Outputs -----
                count_o
                );

   /////////////////////////////////////////////////////
   // Inputs
   /////////////////////////////////////////////////////

   input clk_i; // Clock
   input rst_i; // Reset

   //////////////////////////////////////////////////////
   // Output
   //////////////////////////////////////////////////////
   output [3:0] count_o;
   
   //////////////////////////////////////////////////////
   // Interal nets and registers
   //////////////////////////////////////////////////////
   
   //////////////////////////////////////////////////////
   // Functions
   //////////////////////////////////////////////////////

   //////////////////////////////////////////////////////
   // Instantiations
   //////////////////////////////////////////////////////

   // 4-bit counter
   cpu_counter counter (// ------ Inputs ------
                        .clk_i(clk_i),
                        .rst_i(rst_i),
                        // ------ Outputs -----
                        .count_o(count_o)
                        );
   
   //////////////////////////////////////////////////////
   // Combinatorial Logic
   //////////////////////////////////////////////////////

   //////////////////////////////////////////////////////
   // Sequential Logic
   //////////////////////////////////////////////////////
   
   //////////////////////////////////////////////////////
   // Behavioural Logic
   //////////////////////////////////////////////////////

endmodule
