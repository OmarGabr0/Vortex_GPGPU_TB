module mod_subtraction_reduction #(parameter data_size = 32 , parameter prime_number = 17)
(
	input signed [BIT_WIDTH-1:0] X,
    output signed [BIT_WIDTH-1:0] X_reduction
);

always @ (*) begin
	if (X>prime_number) begin
		X_reduction = X - prime_number ;
	end
	else if (X<0) begin
		X_reduction = X + prime_number ;
	end
	else begin
		X_reduction = X ;
	end
end

endmodule