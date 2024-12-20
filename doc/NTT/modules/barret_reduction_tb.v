module barret_tb () ;
parameter data_size = 32 ;
parameter prime_number = 2971 ;
reg [data_size-1 : 0] X_tb ;
reg clk_tb , rst_tb ;
wire [(data_size/2)-1 : 0] X_reduction_reg_tb ;
parameter CLK_PERIOD = 10 ;

barret_reduction #(.data_size(data_size) , .prime_number (prime_number)) DUT_1  (
.X(X_tb) ,
.clk (clk_tb) ,
.rst (rst_tb) ,
.X_reduction_reg (X_reduction_reg_tb)
);

initial begin
	clk_tb = 0 ;
	forever begin
	#(CLK_PERIOD/2) clk_tb = ~ clk_tb ;	
	end
end

initial begin
	initialization () ;
	X_tb = 'd27311837 ;
	#(3*CLK_PERIOD) ;
	$stop ;
end

task initialization ;
begin
	rst_tb = 1'b1 ;
	X_tb ='d0 ;
	#(CLK_PERIOD) ;
	rst_tb = 1'b0 ;
	#(CLK_PERIOD) ;
	rst_tb = 1'b1 ;
end
endtask
endmodule