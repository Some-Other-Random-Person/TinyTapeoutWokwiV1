
module clock_div #(
    parameter integer INPUT_FREQ  = 31500000,
    parameter integer TARGET_FREQ = 100
)(
    input  wire clk,
    input  wire reset,
    output reg  slower_clk_out_pulse 
);
    localparam DIV = INPUT_FREQ / TARGET_FREQ;

    reg [30:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter   <= 0;
            slower_clk_out_pulse <= 0;
        end else begin
            if (counter >= DIV-1) begin
                counter   <= 0;
                slower_clk_out_pulse <= 1'b1;  
            end else begin
                counter   <= counter + 1;
                slower_clk_out_pulse <= 1'b0;
            end
        end
    end
endmodule