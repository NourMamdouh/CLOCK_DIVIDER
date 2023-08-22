module ClkDiv #(parameter DIV_RATIO_WIDTH=4)(
input		wire							i_ref_clk,i_rst_n, //reference clk and asychronous active low resst
input		wire							i_clk_en,		   //to enable obtaining a clk with a different freq "fout" than reference --> smaller one
input		wire	[DIV_RATIO_WIDTH-1:0]	i_div_ratio,	   //fout = fin / i_div_ratio
output		wire							o_div_clk 			//obtained clk
);

//interal signals for controlling
wire 						odd,clk_en;
reg							clk_en_reg,div_clk;
wire [DIV_RATIO_WIDTH-2:0]	max_count;
reg  [DIV_RATIO_WIDTH-1:0]	count;


//div_clk logic
always @(posedge i_ref_clk,negedge i_rst_n)begin
	if(!i_rst_n)begin
		div_clk <= 1'd0;
	end 
	else if(clk_en_reg && ((count==(max_count-'d1)) || (count==(i_div_ratio-'d1))) )begin
		div_clk <= ~div_clk;
	end
end


//counter logic
always @(posedge i_ref_clk,negedge i_rst_n)begin
	if(!i_rst_n)begin
		count <= 'd0;
	end
	else if(((count==(max_count-'d1)) & !odd) || (count==(i_div_ratio-'d1)) || !clk_en_reg)begin
		count <= 'd0;
	end
	else begin
		count <= count + 'd1;
	end
end


//registerig enable signal to avoid random switching between clk_div and i_clk_ref 
always @(posedge i_ref_clk,negedge i_rst_n)begin
	if(!i_rst_n)begin
		clk_en_reg <= 1'd0;
	end 
	else begin
		clk_en_reg <= clk_en;
	end
end


//control sigals comiational logic
assign odd 		 = i_div_ratio[0];
assign clk_en 	 = i_clk_en && (i_div_ratio!='d0) && (i_div_ratio!='d1);
assign max_count = i_div_ratio >> 'd1;


assign o_div_clk = clk_en_reg? div_clk : i_ref_clk;

endmodule


