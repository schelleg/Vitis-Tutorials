/**********
© Copyright 2020 Xilinx, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
**********/


#include <ap_int.h>
#include <hls_stream.h>
#include <ap_axi_sdata.h>

#define WORD_SIZE 16

extern "C" {

void mm2s_vadd_s(ap_int<WORD_SIZE>* mem, hls::stream<hls::axis<ap_int<WORD_SIZE>, 0, 0, 0>>& s, int size) {
#pragma HLS INTERFACE m_axi port=mem offset=slave bundle=gmem

#pragma HLS INTERFACE axis port=s

#pragma HLS INTERFACE s_axilite port=mem bundle=control
#pragma HLS INTERFACE s_axilite port=size bundle=control
#pragma HLS INTERFACE s_axilite port=return bundle=control

	for(int i = 0; i < size; i++) {
#pragma HLS PIPELINE II=1
		hls::axis<ap_int<WORD_SIZE>, 0, 0, 0> x;
		x.data = mem[i];
		x.keep = -1;
		s.write(x);
	}

}

}
