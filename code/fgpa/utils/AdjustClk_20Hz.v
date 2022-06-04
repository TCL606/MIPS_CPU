module AdjustClk(sysclk, clk);
input wire sysclk;
output reg clk;

reg [32:0] count;

initial begin
    count <= 0;
end

always @(posedge sysclk) begin
    if(count >= 2500000) begin
        clk = ~clk;
        count <= 0;
    end
    else
        count <= count + 1;
end

endmodule