# Copyright (C) 2018 Dan Glastonbury <dan.glastonbury@gmail.com>

add_library(tb_cpu_module cpu_module.cpp)
target_link_libraries(tb_cpu_module PRIVATE verilated_cpu_top)
