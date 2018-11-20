// ====================================================
// v1.0: 2018/11/18 - Thomas
// ====================================================

// ++++++++++++++++++++++++++++++++++++++++
// Global define 
`define 	DW 32
`define		AW 8

// ++++++++++++++++++++++++++++++++++++++++
// Stack interface
module tt_stack (
    input  wire         	iclk,
    input  wire         	ireset,

    // request & response interface
    output wire         	oready,
    input  wire         	ireq_valid,
    input  wire         	ireq_op,             // 0 for push, 1 for pop
    input  wire [`DW-1:0]  	ireq_push_data,
    output reg	         	oresp_valid,
    output wire [`DW-1:0]  	oresp_pop_data,
    output wire [`DW-1:0]  	oresp_error_code,

    // max value interface
    output wire         	omax_data_valid,
    output wire [`DW-1:0]  	omax_data,

    // memory interface
    output wire [`AW-1:0]   omem_addr,
    output wire [`DW-1:0]  	omem_write_data,
    output wire         	omem_write_enable,
    input  wire [`DW-1:0]  	imem_read_data
);

// ----------------------------------------
// Parameters

// ----------------------------------------
// Reg, Wire
reg	 	[`AW:0]		counter;

reg		[`DW-1:0]	s1_tswrdata;
wire				track_stack_write_en;
wire	[`AW-1:0]	track_stack_addr;		
wire	[`DW-1:0]	track_stack_write_data;
wire	[`DW-1:0]	track_stack_read_data;

wire				mem_stack_empty;
wire				mem_stack_full;
wire				mem_stack_push;
wire				mem_stack_pop;

// ----------------------------------------
assign oready = 1'b1;

assign mem_stack_push 		= ireq_valid & ~ireq_op && ~mem_stack_full;
assign mem_stack_pop		= ireq_valid & ireq_op && ~mem_stack_empty;
assign mem_stack_empty 		= (counter == {`AW{1'b0}});
assign mem_stack_full  		= (counter == {1'b1, {`AW{1'b0}}});

assign omem_addr			= mem_stack_push ? counter : (counter - 1'b1);
assign omem_write_enable 	= mem_stack_push;
assign omem_write_data 		= ireq_push_data;
assign oresp_pop_data		= imem_read_data;
								

// Error code
// 00: normal
// 01: push request when stack is full
// 02: pop request when stack is empty
assign oresp_error_code = 	(ireq_valid & ~ireq_op && mem_stack_full) ? 'h01 : 
							(ireq_valid & ireq_op && mem_stack_empty) ? 'h02 : 'h00;

// Stack control unit
always @ (posedge iclk)
begin
	if (ireset)
	begin
		counter	<= {(`AW+1){1'b0}};
	end
	//
	else
	begin
		// push request
		if (mem_stack_push)
			counter	<= counter + 1'b1;
		// pop request
		if (mem_stack_pop)
			counter	<= counter - 1'b1;
	end
end

always @ (posedge iclk)
begin
	oresp_valid	<= ireset ? 1'b0: mem_stack_pop;
end


// Track stack control unit
assign track_stack_write_en 	= mem_stack_push;
assign track_stack_addr			= omem_addr;
assign track_stack_write_data	= (s1_tswrdata > ireq_push_data) ? s1_tswrdata : ireq_push_data;

always @ (posedge iclk)
	s1_tswrdata	<= ireq_push_data;
	
assign omax_data  		= track_stack_read_data;
assign omax_data_valid 	= oresp_valid & (imem_read_data == track_stack_read_data);

// ----------------------------------------
// Module call
single_port_mem TRACK_STACK_00
(
	.iclk				(iclk),
	.iwe				(track_stack_write_en), 
	.iaddr				(track_stack_addr),
	.idata				(track_stack_write_data),
	.oq					(track_stack_read_data)
);

endmodule


// ++++++++++++++++++++++++++++++++++++++++
// Single port memory
module single_port_mem
(
	input				iclk,
	input 				iwe, 
	input 	[`AW-1:0] 	iaddr,
	input 	[`DW-1:0]	idata,
	output 	[`DW-1:0]	oq
);

	// ----------------------------------------
	// Reg, Wire
	reg	 	[`DW-1:0]	sp_mem [0:(2**`AW)-1];		
	// Variable to hold the registered read address
	reg 	[`AW-1:0] 	addr_reg;
	
	// ----------------------------------------
	always @ (posedge iclk)
	begin
	// Write
		if (iwe)
			sp_mem[iaddr] <= idata;		
		addr_reg <= iaddr;		
	end
		
	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	assign oq = sp_mem[addr_reg];
	
endmodule
