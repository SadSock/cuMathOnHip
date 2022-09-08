	.headerflags	@"EF_CUDA_TEXMODE_UNIFIED EF_CUDA_64BIT_ADDRESS EF_CUDA_SM75 EF_CUDA_VIRTUAL_SM(EF_CUDA_SM75)"
	.elftype	@"ET_EXEC"


//--------------------- .debug_frame              --------------------------
	.section	.debug_frame,"",@progbits
.debug_frame:
        /*0000*/ 	.byte	0xff, 0xff, 0xff, 0xff, 0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
        /*0010*/ 	.byte	0xff, 0xff, 0xff, 0xff, 0x03, 0x00, 0x04, 0x7c, 0xff, 0xff, 0xff, 0xff, 0x0f, 0x0c, 0x81, 0x80
        /*0020*/ 	.byte	0x80, 0x28, 0x00, 0x08, 0xff, 0x81, 0x80, 0x28, 0x08, 0x81, 0x80, 0x80, 0x28, 0x00, 0x00, 0x00
        /*0030*/ 	.byte	0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        /*0040*/ 	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        /*0048*/ 	.dword	_Z4drcpPdd
        /*0050*/ 	.byte	0x30, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00, 0x00, 0x00, 0x04, 0x30, 0x00
        /*0060*/ 	.byte	0x00, 0x00, 0x0c, 0x81, 0x80, 0x80, 0x28, 0x00, 0x04, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        /*0070*/ 	.byte	0xff, 0xff, 0xff, 0xff, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
        /*0080*/ 	.byte	0xff, 0xff, 0xff, 0xff, 0x03, 0x00, 0x04, 0x7c, 0x80, 0x82, 0x80, 0x28, 0x0c, 0x81, 0x80, 0x80
        /*0090*/ 	.byte	0x28, 0x00, 0x08, 0xff, 0x81, 0x80, 0x28, 0x08, 0x81, 0x80, 0x80, 0x28, 0x08, 0x80, 0x80, 0x80
        /*00a0*/ 	.byte	0x28, 0x16, 0x80, 0x82, 0x80, 0x28, 0x10, 0x03
        /*00a8*/ 	.dword	_Z4drcpPdd
        /*00b0*/ 	.byte	0x92, 0x80, 0x80, 0x80, 0x28, 0x00, 0x22, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
        /*00c0*/ 	.byte	0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        /*00d0*/ 	.dword	(_Z4drcpPdd + $_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3@srel)
        /*00d8*/ 	.byte	0x30, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0xa8, 0x00, 0x00, 0x00, 0x09, 0x80, 0x80
        /*00e8*/ 	.byte	0x80, 0x28, 0x82, 0x80, 0x80, 0x28, 0x00, 0x00


//--------------------- .nv.info                  --------------------------
	.section	.nv.info,"",@"SHT_CUDA_INFO"
	.align	4


	//----- nvinfo : EIATTR_REGCOUNT
	.align		4
        /*0000*/ 	.byte	0x04, 0x2f
        /*0002*/ 	.short	(.L_2 - .L_1)
	.align		4
.L_1:
        /*0004*/ 	.word	index@(_Z4drcpPdd)
        /*0008*/ 	.word	0x0000000c


	//----- nvinfo : EIATTR_MAX_STACK_SIZE
	.align		4
.L_2:
        /*000c*/ 	.byte	0x04, 0x23
        /*000e*/ 	.short	(.L_4 - .L_3)
	.align		4
.L_3:
        /*0010*/ 	.word	index@($_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3)
        /*0014*/ 	.word	0x00000000


	//----- nvinfo : EIATTR_MIN_STACK_SIZE
	.align		4
.L_4:
        /*0018*/ 	.byte	0x04, 0x12
        /*001a*/ 	.short	(.L_6 - .L_5)
	.align		4
.L_5:
        /*001c*/ 	.word	index@($_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3)
        /*0020*/ 	.word	0x00000000


	//----- nvinfo : EIATTR_FRAME_SIZE
	.align		4
