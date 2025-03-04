
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
    input    logic [1:0]                   m_axi_arburst       [AXI_NUM_BANKS],
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
    output    logic [1:0]                   m_axi_rresp         [AXI_NUM_BANKS] //output   
    

    
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

   //////////////////////////////////////////////////////
   logic                              packed_bvalid1     ;
   logic                              packed_wready1     ;
   logic                              packed_rlast1      ;
   logic   [AXI_TID_WIDTH-1:0]        packed_bid1        ;
   logic                              packed_arready1    ;
   logic                              packed_rvalid1     ;
   logic   [AXI_DATA_WIDTH-1:0]       packed_rdata1      ;
   logic                              packed_awready1    ;
   logic   [1:0]                      packed_bresp1      ;
   logic   [AXI_TID_WIDTH-1:0]        packed_rid1        ;
   logic [1:0]                        packed_rresp1      ;

/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// DECODER ////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////// 

logic                         m_axi_arvalid_d      ; // [AXI_NUM_BANKS] ;
logic                         m_axi_rready_d       ; // [AXI_NUM_BANKS] ;
//logic [AXI_ADDR_WIDTH-1:0]    m_axi_awaddr_d       ; // [AXI_NUM_BANKS] ;
//logic [AXI_ADDR_WIDTH-1:0]    m_axi_araddr_d       ; // [AXI_NUM_BANKS] ;
logic                         m_axi_awvalid_d      ; // [AXI_NUM_BANKS];
logic                         m_axi_wvalid_d       ; // [AXI_NUM_BANKS] ;
//logic [AXI_DATA_WIDTH-1:0]    m_axi_wdata_d        ; // [AXI_NUM_BANKS];

//logic [1:0]                   m_axi_rresp_d         ;// [AXI_NUM_BANKS];
//logic [AXI_TID_WIDTH-1:0]     m_axi_awid_d          ;// [AXI_NUM_BANKS];
//logic [AXI_DATA_WIDTH/8-1:0]  m_axi_wstrb_d         ;// [AXI_NUM_BANKS];
logic                         m_axi_bready_d        ;// [AXI_NUM_BANKS];
//logic                         m_axi_wlast_d         ;// [AXI_NUM_BANKS];



////////////////////////////////////////////////////////////////////////
logic                         m_axi_arvalid_d1      ; // [AXI_NUM_BANKS]; 
logic                         m_axi_rready_d1       ; // [AXI_NUM_BANKS]; 
//logic [AXI_ADDR_WIDTH-1:0]    m_axi_awaddr_d1       ; // [AXI_NUM_BANKS]; 
//logic [AXI_ADDR_WIDTH-1:0]    m_axi_araddr_d1       ; // [AXI_NUM_BANKS]; 
logic                         m_axi_awvalid_d1      ; // [AXI_NUM_BANKS];
logic                         m_axi_wvalid_d1       ; // [AXI_NUM_BANKS]; 
//logic [AXI_DATA_WIDTH-1:0]    m_axi_wdata_d1        ; // [AXI_NUM_BANKS];

//logic [1:0]                   m_axi_rresp_d1        ; // [AXI_NUM_BANKS];
//logic [AXI_TID_WIDTH-1:0]     m_axi_awid_d1         ; // [AXI_NUM_BANKS];
//logic [AXI_DATA_WIDTH/8-1:0]  m_axi_wstrb_d1        ; // [AXI_NUM_BANKS];
logic                         m_axi_bready_d1       ; // [AXI_NUM_BANKS];
//logic                         m_axi_wlast_d1        ; // [AXI_NUM_BANKS];



  reg from_r1,to_r1,from_r2,to_r2;
///////////////////////////////////
/////// first Trail : Using olny 2 rams , one for kernal and other for arg,src,dest
/////// each ram would have memory address  masked to 000000000
/* 
      always @(*) begin 
             // 80,000,000  --> AXI_ADDR_WIDTH-1 =1 
             // kernal ram
             to_r1   = (m_axi_awaddr[31]) ? 1 : 0;
             from_r1 = (m_axi_araddr[31]) ? 1 : 0;
            // 0x10000 
            //kernal arg ram 
             to_r2   = (!m_axi_awaddr[31] && m_axi_awaddr[16]) ? 1 : 0;
            from_r2 = (!m_axi_araddr[31] && m_axi_araddr[16]) ? 1 : 0;
      end
*/
//always @(*) begin
//////////////////////////////// using to from mwthod /////////////////////////////////////

