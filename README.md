# CPU - Verilog + Rust

Inspired by [yupferris](https://www.youtube.com/watch?v=MSWyQJO0ho0)
xenowing project, this is a crazy hydra project of `rust`, `c++`, and
`verilog` driven by `Cargo` and `cmake`.

Most of the `cmake` heavy lifting comes from the
[logic](https://github.com/tymonx/logic) project, although I modifed
the `verilator` support to use `cmake` instead of `make` to compile.

The `test_bench` crate is based upon [looking at
verilator](http://zipcpu.com/blog/2017/06/21/looking-at-verilator.html)
blog by ZipCPU.
