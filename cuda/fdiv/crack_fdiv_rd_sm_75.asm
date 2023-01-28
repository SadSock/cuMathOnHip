
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
		Function : _Z13crack_fdiv_rzPfff
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
                                   // R9 = y0
                                   // R7 = x0
                                   // R6 = y0 << 1
                                   // R8 = x0 << 1
                                   // R2 = y0
                                   // R0 = y0_exp - 1 = (y0 << 1 >> 24) - 1;
                                   // R4 = x0
                                   // R3 = x0_exp - 1 = (x0 << 1 >> 24) - 1;
        /*0060*/                   IMAD.MOV.U32 R9, RZ, RZ, c[0x0][0x168] ;             /* 0x00005a00ff097624 */
                                                                                        /* 0x000fe400078e00ff */
        /*0070*/                   IMAD.MOV.U32 R7, RZ, RZ, c[0x0][0x16c] ;             /* 0x00005b00ff077624 */
                                                                                        /* 0x000fe400078e00ff */
        /*0080*/                   IMAD.SHL.U32 R6, R9, 0x2, RZ ;                       /* 0x0000000209067824 */
                                                                                        /* 0x000fe400078e00ff */
        /*0090*/                   IMAD.SHL.U32 R8, R7, 0x2, RZ ;                       /* 0x0000000207087824 */
                                                                                        /* 0x000fe400078e00ff */
        /*00a0*/                   IMAD.MOV.U32 R2, RZ, RZ, c[0x0][0x168] ;             /* 0x00005a00ff027624 */
                                                                                        /* 0x000fe200078e00ff */
        /*00b0*/                   LEA.HI R0, R6, 0xffffffff, RZ, 0x8 ;                 /* 0xffffffff06007811 */
                                                                                        /* 0x000fe200078f40ff */
        /*00c0*/                   IMAD.MOV.U32 R4, RZ, RZ, c[0x0][0x16c] ;             /* 0x00005b00ff047624 */
                                                                                        /* 0x000fe200078e00ff */
        /*00d0*/                   LEA.HI R3, R8, 0xffffffff, RZ, 0x8 ;                 /* 0xffffffff08037811 */
                                                                                        /* 0x000fc400078f40ff */
        /*00e0*/                   ISETP.GT.U32.AND P0, PT, R0, 0xfd, PT ;              /* 0x000000fd0000780c */
                                                                                        /* 0x000fc80003f04070 */
        /*00f0*/                   ISETP.GT.U32.OR P0, PT, R3, 0xfd, P0 ;               /* 0x000000fd0300780c */
                                                                                        /* 0x000fd80000704470 */
        /*0100*/              @!P0 BRA 0x360 ;                                          /* 0x0000025000008947 */
                                   // case::
                                   // if(y0_exp - 1 > 0xfd || x0_exp - 1 > 0xfd )
                                   // x0 is nan (x0_exp = 0xff)
                                   // x0 is denormal (x0_exp = 0x0)
                                   // y0 is nan (y0_exp = 0xff)
                                   // y0 is denormal (y0_exp = 0x0)


                                   // P0 = is_nan(y0)
        /*0110*/                   FSETP.GTU.FTZ.AND P0, PT, |R9|, +INF , PT ;          /* 0x7f8000000900780b */
                                                                                        /* 0x000fe40003f1c200 */
                                   // P1 = is_nan(x0)
        /*0120*/                   FSETP.GTU.FTZ.AND P1, PT, |R7|, +INF , PT ;          /* 0x7f8000000700780b */
                                                                                        /* 0x000fc80003f3c200 */
                                   // P0 = !P0 & !P1
        /*0130*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2, 0x0 ;             /* 0x000000000000781c */
                                   // case::
                                   // if( is_nan(x0) || is_nan(y0) )
                                   // return x0 + y0
        /*0140*/              @!P0 FADD.FTZ R5, R9, c[0x0][0x16c] ;                     /* 0x00005b0009058621 */
                                                                                        /* 0x000fe20000010000 */
        /*0150*/              @!P0 BRA 0x710 ;                                          /* 0x000005b000008947 */
                                                                                        /* 0x000fea0003800000 */
        /*0160*/                   ISETP.NE.U32.AND P0, PT, R6, RZ, PT ;                /* 0x000000ff0600720c */
                                                                                        /* 0x000fe40003f05070 */
        /*0170*/                   ISETP.NE.U32.AND P1, PT, R8, RZ, PT ;                /* 0x000000ff0800720c */
                                                                                        /* 0x000fe40003f25070 */
                                   // bool R5 = y0==0.0
        /*0180*/                   SEL R5, RZ, 0x1, P0 ;                                /* 0x00000001ff057807 */
                                                                                        /* 0x000fe40000000000 */
                                   // bool R6 = x0==0.0
        /*0190*/                   SEL R6, RZ, 0x1, P1 ;                                /* 0x00000001ff067807 */
                                                                                        /* 0x000fc80000800000 */
                                   // bool P0 = ((x0==0.0) && (y0==0.0))
        /*01a0*/                   LOP3.LUT P0, RZ, R5, R6, RZ, 0xc0, !PT ;             /* 0x0000000605ff7212 */
                                                                                        /* 0x000fd8000780c0ff */
        /*01b0*/               @P0 BRA 0x200 ;                                          /* 0x0000004000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // case::
                                   // if(x0!=0 || y0!=0 )
                                   //
                                   //
                                   //

                                   // P0 = !(abs(y0)==inf)
        /*01c0*/                   FSETP.NEU.FTZ.AND P0, PT, |R9|, +INF , PT ;          /* 0x7f8000000900780b */
                                                                                        /* 0x000fe40003f1d200 */
                                   // P1 = !(abs(x0)==inf)
        /*01d0*/                   FSETP.NEU.FTZ.AND P1, PT, |R7|, +INF , PT ;          /* 0x7f8000000700780b */
                                                                                        /* 0x000fc80003f3d200 */
                                   // P2 = !(abs(y0)==inf) || !(abs(x0)==inf)
        /*01e0*/                   PLOP3.LUT P2, PT, P0, P1, PT, 0xa8, 0x0 ;            /* 0x000000000000781c */
                                                                                        /* 0x000fd80000743570 */
        /*01f0*/               @P2 BRA 0x220 ;                                          /* 0x0000002000002947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R5 = 0x7fffffff
        /*0200*/                   MUFU.RSQ R5, -QNAN  ;                                /* 0xffc0000000057908 */
                                                                                        /* 0x000e220000001400 */
        /*0210*/                   BRA 0x710 ;                                          /* 0x000004f000007947 */
                                                                                        /* 0x000fea0003800000 */
                                   // bool R8 = (abs(x0)==inf)
        /*0220*/                   SEL R8, RZ, 0x1, P1 ;                                /* 0x00000001ff087807 */
                                                                                        /* 0x000fc80000800000 */
                                   // P1 = (abs(x0)==inf) || (y0==0.0)
        /*0230*/                   LOP3.LUT P1, RZ, R8, R5, RZ, 0xfc, !PT ;             /* 0x0000000508ff7212 */
                                                                                        /* 0x000fd8000782fcff */
                                   // R5 = (x0 & y0) | (~x0 & ~y0)
        /*0240*/               @P1 LOP3.LUT R5, R7, c[0x0][0x168], RZ, 0x3c, !PT ;      /* 0x00005a0007051a12 */
                                                                                        /* 0x000fc800078e3cff */
                                   // R5 = (~R5) & 0x80000000
        /*0250*/               @P1 LOP3.LUT R5, R5, 0x80000000, RZ, 0xc0, !PT ;         /* 0x8000000005051812 */
                                                                                        /* 0x000fe200078ec0ff */
                                   // if( (abs(x0)==inf) && (y0==0.0))
                                   //   R5 = (x0 ^ y0) & 0x80000000;
                                   //   return R5;
        /*0260*/               @P1 BRA 0x710 ;                                          /* 0x000004a000001947 */
                                                                                        /* 0x000fea0003800000 */
                                   //   bool R5 = (abs(y0)==inf);
        /*0270*/                   SEL R5, RZ, 0x1, P0 ;                                /* 0x00000001ff057807 */
                                                                                        /* 0x000fc80000000000 */
                                   //   bool P0 = ((abs(y0)==inf) || (x0 == 0.0));
        /*0280*/                   LOP3.LUT P0, RZ, R5, R6, RZ, 0xfc, !PT ;             /* 0x0000000605ff7212 */
                                                                                        /* 0x000fd8000780fcff */
                                   // R5 = (x0 & y0) | (~x0 & ~y0)
        /*0290*/               @P0 LOP3.LUT R5, R7, c[0x0][0x168], RZ, 0x3c, !PT ;      /* 0x00005a0007050a12 */
                                                                                        /* 0x000fc800078e3cff */
                                   // R5 = (~R5) & 0x80000000
        /*02a0*/               @P0 LOP3.LUT R5, R5, 0x80000000, RZ, 0xc0, !PT ;         /* 0x8000000005050812 */
                                                                                        /* 0x000fc800078ec0ff */
                                   // R5 = R5 | 0x7f800000
        /*02b0*/               @P0 LOP3.LUT R5, R5, 0x7f800000, RZ, 0xfc, !PT ;         /* 0x7f80000005050812 */
                                                                                        /* 0x000fe200078efcff */
                                   // if( (abs(y0)==inf) && (x0==0.0))
                                   //   R5 = (x0 ^ y0) & 0x80000000 | 0x7f800000;
                                   //   return R5;
        /*02c0*/               @P0 BRA 0x710 ;                                          /* 0x0000044000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // P0 = y0_is_denormal;
                                   // bool y0_is_denormal = (y0_exp - 1 >= 0)
        /*02d0*/                   ISETP.GE.AND P0, PT, R0, RZ, PT ;                    /* 0x000000ff0000720c */
                                   // P1 = x0_is_denormal;
                                   // bool x0_is_denormal = (x0_exp - 1 >= 0)
        /*02e0*/                   ISETP.GE.AND P1, PT, R3, RZ, PT ;                    /* 0x000000ff0300720c */
                                                                                        /* 0x000fd40003f26270 */
                                   // R5 = exp_fixup
                                   // R2 = y1 = y0 * 2^64;
                                   // if(y0_exp - 1 >= 0){
                                   //   exp_fixup = 0;
                                   //   }else{
                                   //   exp_fixup = -0x40;
                                   //   y1 = y0 * 0x5f800000 (2^64);
                                   //   }
        /*02f0*/              @!P0 IMAD.MOV.U32 R5, RZ, RZ, -0x40 ;                     /* 0xffffffc0ff058424 */
                                                                                        /* 0x000fe400078e00ff */
        /*0300*/              @!P0 FFMA R2, R9, 1.84467440737095516160e+19, RZ ;        /* 0x5f80000009028823 */
                                                                                        /* 0x000fe400000000ff */
        /*0310*/               @P0 IMAD.MOV.U32 R5, RZ, RZ, RZ ;                        /* 0x000000ffff050224 */
                                                                                        /* 0x000fe200078e00ff */
                                   // R4 = x1 = x0 * 2^64
                                   // if(x0_exp - 1 >= 0){
                                   //   exp_fixup = exp_fixup + 0x40;
                                   //   x1 = x0 * 0x5f800000 (2^64);
                                   //   }
        /*0320*/               @P1 BRA 0x370 ;                                          /* 0x0000004000001947 */
                                                                                        /* 0x000fea0003800000 */
        /*0330*/                   FFMA R4, R7, 1.84467440737095516160e+19, RZ ;        /* 0x5f80000007047823 */
                                                                                        /* 0x000fe200000000ff */
        /*0340*/                   IADD3 R5, R5, 0x40, RZ ;                             /* 0x0000004005057810 */
                                                                                        /* 0x000fe20007ffe0ff */
        /*0350*/                   BRA 0x370 ;                                          /* 0x0000001000007947 */
                                                                                        /* 0x000fea0003800000 */
        /*0360*/                   IMAD.MOV.U32 R5, RZ, RZ, RZ ;                        /* 0x000000ffff057224 */
                                                                                        /* 0x000fc400078e00ff */
                                   // R7 = x0_exp - 0x7f
        /*0370*/                   IADD3 R7, R3, -0x7e, RZ ;                            /* 0xffffff8203077810 */
                                                                                        /* 0x000fca0007ffe0ff */
                                   // R4 = x1 = x1 - (x0_exp - 0x7f) * 0x800000;
        /*0380*/                   IMAD R4, R7, -0x800000, R4 ;                         /* 0xff80000007047824 */
                                                                                        /* 0x000fe200078e0204 */
                                   // R7 = y0_exp - 0x7f
        /*0390*/                   IADD3 R7, R0, -0x7e, RZ ;                            /* 0xffffff8200077810 */
                                                                                        /* 0x000fca0007ffe0ff */
                                   // R11 = x1_rcp = rcp(x1)
        /*03a0*/                   MUFU.RCP R11, R4 ;                                   /* 0x00000004000b7308 */
                                                                                        /* 0x000e220000001000 */
                                   // R2 = y1 = y1 - (y0_exp - 0x7f) * 0x800000;
        /*03b0*/                   IMAD R2, R7, -0x800000, R2 ;                         /* 0xff80000007027824 */
                                                                                        /* 0x000fe400078e0202 */
                                   // R7 = -x1
                                   // R2 = y1
                                   //NOTE: FTZ???
        /*03c0*/                   FADD.FTZ R7, -R4, -RZ ;                              /* 0x800000ff04077221 */
                                                                                        /* 0x000fe40000010100 */
                                   // R6 = q1 = __builtin_fma( y1, x1_rcp, 0.0);
        /*03d0*/                   FFMA R6, R2, R11, RZ ;                               /* 0x0000000b02067223 */
                                                                                        /* 0x001fc800000000ff */
                                   // R9 = d1 = __builtin_fma( -x1, q1, y1);
        /*03e0*/                   FFMA R9, R7, R6, R2 ;                                /* 0x0000000607097223 */
                                                                                        /* 0x000fc80000000002 */
                                   // R6 = q2 = __builtin_fma( x1_rcp, d1, q1);
        /*03f0*/                   FFMA R6, R11, R9, R6 ;                               /* 0x000000090b067223 */
                                                                                        /* 0x000fc80000000006 */
                                   // R7 = d2 = __builtin_fma( -x1, q2, y1);
        /*0400*/                   FFMA R7, R7, R6, R2 ;                                /* 0x0000000607077223 */
                                                                                        /* 0x000fc80000000002 */
                                   // R9 = q3_rd = __builtin_fma_rd( x1_rcp, d2, q2);
        /*0410*/                   FFMA.RM R9, R11, R7, R6 ;                            /* 0x000000070b097223 */
                                                                                        /* 0x000fc80000004006 */
                                   // R2 = q3_rd_exp = q3_rd << 1 >> 0x18;
        /*0420*/                   IMAD.SHL.U32 R2, R9, 0x2, RZ ;                       /* 0x0000000209027824 */
                                                                                        /* 0x000fca00078e00ff */
        /*0430*/                   SHF.R.U32.HI R2, RZ, 0x18, R2 ;                      /* 0x00000018ff027819 */
                                                                                        /* 0x000fc80000011602 */
                                   // R0 = q4_rd_exp = q3_rd_exp + y0_exp - x0_exp;
        /*0440*/                   IADD3 R0, R2, R0, -R3 ;                              /* 0x0000000002007210 */
                                                                                        /* 0x000fca0007ffe803 */
                                   // R3 = q5_exp
                                   //    = q4_rd_exp + exp_fixup
                                   //    = q3_rd_exp + y0_exp - x0_exp + exp_fixup
        /*0450*/                   IMAD.IADD R3, R0, 0x1, R5 ;                          /* 0x0000000100037824 */
                                                                                        /* 0x000fca00078e0205 */
                                   // R0 = q5_exp - 0x1
        /*0460*/                   IADD3 R0, R3, -0x1, RZ ;                             /* 0xffffffff03007810 */
                                                                                        /* 0x000fc80007ffe0ff */
                                   // if(!(q5_exp - 0x1 > 0xfd))   normal float number
                                   //   R0 = R3 - R2
                                   //      = (q3_rd_exp + y0_exp - x0_exp + exp_fixup) - (q3_rd_exp)
                                   //      = y0_exp - x0_exp + exp_fixup
                                   //   R5 = q3_rd + (R0 << 23)
                                   //   return R5
        /*0470*/                   ISETP.GT.U32.AND P0, PT, R0, 0xfd, PT ;              /* 0x000000fd0000780c */
                                                                                        /* 0x000fd80003f04070 */
        /*0480*/              @!P0 IMAD.IADD R0, R3, 0x1, -R2 ;                         /* 0x0000000103008824 */
                                                                                        /* 0x000fc800078e0a02 */
        /*0490*/              @!P0 IMAD R5, R0, 0x800000, R9 ;                          /* 0x0080000000058824 */
                                                                                        /* 0x000fe200078e0209 */
        /*04a0*/              @!P0 BRA 0x710 ;                                          /* 0x0000026000008947 */
                                                                                        /* 0x000fea0003800000 */
        /*04b0*/                   ISETP.GT.AND P1, PT, R3, 0xfe, PT ;                  /* 0x000000fe0300780c */
                                                                                        /* 0x000fe20003f24270 */
                                   // R0 = R9 = q3_rd
        /*04c0*/                   IMAD.MOV.U32 R0, RZ, RZ, R9 ;                        /* 0x000000ffff007224 */
                                                                                        /* 0x000fe200078e0009 */
                                   // R13 = q3_rd & 0x80000000
        /*04d0*/                   LOP3.LUT R13, R9, 0x80000000, RZ, 0xc0, !PT ;        /* 0x80000000090d7812 */
                                                                                        /* 0x000fd400078ec0ff */
                                   // if( q5_exp > 0xfe){  q is inf
                                   //   if(q3 & 0x80000000 != 0x0)
                                   //       R0 = 0x7f800000; // inf
                                   //   else
                                   //       R0 = 0x7f7fffff; // the float with the largest absolute value
                                   //
        /*04e0*/               @P1 IMAD.MOV.U32 R2, RZ, RZ, 0x7f800000 ;                /* 0x7f800000ff021424 */
                                                                                        /* 0x000fe200078e00ff */
        /*04f0*/               @P1 ISETP.NE.AND P0, PT, R13, RZ, PT ;                   /* 0x000000ff0d00120c */
                                                                                        /* 0x000fc80003f05270 */
        /*0500*/               @P1 SEL R0, R2, 0x7f7fffff, P0 ;                         /* 0x7f7fffff02001807 */
                                                                                        /* 0x000fe20000000000 */
        /*0510*/               @P1 BRA 0x700 ;                                          /* 0x000001e000001947 */
                                                                                        /* 0x000fee0003800000 */
                                   // if( q5_exp > 0x0){  q is  not  denormal
                                   //   return R0;
                                   //
        /*0520*/                   ISETP.GT.AND P0, PT, R3, RZ, PT ;                    /* 0x000000ff0300720c */
                                                                                        /* 0x000fd80003f04270 */
        /*0530*/               @P0 BRA 0x700 ;                                          /* 0x000001c000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // if( q5_exp < -0x18){  q is infinitesimals
                                   //   if(q3 & 0x80000000 == 0x0)
                                   //       R0 = 0x0; // 0
                                   //   else
                                   //       R0 = 0x1; // the float with the lowest absolute value
                                   //
        /*0540*/                   ISETP.GE.AND P0, PT, R3, -0x18, PT ;                 /* 0xffffffe80300780c */
                                                                                        /* 0x000fd80003f06270 */
        /*0550*/              @!P0 ISETP.NE.AND P1, PT, R13, RZ, PT ;                   /* 0x000000ff0d00820c */
                                                                                        /* 0x000fc80003f25270 */
        /*0560*/              @!P0 SEL R0, RZ, 0xffffffff, !P1 ;                        /* 0xffffffffff008807 */
                                                                                        /* 0x000fca0004800000 */
        /*0570*/              @!P0 IMAD.MOV R0, RZ, RZ, -R0 ;                           /* 0x000000ffff008224 */
                                                                                        /* 0x000fe200078e0a00 */
        /*0580*/              @!P0 BRA 0x700 ;                                          /* 0x0000017000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R0 = q3_ru = __builtin_fma_ru( x1_rcp, d2, q2);
        /*0590*/                   FFMA.RP R0, R11, R7.reuse, R6.reuse ;                /* 0x000000070b007223 */
                                                                                        /* 0x180fe20000008006 */
                                   // R3 = q3_rd_exp + y0_exp - x0_exp + exp_fixup
                                   // P0 = (R3 != 0x1)
        /*05a0*/                   ISETP.NE.AND P0, PT, R3, 0x1, PT ;                   /* 0x000000010300780c */
                                                                                        /* 0x000fe20003f05270 */
                                   // R2 = q3_rz = __builtin_fma_rz( x1_rcp, d2, q2);
        /*05b0*/                   FFMA.RZ R2, R11, R7, R6 ;                            /* 0x000000070b027223 */
                                                                                        /* 0x000fc6000000c006 */
                                   // P1 = (q3_rd != q3_ru)
        /*05c0*/                   FSETP.NEU.FTZ.AND P1, PT, R9, R0, PT ;               /* 0x000000000900720b */
                                                                                        /* 0x000fe40003f3d000 */
                                   // R2 = q3_rz_mantissa = q3_rz & 0x7fffff;
        /*05d0*/                   LOP3.LUT R2, R2, 0x7fffff, RZ, 0xc0, !PT ;           /* 0x007fffff02027812 */
                                                                                        /* 0x000fe400078ec0ff */
                                   // if(q3_rd != q3_ru){
                                   //   R0 = rounding_fixup_hardware = -1;
                                   // }esle{
                                   //   R0 = rounding_fixup_hardware = 0x0;
                                   //}
        /*05e0*/                   SEL R0, RZ, 0xffffffff, !P1 ;                        /* 0xffffffffff007807 */
                                                                                        /* 0x000fe40004800000 */
                                   // R5 = R2 | 0x800000
                                   //    = q3_rz_mantissa | 0x800000
                                   //    = q4
        /*05f0*/                   LOP3.LUT R5, R2, 0x800000, RZ, 0xfc, !PT ;           /* 0x0080000002057812 */
                                                                                        /* 0x000fc600078efcff */
                                   // R0 = rounding_fixup_hardware
                                   //    = - rounding_fixup_hardware
        /*0600*/                   IMAD.MOV R0, RZ, RZ, -R0 ;                           /* 0x000000ffff007224 */
                                                                                        /* 0x000fe200078e0a00 */
        /*0610*/              @!P0 BRA 0x690 ;                                          /* 0x0000007000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   // fixup denormal
                                   // R3 = q3_rd_exp + y0_exp - x0_exp + exp_fixup
                                   // R2 = R3 + 0x1f
        /*0620*/                   IADD3 R2, R3, 0x1f, RZ ;                             /* 0x0000001f03027810 */
                                                                                        /* 0x000fc80007ffe0ff */
                                   // R2 = R3 + 0x1f
                                   // R5 = q4
                                   // R2 = q4 << (R3 + 0x1f)
                                   //    = mantissa_is_dropped
        /*0630*/                   SHF.L.U32 R2, R5, R2, RZ ;                           /* 0x0000000205027219 */
                                                                                        /* 0x000fc800000006ff */
        /*0640*/                   ISETP.NE.U32.AND P0, PT, R2, RZ, PT ;                /* 0x000000ff0200720c */
                                                                                        /* 0x000fe40003f05070 */
                                   // R2 = 0x1 - R3
        /*0650*/                   IADD3 R2, -R3, 0x1, RZ ;                             /* 0x0000000103027810 */
                                                                                        /* 0x000fe40007ffe1ff */
                                   // if(mantissa_is_dropped==0)
                                   //   rounding_fixup_denormal = 0x0;
                                   // else
                                   //   rounding_fixup_denormal = 0x1;
        /*0660*/                   SEL R3, RZ, 0x1, !P0 ;                               /* 0x00000001ff037807 */
                                                                                        /* 0x000fe40004000000 */
                                   // R5 = q4 >> (0x1 - R3)
                                   //    = q5_rd
        /*0670*/                   SHF.R.U32.HI R5, RZ, R2, R5 ;                        /* 0x00000002ff057219 */
                                                                                        /* 0x000fe40000011605 */
                                   // R0 = rounding_fixup_hardware
                                   // R3 = rounding_fixup_denormal
                                   // R0 = rounding_fixup_hardware | rounding_fixup_denormal
        /*0680*/                   LOP3.LUT R0, R0, R3, RZ, 0xfc, !PT ;                 /* 0x0000000300007212 */
                                                                                        /* 0x000fc800078efcff */
        /*0690*/                   ISETP.NE.AND P0, PT, R0, RZ, PT ;                    /* 0x000000ff0000720c */
                                                                                        /* 0x000fc80003f05270 */
        /*06a0*/                   ISETP.NE.AND P0, PT, R13, RZ, P0 ;                   /* 0x000000ff0d00720c */
                                                                                        /* 0x000fc80000705270 */
                                   // if(R0 != 0 && R13 !=0)
                                   //   rounding_fixup = 0x1;
                                   // else
                                   //   rounding_fixup = 0x0;
        /*06b0*/                   SEL R0, RZ, 0x1, !P0 ;                               /* 0x00000001ff007807 */
                                                                                        /* 0x000fca0004000000 */
                                   //   rounding_fixup = - rounding_fixup;
        /*06c0*/                   IMAD.MOV R0, RZ, RZ, -R0 ;                           /* 0x000000ffff007224 */
                                                                                        /* 0x000fca00078e0a00 */
        /*06d0*/                   ISETP.GE.AND P0, PT, R0, RZ, PT ;                    /* 0x000000ff0000720c */
                                                                                        /* 0x000fe20003f06270 */
        /*06e0*/                   IMAD.MOV.U32 R0, RZ, RZ, R5 ;                        /* 0x000000ffff007224 */
                                                                                        /* 0x000fd600078e0005 */
                                   // if( rounding_fixup < 0 )
                                   //   R0 = R5 + 0x1;
                                   //      = q5_rd + 0x1;
                                   //      = q6_rd;
        /*06f0*/              @!P0 IADD3 R0, R0, 0x1, RZ ;                              /* 0x0000000100008810 */
                                                                                        /* 0x000fc80007ffe0ff */
                                   // q7 = (q3_rd & 0x80000000) | q6_rd;
        /*0700*/                   LOP3.LUT R5, R13, R0, RZ, 0xfc, !PT ;                /* 0x000000000d057212 */
                                                                                        /* 0x000fcc00078efcff */
        /*0710*/                   IMAD.MOV.U32 R2, RZ, RZ, R10 ;                       /* 0x000000ffff027224 */
                                                                                        /* 0x000fe400078e000a */
        /*0720*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;                       /* 0x00000000ff037424 */
                                                                                        /* 0x000fcc00078e00ff */
        /*0730*/                   RET.REL.NODEC R2 0x0 ;                               /* 0xfffff8c002007950 */
                                                                                        /* 0x000fea0003c3ffff */
        /*0740*/                   BRA 0x740;                                           /* 0xfffffff000007947 */
                                                                                        /* 0x000fc0000383ffff */
        /*0750*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*0760*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*0770*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
		..........



Fatbin ptx code:
================
arch = sm_75
code version = [7,7]
host = linux
compile_size = 64bit
compressed
