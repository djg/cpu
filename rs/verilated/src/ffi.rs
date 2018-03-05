// Copyright (C) 2018 Dan Glastonbury <dan.glastonbury@gmail.com>

#![allow(dead_code)]

use std::os::raw::{c_char, c_int};

extern "C" {
    pub fn verilated_set_rand_reset(val: c_int);
    pub fn verilated_rand_reset() -> c_int;
    pub fn verilated_set_debug(level: c_int);
    pub fn verilated_debug() -> c_int;
    pub fn verilated_set_calc_unused_sigs(flag: c_int);
    pub fn verilated_calc_unused_sigs() -> c_int;
    pub fn verilated_set_got_finish(flag: c_int);
    pub fn verilated_got_finish() -> c_int;
    pub fn verilated_trace_ever_on(flag: c_int);
    pub fn verilated_set_assert_on(flag: c_int);
    pub fn verilated_assert_on()  -> c_int;
    pub fn verilated_set_fatal_on_vpi_error(flag: c_int);
    pub fn verilated_fatal_on_vpi_error() -> c_int;
    //pub fn verilated_flush_cb(cb: VerilatedVoidCb);
    pub fn verilated_flush_call();
    pub fn verilated_command_args(argc: c_int, argv: *const *const c_char);
    pub fn verilated_command_args_add(argc: c_int, argv: *const *const c_char);
    //    static CommandArgValues* getCommandArgs() {return &s_args;}
    pub fn verilated_command_args_plus_match(prefixp: *const c_char ) -> *const c_char;
    pub fn verilated_product_name() -> *const c_char;
    pub fn verilated_product_version()  -> *const c_char;
    pub fn verilated_internals_dump();
    pub fn verilated_scopes_dump();
}
