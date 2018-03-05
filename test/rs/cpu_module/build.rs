// Copyright (C) 2018 Dan Glastonbury <dan.glastonbury@gmail.com>

extern crate cmake;

fn main() {
    cmake::Config::new("../../..")
        .generator("Ninja")
        .out_dir("../../..")
        .uses_cxx11()
        .build_target("libtb_cpu_module.a")
        .build();

    println!("cargo:rustc-link-search=native=build/test/cpp/cpu_module");
    println!("cargo:rustc-link-search=native=build/rtl/cpu");
    println!("cargo:rustc-link-search=native=build/lib");
    println!("cargo:rustc-link-lib=static=tb_cpu_module");
    println!("cargo:rustc-link-lib=static=verilated_cpu_top");
    println!("cargo:rustc-link-lib=static=verilated");
    println!("cargo:rustc-link-lib=dylib=stdc++");
}
