
`timescale 1ps / 1ps

`include "VX_define.vh"
import VX_gpu_pkg::*;
module tb_vortex_axi ;
    // Parameters
    localparam AXI_DATA_WIDTH = `VX_MEM_DATA_WIDTH;   /// 512 bits 
    localparam AXI_ADDR_WIDTH = `MEM_ADDR_WIDTH + (`VX_MEM_DATA_WIDTH/8);     /// 48 
    localparam AXI_TID_WIDTH  = `VX_MEM_TAG_WIDTH;  
    localparam MEM_SIZE       = 1024; // Memory size in bytes
    localparam AXI_NUM_BANKS  = 1 ;
    
    // Clock and rst
    reg clk = 0;
    reg rst = 1;
    // input 
    reg dcr_wr_valid ;
    reg [31:0 ]dcr_wr_data ; 
    reg [11:0] dcr_wr_addr ;  
    // output 
    wire busy ; 
    /////////////////////////////////////////////////
     // from vortex to ram
   wire                          m_axi_arvalid     [AXI_NUM_BANKS];
   wire                         m_axi_rready       [AXI_NUM_BANKS];
   wire [AXI_ADDR_WIDTH-1:0]     m_axi_awaddr      [AXI_NUM_BANKS];
   wire [AXI_ADDR_WIDTH-1:0]     m_axi_araddr      [AXI_NUM_BANKS];
   wire [AXI_DATA_WIDTH/8-1:0]   m_axi_wstrb       [AXI_NUM_BANKS];
   wire [2:0]                    m_axi_awprot      [AXI_NUM_BANKS];
   wire                         m_axi_awvalid      [AXI_NUM_BANKS];
   wire [2:0]                   m_axi_arsize       [AXI_NUM_BANKS];   
                                                                      ///specify the size of each transfer in a read burst transaction
                                                                      /// IS A CONSTANT NUMBER = 3'd6 corresponding to 64 bytes --> whole 512 bits
   wire [3:0]                   m_axi_awcache      [AXI_NUM_BANKS];
   wire [1:0]                   m_axi_awlock       [AXI_NUM_BANKS];
   wire                         m_axi_bready       [AXI_NUM_BANKS];
   wire                         m_axi_wlast        [AXI_NUM_BANKS];
   wire                         m_axi_wvalid       [AXI_NUM_BANKS];
   wire [AXI_DATA_WIDTH-1:0]    m_axi_wdata        [AXI_NUM_BANKS];
   wire [1:0]                   m_axi_awburst      [AXI_NUM_BANKS];
   wire [2:0]                   m_axi_awsize       [AXI_NUM_BANKS];
   wire [7:0]                   m_axi_awlen        [AXI_NUM_BANKS];
   wire [AXI_TID_WIDTH-1:0]     m_axi_awid         [AXI_NUM_BANKS];
   wire [1:0]                   m_axi_rresp        [AXI_NUM_BANKS];
   wire [AXI_TID_WIDTH-1:0]     m_axi_rid          [AXI_NUM_BANKS];
   wire [1:0]                   m_axi_arburst      [AXI_NUM_BANKS];
   wire [7:0]                   m_axi_arlen        [AXI_NUM_BANKS];
   wire [1:0]                   m_axi_arlock       [AXI_NUM_BANKS];
   wire [2:0]                   m_axi_arprot       [AXI_NUM_BANKS];
   wire [3:0]                   m_axi_arcache      [AXI_NUM_BANKS];
   wire [AXI_TID_WIDTH-1:0]     m_axi_arid         [AXI_NUM_BANKS];
     /// from ram to vortex
   wire                          m_axi_rvalid       [AXI_NUM_BANKS];
   wire [1:0]                    m_axi_bresp        [AXI_NUM_BANKS];
   wire [AXI_DATA_WIDTH-1:0]     m_axi_rdata        [AXI_NUM_BANKS];
   wire                          m_axi_arready      [AXI_NUM_BANKS];
   wire [AXI_TID_WIDTH-1:0]      m_axi_bid          [AXI_NUM_BANKS];
   wire                          m_axi_bvalid       [AXI_NUM_BANKS];
   wire                          m_axi_wready       [AXI_NUM_BANKS];
   wire                          m_axi_awready      [AXI_NUM_BANKS];
   wire                          m_axi_rlast        [AXI_NUM_BANKS];



    // Instantiate Vortex AXI module
    // 35 only connected 
    Vortex_axi vortex (
        .clk(clk),
        .reset(rst),

        .dcr_wr_valid(dcr_wr_valid),
        .dcr_wr_addr(dcr_wr_addr),
        .dcr_wr_data(dcr_wr_data),
        
        .busy(busy),

        // total 35 AXI signals// 

        // AXI write request address channel(12) -2 ig 
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awid(m_axi_awid),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awlock(m_axi_awlock),
        .m_axi_awcache(m_axi_awcache),
        .m_axi_awprot(m_axi_awprot),

        // AXI write request data channel(5)
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wlast(m_axi_wlast),

         // AXI write response channel(4)
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),
        .m_axi_bid(m_axi_bid),
        .m_axi_bresp(m_axi_bresp),

         // AXI read request channel(12) -2 ig
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arid (m_axi_arid ),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arlock(m_axi_arlock),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arprot(m_axi_arprot),

        // AXI read response channel(6)
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rid(m_axi_rid),
        .m_axi_rresp(m_axi_rresp)        

    );
  

    ram_decoder #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_TID_WIDTH(AXI_TID_WIDTH),
        .AXI_NUM_BANKS(AXI_NUM_BANKS),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
                ) decode ( 
            .clk(clk),
            .reset(rst), 

        // total 35 AXI signals// 

        // AXI write request address channel(12) -2 ig 
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awid(m_axi_awid),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awlock(m_axi_awlock),
        .m_axi_awcache(m_axi_awcache),
        .m_axi_awprot(m_axi_awprot),

        // AXI write request data channel(5)
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wlast(m_axi_wlast),

         // AXI write response channel(4)
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),
        .m_axi_bid(m_axi_bid),
        .m_axi_bresp(m_axi_bresp),

         // AXI read request channel(12) -2 ig
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arid (m_axi_arid ),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arlock(m_axi_arlock),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arprot(m_axi_arprot),

        // AXI read response channel(6)
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rid(m_axi_rid),
        .m_axi_rresp(m_axi_rresp)

);


 localparam clkperiod = 5 ;
    // Clock Generation
    always #(clkperiod) clk = ~clk;

    
    // Test Procedure
    initial begin
        integer errors;

        // Parameters
        //integer startup_addr = 32'h80000000;      // Kernel startup address
        integer startup_addr = 32'h7000;      // Kernel startup address
        integer src_addr     = 32'h10000;    // Source buffer address
        integer dst_addr     = 32'h10400;   // Destination buffer address
        integer kernel_arg   = 32'h12000;
        // decode.ram1.mem[32'h12000]=512'h00100;
        decode.ram0.mem[48'h480]=512'h0baadf00dbaadf00dbaadf00dbaadf00dbaadf00dbaadf00dbaadf00d000000000001040000000000000100000000000000000001;
       // decode.ram0.mem[32'h12000]=512'hbaadf00dbaadf00dbaadf00dbaadf00dbaadf00dbaadf00dbaadf00dbaadf00dbaadf00dbaadf00d000000000001040000000000000100000000000000000100;
       // load_kernel("instructions_corrected.txt", startup_addr);
       load_kernel("Exctacted_from_log.txt", startup_addr);
        #5 
        $display("FIRST KERNAL LINE =%0h", decode.ram0.mem[startup_addr[23:0]]);
        // Write Source Buffer
        write_source_buffer(1,512'h0deadbeef, src_addr);
       //  rst up for one clock cycle 
       rst =1 ; 
       #(3 * clkperiod)
        // writing dcr addresess
        dcr_write(startup_addr,32'h0,kernel_arg,32'h0);
       #(9* clkperiod);
       @(negedge clk)
       rst = 0 ; 
        // Load Kernel
    

        // Run Kernel
        run_kernel(startup_addr, src_addr, dst_addr);
        @(posedge busy) ;

        wait_busy_signal();
       

     



        // Read Destination Buffer
        read_destination_buffer(1, dst_addr);

        // Verify Results
        verify_results(1, 32'hdeadbeef, dst_addr, errors);

        // End Simulation
        $stop;
    end

 


  task load_kernel(input string kernel_file, input reg [31:0] startup_addr);
    integer file, status, i;
  //  reg [511:0] kernel_data;  // 32-bit data for kernel
    reg    [511:0]   kernel_data    [90-1:0];
    begin
        file = $fopen(kernel_file, "rb");
        if (file == 0) begin
            $display("Error: Cannot open kernel file!");
            $finish;
        end

        $display("Loading kernel to address %0h...", startup_addr);
        for (i = 0; i <6; i = i + 1) begin
          //  status = $fread(kernel_data, file);  // Read 4 bytes (1 word) from the file
             $readmemh(kernel_file, kernel_data);
            // Access memory directly at the word address
            decode.ram0.mem[ 'h1c0 + i] = kernel_data[i];
        end
        $fclose(file);
        $display("Kernel loaded.");
    end
  endtask
    /// eof

    task write_source_buffer(input integer num_points, input reg [31:0] nonce, input reg [31:0] src_addr);
        integer i;
        begin
            $display("Writing source buffer to address %0h...", src_addr);
            for (i = 0; i < num_points; i = i + 1) begin
                // Access each word at src_addr + i directly
              //  decode.ram0.mem[src_addr + i] = (nonce << i) | (nonce & ((1 << i)-1));
              decode.ram0.mem[ src_addr>>6 + i] = nonce ;
            end
            $display("Source buffer written.");
        end
    endtask

     task read_destination_buffer(input integer num_points, input reg [31:0] dst_addr);
        integer i;
        begin
            $display("Reading destination buffer from address %0d...", dst_addr);
            for (i = 0; i < num_points; i = i + 1) begin
                $display("Data[%0d] = %h", i, decode.ram0.mem[dst_addr>>6 + i]);
            end
            $display("Destination buffer read completed.");
        end
    endtask

    task verify_results(input integer num_points, input reg [31:0] nonce, input reg [31:0] dst_addr, output integer errors);
        integer i;
        reg [511:0] expected;
        reg [511:0] actual;
        begin
            errors = 0;
            $display("Verifying results...");
            for (i = 0; i < num_points; i = i + 1) begin
                expected  = nonce ; 
                actual = decode.ram0.mem['h410 + i];

                if (expected !== actual) begin
                    $display("Error at index %0d: expected = %0h, actual = %0h", i, expected, actual);
                    errors = errors + 1;
                end
            end
            if (errors == 0) begin
            $display("********************************");
            $display("********************************");
                $display("Verification PASSED.");
            $display("********************************");
            $display("********************************");
            end
            else
            begin
                $display("Verification FAILED with %0d errors.", errors);
            end
        end
    endtask

    task run_kernel(input integer startup_addr, input integer src_addr, input integer dst_addr);
        begin
            $display("Running kernel...");
            $display("Kernel executed with startup address=%0h, src address=%0h, dst address=%0h.",startup_addr, src_addr, dst_addr);
        end
    endtask

task dcr_write(input integer startup_addr0 ,input integer startup_addr1 , input integer kernel_arg0 , input integer kernel_arg1 );

    begin   
        //writing startup address
        @(negedge clk)

        dcr_wr_addr = 12'h01  ;
        dcr_wr_data  =  startup_addr0 ; 
        dcr_wr_valid =1 ;
            @ (negedge clk)
            dcr_wr_valid =0 ;
            @ (negedge clk)
        dcr_wr_addr = 12'h02  ;
        dcr_wr_data =  startup_addr1 ; 
        dcr_wr_valid =1 ;
            @ (negedge clk)
            dcr_wr_valid =0 ;
            @ (negedge clk)
        dcr_wr_addr = 12'h03  ;
        dcr_wr_data =  startup_addr1 ; 
        dcr_wr_valid =1 ;
            @ (negedge clk)
            dcr_wr_valid =0 ;
            @ (negedge clk)
        dcr_wr_addr = 12'h04  ;
        dcr_wr_data =  startup_addr1 ; 
        dcr_wr_valid =1 ;
            @ (negedge clk)
            dcr_wr_valid =0 ;
            @ (negedge clk)
        dcr_wr_addr = 12'h05  ;
        dcr_wr_data =  startup_addr1 ; 
        dcr_wr_valid =1 ;
            @ (negedge clk)
            dcr_wr_valid =0 ;
        /////////////////////////
          @ (negedge clk)
        dcr_wr_addr = 12'h03  ;
        dcr_wr_data =  kernel_arg0 ; 
        dcr_wr_valid =1 ;
            @ (negedge clk)
            dcr_wr_valid =0 ;
            @ (negedge clk)
        dcr_wr_addr = 12'h04  ;
        dcr_wr_data =  kernel_arg1 ; 
        dcr_wr_valid =1 ;
            @ (negedge clk)
            dcr_wr_valid =0 ;
        //////////////////////////  
    end

endtask 

task wait_busy_signal;
    automatic integer timeout = (24432 / 2) * clkperiod;  // Set a timeout value in clock cycles
    automatic integer count = 0;
begin
    while (busy && count < timeout) begin
        @(posedge clk);
        count++;
    end
    if (count >= timeout) begin
        $display("Error: Timeout waiting for busy to go low");
        $stop;  // Terminate simulation
    end else begin
        $display("Busy went low after %0d cycles", count);
    end
end
endtask

 

endmodule
