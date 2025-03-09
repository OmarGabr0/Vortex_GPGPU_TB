
module ram_decoder #(
    ////////////////////
    parameter AXI_DATA_WIDTH = 512 ,
    parameter AXI_ADDR_WIDTH = 31 ,   // 42
    parameter AXI_TID_WIDTH  = 1 , 
    parameter AXI_NUM_BANKS  = 1 ,
    parameter VIRTUAL_ADDR_WIDTH = 64,
    parameter PHYSICAL_ADDR_WIDTH = 24

)  (

   input wire clk,reset,
///////////////////////////////////////////////////////////////
    
    // from vortex to ram
    
    input    logic                         m_axi_arvalid       [AXI_NUM_BANKS],  
    input    logic                         m_axi_rready        [AXI_NUM_BANKS],   
    input    logic [AXI_ADDR_WIDTH-1:0]    m_axi_awaddr        [AXI_NUM_BANKS],      
    input    logic [AXI_ADDR_WIDTH-1:0]    m_axi_araddr        [AXI_NUM_BANKS],      
    input    logic                         m_axi_awvalid       [AXI_NUM_BANKS],
    input    logic                         m_axi_wvalid        [AXI_NUM_BANKS], 
    input    logic [AXI_DATA_WIDTH-1:0]    m_axi_wdata         [AXI_NUM_BANKS],


    input    logic [1:0]                   m_axi_awburst       [AXI_NUM_BANKS],
    input    logic [2:0]                   m_axi_awsize        [AXI_NUM_BANKS],
    input    logic [7:0]                   m_axi_awlen         [AXI_NUM_BANKS],
    input    logic [AXI_TID_WIDTH-1:0]     m_axi_awid          [AXI_NUM_BANKS], 
    input    logic [AXI_DATA_WIDTH/8-1:0]  m_axi_wstrb        [AXI_NUM_BANKS],
    input    logic [2:0]                   m_axi_awprot       [AXI_NUM_BANKS], 
    input    logic [2:0]                   m_axi_arsize        [AXI_NUM_BANKS], //c
    input    logic [3:0]                   m_axi_awcache       [AXI_NUM_BANKS],
    input    logic [1:0]                   m_axi_awlock        [AXI_NUM_BANKS], // not in ram & c
    input    logic                         m_axi_bready        [AXI_NUM_BANKS],
    input    logic                         m_axi_wlast         [AXI_NUM_BANKS],

    input    logic [3:0]                   m_axi_arcache       [AXI_NUM_BANKS],
    input    logic [2:0]                   m_axi_arprot        [AXI_NUM_BANKS],
    input    logic [1:0]                   m_axi_arlock        [AXI_NUM_BANKS],
    input    logic [1:0]                   m_axi_arburst       [AXI_NUM_BANKS], // assigned to 00 --> Fixed 
    input    logic [7:0]                   m_axi_arlen         [AXI_NUM_BANKS], //c
    input    logic [AXI_TID_WIDTH-1:0]     m_axi_arid          [AXI_NUM_BANKS],
    
    /// from ram to vortex
    output   logic                          m_axi_rvalid       [AXI_NUM_BANKS],
    output   logic [1:0]                    m_axi_bresp        [AXI_NUM_BANKS],
    output   logic [AXI_DATA_WIDTH-1:0]     m_axi_rdata        [AXI_NUM_BANKS],
    output   logic                          m_axi_arready      [AXI_NUM_BANKS],
    output   logic [AXI_TID_WIDTH-1:0]      m_axi_bid          [AXI_NUM_BANKS],
    output   logic                          m_axi_bvalid       [AXI_NUM_BANKS],
    output   logic                          m_axi_wready       [AXI_NUM_BANKS],
    output   logic                          m_axi_awready      [AXI_NUM_BANKS],
    output   logic                          m_axi_rlast        [AXI_NUM_BANKS],

    output    logic [AXI_TID_WIDTH-1:0]     m_axi_rid           [AXI_NUM_BANKS], // output !!
    output    logic [1:0]                   m_axi_rresp         [AXI_NUM_BANKS] //output    // assigned to 00 -> always OK 
    

    
);

localparam ADDR=22 ; 

   /// ASSIGNING OUTPUTS 
   logic                              packed_bvalid0      ;
   logic                              packed_wready0      ;
   logic                              packed_rlast0       ;
   logic   [AXI_TID_WIDTH-1:0]        packed_bid0         ;
   logic                              packed_arready0     ;
   logic                              packed_rvalid0      ;
   logic   [AXI_DATA_WIDTH-1:0]       packed_rdata0       ;
   logic                              packed_awready0     ;
   logic   [1:0]                      packed_bresp0       ;
   logic   [AXI_TID_WIDTH-1:0]        packed_rid0         ;
   logic [1:0]                        packed_rresp0       ;

   logic                         m_axi_arvalid_d      ; 
