# Copyright (C) 2018 Dan Glastonbury <dan.glastonbury@gmail.com>

add_hdl_source(cpu_counter.v)
add_hdl_source(cpu_top.v
  DEPENDS cpu_counter
  COMPILE Verilator
  )
    
