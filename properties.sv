module sva_tb(
	input [7:0] A,
	input [7:0] B
);

reg [7:0] mutsel = 8'd `MUTIDX;

wire A_EQ_B;
wire error;

redundant_comparator dut (
	.A(A),
	.B(B),
	.mutsel(mutsel),
	.A_EQ_B(A_EQ_B),
	.error(error)
);

always @(*) begin
	if (A != B)
		assert( !A_EQ_B || error );
end

endmodule
