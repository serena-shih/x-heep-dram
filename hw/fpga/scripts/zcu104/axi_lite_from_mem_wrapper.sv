// Wrapper for axi_lite_from_mem that provides concrete parameter types and
// exposes a standard AXI4-Lite master port for Vivado IP packaging.
//
// The original module uses parameter type axi_req_t / axi_rsp_t (structs).
// This wrapper defines compatible packed struct typedefs and connects the
// split AXI4-Lite signals (AW/W/AR/B/R) to those structs. The AXI port is
// annotated with X_INTERFACE_* attributes so Vivado recognizes it.
//
// Note: The wrapper exposes an AXI4-Lite *master* interface named M_AXI.
// When connecting to a PS (AXI full/master) in a block design, Vivado's
// connection automation / SmartConnect will be able to insert adapters
// / interconnects as needed.

`timescale 1ns / 1ps

module axi_lite_from_mem_wrapper #(
    parameter int unsigned MemAddrWidth = 32,
    parameter int unsigned AxiAddrWidth = 32,
    parameter int unsigned DataWidth    = 32,
    parameter int unsigned MaxRequests  = 4,
    parameter int unsigned AxiProt      = 3'b000
) (
    // Clock / Reset
    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_CLK, ASSOCIATED_BUSIF M_AXI, ASSOCIATED_RESET rst_ni" *)
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M_AXI_CLK CLK" *)
    input logic clk_i,

    (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI_RST, POLARITY ACTIVE_LOW" *)
        (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 M_AXI_RST RST" *)
    input logic rst_ni,

    // Memory slave port (unchanged)
    input  logic                    mem_req_i,
    input  logic [MemAddrWidth-1:0] mem_addr_i,
    input  logic                    mem_we_i,
    input  logic [   DataWidth-1:0] mem_wdata_i,
    input  logic [ DataWidth/8-1:0] mem_be_i,
    output logic                    mem_gnt_o,
    output logic                    mem_rsp_valid_o,
    output logic [   DataWidth-1:0] mem_rsp_rdata_o,
    output logic                    mem_rsp_error_o,

    // AXI4-Lite MASTER port (split signals) - named M_AXI
    // AW
    output logic [AxiAddrWidth-1:0] M_AXI_AWADDR,
    output logic [             2:0] M_AXI_AWPROT,
    output logic                    M_AXI_AWVALID,
    input  logic                    M_AXI_AWREADY,
    // W
    output logic [   DataWidth-1:0] M_AXI_WDATA,
    output logic [ DataWidth/8-1:0] M_AXI_WSTRB,
    output logic                    M_AXI_WVALID,
    input  logic                    M_AXI_WREADY,
    // B
    input  logic [             1:0] M_AXI_BRESP,
    input  logic                    M_AXI_BVALID,
    output logic                    M_AXI_BREADY,
    // AR
    output logic [AxiAddrWidth-1:0] M_AXI_ARADDR,
    output logic [             2:0] M_AXI_ARPROT,
    output logic                    M_AXI_ARVALID,
    input  logic                    M_AXI_ARREADY,
    // R
    input  logic [   DataWidth-1:0] M_AXI_RDATA,
    input  logic [             1:0] M_AXI_RRESP,
    input  logic                    M_AXI_RVALID,
    output logic                    M_AXI_RREADY
);

  // ------------------------------------------------------------------------
  // Local struct typedefs to satisfy `parameter type axi_req_t / axi_rsp_t`
  // These match the fields referenced by the original axi_lite_from_mem.
  // ------------------------------------------------------------------------
  typedef struct packed {
    logic [AxiAddrWidth-1:0] addr;
    logic [2:0]              prot;
  } aw_s_t;

  typedef struct packed {
    logic [DataWidth-1:0]   data;
    logic [DataWidth/8-1:0] strb;
  } w_s_t;

  typedef struct packed {logic [1:0] resp;} b_s_t;

  typedef struct packed {
    logic [AxiAddrWidth-1:0] addr;
    logic [2:0]              prot;
  } ar_s_t;

  typedef struct packed {
    logic [DataWidth-1:0] data;
    logic [1:0]           resp;
  } r_s_t;

  typedef struct {
    aw_s_t aw;
    logic  aw_valid;
    w_s_t  w;
    logic  w_valid;
    b_s_t  b;         // only b.ready used from request side
    logic  b_ready;
    ar_s_t ar;
    logic  ar_valid;
    logic  r_ready;
  } axi_req_t_local;

  typedef struct {
    logic aw_ready;
    logic w_ready;
    logic b_valid;
    b_s_t b;
    logic r_valid;
    r_s_t r;
    logic ar_ready;
  } axi_rsp_t_local;

  // Signals to connect to the original module (struct ports)
  axi_req_t_local axi_req_o_s;
  axi_rsp_t_local axi_rsp_i_s;

  // ------------------------------------------------------------------------
  // Map wrapper's split AXI signals to the structs expected by axi_lite_from_mem
  // (axi_req_o  -> outputs from core -> external M_AXI outputs)
  // (axi_rsp_i  -> inputs to core  <- external M_AXI inputs)
  // ------------------------------------------------------------------------

  // AW channel: core drives aw.addr, aw.prot, aw_valid -> map to M_AXI AW*
  assign M_AXI_AWADDR = axi_req_o_s.aw.addr;
  assign M_AXI_AWPROT = axi_req_o_s.aw.prot;
  assign M_AXI_AWVALID = axi_req_o_s.aw_valid;
  // External AWREADY feeds core's response struct
  assign axi_rsp_i_s.aw_ready = M_AXI_AWREADY;

  // W channel:
  assign M_AXI_WDATA = axi_req_o_s.w.data;
  assign M_AXI_WSTRB = axi_req_o_s.w.strb;
  assign M_AXI_WVALID = axi_req_o_s.w_valid;
  assign axi_rsp_i_s.w_ready = M_AXI_WREADY;

  // B channel: external gives BRESP/BVALID -> feed core's axi_rsp_i_s
  assign axi_rsp_i_s.b_valid = M_AXI_BVALID;
  assign axi_rsp_i_s.b.resp = M_AXI_BRESP;
  // core indicates ready to accept B
  assign M_AXI_BREADY = axi_req_o_s.b_ready;

  // AR channel:
  assign M_AXI_ARADDR = axi_req_o_s.ar.addr;
  assign M_AXI_ARPROT = axi_req_o_s.ar.prot;
  assign M_AXI_ARVALID = axi_req_o_s.ar_valid;
  assign axi_rsp_i_s.ar_ready = M_AXI_ARREADY;

  // R channel:
  assign axi_rsp_i_s.r_valid = M_AXI_RVALID;
  assign axi_rsp_i_s.r.data = M_AXI_RDATA;
  assign axi_rsp_i_s.r.resp = M_AXI_RRESP;
  assign M_AXI_RREADY = axi_req_o_s.r_ready;

  // ------------------------------------------------------------------------
  // Instantiate the original parameterized module and bind types / params
  // ------------------------------------------------------------------------
  axi_lite_from_mem #(
      .MemAddrWidth(MemAddrWidth),
      .AxiAddrWidth(AxiAddrWidth),
      .DataWidth   (DataWidth),
      .MaxRequests (MaxRequests),
      .AxiProt     (AxiProt),
      // bind the parameter types to local typedefs
      .axi_req_t   (axi_req_t_local),
      .axi_rsp_t   (axi_rsp_t_local),
      .mem_addr_t  (logic [MemAddrWidth-1:0]),
      .axi_addr_t  (logic [AxiAddrWidth-1:0]),
      .data_t      (logic [DataWidth-1:0]),
      .strb_t      (logic [DataWidth/8-1:0])
  ) i_axi_lite_from_mem (
      .clk_i          (clk_i),
      .rst_ni         (rst_ni),
      .mem_req_i      (mem_req_i),
      .mem_addr_i     (mem_addr_i),
      .mem_we_i       (mem_we_i),
      .mem_wdata_i    (mem_wdata_i),
      .mem_be_i       (mem_be_i),
      .mem_gnt_o      (mem_gnt_o),
      .mem_rsp_valid_o(mem_rsp_valid_o),
      .mem_rsp_rdata_o(mem_rsp_rdata_o),
      .mem_rsp_error_o(mem_rsp_error_o),
      // connect struct-style axi ports
      .axi_req_o      (axi_req_o_s),
      .axi_rsp_i      (axi_rsp_i_s)
  );

endmodule : axi_lite_from_mem_wrapper
