module barret_reduction #(parameter data_size = 4 , parameter prime_number = 101 ,
parameter no_of_bits_of_prime_no = $clog2(prime_number) , parameter factor_approximate_div = (2^(2*no_of_bits_of_prime_no)) / prime_number )
(
input [data_size-1 : 0] X ,
input clk , rst ,

output reg [(data_size/2)-1 : 0] X_reduction_reg 
);
reg [data_size-1 : 0] X_reg ;
reg [(data_size/2)-1 : 0] X_reduction ;
reg [data_size-1 : 0] q ;
reg [data_size-1 : 0] q_bar ;
reg [data_size-1 : 0] r ;
integer i ;

always @(*) begin
if (X_reg < prime_number) begin
	X_reduction = X_reg ;
end
else begin
	q = X_reg >> no_of_bits_of_prime_no ;
	q_bar = (q*factor_approximate_div) >> no_of_bits_of_prime_no ;
	r = X_reg - (q_bar * prime_number) ;
	for (i=0 ; r>prime_number ; i = i +1) begin
		r = r - prime_number ;
	end
	X_reduction = r ;
end

end

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		X_reg <= 0 ;
		X_reduction_reg <= 0 ;
	end
	else begin
		X_reg <= X ;
		X_reduction_reg <= X_reduction ;
	end
end
endmodule