always @(posedge clk) begin   
    
    if (m_axi_awaddr[0][31])  // 0x8000_0000
        to_r1 = 1;
      else 
        to_r1 = 0;

    if (m_axi_araddr[0][31]) // 0x8000_0000
        from_r1 = 1;
      else 
        from_r1 = 0;

    if (!m_axi_awaddr[0][31] && m_axi_awaddr[0][16]) // 0x12000 and not 0x8000_0000
        to_r2 = 1;
      else
       to_r2 = 0;
    if (!m_axi_araddr[0][31] && m_axi_araddr[0][16]) // 0x12000 and not 0x8000_0000
        from_r2 = 1;
        else
        from_r2 = 0;
end
/////////////////////////// Try2: Only Valid & ready signal is important /////////////////////////////////////////////////////////////
////////////////////////////////
//decoding slave output 
always @(*) begin
//always @(posedge clk) begin  
    case ( {to_r1||from_r1 , to_r2||from_r2})
     2'b10 : begin 
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
     end
     2'b01: begin 
            m_axi_awready [0]  =  packed_awready1  ;
            m_axi_wready  [0]  =  packed_wready1   ;
            m_axi_bvalid  [0]  =  packed_bvalid1   ;  
            m_axi_bid     [0]  =  packed_bid1      ;
            m_axi_bresp   [0]  =  packed_bresp1    ;
            m_axi_arready [0]  =  packed_arready1  ;    
            m_axi_rvalid  [0]  =  packed_rvalid1   ;  
            m_axi_rdata   [0]  =  packed_rdata1    ; 
            m_axi_rlast   [0]  =  packed_rlast1    ; 
            m_axi_rid     [0]  =  packed_rid1      ;
            m_axi_rresp   [0]  =  packed_rresp1    ;
     end
     default:  begin 
            m_axi_awready  [0]  =  packed_awready0  ;
            m_axi_wready   [0]  =  packed_wready0   ;
            m_axi_bvalid   [0]  =  packed_bvalid0   ;  
            m_axi_bid      [0]  =  packed_bid0      ;
            m_axi_bresp    [0]  =  packed_bresp0    ;
            m_axi_arready  [0]  =  packed_arready0  ;    
            m_axi_rvalid   [0]  =  packed_rvalid0   ;  
            m_axi_rdata    [0]  =  packed_rdata0    ; 
            m_axi_rlast    [0]  =  packed_rlast0    ; 
            m_axi_rid      [0]  =  packed_rid0      ;
            m_axi_rresp    [0]  =  packed_rresp0    ;
     end
    endcase
// Read request + read data handling 
    case({from_r1,from_r2}) 
    2'b10: begin 
            /// read request channel 
        m_axi_arvalid_d = m_axi_arvalid [0]  ;
        m_axi_arvalid_d1 = 'b0 ;
           // reaed response channel 
        m_axi_rready_d =m_axi_rready[0]   ;
        m_axi_rready_d1 ='b0 ;
    end
   2'b01: begin 

            /// read request channel 
        m_axi_arvalid_d1 =m_axi_arvalid [0]  ;
        m_axi_arvalid_d  = 'b0 ;

           // read response channel 
        m_axi_rready_d1 =m_axi_rready  [0] ;
        m_axi_rready_d  ='b0 ;
   end
   default: begin 
       /// read request channel 
        m_axi_arvalid_d =m_axi_arvalid [0]  ;
        m_axi_arvalid_d1  = 'b0 ;
           // reaed response channel 
        m_axi_rready_d =m_axi_rready [0]  ;
        m_axi_rready_d1  ='b0 ;
   end 
    endcase
 // Write request + write response +write data handling    
     case({to_r1,to_r2}) 
     2'b10: begin 
            /// write request channel
            m_axi_awvalid_d = m_axi_awvalid [0]  ; 
            m_axi_awvalid_d1  = 'b0; 
              // write data channel 
            m_axi_wvalid_d =m_axi_wvalid [0]  ; 
            m_axi_wvalid_d1  = 'b0 ; 
              // write rtesponse 
            m_axi_bready_d =m_axi_bready [0]  ;
            m_axi_bready_d1   ='b0 ;
     end
    2'b01: begin 
               /// write request channel
            m_axi_awvalid_d1 = m_axi_awvalid [0]  ; 
            m_axi_awvalid_d  = 'b0; 
              // write data channel 
            m_axi_wvalid_d1 =m_axi_wvalid [0]  ; 
            m_axi_wvalid_d  = 'b0 ; 
              // write rtesponse 
            m_axi_bready_d1 =m_axi_bready [0]  ;
            m_axi_bready_d  ='b0 ;
     end
 default: begin 
            /// write request channel
            m_axi_awvalid_d = m_axi_awvalid [0]  ; 
            m_axi_awvalid_d1 = 'b0; 
              // write data channel 
            m_axi_wvalid_d =m_axi_wvalid [0]  ; 
            m_axi_wvalid_d1 = 'b0 ; 
              // write rtesponse 
            m_axi_bready_d =m_axi_bready [0]  ;
            m_axi_bready_d1 ='b0 ;
 end

 endcase


end
 
/*
 //////////////////////////////// using direct register bits values /////////////////////////////////////

 always @(posedge clk) begin  
    case ( {m_axi_awaddr[31]||m_axi_araddr , (!m_axi_awaddr[31] && m_axi_awaddr[16])||(!m_axi_araddr[31] && m_axi_araddr[16])})
     2'b10 : begin 
            m_axi_awready [0] =  packed_awready0  ;
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
     end
     2'b01: begin 
            m_axi_awready [0]  =  packed_awready1  ;
            m_axi_wready  [0]  =  packed_wready1   ;
            m_axi_bvalid  [0]  =  packed_bvalid1   ;  
            m_axi_bid     [0]  =  packed_bid1      ;
            m_axi_bresp   [0]  =  packed_bresp1    ;
            m_axi_arready [0]  =  packed_arready1  ;    
            m_axi_rvalid  [0]  =  packed_rvalid1   ;  
            m_axi_rdata   [0]  =  packed_rdata1    ; 
            m_axi_rlast   [0]  =  packed_rlast1    ; 
            m_axi_rid     [0]  =  packed_rid1      ;
            m_axi_rresp   [0]  =  packed_rresp1    ;
     end
     default:  begin 
            m_axi_awready  [0]  =  packed_awready0  ;
            m_axi_wready   [0]  =  packed_wready0   ;
            m_axi_bvalid   [0]  =  packed_bvalid0   ;  
            m_axi_bid      [0]  =  packed_bid0      ;
            m_axi_bresp    [0]  =  packed_bresp0    ;
            m_axi_arready  [0]  =  packed_arready0  ;    
            m_axi_rvalid   [0]  =  packed_rvalid0   ;  
            m_axi_rdata    [0]  =  packed_rdata0    ; 
            m_axi_rlast    [0]  =  packed_rlast0    ; 
            m_axi_rid      [0]  =  packed_rid0      ;
            m_axi_rresp    [0]  =  packed_rresp0    ;
     end
    endcase
// Read request + read data handling 
    case({m_axi_araddr,(!m_axi_araddr[31] && m_axi_araddr[16])}) 
    2'b10: begin 
            /// read request channel 
        m_axi_arvalid_d = m_axi_arvalid [0]  ;
        m_axi_arvalid_d1 = 'b0 ;
           // reaed response channel 
        m_axi_rready_d =m_axi_rready[0]   ;
        m_axi_rready_d1 ='b0 ;
    end
   2'b01: begin 

            /// read request channel 
        m_axi_arvalid_d1 =m_axi_arvalid [0]  ;
        m_axi_arvalid_d  = 'b0 ;

           // read response channel 
        m_axi_rready_d1 =m_axi_rready  [0] ;
        m_axi_rready_d  ='b0 ;
   end
   default: begin 
       /// read request channel 
        m_axi_arvalid_d =m_axi_arvalid [0]  ;
        m_axi_arvalid_d1  = 'b0 ;
           // reaed response channel 
        m_axi_rready_d =m_axi_rready [0]  ;
        m_axi_rready_d1  ='b0 ;
   end 
    endcase
 // Write request + write response +write data handling    
     case({m_axi_awaddr[31],(!m_axi_awaddr[31] && m_axi_awaddr[16])}) 
     2'b10: begin 
            /// write request channel
            m_axi_awvalid_d = m_axi_awvalid [0]  ; 
            m_axi_awvalid_d1  = 'b0; 
              // write data channel 
            m_axi_wvalid_d =m_axi_wvalid [0]  ; 
            m_axi_wvalid_d1  = 'b0 ; 
              // write rtesponse 
            m_axi_bready_d =m_axi_bready [0]  ;
            m_axi_bready_d1   ='b0 ;
     end
    2'b01: begin 
               /// write request channel
            m_axi_awvalid_d1 = m_axi_awvalid [0]  ; 
            m_axi_awvalid_d  = 'b0; 
              // write data channel 
            m_axi_wvalid_d1 =m_axi_wvalid [0]  ; 
            m_axi_wvalid_d  = 'b0 ; 
              // write rtesponse 
            m_axi_bready_d1 =m_axi_bready [0]  ;
            m_axi_bready_d  ='b0 ;
     end
 default: begin 
            /// write request channel
            m_axi_awvalid_d = m_axi_awvalid [0]  ; 
            m_axi_awvalid_d1 = 'b0; 
              // write data channel 
            m_axi_wvalid_d =m_axi_wvalid [0]  ; 
            m_axi_wvalid_d1 = 'b0 ; 
              // write rtesponse 
            m_axi_bready_d =m_axi_bready [0]  ;
            m_axi_bready_d1 ='b0 ;
 end

 endcase


end
   
 */     
      



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
                .s_axi_araddr(m_axi_araddr[0]  & {{(AXI_ADDR_WIDTH-24){1'b0}},24'h0FF_FFFF} ),
                .s_axi_awaddr(m_axi_awaddr [0] &  {{(AXI_ADDR_WIDTH-24){1'b0}},24'h0FF_FFFF}), 
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

    //// arg ram
  axi_ram #(
                .DATA_WIDTH(AXI_DATA_WIDTH),
                //.ADDR_WIDTH(PHYSICAL_ADDR_WIDTH), // Address width within each RAM
                .ADDR_WIDTH(AXI_ADDR_WIDTH),
                .ID_WIDTH(AXI_TID_WIDTH)
  ) ram1 (
                .clk(clk),
                .rst(reset),
                .s_axi_awready(packed_awready1), 
                .s_axi_wready(packed_wready1),
                .s_axi_bvalid(packed_bvalid1),
                .s_axi_bid(packed_bid1),
                .s_axi_rdata(packed_rdata1),
                .s_axi_rlast(packed_rlast1),
                .s_axi_rvalid(packed_rvalid1), // && mem0_enable ? 
                .s_axi_arready(packed_arready1 ), //  && mem0_enable ? 
                .s_axi_bresp (packed_bresp1),
                .s_axi_rid(packed_rid1),      // output!!
                .s_axi_rresp(packed_rresp1), //output !!
                
                // inputs (from vortex to ram)
                .s_axi_arid(m_axi_arid [0]),
                .s_axi_arlen(m_axi_arlen [0]), 
                .s_axi_arburst(m_axi_arburst[0]),
                .s_axi_arlock (1'b0), //(m_axi_arlock [0]),
                .s_axi_arcache(m_axi_arcache [0]),
                .s_axi_arprot(m_axi_arprot [0]),            
                           //.s_axi_awaddr(m_axi_awaddr[0][PHYSICAL_ADDR_WIDTH-1:0]),  
                .s_axi_araddr(m_axi_araddr[0]   &  {{(AXI_ADDR_WIDTH-24){1'b0}},24'h0FF_FFFF} ),
                .s_axi_awaddr(m_axi_awaddr [0]  &  {{(AXI_ADDR_WIDTH-24){1'b0}},24'h0FF_FFFF}), 
                .s_axi_awvalid(m_axi_awvalid_d1  ),   // shk
                .s_axi_awcache(m_axi_awcache [0]),    
                .s_axi_awid(m_axi_awid [0]),
                .s_axi_awlen(8'b0),
                .s_axi_awsize(m_axi_awsize [0] ),
                .s_axi_awburst(m_axi_awburst[0]),
                .s_axi_wvalid(m_axi_wvalid_d1),
                .s_axi_wdata(m_axi_wdata [0]),
                .s_axi_wlast(m_axi_wlast [0]),
                .s_axi_bready(m_axi_bready_d1),
                .s_axi_arvalid(m_axi_arvalid_d1),
                .s_axi_rready(m_axi_rready_d1),
                .s_axi_awlock(1'b0),
                .s_axi_wstrb(m_axi_wstrb [0]),
                .s_axi_arsize(m_axi_arsize[0]),
                .s_axi_awprot(m_axi_awprot [0])
                
                

            );

  // Address translation function
  function logic [PHYSICAL_ADDR_WIDTH-1:0] translate_address(
      input logic [VIRTUAL_ADDR_WIDTH-1:0] vaddr);
      translate_address = vaddr & 32'h003F_FFFF;  // Mask to fit within 4MB
  endfunction

  // Apply translation for each bank



endmodule 
/*
 for (genvar ram_id = 0; ram_id < 3; ++ram_id) begin : g_ram
        VX_AXI_if  per_ram_AXI_if( .AXI_NUM_BANKS(AXI_NUM_BANKS));


   

    
 
    assign      per_ram_AXI_if.m_axi_bvalid   [0]  =  packed_bvalid    ;  
    assign      per_ram_AXI_if.m_axi_wready   [0]  =  packed_wready    ;  
    assign      per_ram_AXI_if.m_axi_rlast    [0]  =  packed_rlast     ;
    assign      per_ram_AXI_if.m_axi_bid      [0]  =  packed_bid       ;
    assign      per_ram_AXI_if.m_axi_arready  [0]  =  packed_arready   ;
    assign      per_ram_AXI_if.m_axi_rvalid   [0]  =  packed_rvalid    ;
    assign      per_ram_AXI_if.m_axi_rdata    [0]  =  packed_rdata     ;
    assign      per_ram_AXI_if.m_axi_awready  [0]  =  packed_awready   ;
    assign      per_ram_AXI_if.m_axi_bresp    [0][1:0]  =  packed_bresp     ;
 end

*/