.L_6:
        /*0024*/ 	.byte	0x04, 0x11
        /*0026*/ 	.short	(.L_8 - .L_7)
	.align		4
.L_7:
        /*0028*/ 	.word	index@($_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3)
        /*002c*/ 	.word	0x00000000


	//----- nvinfo : EIATTR_MAX_STACK_SIZE
	.align		4
.L_8:
        /*0030*/ 	.byte	0x04, 0x23
        /*0032*/ 	.short	(.L_10 - .L_9)
	.align		4
.L_9:
        /*0034*/ 	.word	index@(_Z4drcpPdd)
        /*0038*/ 	.word	0x00000000


	//----- nvinfo : EIATTR_MIN_STACK_SIZE
	.align		4
.L_10:
        /*003c*/ 	.byte	0x04, 0x12
        /*003e*/ 	.short	(.L_12 - .L_11)
	.align		4
.L_11:
        /*0040*/ 	.word	index@(_Z4drcpPdd)
        /*0044*/ 	.word	0x00000000


	//----- nvinfo : EIATTR_FRAME_SIZE
	.align		4
.L_12:
        /*0048*/ 	.byte	0x04, 0x11
        /*004a*/ 	.short	(.L_14 - .L_13)
	.align		4
.L_13:
        /*004c*/ 	.word	index@(_Z4drcpPdd)
        /*0050*/ 	.word	0x00000000
.L_14:


//--------------------- .nv.info._Z4drcpPdd       --------------------------
	.section	.nv.info._Z4drcpPdd,"",@"SHT_CUDA_INFO"
	.align	4


	//----- nvinfo : EIATTR_SW_WAR
	.align		4
        /*0000*/ 	.byte	0x04, 0x36
        /*0002*/ 	.short	(.L_16 - .L_15)
.L_15:
        /*0004*/ 	.word	0x00000001


	//----- nvinfo : EIATTR_CUDA_API_VERSION
	.align		4
.L_16:
        /*0008*/ 	.byte	0x04, 0x37
        /*000a*/ 	.short	(.L_18 - .L_17)
.L_17:
        /*000c*/ 	.word	0x00000075


	//----- nvinfo : EIATTR_PARAM_CBANK
	.align		4
.L_18:
        /*0010*/ 	.byte	0x04, 0x0a
        /*0012*/ 	.short	(.L_20 - .L_19)
	.align		4
.L_19:
        /*0014*/ 	.word	index@(.nv.constant0._Z4drcpPdd)
        /*0018*/ 	.short	0x0160
        /*001a*/ 	.short	0x0010


	//----- nvinfo : EIATTR_CBANK_PARAM_SIZE
	.align		4
.L_20:
        /*001c*/ 	.byte	0x03, 0x19
        /*001e*/ 	.short	0x0010


	//----- nvinfo : EIATTR_KPARAM_INFO
	.align		4
        /*0020*/ 	.byte	0x04, 0x17
        /*0022*/ 	.short	(.L_22 - .L_21)
.L_21:
        /*0024*/ 	.word	0x00000000
        /*0028*/ 	.short	0x0001
        /*002a*/ 	.short	0x0008
        /*002c*/ 	.byte	0x00, 0xf0, 0x21, 0x00


	//----- nvinfo : EIATTR_KPARAM_INFO
	.align		4
.L_22:
        /*0030*/ 	.byte	0x04, 0x17
        /*0032*/ 	.short	(.L_24 - .L_23)
.L_23:
        /*0034*/ 	.word	0x00000000
        /*0038*/ 	.short	0x0000
        /*003a*/ 	.short	0x0000
        /*003c*/ 	.byte	0x00, 0xf0, 0x21, 0x00


	//----- nvinfo : EIATTR_MAXREG_COUNT
	.align		4
.L_24:
        /*0040*/ 	.byte	0x03, 0x1b
        /*0042*/ 	.short	0x00ff


	//----- nvinfo : EIATTR_EXIT_INSTR_OFFSETS
	.align		4
        /*0044*/ 	.byte	0x04, 0x1c
        /*0046*/ 	.short	(.L_26 - .L_25)


	//   ....[0]....
.L_25:
        /*0048*/ 	.word	0x00000130


	//----- nvinfo : EIATTR_CRS_STACK_SIZE
	.align		4
.L_26:
        /*004c*/ 	.byte	0x04, 0x1e
        /*004e*/ 	.short	(.L_28 - .L_27)
.L_27:
        /*0050*/ 	.word	0x00000000
.L_28:


//--------------------- .nv.rel.action            --------------------------
	.section	.nv.rel.action,"",@"SHT_CUDA_RELOCINFO"
	.align	8
	.sectionentsize	8
        /*0000*/ 	.byte	0x4b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x02, 0x08, 0x10, 0x0a, 0x2f, 0x22
        /*0010*/ 	.byte	0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00
        /*0020*/ 	.byte	0x00, 0x00, 0x10, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x08, 0x00, 0x00, 0x00, 0x00
        /*0030*/ 	.byte	0x00, 0x00, 0x20, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x08, 0x00, 0x00, 0x00, 0x00
        /*0040*/ 	.byte	0x00, 0x00, 0x30, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x08, 0x00, 0x00, 0x00, 0x00
        /*0050*/ 	.byte	0x01, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00
        /*0060*/ 	.byte	0x01, 0x00, 0x10, 0x08, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x18, 0x08, 0x00, 0x00, 0x00, 0x00
        /*0070*/ 	.byte	0x01, 0x00, 0x20, 0x08, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x28, 0x08, 0x00, 0x00, 0x00, 0x00
        /*0080*/ 	.byte	0x01, 0x00, 0x30, 0x08, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x38, 0x08, 0x00, 0x00, 0x00, 0x00
        /*0090*/ 	.byte	0x02, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x08, 0x08, 0x00, 0x00, 0x00, 0x00
        /*00a0*/ 	.byte	0x02, 0x00, 0x10, 0x08, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x18, 0x08, 0x00, 0x00, 0x00, 0x00
        /*00b0*/ 	.byte	0x02, 0x00, 0x20, 0x08, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x28, 0x08, 0x00, 0x00, 0x00, 0x00
        /*00c0*/ 	.byte	0x02, 0x00, 0x30, 0x08, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x38, 0x08, 0x00, 0x00, 0x00, 0x00
        /*00d0*/ 	.byte	0x00, 0x00, 0x00, 0x14, 0x2c, 0x00, 0x00, 0x00, 0x09, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00


//--------------------- .nv.constant0._Z4drcpPdd  --------------------------
	.section	.nv.constant0._Z4drcpPdd,"a",@progbits
	.align	4
.nv.constant0._Z4drcpPdd:
	.zero		368


//--------------------- .text._Z4drcpPdd          --------------------------
	.section	.text._Z4drcpPdd,"ax",@progbits
	.sectioninfo	@"SHI_REGISTERS=12"
	.align	128
        .global         _Z4drcpPdd
        .type           _Z4drcpPdd,@function
        .size           _Z4drcpPdd,(.L_x_5 - _Z4drcpPdd)
        .other          _Z4drcpPdd,@"STO_CUDA_ENTRY STV_DEFAULT"
_Z4drcpPdd:
.text._Z4drcpPdd:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   MUFU.RCP64H R3, c[0x0][0x16c] ;          R3 = r0_hi
        /*0020*/                   IMAD.MOV.U32 R0, RZ, RZ, c[0x0][0x16c] ; R0 = x_hi
        /*0030*/                   IMAD.MOV.U32 R6, RZ, RZ, c[0x0][0x168] ; R6 = x_lo
        /*0040*/                   IMAD.MOV.U32 R7, RZ, RZ, c[0x0][0x16c] ; R7 = x_hi
        /*0050*/                   IADD3 R2, R0, 0x300402, RZ ;           ; R2 = r0_lo = x_hi + 0x300402
        /*0060*/                   FSETP.GEU.AND P0, PT, |R2|, 5.8789094863358348022e-39, PT ; //400402
        /*0070*/                   DFMA R4, R2, -R6, 1 ; d1 = r0 * (-x0) + 1.0
        /*0080*/                   DFMA R4, R4, R4, R4 ; R4 = dd0 = d1 * d1 + d1
        /*0090*/                   DFMA R4, R2, R4, R2 ; R4 = r1  = r0 * dd0 + r0
        /*00a0*/                   DFMA R6, R4, -R6, 1 ; R6 = d2 = r1 * (-x0) + 1.0
        /*00b0*/                   DFMA R4, R4, R6, R4 ; R4 = r2 = r1 * d2 + r1
        /*00c0*/               @P0 BRA `(.L_x_0) ;     x_exp_bisa >= 1
        /*00d0*/                   LOP3.LUT R0, R0, 0x7fffffff, RZ, 0xc0, !PT ; R0 = x_hi and 0x7fffffff
        /*00e0*/                   IADD3 R7, R0, -0x100000, RZ ; R7 = x_hi and 0x7fffffff - 0x100000  x_exp_bias - 1
        /*00f0*/                   MOV R0, 0x110 ; R0 = 0x110
        /*0100*/                   CALL.REL.NOINC `($_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3) ;
.L_x_0:
        /*0110*/                   ULDC.64 UR4, c[0x0][0x160] ;
        /*0120*/                   STG.E.64.SYS [UR4], R4 ;
        /*0130*/                   EXIT ;
        .weak           $_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3
        .type           $_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3,@function
        .size           $_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3,(.L_x_5 - $_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3)
$_Z4drcpPdd$__cuda_sm20_dblrcp_rn_slowpath_v3:
        /*0140*/                   IMAD.MOV.U32 R8, RZ, RZ, c[0x0][0x168] ; R8 = x0_lo
        /*0150*/                   MOV R9, c[0x0][0x16c] ;                  R9 = x0_hi
        /*0160*/                   IMAD.MOV.U32 R4, RZ, RZ, c[0x0][0x16c] ; R4 = x0_hi
        /*0170*/                   DSETP.GTU.AND P0, PT, |R8|, +INF , PT ;  P0 = isnan(R8)
        /*0180*/               @P0 BRA `(.L_x_1) ;
        /*0190*/                   LOP3.LUT R5, R4, 0x7fffffff, RZ, 0xc0, !PT ; R5 = x0_hi and 0x7fffffff  //clear sign
        /*01a0*/                   IADD3 R2, R5, -0x1, RZ ;                     R2 = (x0_hi & 0x7fffffff) - 0x1
        /*01b0*/                   ISETP.GE.U32.AND P0, PT, R2, 0x7fefffff, PT ; inf nan denormal //P0 = (x0_hi & 0x7fffffff - 0x1) >= 0x7fefffff // (x0_hi & 0x7fffffff) >= 0x7ff00000 或者 (x0_hi & 0x7fffffff) == 0
        /*01c0*/               @P0 LOP3.LUT R3, R4, 0x7ff00000, RZ, 0x3c, !PT ;//or R3 = ret_hi = x0_mantissa_hi
        /*01d0*/               @P0 IMAD.MOV.U32 R2, RZ, RZ, RZ ; R2 = ret_lo = 0
        /*01e0*/               @P0 BRA `(.L_x_2) ;//inf nan denormal
        /*01f0*/                   ISETP.GE.U32.AND P0, PT, R5, 0x1000001, PT ; P0 = (x0_hi & 0x7fffffff) >= 0x1000001
        /*0200*/              @!P0 BRA `(.L_x_3) ;
        /*0210*/                   IADD3 R3, R4, -0x3fe00000, RZ ; R3 = R4 - 0x3fe00000
        /*0220*/                   IMAD.MOV.U32 R2, RZ, RZ, c[0x0][0x168] ; R2 = x0_lo
        /*0230*/                   MOV R4, R7 ;
        /*0240*/                   MUFU.RCP64H R5, R3 ;// r0 = r[5:4]
        /*0250*/                   DFMA R6, -R2, R4, 1 ; double d1  = -x0 * r0 + 1.0
        /*0260*/                   DFMA R6, R6, R6, R6 ; double dd1 = d1 * d1 + d1
        /*0270*/                   DFMA R6, R4, R6, R4 ; double r1  = r0 * dd1 + r0
        /*0280*/                   DFMA R4, -R2, R6, 1 ; double d2  = -x0 * r1 + 1.0
        /*0290*/                   DFMA R4, R6, R4, R6 ; double r2  = r1 * d2 + r1
        /*02a0*/                   DMUL R4, R4, 2.2250738585072013831e-308 ; double r3 = r2 * (double)0x0010000006067828
        /*02b0*/                   DFMA R6, R4, -R8, 1 ; double d3  = r3 * -x + 1;
        /*02c0*/                   DFMA R6, R6, R6, R6 ; double dd3 = d3 * d3 + d3
        /*02d0*/                   DFMA R2, R4, R6, R4 ; double r4  = r3 * dd3 + r3
        /*02e0*/                   BRA `(.L_x_2) ;
.L_x_3:
        /*02f0*/                   DMUL R4, R8, 8.11296384146066816958e+31 ; R8 = x;  R4 = R8 * 0x4690000004047828
        /*0300*/                   IMAD.MOV.U32 R2, RZ, RZ, R7 ; R7 = x_hi and 0x7fffffff - 0x100000  x_exp_bias - 1
        /*0310*/                   MUFU.RCP64H R3, R5 ;
        /*0320*/                   DFMA R6, -R4, R2, 1 ; R6 = d1  = __builtin_fma(-x0, r0, 1.0);
        /*0330*/                   DFMA R6, R6, R6, R6 ; R6 = dd1 = __builtin_fma(d1, d1, d1);
        /*0340*/                   DFMA R6, R2, R6, R2 ; R6 = r1  = __builtin_fma(r0, dd1, r0);
        /*0350*/                   DFMA R2, -R4, R6, 1 ; R2 = d2  = __builtin_fma(-x0, r1, 1.0);
        /*0360*/                   DFMA R2, R6, R2, R6 ; R2 = r2  = __builtin_fma(r1, d2, r1);
        /*0370*/                   DMUL R2, R2, 8.11296384146066816958e+31 ; R2 = r2 * 0x4690000004047828
        /*0380*/                   BRA `(.L_x_2) ;
.L_x_1:
        /*0390*/                   LOP3.LUT R3, R4, 0x80000, RZ, 0xfc, !PT ; R3 = x0_hi or 0x80000
        /*03a0*/                   IMAD.MOV.U32 R2, RZ, RZ, c[0x0][0x168] ;  R2 = x0_lo
.L_x_2:
        /*03b0*/                   IMAD.MOV.U32 R4, RZ, RZ, R2 ; R4 = x0_lo
        /*03c0*/                   MOV R5, R3 ;                  R5 = x0_hi or 0x80000
        /*03d0*/                   IMAD.MOV.U32 R2, RZ, RZ, R0 ;
        /*03e0*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;
        /*03f0*/                   RET.REL.NODEC R2 `(_Z4drcpPdd) ;
.L_x_4:
        /*0400*/                   BRA `(.L_x_4);
        /*0410*/                   NOP;
        /*0420*/                   NOP;
        /*0430*/                   NOP;
        /*0440*/                   NOP;
        /*0450*/                   NOP;
        /*0460*/                   NOP;
        /*0470*/                   NOP;
.L_x_5:
