/*
Copyright (C) 2024, Advanced Micro Devices, Inc. All rights reserved.
SPDX-License-Identifier: MIT
*/

#include <stdlib.h>
#include <stdio.h>

#include "core01.h"
#include "core01lut.h"

#ifndef INLINE

INLINE_DECL void core01(
        const int RowA_tile,
        const int ColA_tile,
        const int ColB_tile,
        int8_t* A_in,
        int8_t* C_out,
	int shift
) {      
	
	//********** Matrix dimensions********/
	constexpr size_t sizeTileA = 4 * 8;
	constexpr size_t sizeTileB = 8 * 8;
	constexpr size_t sizeTileC = 4 * 8;


	//********** Mul Intrinsic********/
	using MMUL = aie::mmul<4, 8, 8, int8_t, int8_t>;

    	unsigned int i,j,z;
	

	for (z=0; z<RowA_tile; z++) 
			chess_prepare_for_pipelining
		chess_loop_range(144,144)
	{

		//********** Output vector ********/
		int8_t * __restrict pC1 = C_out + (      z * ColB_tile +       0) * sizeTileC;
		int8_t * __restrict pC2 = C_out + ((z + 1) * ColB_tile +       0) * sizeTileC;


		for (j=0; j<ColB_tile; j++) 
			chess_prepare_for_pipelining
			chess_loop_range(1,1)
		{		   	  	
			 const int8_t * __restrict pA1 = A_in + (      z * ColA_tile +       0) * sizeTileA;
          		 const int8_t * __restrict pA2 = A_in + ((z + 1) * ColA_tile +       0) * sizeTileA;
          		 const int8_t * __restrict pB1 = B + (      0 * ColB_tile +       j) * sizeTileB;
          		 const int8_t * __restrict pB2 = B + (      0 * ColB_tile + (j + 1)) * sizeTileB;

 

          		 aie::vector<int8_t, sizeTileA> A0 = aie::load_v<sizeTileA>(pA1); pA1 += sizeTileA;

          		 aie::vector<int8_t, sizeTileA> A1 = aie::load_v<sizeTileA>(pA2); pA2 += sizeTileA;

          		 aie::vector<int8_t, sizeTileB> B0 = aie::load_v<sizeTileB>(pB1); pB1 += sizeTileB * ColB_tile;

          		 aie::vector<int8_t, sizeTileB> B1 = aie::load_v<sizeTileB>(pB2); pB2 += sizeTileB * ColB_tile;



          		 MMUL C00; C00.mul(A0, B0);
          		 MMUL C01; C01.mul(A0, B1);
          		 MMUL C10; C10.mul(A1, B0);
          		 MMUL C11; C11.mul(A1, B1);

          		for (i = 1; i < ColA_tile; ++i)
			chess_prepare_for_pipelining chess_loop_range(4,4)
			 {
          		     A0 = aie::load_v<sizeTileA>(pA1); pA1 += sizeTileA;
          		     A1 = aie::load_v<sizeTileA>(pA2); pA2 += sizeTileA;
          		     B0 = aie::load_v<sizeTileB>(pB1); pB1 += sizeTileB * ColB_tile;
          		     B1 = aie::load_v<sizeTileB>(pB2); pB2 += sizeTileB * ColB_tile;
          		     C00.mac(A0, B0);
          		     C01.mac(A0, B1);
          		     C10.mac(A1, B0);
          		     C11.mac(A1, B1);
          		 }
			 //******will require rearrangement of output*************//
			 //*************bsrs and shift****************************//
          		 aie::store_v(pC1, C00.template to_vector<int8_t>(shift)); pC1 += sizeTileC;
          		 aie::store_v(pC1, C01.template to_vector<int8_t>(shift)); pC1 += sizeTileC;
          		 aie::store_v(pC2, C10.template to_vector<int8_t>(shift)); pC2 += sizeTileC;
          		 aie::store_v(pC2, C11.template to_vector<int8_t>(shift)); pC2 += sizeTileC;




		}
	
	}
	
}
#endif
void core01_top(input_buffer<int> & __restrict inA, output_buffer<int> & __restrict out){
	int shift = 9;
	set_sat();
	set_rnd(rnd_sym_inf);
	
	int *__restrict ptr = inA.data();
	int *__restrict ptr_1 = out.data();
	core01(ROW_A >> 2, COL_A >> 3, COL_B >> 3, (int8_t *)ptr, (int8_t *)ptr_1, shift);
}




