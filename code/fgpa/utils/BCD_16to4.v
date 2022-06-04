module BCD_16to4(reset, sysclk, display_sig, out, an);
input wire reset;
input wire sysclk;
input wire [15:0] display_sig;
output wire [3:0] out;
output wire [3:0] an;
reg [32:0] count;
reg [1:0] status;

initial begin
    count <= 0;
end

always@(posedge reset or posedge sysclk) begin
    if(reset) begin
        count <= 0;
        status <= 0;
    end
    else begin
        if(count >= 9999) begin
            if(status == 3)
                status <= 0;
            else
                status <= status + 1;
            count <= 0;
        end
        else
            count <= count + 1;
    end
end 

assign out = status == 2'b00 ? display_sig[3:0] :
             status == 2'b01 ? display_sig[7:4] :
             status == 2'b10 ? display_sig[11:8] :
             status == 2'b11 ? display_sig[15:12] : 0;

assign an = status == 2'b00 ? 4'b0001 :
            status == 2'b01 ? 4'b0010 :
            status == 2'b10 ? 4'b0100 :
            status == 2'b11 ? 4'b1000 : 0;

endmodule