




module internal_reset(
    input        i_clk,
    input wire   i_rstn,
    output wire   o_reset
);
    parameter RESET_FIFO_DEPTH = 5;

    reg[RESET_FIFO_DEPTH-1:0] synch_regs_q;

    always @ (posedge i_clk or negedge i_rstn) begin
        if (~i_rstn) begin
            synch_regs_q <= 0;
        end else begin
            synch_regs_q <= {synch_regs_q[RESET_FIFO_DEPTH-2:0], 1'b1};
        end
    end

    assign o_reset = synch_regs_q[RESET_FIFO_DEPTH-1];

endmodule