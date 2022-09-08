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
        /*0050*/ 	.byte	0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00, 0x00, 0x00, 0x04, 0x04, 0x00
        /*0060*/ 	.byte	0x00, 0x00, 0x0c, 0x81, 0x80, 0x80, 0x28, 0x00, 0x04, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        /*0070*/ 	.byte	0xff, 0xff, 0xff, 0xff, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
        /*0080*/ 	.byte	0xff, 0xff, 0xff, 0xff, 0x03, 0x00, 0x04, 0x7c, 0x80, 0x82, 0x80, 0x28, 0x0c, 0x81, 0x80, 0x80
        /*0090*/ 	.byte	0x28, 0x00, 0x08, 0xff, 0x81, 0x80, 0x28, 0x08, 0x81, 0x80, 0x80, 0x28, 0x08, 0x80, 0x80, 0x80
        /*00a0*/ 	.byte	0x28, 0x16, 0x80, 0x82, 0x80, 0x28, 0x10, 0x03
        /*00a8*/ 	.dword	_Z4drcpPdd
        /*00b0*/ 	.byte	0x92, 0x80, 0x80, 0x80, 0x28, 0x00, 0x22, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
        /*00c0*/ 	.byte	0x28, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
        /*00d0*/ 	.dword	(_Z4drcpPdd + $_Z4drcpPdd$__cuda_sm20_rcp_ru_f64@srel)
        /*00d8*/ 	.byte	0xf0, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x70, 0x01, 0x00, 0x00, 0x09, 0x80, 0x80
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
        /*0008*/ 	.word	0x00000014


	//----- nvinfo : EIATTR_MAX_STACK_SIZE
	.align		4
.L_2:
        /*000c*/ 	.byte	0x04, 0x23
        /*000e*/ 	.short	(.L_4 - .L_3)
	.align		4
.L_3:
        /*0010*/ 	.word	index@($_Z4drcpPdd$__cuda_sm20_rcp_ru_f64)
        /*0014*/ 	.word	0x00000000


	//----- nvinfo : EIATTR_MIN_STACK_SIZE
	.align		4
.L_4:
        /*0018*/ 	.byte	0x04, 0x12
        /*001a*/ 	.short	(.L_6 - .L_5)
	.align		4
.L_5:
        /*001c*/ 	.word	index@($_Z4drcpPdd$__cuda_sm20_rcp_ru_f64)
        /*0020*/ 	.word	0x00000000


	//----- nvinfo : EIATTR_FRAME_SIZE
	.align		4
.L_6:
        /*0024*/ 	.byte	0x04, 0x11
        /*0026*/ 	.short	(.L_8 - .L_7)
	.align		4
.L_7:
        /*0028*/ 	.word	index@($_Z4drcpPdd$__cuda_sm20_rcp_ru_f64)
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
        /*0048*/ 	.word	0x00000070


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
	.sectioninfo	@"SHI_REGISTERS=20"
	.align	128
        .global         _Z4drcpPdd
        .type           _Z4drcpPdd,@function
        .size           _Z4drcpPdd,(.L_x_4 - _Z4drcpPdd)
        .other          _Z4drcpPdd,@"STO_CUDA_ENTRY STV_DEFAULT"
_Z4drcpPdd:
.text._Z4drcpPdd:
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;
        /*0010*/                   MOV R0, 0x30 ;
        /*0020*/                   CALL.REL.NOINC `($_Z4drcpPdd$__cuda_sm20_rcp_ru_f64) ;
        /*0030*/                   IMAD.MOV.U32 R2, RZ, RZ, R4 ;
        /*0040*/                   ULDC.64 UR4, c[0x0][0x160] ;
        /*0050*/                   IMAD.MOV.U32 R3, RZ, RZ, R5 ;
        /*0060*/                   STG.E.64.SYS [UR4], R2 ;
        /*0070*/                   EXIT ;
        .weak           $_Z4drcpPdd$__cuda_sm20_rcp_ru_f64
        .type           $_Z4drcpPdd$__cuda_sm20_rcp_ru_f64,@function
        .size           $_Z4drcpPdd$__cuda_sm20_rcp_ru_f64,(.L_x_4 - $_Z4drcpPdd$__cuda_sm20_rcp_ru_f64)
$_Z4drcpPdd$__cuda_sm20_rcp_ru_f64:
        /*0080*/                   IMAD.MOV.U32 R8, RZ, RZ, c[0x0][0x16c] ; R8 = x_hi
        /*0090*/                   IMAD.MOV.U32 R7, RZ, RZ, c[0x0][0x168] ; R7 = x_lo
        /*00a0*/                   IMAD.SHL.U32 R2, R8, 0x2, RZ ;           R2 = R8 << 1
        /*00b0*/                   IMAD.MOV.U32 R6, RZ, RZ, c[0x0][0x16c] ; R6 = x_hi
        /*00c0*/                   SHF.R.U32.HI R14, RZ, 0x15, R2 ;         R14 = x_hi << 1 >> 21
        /*00d0*/                   IADD3 R9, R14, -0x1, RZ ;                R9  = R14 - 1
        /*00e0*/                   ISETP.GT.U32.AND P0, PT, R9, 0x7fd, PT ;
        /*00f0*/              @!P0 BRA `(.L_x_0) ;
        /*0100*/                   IMAD.MOV.U32 R4, RZ, RZ, c[0x0][0x168] ;
        /*0110*/                   IMAD.MOV.U32 R5, RZ, RZ, c[0x0][0x16c] ;
        /*0120*/                   DSETP.GTU.AND P0, PT, |R4|, +INF , PT ;
        /*0130*/               @P0 LOP3.LUT R3, R8, 0x80000, RZ, 0xfc, !PT ; R3 = R8 or 0x80000
        /*0140*/               @P0 IMAD.MOV.U32 R2, RZ, RZ, R7 ;
        /*0150*/               @P0 BRA `(.L_x_1) ;
        /*0160*/                   DSETP.NEU.AND P0, PT, |R4|, +INF , PT ;
        /*0170*/              @!P0 LOP3.LUT R3, R8, 0x80000000, RZ, 0xc0, !PT ; R3 = R8 and 0x80000000
        /*0180*/              @!P0 IMAD.MOV.U32 R2, RZ, RZ, RZ ;
        /*0190*/              @!P0 BRA `(.L_x_1) ;
        /*01a0*/                   DSETP.NEU.AND P0, PT, RZ, c[0x0][0x168], PT ;
        /*01b0*/              @!P0 LOP3.LUT R2, R8, 0x80000000, RZ, 0xc0, !PT ; and
        /*01c0*/              @!P0 LOP3.LUT R3, R2, 0x7ff00000, RZ, 0xfc, !PT ; xor
        /*01d0*/              @!P0 IMAD.MOV.U32 R2, RZ, RZ, RZ ;
        /*01e0*/              @!P0 BRA `(.L_x_1) ;
        /*01f0*/                   ISETP.GE.AND P0, PT, R9, RZ, PT ;
        /*0200*/              @!P0 DMUL R2, R4, 1.80143985094819840000e+16 ; R[2:3] = R[4:5] * 2^54
        /*0210*/              @!P0 IMAD.MOV.U32 R15, RZ, RZ, 0x36 ;
        /*0220*/               @P0 IMAD.MOV.U32 R15, RZ, RZ, RZ ;
        /*0230*/              @!P0 IMAD.MOV.U32 R7, RZ, RZ, R2 ; R7 = x0_lo
        /*0240*/              @!P0 IMAD.MOV.U32 R6, RZ, RZ, R3 ; R6 = x0_hi
        /*0250*/                   BRA `(.L_x_2) ;
.L_x_0:
        /*0260*/                   IMAD.MOV.U32 R15, RZ, RZ, RZ ;
.L_x_2:
        /*0270*/                   IADD3 R3, R14, -0x3ff, RZ ;    R3 = R14 - 0x3ff // true mantissa
        /*0280*/                   IMAD.MOV.U32 R2, RZ, RZ, R7 ;  R2 = x0_lo
        /*0290*/                   IMAD.MOV.U32 R4, RZ, RZ, 0x1 ; R4 = 1
        /*02a0*/                   IMAD R3, R3, -0x100000, R6 ;   R3 = x_hi - R3 * 2 ^20

        /*02b0*/                   MUFU.RCP64H R5, R3 ;       R2 = x0   R4 = r0
        /*02c0*/                   DFMA R6, -R2, R4, 1 ;      R6 = d1 = -x0 * r0 + 1
        /*02d0*/                   DFMA R8, R4, R6, R4 ;      R8 = r1 = r0 * d1 + r0
        /*02e0*/                   DMUL R10, R6, R6 ;         R10= dd1 = d1 * d1
        /*02f0*/                   DFMA R10, R8, R10, R8 ;    R10= r2 = r1 * dd1 + r1

        /*0300*/                   DFMA R8, -R2, R10, 1 ;     R8 = d2 = -x0 * r2 + 1
        /*0310*/                   DFMA R6, R6, R10, R4 ;     R6 = r3 = d1 * r2 + r0
        /*0320*/                   DFMA R8, R10, R8, R10 ;    R8 = r4 = r2 * d2 + r2

        /*0330*/                   DFMA R10, -R2, R6, 1 ;     R10 = d3 = -x0 * r3 + 1.0
        /*0340*/                   DFMA.RP R12, R8, R10, R6 ; R12 = r5 = r4 * d3 + r3

        /*0350*/                   IMAD.SHL.U32 R2, R13, 0x2, RZ ;
        /*0360*/                   SHF.R.U32.HI R2, RZ, 0x15, R2 ; R2 = r5_mantissa
        /*0370*/                   IADD3 R15, R15, R2, -R14 ; R15 = r5_exp_true = x0_mantissa_scale + r5_mantissa - x_mantissa
        /*0380*/                   IADD3 R3, R15, 0x3fe, RZ ; R3  = x0_mantissa_scale + r5_mantissa - (x_mantissa - 0x3ff) - 1
        /*0390*/                   ISETP.GT.U32.AND P0, PT, R3, 0x7fd, PT ;
        /*03a0*/              @!P0 IADD3 R3, R15, 0x3ff, -R2 ; R3 = x0_mantissa_scale - (x_mantissa - 0x3ff)
        /*03b0*/              @!P0 IMAD.MOV.U32 R2, RZ, RZ, R12 ;
        /*03c0*/              @!P0 IMAD R3, R3, 0x100000, R13 ;
        /*03d0*/              @!P0 BRA `(.L_x_1) ;
        /*03e0*/                   ISETP.GT.AND P1, PT, R15, 0x3ff, PT ; P1 = R15(r5_exp_true) > 1023?
        /*03f0*/                   LOP3.LUT R16, R13, 0x80000000, RZ, 0xc0, !PT ; R16 = r5_sign = R13 and 0x80000000
        /*0400*/           /*inf*/ @P1 IMAD.MOV.U32 R2, RZ, RZ, -0x100001 ; R2 = 0xFFEFFFFF
        /*0410*/           /*inf*/ @P1 ISETP.NE.AND P0, PT, R16, RZ, PT ;
        /*0420*/           /*inf*/ @P1 SEL R3, R2, 0x7ff00000, P0 ;
        /*0430*/           /*inf*/ @P1 SEL R2, RZ, 0xffffffff, !P0 ;
        /*0440*/           /*inf*/ @P1 BRA `(.L_x_1) ;
        /*0450*/                   ISETP.GE.AND P1, PT, R15, -0x434, PT ; R15 > -1076 = -(1022 + 54)
        /*0460*/                   ISETP.NE.AND P0, PT, R16, RZ, PT ;
        /*0470*/                   SEL R17, RZ, 0x1, P0 ;
        /*0480*/              @!P1 IMAD.MOV.U32 R2, RZ, RZ, R17 ;
        /*0490*/              @!P1 IMAD.MOV.U32 R3, RZ, RZ, R16 ;
        /*04a0*/              @!P1 BRA `(.L_x_1) ;
        /*04b0*/                   DFMA.RZ R4, R8, R10, R6 ;
        /*04c0*/                   IADD3 R3, R15, 0x43e, RZ ; R3 = R15(r5_exp_true) + 1022 + 64
        /*04d0*/                   LOP3.LUT R14, R5, 0xfffff, RZ, 0xc0, !PT ; R14 = R5 and 0x000fffff // erase the exp
        /*04e0*/                   SHF.L.U32 R2, R4, R3.reuse, RZ ; R2 = R4 << (64 + r5_exp_true + 1022) // significant mantissa
        /*04f0*/                   LOP3.LUT R14, R14, 0x100000, RZ, 0xfc, !PT ; R14 = R14 or 0x100000
        /*0500*/                   ISETP.NE.U32.AND P0, PT, R2, RZ, PT ;
        /*0510*/                   SHF.L.U64.HI R3, R4, R3, R14           ; R[3:2] = R[14:4] << R3
        /*0520*/                   ISETP.NE.AND.EX P0, PT, R3, RZ, PT, P0 ; P0 = (R[3:2] == 0)?
        /*0530*/                   DFMA.RM R2, R8, R10, R6 ; R[3:2] = r5_rd
        /*0540*/                   DSETP.NE.OR P0, PT, R12, R2, P0 ; P0 = (r5_rd != r5_ru) || P0
        /*0550*/                   IADD3 R3, -R15, -0x3fe, RZ ; R3 = -(R15 + 1022)
        /*0560*/                   SHF.R.S64 R5, R4, R3.reuse, R14.reuse ;
        /*0570*/                   SHF.R.S32.HI R6, RZ, R3, R14 ;
        /*0580*/                   SEL R2, RZ, 0x1, !P0 ;
        /*0590*/                   IADD3 R4, P0, R5, 0x1, RZ ; R4 = R5 + 0x1
        /*05a0*/                   LOP3.LUT R2, R17, R2, RZ, 0xc0, !PT ;
        /*05b0*/                   IMAD.X R3, RZ, RZ, R6, P0 ;
        /*05c0*/                   IMAD.MOV R2, RZ, RZ, -R2 ;
        /*05d0*/                   ISETP.GE.AND P0, PT, R2, RZ, PT ;
        /*05e0*/                   SEL R3, R6, R3, P0 ;
        /*05f0*/                   SEL R2, R5, R4, P0 ; //R2 = R4
        /*0600*/                   LOP3.LUT R3, R3, R16, RZ, 0xfc, !PT ;
.L_x_1:
        /*0610*/                   IMAD.MOV.U32 R4, RZ, RZ, R2 ;
        /*0620*/                   IMAD.MOV.U32 R5, RZ, RZ, R3 ;
        /*0630*/                   IMAD.MOV.U32 R2, RZ, RZ, R0 ;
        /*0640*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;
        /*0650*/                   RET.REL.NODEC R2 `(_Z4drcpPdd) ;
.L_x_3:
        /*0660*/                   BRA `(.L_x_3);
        /*0670*/                   NOP;
.L_x_4:
