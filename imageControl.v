`timescale 1ns / 1ps

module imageControl(
input                    i_clk,
input                    i_rst,
input [7:0]              i_pixel_data,
input                    i_pixel_data_valid,
output reg [71:0]        o_pixel_data,
output                   o_pixel_data_valid,
output reg               o_intr,
output reg               t_last
);

reg [10:0] pixelCounter;
reg [1:0] currentWrLineBuffer;
reg [3:0] lineBuffDataValid;    //vector to enable write to a lineBuffer (0,0,1,0)
reg [3:0] lineBuffRdData;
reg [1:0] currentRdLineBuffer;
wire [23:0] lb0data;
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;
reg [10:0] rdCounter;
reg rd_line_buffer;
reg [11:0] totalPixelCounter;
reg [1:0] flag;
reg rdState;

localparam IDLE = 'b0,
           RD_BUFFER = 'b1;

assign o_pixel_data_valid = rd_line_buffer;
////////////////

///this process tell how much pixels there is in the 4 buffers
always @(posedge i_clk)
begin
    if(i_rst)
        totalPixelCounter <= 0;
    else
    begin
        if(i_pixel_data_valid & !rd_line_buffer)
            totalPixelCounter <= totalPixelCounter + 1;
        else if(!i_pixel_data_valid & rd_line_buffer)
            totalPixelCounter <= totalPixelCounter - 1;
    end
end
///////////////9
always @(posedge i_clk)
begin
    if(i_rst)
    begin
        rdState <= IDLE;
        rd_line_buffer <= 1'b0;
        o_intr <= 1'b0;
    end
    else
    begin
        case(rdState)
            IDLE:begin
                o_intr <= 1'b0;
                if(totalPixelCounter >= 1920)
                begin
                    rd_line_buffer <= 1'b1;
                    rdState <= RD_BUFFER;
                end
            end
            RD_BUFFER:begin
                if(rdCounter == 639)
                begin
                    rdState <= IDLE;
                    rd_line_buffer <= 1'b0;
                    o_intr <= 1'b1;
                end
            end
        endcase
    end
end
    
//////////t_last process
always @(posedge i_clk)
begin
    if (i_rst) begin
        t_last <= 0;
        flag <= 0;
    end    
    else begin
        if (rd_line_buffer == 1) begin 
            flag <= 1;
            t_last <= 0;
        end
        if (!rd_line_buffer & flag >= 1) begin
          flag <= 2;
           if (flag == 2) begin 
                flag <= 0;
              t_last <= 1;
           end 
        end
    end
end


always @(posedge i_clk)
begin
    if(i_rst)
        pixelCounter <= 0;
    else 
    begin
        if(i_pixel_data_valid)
        begin
        if (pixelCounter == 639)
            pixelCounter <= 0;
        else
            pixelCounter <= pixelCounter + 1;
        end
    end
end

/////////2
always @(posedge i_clk)
begin
    if(i_rst)
        currentWrLineBuffer <= 0;
    else
    begin
        if(pixelCounter == 639 & i_pixel_data_valid)
        begin
            currentWrLineBuffer <= currentWrLineBuffer+1;
//            pixelCounter <= 0;
        end
    end
end
///////////////////////3
always @(*)
begin
    lineBuffDataValid = 4'h0;
    lineBuffDataValid[currentWrLineBuffer] = i_pixel_data_valid;
end
////////////////6
always @(posedge i_clk)
begin
  if (i_rst) 
    rdCounter <= 0;
  else 
  begin 
  if (rd_line_buffer) begin
    if (rdCounter == 639) 
      rdCounter <= 0;
    else
      rdCounter <= rdCounter + 1;
    end
  end
end

//////////////////5
always @(posedge i_clk)
begin
    if(i_rst)
    begin
        currentRdLineBuffer <= 0;
    end
    else
    begin
        if(rdCounter == 639 & rd_line_buffer)
            currentRdLineBuffer <= currentRdLineBuffer + 1;
    end
end

///////////////////////////////////////////4
always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            o_pixel_data = {lb2data,lb1data,lb0data};
        end
        1:begin
            o_pixel_data = {lb3data,lb2data,lb1data};
        end
        2:begin
            o_pixel_data = {lb0data,lb3data,lb2data};
        end
        3:begin
            o_pixel_data = {lb1data,lb0data,lb3data};
        end
    endcase
end
////////////////////////////////7
always @(*)
begin
    case(currentRdLineBuffer)
        0:begin
            lineBuffRdData[0] = rd_line_buffer;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = 1'b0;
        end
       1:begin
            lineBuffRdData[0] = 1'b0;
            lineBuffRdData[1] = rd_line_buffer;
            lineBuffRdData[2] = rd_line_buffer;
            lineBuffRdData[3] = rd_line_buffer;
        end
       2:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = 1'b0;
             lineBuffRdData[2] = rd_line_buffer;
             lineBuffRdData[3] = rd_line_buffer;
       end  
      3:begin
             lineBuffRdData[0] = rd_line_buffer;
             lineBuffRdData[1] = rd_line_buffer;
             lineBuffRdData[2] = 1'b0;
             lineBuffRdData[3] = rd_line_buffer;
       end        
    endcase
end
    
lineBuffer lB0(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_data(i_pixel_data),
    .i_data_valid(lineBuffDataValid[0]),
    .o_data(lb0data),
    .i_rd_data(lineBuffRdData[0])
 ); 
 
 lineBuffer lB1(
     .i_clk(i_clk),
     .i_rst(i_rst),
     .i_data(i_pixel_data),
     .i_data_valid(lineBuffDataValid[1]),
     .o_data(lb1data),
     .i_rd_data(lineBuffRdData[1])
  ); 
  
  lineBuffer lB2(
      .i_clk(i_clk),
      .i_rst(i_rst),
      .i_data(i_pixel_data),
      .i_data_valid(lineBuffDataValid[2]),
      .o_data(lb2data),
      .i_rd_data(lineBuffRdData[2])
   ); 
   
   lineBuffer lB3(
       .i_clk(i_clk),
       .i_rst(i_rst),
       .i_data(i_pixel_data),
       .i_data_valid(lineBuffDataValid[3]),
       .o_data(lb3data),
       .i_rd_data(lineBuffRdData[3])
    );    
    
endmodule