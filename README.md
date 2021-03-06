Hardware stack that can tracking current maximum element. 
### Description:   
  - The stack was written in Verilog HDL and simulated by Modelsim.
### File structure:
  - src_code_20181119/src_code: 3 main files
    - tt_stack.v: Verilog source code
    - tt_stack_tb.v: Verilog testbench code
    - stack_mem.dat: Simulation data 
  - src_code/pics: snapshots of 3 test cases
    - test_push_pop.png: Test push and pop commands with maximum values tracking
<figure>
<p align="center"><img src="https://github.com/nxthuan512/Hardware-stack-maxium-tracking/blob/master/src_code_20181119/pics/test_push_pop.PNG" alt="hinh1" width="100%"></p>    
<figcaption><p align="center"></p></figcaption>
</figure>
    - test_error_pop_empty.png: Test pop command when stack is empty -> error 02
<figure>
<p align="center"><img src="https://github.com/nxthuan512/Hardware-stack-maxium-tracking/blob/master/src_code_20181119/pics/test_error_pop_empty.PNG" alt="hinh1" width="100%"></p>    
<figcaption><p align="center"></p></figcaption>
</figure>   
    - test_error_push_full.png: Test push command when stack is full -> error 01
 <figure>
<p align="center"><img src="https://github.com/nxthuan512/Hardware-stack-maxium-tracking/blob/master/src_code_20181119/pics/test_error_push_full.PNG" alt="hinh1" width="100%"></p>    
<figcaption><p align="center"></p></figcaption>
</figure>    
