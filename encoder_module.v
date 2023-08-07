
//旋转编码器mk991 顺时针转一格计数值加一，逆时针转一格计数值减一

module encoder_module
(
	input clk_50mhz,
	input rst_n,
	input A,
	input B,
	
	output [15:0]encoder_count
);

reg clk_div; //对系统时钟进行分频，使编码器稳定计数
reg [7:0]cnt_div;
//-------------------------------------------
//分频
always@(posedge clk_50mhz or negedge rst_n)
begin
	if(!rst_n)
	begin
		cnt_div<=0;
	end
	else if(cnt_div==8'd249)
	begin
		cnt_div<=0;
		clk_div<=~clk_div;
	end
	else cnt_div<=cnt_div+1;
end
//--------------------------------------------
reg [15:0]encoder_cnt_reg;

wire posedge_A; //用于检测A相的上升沿，A上升沿时若B为0则顺时针转一格，A上升沿时若B为1则逆时针转一格
reg A_buff_1,A_buff_2;
reg B_buff_1,B_buff_2;

always@(posedge clk_div or negedge rst_n)
begin
	if(!rst_n)
	begin
		A_buff_1<=0;
		A_buff_2<=0;
		B_buff_1<=0;
		B_buff_2<=0;
	end
	else
	begin
		A_buff_1<=A;
		A_buff_2<=A_buff_1;
		B_buff_1<=B;
		B_buff_2<=B_buff_1;
	end
end

assign posedge_A = (A_buff_2==0)&&(A_buff_1==1);

//----------------------------------------------
//---逆时针转计数值加一，顺时针转计数值减一
//用16位cnt计数，每4位代表一个数字，计数值从0-9999
//
always@(posedge clk_div or negedge rst_n)
begin
	if(!rst_n)
	begin
		encoder_cnt_reg<=0;
	end	
	else if(posedge_A && B_buff_2)
	begin
		if(encoder_cnt_reg[3:0]==0)
		begin
			encoder_cnt_reg[3:0]<=9;
			if(encoder_cnt_reg[7:4]==0)
			begin
				encoder_cnt_reg[7:4]<=9;
				if(encoder_cnt_reg[11:8]==0)
				begin
					encoder_cnt_reg[11:8]<=9;
					if(encoder_cnt_reg[15:12]==0)
					begin
						encoder_cnt_reg[15:12]<=9;
					end
					else encoder_cnt_reg[15:12]<=encoder_cnt_reg[15:12]-1;
				end
				else encoder_cnt_reg[11:8]<=encoder_cnt_reg[11:8]-1;
			end
			else encoder_cnt_reg[7:4]<=encoder_cnt_reg[7:4]-1;
		end
		else encoder_cnt_reg[3:0]<=encoder_cnt_reg[3:0]-1;
	end
	else if(posedge_A && (~B_buff_2))
	begin
		if(encoder_cnt_reg[3:0]==9)
		begin
			encoder_cnt_reg[3:0]<=0;
			if(encoder_cnt_reg[7:4]==9)
			begin
				encoder_cnt_reg[7:4]<=0;
				if(encoder_cnt_reg[11:8]==9)
				begin
					encoder_cnt_reg[11:8]<=0;
					if(encoder_cnt_reg[15:12]==9)
					begin
						encoder_cnt_reg[15:12]<=0;
					end
					else encoder_cnt_reg[15:12]<=encoder_cnt_reg[15:12]+1;
				end
				else encoder_cnt_reg[11:8]<=encoder_cnt_reg[11:8]+1;
			end
			else encoder_cnt_reg[7:4]<=encoder_cnt_reg[7:4]+1;
		end
		else encoder_cnt_reg[3:0]<=encoder_cnt_reg[3:0]+1;
	end
	else encoder_cnt_reg<=encoder_cnt_reg;
end




assign encoder_count=encoder_cnt_reg;

endmodule
