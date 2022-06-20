module Queue8192(
  input         clock,
  input         reset,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [31:0] io_enq_bits,
  input         io_deq_ready,
  output        io_deq_valid,
  output [31:0] io_deq_bits
);
  reg [31:0] _T [0:8191]; // @[Decoupled.scala 209:24]
  reg [31:0] _RAND_0;
  wire [31:0] _T__T_18_data; // @[Decoupled.scala 209:24]
  wire [12:0] _T__T_18_addr; // @[Decoupled.scala 209:24]
  wire [31:0] _T__T_10_data; // @[Decoupled.scala 209:24]
  wire [12:0] _T__T_10_addr; // @[Decoupled.scala 209:24]
  wire  _T__T_10_mask; // @[Decoupled.scala 209:24]
  wire  _T__T_10_en; // @[Decoupled.scala 209:24]
  reg [12:0] value; // @[Counter.scala 29:33]
  reg [31:0] _RAND_1;
  reg [12:0] value_1; // @[Counter.scala 29:33]
  reg [31:0] _RAND_2;
  reg  _T_1; // @[Decoupled.scala 212:35]
  reg [31:0] _RAND_3;
  wire  _T_2; // @[Decoupled.scala 214:41]
  wire  _T_3; // @[Decoupled.scala 215:36]
  wire  _T_4; // @[Decoupled.scala 215:33]
  wire  _T_5; // @[Decoupled.scala 216:32]
  wire  _T_6; // @[Decoupled.scala 40:37]
  wire  _T_8; // @[Decoupled.scala 40:37]
  wire [12:0] _T_12; // @[Counter.scala 39:22]
  wire [12:0] _T_14; // @[Counter.scala 39:22]
  wire  _T_15; // @[Decoupled.scala 227:16]
  assign _T__T_18_addr = value_1;
  assign _T__T_18_data = _T[_T__T_18_addr]; // @[Decoupled.scala 209:24]
  assign _T__T_10_data = io_enq_bits;
  assign _T__T_10_addr = value;
  assign _T__T_10_mask = 1'h1;
  assign _T__T_10_en = io_enq_ready & io_enq_valid;
  assign _T_2 = value == value_1; // @[Decoupled.scala 214:41]
  assign _T_3 = ~_T_1; // @[Decoupled.scala 215:36]
  assign _T_4 = _T_2 & _T_3; // @[Decoupled.scala 215:33]
  assign _T_5 = _T_2 & _T_1; // @[Decoupled.scala 216:32]
  assign _T_6 = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  assign _T_8 = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign _T_12 = value + 13'h1; // @[Counter.scala 39:22]
  assign _T_14 = value_1 + 13'h1; // @[Counter.scala 39:22]
  assign _T_15 = _T_6 != _T_8; // @[Decoupled.scala 227:16]
  assign io_enq_ready = ~_T_5; // @[Decoupled.scala 232:16]
  assign io_deq_valid = ~_T_4; // @[Decoupled.scala 231:16]
  assign io_deq_bits = _T__T_18_data; // @[Decoupled.scala 233:15]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
  _RAND_0 = {1{`RANDOM}};
  `ifdef RANDOMIZE_MEM_INIT
  for (initvar = 0; initvar < 8192; initvar = initvar+1)
    _T[initvar] = _RAND_0[31:0];
  `endif // RANDOMIZE_MEM_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  value = _RAND_1[12:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{`RANDOM}};
  value_1 = _RAND_2[12:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  _T_1 = _RAND_3[0:0];
  `endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`endif // SYNTHESIS
  always @(posedge clock) begin
    if(_T__T_10_en & _T__T_10_mask) begin
      _T[_T__T_10_addr] <= _T__T_10_data; // @[Decoupled.scala 209:24]
    end
    if (reset) begin
      value <= 13'h0;
    end else if (_T_6) begin
      value <= _T_12;
    end
    if (reset) begin
      value_1 <= 13'h0;
    end else if (_T_8) begin
      value_1 <= _T_14;
    end
    if (reset) begin
      _T_1 <= 1'h0;
    end else if (_T_15) begin
      _T_1 <= _T_6;
    end
  end
endmodule
module Queue8192_1(
  input   clock,
  input   reset,
  output  io_enq_ready,
  input   io_enq_valid,
  input   io_enq_bits,
  input   io_deq_ready,
  output  io_deq_valid,
  output  io_deq_bits
);
  reg  _T [0:8191]; // @[Decoupled.scala 209:24]
  reg [31:0] _RAND_0;
  wire  _T__T_18_data; // @[Decoupled.scala 209:24]
  wire [12:0] _T__T_18_addr; // @[Decoupled.scala 209:24]
  wire  _T__T_10_data; // @[Decoupled.scala 209:24]
  wire [12:0] _T__T_10_addr; // @[Decoupled.scala 209:24]
  wire  _T__T_10_mask; // @[Decoupled.scala 209:24]
  wire  _T__T_10_en; // @[Decoupled.scala 209:24]
  reg [12:0] value; // @[Counter.scala 29:33]
  reg [31:0] _RAND_1;
  reg [12:0] value_1; // @[Counter.scala 29:33]
  reg [31:0] _RAND_2;
  reg  _T_1; // @[Decoupled.scala 212:35]
  reg [31:0] _RAND_3;
  wire  _T_2; // @[Decoupled.scala 214:41]
  wire  _T_3; // @[Decoupled.scala 215:36]
  wire  _T_4; // @[Decoupled.scala 215:33]
  wire  _T_5; // @[Decoupled.scala 216:32]
  wire  _T_6; // @[Decoupled.scala 40:37]
  wire  _T_8; // @[Decoupled.scala 40:37]
  wire [12:0] _T_12; // @[Counter.scala 39:22]
  wire [12:0] _T_14; // @[Counter.scala 39:22]
  wire  _T_15; // @[Decoupled.scala 227:16]
  assign _T__T_18_addr = value_1;
  assign _T__T_18_data = _T[_T__T_18_addr]; // @[Decoupled.scala 209:24]
  assign _T__T_10_data = io_enq_bits;
  assign _T__T_10_addr = value;
  assign _T__T_10_mask = 1'h1;
  assign _T__T_10_en = io_enq_ready & io_enq_valid;
  assign _T_2 = value == value_1; // @[Decoupled.scala 214:41]
  assign _T_3 = ~_T_1; // @[Decoupled.scala 215:36]
  assign _T_4 = _T_2 & _T_3; // @[Decoupled.scala 215:33]
  assign _T_5 = _T_2 & _T_1; // @[Decoupled.scala 216:32]
  assign _T_6 = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  assign _T_8 = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign _T_12 = value + 13'h1; // @[Counter.scala 39:22]
  assign _T_14 = value_1 + 13'h1; // @[Counter.scala 39:22]
  assign _T_15 = _T_6 != _T_8; // @[Decoupled.scala 227:16]
  assign io_enq_ready = ~_T_5; // @[Decoupled.scala 232:16]
  assign io_deq_valid = ~_T_4; // @[Decoupled.scala 231:16]
  assign io_deq_bits = _T__T_18_data; // @[Decoupled.scala 233:15]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
  _RAND_0 = {1{`RANDOM}};
  `ifdef RANDOMIZE_MEM_INIT
  for (initvar = 0; initvar < 8192; initvar = initvar+1)
    _T[initvar] = _RAND_0[0:0];
  `endif // RANDOMIZE_MEM_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  value = _RAND_1[12:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_2 = {1{`RANDOM}};
  value_1 = _RAND_2[12:0];
  `endif // RANDOMIZE_REG_INIT
  `ifdef RANDOMIZE_REG_INIT
  _RAND_3 = {1{`RANDOM}};
  _T_1 = _RAND_3[0:0];
  `endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`endif // SYNTHESIS
  always @(posedge clock) begin
    if(_T__T_10_en & _T__T_10_mask) begin
      _T[_T__T_10_addr] <= _T__T_10_data; // @[Decoupled.scala 209:24]
    end
    if (reset) begin
      value <= 13'h0;
    end else if (_T_6) begin
      value <= _T_12;
    end
    if (reset) begin
      value_1 <= 13'h0;
    end else if (_T_8) begin
      value_1 <= _T_14;
    end
    if (reset) begin
      _T_1 <= 1'h0;
    end else if (_T_15) begin
      _T_1 <= _T_6;
    end
  end
endmodule
module QueueLastGbemac8192(
  input         clock,
  input         reset,
  output        io_full,
  input         io_deq_ready,
  output        io_deq_valid,
  output [31:0] io_deq_bits,
  output        io_enq_ready,
  input         io_enq_valid,
  input  [31:0] io_enq_bits,
  input         io_enq_last,
  output        io_deq_last
);
  wire  q_clock; // @[QueueGbemac.scala 79:17]
  wire  q_reset; // @[QueueGbemac.scala 79:17]
  wire  q_io_enq_ready; // @[QueueGbemac.scala 79:17]
  wire  q_io_enq_valid; // @[QueueGbemac.scala 79:17]
  wire [31:0] q_io_enq_bits; // @[QueueGbemac.scala 79:17]
  wire  q_io_deq_ready; // @[QueueGbemac.scala 79:17]
  wire  q_io_deq_valid; // @[QueueGbemac.scala 79:17]
  wire [31:0] q_io_deq_bits; // @[QueueGbemac.scala 79:17]
  wire  q_last_clock; // @[QueueGbemac.scala 81:22]
  wire  q_last_reset; // @[QueueGbemac.scala 81:22]
  wire  q_last_io_enq_ready; // @[QueueGbemac.scala 81:22]
  wire  q_last_io_enq_valid; // @[QueueGbemac.scala 81:22]
  wire  q_last_io_enq_bits; // @[QueueGbemac.scala 81:22]
  wire  q_last_io_deq_ready; // @[QueueGbemac.scala 81:22]
  wire  q_last_io_deq_valid; // @[QueueGbemac.scala 81:22]
  wire  q_last_io_deq_bits; // @[QueueGbemac.scala 81:22]
  reg [31:0] counter; // @[QueueGbemac.scala 83:24]
  reg [31:0] _RAND_0;
  wire  _T; // @[Decoupled.scala 40:37]
  wire  _T_1; // @[Decoupled.scala 40:37]
  wire  _T_2; // @[QueueGbemac.scala 86:25]
  wire  _T_3; // @[QueueGbemac.scala 86:22]
  wire [31:0] _T_5; // @[QueueGbemac.scala 87:24]
  wire  _T_7; // @[QueueGbemac.scala 88:14]
  wire  _T_9; // @[QueueGbemac.scala 88:29]
  wire [31:0] _T_11; // @[QueueGbemac.scala 89:24]
  wire  _T_12; // @[QueueGbemac.scala 95:37]
  Queue8192 q ( // @[QueueGbemac.scala 79:17]
    .clock(q_clock),
    .reset(q_reset),
    .io_enq_ready(q_io_enq_ready),
    .io_enq_valid(q_io_enq_valid),
    .io_enq_bits(q_io_enq_bits),
    .io_deq_ready(q_io_deq_ready),
    .io_deq_valid(q_io_deq_valid),
    .io_deq_bits(q_io_deq_bits)
  );
  Queue8192_1 q_last ( // @[QueueGbemac.scala 81:22]
    .clock(q_last_clock),
    .reset(q_last_reset),
    .io_enq_ready(q_last_io_enq_ready),
    .io_enq_valid(q_last_io_enq_valid),
    .io_enq_bits(q_last_io_enq_bits),
    .io_deq_ready(q_last_io_deq_ready),
    .io_deq_valid(q_last_io_deq_valid),
    .io_deq_bits(q_last_io_deq_bits)
  );
  assign _T = io_enq_ready & io_enq_valid; // @[Decoupled.scala 40:37]
  assign _T_1 = io_deq_ready & io_deq_valid; // @[Decoupled.scala 40:37]
  assign _T_2 = ~_T_1; // @[QueueGbemac.scala 86:25]
  assign _T_3 = _T & _T_2; // @[QueueGbemac.scala 86:22]
  assign _T_5 = counter + 32'h1; // @[QueueGbemac.scala 87:24]
  assign _T_7 = ~_T; // @[QueueGbemac.scala 88:14]
  assign _T_9 = _T_7 & _T_1; // @[QueueGbemac.scala 88:29]
  assign _T_11 = counter - 32'h1; // @[QueueGbemac.scala 89:24]
  assign _T_12 = ~io_full; // @[QueueGbemac.scala 95:37]
  assign io_full = counter == 32'h1ff0; // @[QueueGbemac.scala 106:11]
  assign io_deq_valid = q_io_deq_valid; // @[QueueGbemac.scala 98:10]
  assign io_deq_bits = q_io_deq_bits; // @[QueueGbemac.scala 98:10]
  assign io_enq_ready = q_io_enq_ready & _T_12; // @[QueueGbemac.scala 96:16]
  assign io_deq_last = q_last_io_deq_bits; // @[QueueGbemac.scala 104:15]
  assign q_clock = clock;
  assign q_reset = reset;
  assign q_io_enq_valid = io_enq_valid & _T_12; // @[QueueGbemac.scala 95:18]
  assign q_io_enq_bits = io_enq_bits; // @[QueueGbemac.scala 93:17]
  assign q_io_deq_ready = io_deq_ready; // @[QueueGbemac.scala 98:10]
  assign q_last_clock = clock;
  assign q_last_reset = reset;
  assign q_last_io_enq_valid = io_enq_valid & _T_12; // @[QueueGbemac.scala 101:23]
  assign q_last_io_enq_bits = io_enq_last; // @[QueueGbemac.scala 100:22]
  assign q_last_io_deq_ready = io_deq_ready; // @[QueueGbemac.scala 103:23]
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
  `ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  counter = _RAND_0[31:0];
  `endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`endif // SYNTHESIS
  always @(posedge clock) begin
    if (reset) begin
      counter <= 32'h0;
    end else if (_T_3) begin
      counter <= _T_5;
    end else if (_T_9) begin
      counter <= _T_11;
    end
  end
endmodule
