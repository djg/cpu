# Copyright (C) 2018 Dan Glastonbury <dan.glastonbury@gmail.com>

cmake_minimum_required(VERSION 3.4)
project(hdl CXX)

set (CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${CMAKE_CURRENT_LIST_DIR}/cmake
  )

include(AddHDL)

find_package(Verilator)

add_subdirectory(rtl)
add_subdirectory(test)
