module CTRL (
    input rst,
    input stallq,
    input pasue_from_id,
    input pasue_from_exe,
    input pasue_from_mem,
    output reg [5:0]stall
);
//0     1     2   3   4   5 
//PC    IF    ID  EXE MEM WB
always @(*) begin
    if(rst)begin
        stall <= 6'b000000;
    end else begin
        stall <= //stallq         ?   6'b001111 :
                 pasue_from_exe ?   6'b001111 :
                 pasue_from_id  ?   6'b000011 :
                                    6'b000000;
    end
end
endmodule