// Copyright (C) 2018 Dan Glastonbury <dan.glastonbury@gmail.com>

extern crate cmake;

fn main() {
    cmake::Config::new("../..")
        .generator("Ninja")
        .out_dir("../..")
        .uses_cxx11()
        .build_target("libverilated.a")
        .build();

    println!("cargo:rustc-link-search=native=build/lib");
    println!("cargo:rustc-link-lib=static=verilated");
    println!("cargo:rustc-link-lib=dylib=stdc++");
}