logic                         m_axi_rready_d       ; 
logic                         m_axi_awvalid_d      ; 
logic                         m_axi_wvalid_d       ; 
logic                         m_axi_bready_d       ;



   always @(*) begin 
            m_axi_awready [0] =  packed_awready0   ;
            m_axi_wready  [0]  =  packed_wready0   ;
            m_axi_bvalid  [0]  =  packed_bvalid0   ;  
            m_axi_bid     [0]  =  packed_bid0      ;
            m_axi_bresp   [0]  =  packed_bresp0    ;
            m_axi_arready [0]  =  packed_arready0  ;    
            m_axi_rvalid  [0]  =  packed_rvalid0   ;  
            m_axi_rdata   [0]  =  packed_rdata0    ; 
            m_axi_rlast   [0]  =  packed_rlast0    ; 
            m_axi_rid     [0]  =  packed_rid0      ;
            m_axi_rresp   [0]  =  packed_rresp0    ;

                   /// read request channel 
            m_axi_arvalid_d = m_axi_arvalid [0]  ;
 
        // reaed response channel 
            m_axi_rready_d =m_axi_rready[0]   ;

      //////////////////////////////////////////////
                  /// write request channel
            m_axi_awvalid_d = m_axi_awvalid [0]  ; 

              // write data channel 
            m_axi_wvalid_d =m_axi_wvalid [0]  ; 

              // write rtesponse 
            m_axi_bready_d =m_axi_bready [0]  ;


   end 
   







/////////////////////////////////////////////////////////////////////////////////



       


/// kernal ram 

  axi_ram #(
                .DATA_WIDTH(AXI_DATA_WIDTH),
                //.ADDR_WIDTH(PHYSICAL_ADDR_WIDTH), // Address width within each RAM
                .ADDR_WIDTH(AXI_ADDR_WIDTH),
                .ID_WIDTH(AXI_TID_WIDTH)
  ) ram0 (
                .clk(clk),
                .rst(reset),
                .s_axi_awready(packed_awready0), 
                .s_axi_wready(packed_wready0),
                .s_axi_bvalid(packed_bvalid0),
                .s_axi_bid(packed_bid0),
                .s_axi_rdata(packed_rdata0),
                .s_axi_rlast(packed_rlast0),
                .s_axi_rvalid(packed_rvalid0), // && mem0_enable ? 
                .s_axi_arready(packed_arready0 ), //  && mem0_enable ? 
                .s_axi_bresp (packed_bresp0),
                .s_axi_rid(packed_rid0),      // output!!
                .s_axi_rresp(packed_rresp0), //output !!
                
                // inputs (from vortex to ram)
                .s_axi_arid(m_axi_arid [0]),
                .s_axi_arlen(m_axi_arlen [0]), 
                .s_axi_arburst(m_axi_arburst[0]),
                .s_axi_arlock (1'b0),//(m_axi_arlock [0]),
                .s_axi_arcache(m_axi_arcache [0]),
                .s_axi_arprot(m_axi_arprot [0]),            
                           //.s_axi_awaddr(m_axi_awaddr[0][PHYSICAL_ADDR_WIDTH-1:0]),  // Connect the address
                .s_axi_araddr((m_axi_araddr[0] ) & {{(AXI_ADDR_WIDTH-24){1'b0}},24'h0FF_FFFF} ),
                .s_axi_awaddr((m_axi_awaddr [0] ) &  {{(AXI_ADDR_WIDTH-24){1'b0}},24'h0FF_FFFF}), 
                .s_axi_awvalid(m_axi_awvalid_d  ),   // shk
                .s_axi_awcache(m_axi_awcache [0]),     
                .s_axi_awlen(8'b0),  //8'b0  //m_axi_awlen  [0]
                .s_axi_awsize(m_axi_awsize [0] ),
                .s_axi_awburst(m_axi_awburst[0]),

                .s_axi_awid(m_axi_awid [0] ),
                .s_axi_wvalid(m_axi_wvalid_d),
                .s_axi_wdata(m_axi_wdata [0] ),   //c input 
                .s_axi_wlast(m_axi_wlast [0] ),
                .s_axi_bready(m_axi_bready_d),
                .s_axi_arvalid(m_axi_arvalid_d),
                .s_axi_rready(m_axi_rready_d),
                .s_axi_awlock(1'b0),
                .s_axi_wstrb(m_axi_wstrb [0]),
                .s_axi_arsize(m_axi_arsize[0]),
                .s_axi_awprot(m_axi_awprot [0])
                
                

            );

endmodule 
