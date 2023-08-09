`timescale 1ns / 1ps


module lineBuffer(
input   i_clk,
input   i_rst,
input [7:0] i_data,
input   i_data_valid,
output [23:0] o_data,
input i_rd_data
);

reg [7:0] line [639:0]; //line buffer
reg [10:0] wrPntr;
reg [10:0] rdPntr;

always @(posedge i_clk)
begin
    if(i_data_valid)
        line[wrPntr] <= i_data;
end

always @(posedge i_clk) begin
  if (i_rst) begin
    wrPntr <= 'd0;
  end else if (i_data_valid) begin
    if (wrPntr == 639) begin
      wrPntr <= 'd0;
    end else begin
      wrPntr <= wrPntr + 'd1;
    end
  end
end


always @(posedge i_clk) begin
  if (i_rst) begin
    rdPntr <= 'd0;
  end 
  else if (i_rd_data) begin
    if (rdPntr == 639) begin
      rdPntr <= 'd0;
    end else begin
      rdPntr <= rdPntr + 'd1;
    end
  end
end

assign o_data = {line[rdPntr],line[rdPntr+1],line[rdPntr+2]};
endmodule