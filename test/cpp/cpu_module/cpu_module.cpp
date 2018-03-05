#include "cpu_top.h"

extern "C" {
  // CONSTRUCTORS
  cpu_top*
  cpu_top_new() {
    return new cpu_top();
  }

  void
  cpu_top_delete(cpu_top* __top) {
    delete __top;
  }

  // API METHODS
  void
  cpu_top_eval(cpu_top* __top) {
    __top->eval();
  }

  void
  cpu_top_final(cpu_top* __top) {
    __top->final();
  }

  // PORTS
  void cpu_top_clk_i(cpu_top* __top, vluint8_t __in) {
    __top->clk_i = __in;
  }

  void cpu_top_rst_i(cpu_top* __top, vluint8_t __in) {
    __top->rst_i = __in;
  }

  vluint8_t
  cpu_top_count_o(cpu_top* __top) {
    return __top->count_o;
  }
}
