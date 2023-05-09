#/*
# Copyright (C) 2023, Advanced Micro Devices, Inc. All rights reserved.
# SPDX-License-Identifier: X11
#*/

if { $::argc != 4 } {
    puts "ERROR: Program \"$::argv0\" requires 4 arguments!\n"
    puts "Usage: $::argv0 <xoname> <krnl_name> <target> <device>\n"
    exit
}

set xoname    [lindex $::argv 0]
set krnl_name [lindex $::argv 1]
set target    [lindex $::argv 2]
set device    [lindex $::argv 3]

set suffix "${krnl_name}_${target}_${device}"

source -notrace ./scripts/package_kernel.tcl

if {[file exists "${xoname}"]} {
    file delete -force "${xoname}"
}

#package_xo -xo_path ${xoname} -kernel_name Vadd_A_B -ip_directory ./packaged_kernel_${suffix} -kernel_xml ./src/xml/kernel.xml -kernel_files ./src/c-model/Vadd_A_B.cpp
package_xo -xo_path ${xoname} -kernel_name Vadd_A_B -ip_directory ./packaged_kernel_${suffix} -kernel_xml ./src/xml/user.xml -kernel_files ./src/c-model/Vadd_A_B.cpp
