module Second_Pool(
    clk,
    rst_n,
    Din_Valid, // 矩阵输入；tvalid；
    Cal_Valid, // 有效操作；
    Din, // 数据输入;
    Dout // 数据输出；
    );
	
    input clk;
    input rst_n;
    input Din_Valid;
    input Cal_Valid;
    input [15:0] Din;
    output reg [15:0] Dout;

    reg [287:0] line_buffer; // 16*16 特征图的行缓冲区；
    reg [15:0] window_buffer [3:0]; // 2*2 窗口的窗缓冲区；            
    
    // Data Buffer
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                line_buffer      <= 288'd0;
                window_buffer[3] <= 16'd0;
                window_buffer[2] <= 16'd0;
                window_buffer[1] <= 16'd0;
                window_buffer[0] <= 16'd0;
        end
        else begin
        	if(Din_Valid) begin
                line_buffer      <= {line_buffer[271:0],Din}; // 串行输入，数据移位；
                window_buffer[3] <= line_buffer[287:272]; // 窗口显示，并行操作；
                window_buffer[2] <= line_buffer[271:256];
                window_buffer[1] <= line_buffer[31:16];
                window_buffer[0] <= line_buffer[15:0];
            end
            else begin
            	line_buffer   <= line_buffer;
            	window_buffer[3] <= window_buffer[3];
                window_buffer[2] <= window_buffer[2];
                window_buffer[1] <= window_buffer[1];
                window_buffer[0] <= window_buffer[0];
            end	
        end
    end

    wire sel0,sel1,sel2;
    reg [15:0] bigger0,bigger1;

    assign sel0 = (window_buffer[0] <= window_buffer[1])? 1:0;
    assign sel1 = (window_buffer[2] <= window_buffer[3])? 1:0;
    assign sel2 = (bigger0 <= bigger1)? 1:0;
    
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin     
            bigger0 <= 16'd0;
        end
        else begin
            if(sel0)
                bigger0 <= window_buffer[1];
            else
                bigger0 <= window_buffer[0];
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin     
            bigger1 <= 16'd0;
        end
        else begin
            if(sel1)
                bigger1 <= window_buffer[3];
            else
                bigger1 <= window_buffer[2];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            Dout <= 16'd0;
        else begin
            if(Cal_Valid) begin
                if(sel2)
                    Dout <= bigger1;
                else
                    Dout <= bigger0;
            end
            else 
                Dout <= 16'd0;
        end
    end

endmodule