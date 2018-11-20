// ====================================================
// v1.0: 2018/11/18 - Thomas
// ====================================================

// ----------------------------------------
// Global define 
`timescale	1ns/1ps
`define 	DW 32
`define		AW 8


module tt_stack_tb ();

// ----------------------------------------
// Parameters

// ----------------------------------------
// Reg, Wire
reg	 	[`DW-1:0]	sim_stack [0:(2**(`AW+1))-1];		

reg					clk;
reg					reset;

reg         		req_valid;
reg         		req_op;             // 0 for push, 1 for pop
reg 	[`DW-1:0]  	req_push_data;

wire				ready;
wire        		resp_valid;
wire	[`DW-1:0]  	resp_pop_data;
wire	[`DW-1:0]  	resp_error_code;

wire	        	max_data_valid;
wire	[`DW-1:0]  	max_data;
wire	[`AW-1:0]   mem_addr;
wire	[`DW-1:0]  	mem_write_data;
wire				mem_write_enable;
wire	[`DW-1:0]	mem_read_data;

integer i;

// ----------------------------------------		
// Clock & Reset & General initilization
initial 
	clk = 1'b0;
always #5
	clk = ~clk;

initial 
begin
	reset	= 1'b1;
	repeat(5) @(posedge clk);
	reset	= 1'b0;
end

// ----------------------------------------			
// Signal generation
initial
begin
	req_valid 		= 1'b0;
	req_op			= 1'b0;
	req_push_data	= {`DW{1'b0}};
	
	wait(reset == 1'b0);
	repeat(2) @(posedge clk);
	
	$readmemh("stack_mem.dat", sim_stack);
	
	// ----------------------------------------------
	// Push
	$display("Test Push/Pop");
	for (i = 0; i < 10; i = i + 1)
	begin
		@(posedge clk);
		req_valid		= 1'b1;
		req_push_data	= sim_stack[i];
	end
	
	@(posedge clk);
	req_valid			= 1'b0;
	
	// Pop
	for (i = 0; i < 10; i = i + 1)
	begin
		@(posedge clk);
		req_valid		= 1'b1;
		req_op			= 1'b1;
	end
	
	@(posedge clk);
	req_valid			= 1'b0;
	req_op				= 1'b0;
	
	// ----------------------------------------------
	// Error caused by pop empty stack_mem
	$display("Test Error");
	for (i = 0; i < 3; i = i + 1)
	begin
		@(posedge clk);
		req_valid		= 1'b1;
		req_op			= 1'b1;
	end
	@(posedge clk);
	req_valid			= 1'b0;
	req_op				= 1'b0;
	
	// Error caused by push full stack_mem
	for (i = 0; i < 260; i = i + 1)
	begin
		@(posedge clk);
		req_valid		= 1'b1;
		req_push_data	= sim_stack[i];
	end
	
	@(posedge clk);
	req_valid			= 1'b0;
end

// ----------------------------------------			
// Module  call					
tt_stack TT_STACK_00 (
    .iclk				(clk),
    .ireset				(reset),
    // request & response interface
    .oready				(ready),
    .ireq_valid			(req_valid),
    .ireq_op			(req_op),             // 0 for push, 1 for pop
    .ireq_push_data		(req_push_data),
    .oresp_valid		(resp_valid),
    .oresp_pop_data		(resp_pop_data),
    .oresp_error_code	(resp_error_code),
    // max value interface
    .omax_data_valid	(max_data_valid),
    .omax_data			(max_data),
    // memory interface
    .omem_addr			(mem_addr),
    .omem_write_data	(mem_write_data),
    .omem_write_enable	(mem_write_enable),
    .imem_read_data		(mem_read_data)
);

single_port_mem STACK_00
(
	.iclk				(clk),
	.iwe				(mem_write_enable), 
	.iaddr				(mem_addr),
	.idata				(mem_write_data),
	.oq					(mem_read_data)
);

endmodule