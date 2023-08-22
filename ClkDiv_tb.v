`timescale 1ns / 1ps
module ClkDiv_tb;

	//parameters
	parameter clk_period = 10;
	parameter DIV_width=4;
	parameter highet_freq_ratio=(2**DIV_width);
	
	// Inputs
	reg i_ref_clk_tb;
	reg i_rst_n_tb;
	reg i_clk_en_tb;
	reg [DIV_width-1:0] i_div_ratio_tb;
	
	
	

	// Outputs
	wire o_div_clk_tb;

	// Instantiate the Unit Under Test (UUT)
	ClkDiv #(.DIV_RATIO_WIDTH(DIV_width)) uut (
		.i_ref_clk(i_ref_clk_tb), 
		.i_rst_n(i_rst_n_tb), 
		.i_clk_en(i_clk_en_tb), 
		.i_div_ratio(i_div_ratio_tb), 
		.o_div_clk(o_div_clk_tb)
	);
	
	
	always #(clk_period/2) i_ref_clk_tb =~i_ref_clk_tb;

	initial begin
		
		$dumpfile("ClkDiv.vcd");
		$dumpvars;	
		
		//Initialize Inputs	
		initialize();
		
		//resettig
		reset();
		
		DIV_CLK_ENABLE('d6);
		check_freq_ratio('d6);
		i_div_ratio_tb=8;
		check_freq_ratio('d8);
		i_div_ratio_tb=2;
		check_freq_ratio('d2);
		i_div_ratio_tb=9;
		check_freq_ratio('d9);		
		
		//check timig diagram to make sure o_dic_clk is sams as i_ref_clk
		i_div_ratio_tb=1;
		#(3*clk_period);
		
		//check timig diagram to make sure o_dic_clk is still sams as i_ref_clk
		i_div_ratio_tb=0;
		#(3*clk_period);		
		
		i_div_ratio_tb=11;
		check_freq_ratio('d11);		
		#clk_period;
		DIV_CLK_DISABLE();
		#(3*clk_period);
		DIV_CLK_ENABLE('d7);
		check_freq_ratio('d7);
		DIV_CLK_DISABLE();
		
		#(10*clk_period);
		
		$stop();
		

	end
	
/////////////////////////////////////////	
	task initialize();begin
		i_ref_clk_tb = 0;
		i_rst_n_tb = 1;
		i_clk_en_tb = 0;
		i_div_ratio_tb = 0;	end
	endtask

/////////////////////////////////////////	
	task reset();begin
		i_rst_n_tb = 0;
		#clk_period;
		i_rst_n_tb = 1;
	end
	endtask

///////////////////////////////////////////	
	task DIV_CLK_ENABLE;
	input [DIV_width-1:0] DIV_RATIO;
	begin
		i_div_ratio_tb = DIV_RATIO;
		i_clk_en_tb=1;
		#clk_period;
	end
	endtask

///////////////////////////////////////////	
	task DIV_CLK_DISABLE;
	begin
		i_clk_en_tb=0;
	end
	endtask

///////////////////////////////////////////
	task check_freq_ratio;
	input [DIV_width-1:0] freq_ratio;
	reg [highet_freq_ratio-1:0] data;
	integer i;
	reg check1,check2;
	begin
		check1=1;
		check2=1;
		$display("------------------------------------");
		for(i=0;i<(freq_ratio/2); i=i+1)begin
			data[i] = o_div_clk_tb;
			check1 = check1 & data[i];
			$display("data= %0d, time= %0t ",data[i],$time);
			#clk_period;
		end
		
		for(i=(freq_ratio/2);i<(freq_ratio); i=i+1)begin
			data[i] = o_div_clk_tb;
			check2 = check2 & data[i];
			$display("data= %0d, time= %0t ",data[i],$time);
			#clk_period;
		end
		
		if ( check1  != check2) begin
			$display("clk_freq is %0dX smaller than ref_clk_freq --> tst is successful",freq_ratio);
		end
		else begin
			$display("clk_freq is not %0dX smaller than ref_clk_freq --> tst failed",freq_ratio);
		end
		
		$display("------------------------------------");
		
	end
	endtask
	
      
endmodule