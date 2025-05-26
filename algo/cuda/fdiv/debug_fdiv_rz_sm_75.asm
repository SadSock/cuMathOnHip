
Fatbin elf code:
================
arch = sm_75
code version = [1,7]
host = linux
compile_size = 64bit

	code for sm_75

Fatbin elf code:
================
arch = sm_75
code version = [1,7]
host = linux
compile_size = 64bit

	code for sm_75
		Function : _Z12test_fdiv_rzPfff
	.headerflags    @"EF_CUDA_SM75 EF_CUDA_PTX_SM(EF_CUDA_SM75)"
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;              /* 0x00000a00ff017624 */
                                                                                        /* 0x000fc400078e00ff */
        /*0010*/                   MOV R10, 0x30 ;                                      /* 0x00000030000a7802 */
                                                                                        /* 0x000fcc0000000f00 */
        /*0020*/                   CALL.REL.NOINC 0x60 ;                                /* 0x0000003000007944 */
                                                                                        /* 0x000fea0003c00000 */
        /*0030*/                   ULDC.64 UR4, c[0x0][0x160] ;                         /* 0x0000580000047ab9 */
                                                                                        /* 0x000fe40000000a00 */
        /*0040*/                   STG.E.SYS [UR4], R5 ;                                /* 0x00000005ff007986 */
                                                                                        /* 0x001fe2000c10e904 */
        /*0050*/                   EXIT ;                                               /* 0x000000000000794d */
                                                                                        /* 0x000fea0003800000 */
                                   // R9 = y
                                   // R7 = x
                                   // y  = c[0x0][0x168]
                                   // x  = c[0x0][0x16c]
        /*0060*/                   IMAD.MOV.U32 R9, RZ, RZ, c[0x0][0x168] ;             /* 0x00005a00ff097624 */
                                                                                        /* 0x000fe400078e00ff */
        /*0070*/                   IMAD.MOV.U32 R7, RZ, RZ, c[0x0][0x16c] ;             /* 0x00005b00ff077624 */
                                                                                        /* 0x000fe400078e00ff */
                                   // R6 = y << 1
        /*0080*/                   IMAD.SHL.U32 R6, R9, 0x2, RZ ;                       /* 0x0000000209067824 */
                                                                                        /* 0x000fe400078e00ff */
                                   // R8 = x << 1
        /*0090*/                   IMAD.SHL.U32 R8, R7, 0x2, RZ ;                       /* 0x0000000207087824 */
                                                                                        /* 0x000fe400078e00ff */
                                   // R2 = y
        /*00a0*/                   IMAD.MOV.U32 R2, RZ, RZ, c[0x0][0x168] ;             /* 0x00005a00ff027624 */
                                                                                        /* 0x000fe200078e00ff */
                                   // R0 = y_exp - 1
        /*00b0*/                   LEA.HI R0, R6, 0xffffffff, RZ, 0x8 ;                 /* 0xffffffff06007811 */
                                                                                        /* 0x000fe200078f40ff */
                                   // R4 = x
        /*00c0*/                   IMAD.MOV.U32 R4, RZ, RZ, c[0x0][0x16c] ;             /* 0x00005b00ff047624 */
                                                                                        /* 0x000fe200078e00ff */
                                   // R3 = x_exp - 1
        /*00d0*/                   LEA.HI R3, R8, 0xffffffff, RZ, 0x8 ;                 /* 0xffffffff08037811 */
                                                                                        /* 0x000fc400078f40ff */
                                   //  P0 = if( x_exp - 1 > 0xfd or y_exp - 1 > 0xfd   )
        /*00e0*/                   ISETP.GT.U32.AND P0, PT, R0, 0xfd, PT ;              /* 0x000000fd0000780c */
                                                                                        /* 0x000fc80003f04070 */
        /*00f0*/                   ISETP.GT.U32.OR P0, PT, R3, 0xfd, P0 ;               /* 0x000000fd0300780c */
                                                                                        /* 0x000fd80000704470 */
        /*0100*/              @!P0 BRA 0x360 ;                                          /* 0x0000025000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   //  P0 = isnan(y) 
                                   //  P1 = isnan(x) 
                                   //  P0 = !isnan(x) & !isnan(y) 
        /*0110*/                   FSETP.GTU.FTZ.AND P0, PT, |R9|, +INF , PT ;          /* 0x7f8000000900780b */
                                                                                        /* 0x000fe40003f1c200 */
        /*0120*/                   FSETP.GTU.FTZ.AND P1, PT, |R7|, +INF , PT ;          /* 0x7f8000000700780b */
                                                                                        /* 0x000fc80003f3c200 */
                                   //  P0 = !P0 & !P1
        /*0130*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2, 0x0 ;             /* 0x000000000000781c */
                                                                                        /* 0x000fd80000702072 */
        /*0140*/              @!P0 FADD.FTZ R5, R9, c[0x0][0x16c] ;                     /* 0x00005b0009058621 */
                                                                                        /* 0x000fe20000010000 */
        /*0150*/              @!P0 BRA 0x580 ;                                          /* 0x0000042000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R6 = y << 1
                                   // R8 = x << 1
                                   // P0 = if(R6 != 0)
        /*0160*/                   ISETP.NE.U32.AND P0, PT, R6, RZ, PT ;                /* 0x000000ff0600720c */
                                                                                        /* 0x000fe40003f05070 */
                                   // P1 = if(R8 != 0)
        /*0170*/                   ISETP.NE.U32.AND P1, PT, R8, RZ, PT ;                /* 0x000000ff0800720c */
                                                                                        /* 0x000fe40003f25070 */
        /*0180*/                   SEL R5, RZ, 0x1, P0 ;                                /* 0x00000001ff057807 */
                                                                                        /* 0x000fe40000000000 */
        /*0190*/                   SEL R6, RZ, 0x1, P1 ;                                /* 0x00000001ff067807 */
                                                                                        /* 0x000fc80000800000 */
                                   uint32_t x_flag = 0;
                                   uint32_t y_flag = 0;
                                   if(y << 1 != 0){
                                     y_flag = 0x0;
                                   }else{
                                     y_flag = 0x1;
                                   }
                                   if(x << 1 != 0){
                                     x_flag = 0x0;
                                   }else{
                                     x_flag = 0x1;
                                   }
                                   flag = x_flag(R6) and y_flag(R5)
        /*01a0*/                   LOP3.LUT P0, RZ, R5, R6, RZ, 0xc0, !PT ;             /* 0x0000000605ff7212 */
                                                                                        /* 0x000fd8000780c0ff */
        /*01b0*/               @P0 BRA 0x200 ;                                          /* 0x0000004000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // if(fabs(y) != INFINITY)
        /*01c0*/                   FSETP.NEU.FTZ.AND P0, PT, |R9|, +INF , PT ;          /* 0x7f8000000900780b */
                                                                                        /* 0x000fe40003f1d200 */
                                   // if(fabs(x) != INFINITY)
        /*01d0*/                   FSETP.NEU.FTZ.AND P1, PT, |R7|, +INF , PT ;          /* 0x7f8000000700780b */
                                                                                        /* 0x000fc80003f3d200 */
                                   // P2 = P0 or P1
        /*01e0*/                   PLOP3.LUT P2, PT, P0, P1, PT, 0xa8, 0x0 ;            /* 0x000000000000781c */
                                                                                        /* 0x000fd80000743570 */
                                   // if(fabs(y) != INFINITY || fabs(x) != INFINITY)
        /*01f0*/               @P2 BRA 0x220 ;                                          /* 0x0000002000002947 */
                                                                                        /* 0x000fea0003800000 */
        /*0200*/                   MUFU.RSQ R5, -QNAN  ;                                /* 0xffc0000000057908 */
                                                                                        /* 0x000e220000001400 */
        /*0210*/                   BRA 0x580 ;                                          /* 0x0000036000007947 */
                                   
                                   //if(fabs(x) != INFINITY){
                                   //    R8 = 0x0;
                                   //  }else{
                                   //    R8 = 0x1;
                                   //}
                                                                                        /* 0x000fea0003800000 */
        /*0220*/                   SEL R8, RZ, 0x1, P1 ;                                /* 0x00000001ff087807 */
                                                                                        /* 0x000fc80000800000 */
                                   // P1 = R8 or R5(y_flag)
        /*0230*/                   LOP3.LUT P1, RZ, R8, R5, RZ, 0xfc, !PT ;             /* 0x0000000508ff7212 */
                                                                                        /* 0x000fd8000782fcff */
                                   // R5 = x XOR y
        /*0240*/               @P1 LOP3.LUT R5, R7, c[0x0][0x168], RZ, 0x3c, !PT ;      /* 0x00005a0007051a12 */
                                                                                        /* 0x000fc800078e3cff */
                                   // R5 = R5 AND 0x80000000
        /*0250*/               @P1 LOP3.LUT R5, R5, 0x80000000, RZ, 0xc0, !PT ;         /* 0x8000000005051812 */
                                                                                        /* 0x000fe200078ec0ff */
        /*0260*/               @P1 BRA 0x580 ;                                          /* 0x0000031000001947 */
                                                                                        /* 0x000fea0003800000 */
                                   //if(fabs(y) != INFINITY){
                                   //    R5 = 0x0;
                                   //  }else{
                                   //    R5 = 0x1;
                                   //}
                                                                                        /* 0x000fea0003800000 */
        /*0270*/                   SEL R5, RZ, 0x1, P0 ;                                /* 0x00000001ff057807 */
                                                                                        /* 0x000fc80000000000 */
                                   // P0 = R5 or x_flag
        /*0280*/                   LOP3.LUT P0, RZ, R5, R6, RZ, 0xfc, !PT ;             /* 0x0000000605ff7212 */
                                                                                        /* 0x000fd8000780fcff */
                                   // R5 = x XOR y
        /*0290*/               @P0 LOP3.LUT R5, R7, c[0x0][0x168], RZ, 0x3c, !PT ;      /* 0x00005a0007050a12 */
                                                                                        /* 0x000fc800078e3cff */
                                   // R5 = R5 AND 0x80000000
        /*02a0*/               @P0 LOP3.LUT R5, R5, 0x80000000, RZ, 0xc0, !PT ;         /* 0x8000000005050812 */
                                                                                        /* 0x000fc800078ec0ff */
                                   // R5 = R5 OR 0x7f800000
        /*02b0*/               @P0 LOP3.LUT R5, R5, 0x7f800000, RZ, 0xfc, !PT ;         /* 0x7f80000005050812 */
                                                                                        /* 0x000fe200078efcff */
        /*02c0*/               @P0 BRA 0x580 ;                                          /* 0x000002b000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R0 = y_exp - 1
                                   // R3 = x_exp - 1
        /*02d0*/                   ISETP.GE.AND P0, PT, R0, RZ, PT ;                    /* 0x000000ff0000720c */
                                                                                        /* 0x000fe40003f06270 */
        /*02e0*/                   ISETP.GE.AND P1, PT, R3, RZ, PT ;                    /* 0x000000ff0300720c */
                                                                                        /* 0x000fd40003f26270 */
        /*02f0*/              @!P0 IMAD.MOV.U32 R5, RZ, RZ, -0x40 ;                     /* 0xffffffc0ff058424 */
                                                                                        /* 0x000fe400078e00ff */
        /*0300*/              @!P0 FFMA R2, R9, 1.84467440737095516160e+19, RZ ;        /* 0x5f80000009028823 */
                                                                                        /* 0x000fe400000000ff */
        /*0310*/               @P0 IMAD.MOV.U32 R5, RZ, RZ, RZ ;                        /* 0x000000ffff050224 */
                                                                                        /* 0x000fe200078e00ff */
        /*0320*/               @P1 BRA 0x370 ;                                          /* 0x0000004000001947 */
                                                                                        /* 0x000fea0003800000 */
        /*0330*/                   FFMA R4, R7, 1.84467440737095516160e+19, RZ ;        /* 0x5f80000007047823 */
                                                                                        /* 0x000fe200000000ff */
        /*0340*/                   IADD3 R5, R5, 0x40, RZ ;                             /* 0x0000004005057810 */
                                                                                        /* 0x000fe20007ffe0ff */
        /*0350*/                   BRA 0x370 ;                                          /* 0x0000001000007947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R0 = y_exp - 1
                                   // R5 = 0
                                   // R3 = x_exp - 1
                                   // R4 = x
                                   // R2 = y
        /*0360*/                   IMAD.MOV.U32 R5, RZ, RZ, RZ ;                        /* 0x000000ffff057224 */
                                                                                        /* 0x000fc400078e00ff */
                                   // R7 = R3 = x_exp - 1 - 0x7e
        /*0370*/                   IADD3 R7, R3, -0x7e, RZ ;                            /* 0xffffff8203077810 */
                                                                                        /* 0x000fca0007ffe0ff */
                                   // R4 = x0 = x - (R7 << 23)
                                   // scale the exp of x to 0x7f
        /*0380*/                   IMAD R4, R7, -0x800000, R4 ;                         /* 0xff80000007047824 */
                                                                                        /* 0x000fe200078e0204 */
                                   // R7 = R0 = y_exp - 1 - 0x7e
        /*0390*/                   IADD3 R7, R0, -0x7e, RZ ;                            /* 0xffffff8200077810 */
                                                                                        /* 0x000fca0007ffe0ff */
                                   // R9 = r0 = rcp(x0)
        /*03a0*/                   MUFU.RCP R9, R4 ;                                    /* 0x0000000400097308 */
                                                                                        /* 0x000e220000001000 */
                                   // R2 = y0 = y - ((y_exp - 0x7f) << 23)
                                   // scale the exp of x to 0x7f
        /*03b0*/                   IMAD R2, R7, -0x800000, R2 ;                         /* 0xff80000007027824 */
                                                                                        /* 0x000fe400078e0202 */
                                   // R7 = x1 = -x0
        /*03c0*/                   FADD.FTZ R7, -R4, -RZ ;                              /* 0x800000ff04077221 */
                                                                                        /* 0x000fe40000010100 */
                                   // R2 = y0
                                   // R4 = x0
                                   // R7 = x1
                                   // R9 = r0
                                   
                                   // R6 = q0 = y0 * r0 + 0.0
        /*03d0*/                   FFMA R6, R2, R9, RZ ;                                /* 0x0000000902067223 */
                                                                                        /* 0x001fc800000000ff */
                                   // R8 = dd0 = x1 * q0 + y0
        /*03e0*/                   FFMA R8, R7, R6, R2 ;                                /* 0x0000000607087223 */
                                                                                        /* 0x000fc80000000002 */
                                   // R8 = q1 = r0 * dd0 + q0
        /*03f0*/                   FFMA R8, R9, R8, R6 ;                                /* 0x0000000809087223 */
                                                                                        /* 0x000fc80000000006 */
                                   // R2 = dd1 = x1 * q1 + y0
        /*0400*/                   FFMA R2, R7, R8, R2 ;                                /* 0x0000000807027223 */
                                                                                        /* 0x000fc80000000002 */
                                   // R8 = q2 = r0 * dd1 + q1
        /*0410*/                   FFMA.RZ R8, R9, R2, R8 ;                             /* 0x0000000209087223 */
                                                                                        /* 0x000fc8000000c008 */
                                   // R2 = q2 << 1
        /*0420*/                   IMAD.SHL.U32 R2, R8, 0x2, RZ ;                       /* 0x0000000208027824 */
                                                                                        /* 0x000fca00078e00ff */
                                   // R2 =  = q2_exp = R2 >> 24
        /*0430*/                   SHF.R.U32.HI R2, RZ, 0x18, R2 ;                      /* 0x00000018ff027819 */
                                                                                        /* 0x000fc80000011602 */
                                   // R0 = y_exp - 1
                                   // R3 = x_exp - 1
                                   // R5 = fixup_exp
                                   
                                   // R0 = q2_exp + (y_exp - 1) - (x_exp - 1) = q2_exp + y_exp - x_exp
        /*0440*/                   IADD3 R0, R2, R0, -R3 ;                              /* 0x0000000002007210 */
                                                                                        /* 0x000fca0007ffe803 */
                                   // R3 = R0 * 0x1 + R5 = R0 = q2_exp + y_exp - x_exp + fixup_exp
        /*0450*/                   IMAD.IADD R3, R0, 0x1, R5 ;                          /* 0x0000000100037824 */
                                                                                        /* 0x000fca00078e0205 */
                                   // R0 = q2_exp + y_exp - 1 - x_exp + fixup_exp
        /*0460*/                   IADD3 R0, R3, -0x1, RZ ;                             /* 0xffffffff03007810 */
                                                                                        /* 0x000fc80007ffe0ff */
        /*0470*/                   ISETP.GT.U32.AND P0, PT, R0, 0xfd, PT ;              /* 0x000000fd0000780c */
                                                                                        /* 0x000fd80003f04070 */
                                   // R5 = q2_exp + (y_exp - 1) - (x_exp - 1) - q2_exp = y_exp - x_exp + fixup_exp
        /*0480*/              @!P0 IMAD.IADD R5, R3, 0x1, -R2 ;                         /* 0x0000000103058824 */
                                                                                        /* 0x000fc800078e0a02 */
                                   // R5 = q3 = (y_exp - x_exp + fixup_exp) * 0x800000 + q2
        /*0490*/              @!P0 IMAD R5, R5, 0x800000, R8 ;                          /* 0x0080000005058824 */
                                                                                        /* 0x000fe200078e0208 */
        /*04a0*/              @!P0 BRA 0x580 ;                                          /* 0x000000d000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R3 = q2_exp + y_exp - x_exp
                                   // P0 = if(q2_exp + y_exp - x_exp > 0xfe)
        /*04b0*/                   ISETP.GT.AND P0, PT, R3, 0xfe, PT ;                  /* 0x000000fe0300780c */
                                                                                        /* 0x000fe20003f04270 */
                                   // R5 = q3 = q2
        /*04c0*/                   IMAD.MOV.U32 R5, RZ, RZ, R8 ;                        /* 0x000000ffff057224 */
                                                                                        /* 0x000fd600078e0008 */
                                   // q3 = 0x7f7fffff
        /*04d0*/               @P0 IMAD.MOV.U32 R5, RZ, RZ, 0x7f7fffff ;                /* 0x7f7fffffff050424 */
                                                                                        /* 0x000fe200078e00ff */
        /*04e0*/               @P0 BRA 0x570 ;                                          /* 0x0000008000000947 */
                                                                                        /* 0x000fea0003800000 */
        /*04f0*/                   ISETP.GT.AND P0, PT, R3, RZ, PT ;                    /* 0x000000ff0300720c */
                                                                                        /* 0x000fd80003f04270 */
        /*0500*/               @P0 BRA 0x570 ;                                          /* 0x0000006000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R3 = q2_exp + y_exp - x_exp
                                   // P0 = if(q2_exp + y_exp - x_exp >= -0x18)
        /*0510*/                   ISETP.GE.AND P0, PT, R3, -0x18, PT ;                 /* 0xffffffe80300780c */
                                                                                        /* 0x000fd80003f06270 */
                                   // R0 =  q2 and 0x7fffff
        /*0520*/               @P0 LOP3.LUT R0, R8, 0x7fffff, RZ, 0xc0, !PT ;           /* 0x007fffff08000812 */
                                                                                        /* 0x000fe200078ec0ff */
        /*0530*/              @!P0 IMAD.MOV.U32 R5, RZ, RZ, RZ ;                        /* 0x000000ffff058224 */
                                                                                        /* 0x000fe200078e00ff */
                                   // R3 = 1 - (q2_exp + y_exp - x_exp)
        /*0540*/               @P0 IADD3 R3, -R3, 0x1, RZ ;                             /* 0x0000000103030810 */
                                   // R0 = R0 or 0x800000                                                     /* 0x000fe40007ffe1ff */
        /*0550*/               @P0 LOP3.LUT R0, R0, 0x800000, RZ, 0xfc, !PT ;           /* 0x0080000000000812 */
                                   // q3 = R0 >> R3                                                     /* 0x000fc800078efcff */
        /*0560*/               @P0 SHF.R.U32.HI R5, RZ, R3, R0 ;                        /* 0x00000003ff050219 */
                                   // q3 = q3 or (q2 and 0x80000000)                                                      /* 0x000fc80000011600 */
        /*0570*/                   LOP3.LUT R5, R5, 0x80000000, R8, 0xf8, !PT ;         /* 0x8000000005057812 */
                                                                                        /* 0x000fcc00078ef808 */
        /*0580*/                   IMAD.MOV.U32 R2, RZ, RZ, R10 ;                       /* 0x000000ffff027224 */
                                                                                        /* 0x000fe400078e000a */
        /*0590*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;                       /* 0x00000000ff037424 */
                                                                                        /* 0x000fcc00078e00ff */
        /*05a0*/                   RET.REL.NODEC R2 0x0 ;                               /* 0xfffffa5002007950 */
                                                                                        /* 0x000fea0003c3ffff */
        /*05b0*/                   BRA 0x5b0;                                           /* 0xfffffff000007947 */
                                                                                        /* 0x000fc0000383ffff */
        /*05c0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*05d0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*05e0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*05f0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
		..........



Fatbin ptx code:
================
arch = sm_75
code version = [7,7]
host = linux
compile_size = 64bit
compressed
