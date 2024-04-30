//
// Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
// SPDX-License-Identifier: MIT
//

module wrp_shff_din_buff
#(parameter RA_INIT = 4'd0, parameter ram_delay=2)
(
	input         clk,
	input         srst,
	//---------------------------
	output  reg   axi_trdy,
	input         axi_tvld,
	input  [63:0] axi_tdat,
	//---------------------------
	output  ready,
	input   start_i,
	output  reg [63:0] dat_o
);

//------------------------------------------
// 4 blocks of data for parallel write/read
//------------------------------------------
localparam ramlatency = ram_delay;
localparam addr_bw = 6; // depth=64 for distributed RAM, 

// RAM Interface Signals
reg [addr_bw-1:0] ram_wa;
reg [addr_bw-1:0] ram_ra;

reg [63:0] ram_wd;
reg ram_we;
wire [63:0] ram_rd;


// every read/write session is 16 words
// 64-depth memory is divided into 4 blocks
reg [addr_bw-1-3:0] ra_msb;
reg [2:0] acnt;
reg [3:0] ra_lsb;

reg  cnt_incr;
reg  cnt_decr;
reg [4:0] rcnt;

// flag to indicate whether any data in the buffer
wire acnt_not_zero;
reg rd_done;

reg [1:0] cst;


localparam stat_wait = 2'b01;
localparam stat_rd   = 2'b10;
localparam stat_rcnt = 2'b00;
localparam stat_rst  = 2'b11;

//----------------------------------------
// memory write interface
//----------------------------------------
assign acnt_not_zero = |acnt;
assign ready = (cst==stat_rd)? 1'b1 : 1'b0;
//----------------------------------------
always @(posedge clk) begin

	// generate ready signal
	axi_trdy <= ~|acnt[2:1];

	// ram write interface	
	ram_we <= axi_trdy & axi_tvld;
	ram_wd <= axi_tdat;
	ram_wa <= srst? 0: ram_we? ram_wa+1 : ram_wa;

	// a pulse to increment cnt after 16 samples are written
	cnt_incr <= (&ram_wa[3:0]) & ram_we;
	
	// count number of samples available
	acnt <= srst? 3'd0 : (cnt_incr & (~cnt_decr))? acnt+1 : (cnt_decr & (~cnt_incr)) ? acnt-1 : acnt;

end


//----------------------------------------
// memory read interface
//----------------------------------------
always @(posedge clk) begin
	
	// generate a read counter. use it for lsb of read address
	rcnt <= srst? 0    : start_i? 16 : rcnt[4]? rcnt+1 : rcnt;
	
	// register read address
	ra_msb <= srst? -1 : start_i? ra_msb+1 : ra_msb;
	ra_lsb <= rcnt[4]? (ra_lsb+1) : RA_INIT;
	
	// generate read address
	// with offset
	ram_ra <= {ra_msb, ra_lsb};

	// for valid signal generation
	dat_o <= ram_rd;
	
	cnt_decr <= start_i;
	rd_done  <= cnt_decr;
end



//------------------------------------------
// Read State Machine
//------------------------------------------
always@(posedge clk)
begin
  if(srst==1'b1) cst  <= stat_rst;
  else begin  
	   case(cst)
		stat_wait:	cst <= acnt_not_zero? stat_rd : cst;
		stat_rd:	cst <= start_i? stat_rcnt : cst;
		stat_rcnt:  cst <= (rcnt[3]&rcnt[2])? stat_wait : stat_rcnt; 
		default:    cst <= stat_wait;
	   endcase
	end
end

//------------------------------------------
// xpm_memory_sdpram: Simple Dual Port RAM
// Xilinx Parameterized Macro
//------------------------------------------
xpm_memory_sdpram #(
   .ADDR_WIDTH_A(addr_bw),         // DECIMAL
   .ADDR_WIDTH_B(addr_bw),         // DECIMAL
   .AUTO_SLEEP_TIME(0),            // DECIMAL
   .BYTE_WRITE_WIDTH_A(64),        // DECIMAL
   .CASCADE_HEIGHT(0),             // DECIMAL
   .CLOCKING_MODE("common_clock"), // String
   .ECC_MODE("no_ecc"),            // String
   .MEMORY_INIT_FILE("none"), // String
   .MEMORY_INIT_PARAM("0"),        // String
   .MEMORY_OPTIMIZATION("false"),   // String
   .MEMORY_PRIMITIVE("distributed"), // String
   .MEMORY_SIZE(64*(2**addr_bw)),   // DECIMAL
   .MESSAGE_CONTROL(0),            // DECIMAL
   .READ_DATA_WIDTH_B(64),         // DECIMAL
   .READ_LATENCY_B(ramlatency),    // DECIMAL
   .READ_RESET_VALUE_B("0"),       // String
   .RST_MODE_A("SYNC"),            // String
   .RST_MODE_B("SYNC"),            // String
   .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .USE_EMBEDDED_CONSTRAINT(0),    // DECIMAL
   .USE_MEM_INIT(0),               // DECIMAL
   .WAKEUP_TIME("disable_sleep"),  // String
   .WRITE_DATA_WIDTH_A(64),        // DECIMAL
   .WRITE_MODE_B("read_first")      // String
)
xpm_memory_sdpram_inst (
   .dbiterrb(),             // 1-bit output: Status signal to indicate double bit error occurrence
                                    // on the data output of port B.

   .doutb(ram_rd),                   // READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
   .sbiterrb(),             // 1-bit output: Status signal to indicate single bit error occurrence
                                    // on the data output of port B.

   .addra(ram_wa),        // ADDR_WIDTH_A-bit input: Address for port A write operations.
   .addrb(ram_ra),                   // ADDR_WIDTH_B-bit input: Address for port B read operations.
   .clka(clk),                     // 1-bit input: Clock signal for port A. Also clocks port B when
                                    // parameter CLOCKING_MODE is "common_clock".

   .clkb(clk),                     // 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                    // "independent_clock". Unused when parameter CLOCKING_MODE is
                                    // "common_clock".

   .dina(ram_wd),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
   .ena(1'b1),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
                                    // cycles when write operations are initiated. Pipelined internally.

   .enb(1'b1),                       // 1-bit input: Memory enable signal for port B. Must be high on clock
                                    // cycles when read operations are initiated. Pipelined internally.

   .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
                                    // ECC enabled (Error injection capability is not available in
                                    // "decode_only" mode).

   .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
                                    // ECC enabled (Error injection capability is not available in
                                    // "decode_only" mode).

   .regceb(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
                                    // data path.

   .rstb(1'b0),                     // 1-bit input: Reset signal for the final port B output register stage.
                                    // Synchronously resets output port doutb to the value specified by
                                    // parameter READ_RESET_VALUE_B.

   .sleep(1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
   .wea(ram_we)                     // WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-bit input: Write enable vector
                                    // for port A input data port dina. 1 bit wide when word-wide writes are
                                    // used. In byte-wide write configurations, each bit controls the
                                    // writing one byte of dina to address addra. For example, to
                                    // synchronously write only bits [15-8] of dina when WRITE_DATA_WIDTH_A
                                    // is 32, wea would be 4'b0010.

);

// End of xpm_memory_sdpram_inst instantiation



endmodule
