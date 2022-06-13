module comparator(
	input [7:0] A,
	input [7:0] B,
	output A_EQ_B
);

assign A_EQ_B = (A == B);

endmodule

module redundant_comparator(
	input [7:0] A,
	input [7:0] B,
	output A_EQ_B,
	output error
);

wire EQ1;
wire EQ2;

comparator comp1 (
	.A(A),
	.B(B),
	.A_EQ_B(EQ1)
	);

comparator comp2 (
	.A(A),
	.B(B),
	.A_EQ_B(EQ2)
	);

assign A_EQ_B = (EQ1 && EQ2);
assign error = (EQ1 != EQ2);

endmodule
