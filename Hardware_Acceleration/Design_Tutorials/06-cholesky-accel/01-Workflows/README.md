<table class="sphinxhide" width="100%">
 <tr width="100%">
    <td align="center"><img src="https://raw.githubusercontent.com/Xilinx/Image-Collateral/main/xilinx-logo.png" width="30%"/><h1>Vitis™ Hardware Acceleration Tutorials</h1>
    <a href="https://www.xilinx.com/products/design-tools/vitis.html">See Vitis™ Development Environment on xilinx.com</a>
    </td>
 </tr>
</table>

# Section 1 - Workflows

> **_In this section:_** _Quick overview of the Vitis flow and description of the host/kernel paradigm._

## The Vitis Flow

To enable hardware acceleration, the code is split between an host and one or several kernels.  The host program, written in C/C++ uses API abstractions like OpenCL™, runs on a host processor (a x86 server or an Arm® processor in the case of embedded platforms). The hardware accelerated kernels run onto the programmable logic (PL) of an AMD device.

The API calls, processed by Xilinx Runtime (XRT), manage process transactions between the host program and the hardware accelerators (kernels). Communication between the host and the kernel(s), including control and data transfers, occurs across the PCIe® bus or an AXI bus for embedded platforms.

In a typical application, the host first transfers data to be operated on by the kernel from host memory into global memory. The kernel subsequently operates on the data, storing results back to the global memory. Upon kernel completion, the host transfers the results back into the host memory. Data transfers between the host and global memory introduce latency, which can be costly to the overall application. To achieve acceleration in a real system, the benefits achieved by the hardware acceleration kernels must outweigh the added latency of these data transfers.

The Vitis core development flow helps manage, configure, build, and run a host application and hardware accelerated kernels.

- The host application is developed in C/C++ with native XRT API or OpenCL API calls
- The hardware kernels can be developed in C/C++, OpenCL C, or RTL.

Here is a diagram of the functional blocks involved for a x86 server connected to an AMD Alveo™ acceleration card:

![flow](../03-Algorithm_Acceleration/docs/images/host-kernel.png)

In the next [**section**](../02-System_Setup/README.md), you will learn how to prepare your environment to run the tutorial.

<p class="sphinxhide" align="center"><sub>Copyright © 2020–2023 Advanced Micro Devices, Inc</sub></p>

<p class="sphinxhide" align="center"><sup><a href="https://www.amd.com/en/corporate/copyright">Terms and Conditions</a></sup></p>
