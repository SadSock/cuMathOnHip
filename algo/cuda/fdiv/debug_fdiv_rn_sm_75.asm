
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
		Function : _Z12test_fdiv_rnPfff
	.headerflags    @"EF_CUDA_SM75 EF_CUDA_PTX_SM(EF_CUDA_SM75)"
        /*0000*/                   IMAD.MOV.U32 R1, RZ, RZ, c[0x0][0x28] ;              /* 0x00000a00ff017624 */
                                                                                        /* 0x000fc400078e00ff */
                                   // r0 = R0
                                   // x0 = c[0x0][0x16c]
                                   // y0 = c[0x0][0x168]
                                   //
        /*0010*/                   MUFU.RCP R0, c[0x0][0x16c] ;                         /* 0x00005b0000007b08 */
                                                                                        /* 0x000e220000001000 */
                                   // UR4 = y0
        /*0020*/                   ULDC UR4, c[0x0][0x168] ;                            /* 0x00005a0000047ab9 */
                                                                                        /* 0x000fe20000000800 */
                                   // R5 = x0
        /*0030*/                   IMAD.MOV.U32 R5, RZ, RZ, c[0x0][0x16c] ;             /* 0x00005b00ff057624 */
                                                                                        /* 0x000fe400078e00ff */
                                   // R4 = y0
        /*0040*/                   IMAD.U32 R4, RZ, RZ, UR4 ;                           /* 0x00000004ff047e24 */
                                                                                        /* 0x000fcc000f8e00ff */
                                   // P0 = fchk(y0, x0);
        /*0050*/                   FCHK P0, R4, c[0x0][0x16c] ;                         /* 0x00005b0004007b02 */
                                                                                        /* 0x000e620000000000 */
                                   // R3 = rd1 = r0 * -x0 + 1.0
        /*0060*/                   FFMA R3, R0, -R5, 1 ;                                /* 0x3f80000000037423 */
                                                                                        /* 0x001fc80000000805 */
                                   // R3 = r1 = r0 * rd1 + r0
        /*0070*/                   FFMA R3, R0, R3, R0 ;                                /* 0x0000000300037223 */
                                                                                        /* 0x000fc80000000000 */
                                   // R0 = q1 = r1 * y0
        /*0080*/                   FFMA R0, R3, c[0x0][0x168], RZ ;                     /* 0x00005a0003007a23 */
                                                                                        /* 0x000fc800000000ff */
                                   // R2 = qd1 = q1 * -x0 + y0
        /*0090*/                   FFMA R2, R0, -R5, c[0x0][0x168] ;                    /* 0x00005a0000027623 */
                                                                                        /* 0x000fc80000000805 */
                                   // R0 = r1 * qd1 + q1
        /*00a0*/                   FFMA R0, R3, R2, R0 ;                                /* 0x0000000203007223 */
                                                                                        /* 0x000fe20000000000 */
        /*00b0*/              @!P0 BRA 0xe0 ;                                           /* 0x0000002000008947 */
                                                                                        /* 0x002fea0003800000 */
                                   // R8 = 0xe0
        /*00c0*/                   MOV R8, 0xe0 ;                                       /* 0x000000e000087802 */
                                                                                        /* 0x000fc60000000f00 */
        /*00d0*/                   CALL.REL.NOINC 0x110 ;                               /* 0x0000003000007944 */
                                                                                        /* 0x000fea0003c00000 */
        /*00e0*/                   ULDC.64 UR4, c[0x0][0x160] ;                         /* 0x0000580000047ab9 */
                                                                                        /* 0x000fe40000000a00 */
        /*00f0*/                   STG.E.SYS [UR4], R0 ;                                /* 0x00000000ff007986 */
                                                                                        /* 0x000fe2000c10e904 */
        /*0100*/                   EXIT ;                                               /* 0x000000000000794d */
                                                                                        /* 0x000fea0003800000 */
                                   // R3  = y
                                   // R4  = x
                                   // R6  = y
                                   // R10 = x
        /*0110*/                   IMAD.MOV.U32 R10, RZ, RZ, c[0x0][0x16c] ;            /* 0x00005b00ff0a7624 */
                                                                                        /* 0x000fe400078e00ff */
        /*0120*/                   IMAD.MOV.U32 R6, RZ, RZ, c[0x0][0x168] ;             /* 0x00005a00ff067624 */
                                                                                        /* 0x000fe400078e00ff */
        /*0130*/                   IMAD.MOV.U32 R3, RZ, RZ, c[0x0][0x168] ;             /* 0x00005a00ff037624 */
                                                                                        /* 0x000fe200078e00ff */
                                   // R2  = x >> 0x17
        /*0140*/                   SHF.R.U32.HI R2, RZ, 0x17, R10 ;                     /* 0x00000017ff027819 */
                                                                                        /* 0x000fe2000001160a */
        /*0150*/                   IMAD.MOV.U32 R4, RZ, RZ, c[0x0][0x16c] ;             /* 0x00005b00ff047624 */
                                                                                        /* 0x000fe200078e00ff */
                                   // R0  = y >> 0x17
        /*0160*/                   SHF.R.U32.HI R0, RZ, 0x17, R6 ;                      /* 0x00000017ff007819 */
                                                                                        /* 0x000fc40000011606 */
                                   // R2  = x_exp = (x >> 0x17) and 0xff
        /*0170*/                   LOP3.LUT R2, R2, 0xff, RZ, 0xc0, !PT ;               /* 0x000000ff02027812 */
                                                                                        /* 0x000fe400078ec0ff */
                                   // R0  = y_exp = (y >> 0x17) and 0xff
        /*0180*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;               /* 0x000000ff00007812 */
                                                                                        /* 0x000fe400078ec0ff */
                                   // R9  =  x_exp - 0x1 = ((x >> 0x17) and 0xff - 0x1)
        /*0190*/                   IADD3 R9, R2, -0x1, RZ ;                             /* 0xffffffff02097810 */
                                                                                        /* 0x000fe40007ffe0ff */
                                   // R7  =  y_exp - 0x1 = ((y >> 0x17) and 0xff - 0x1)
        /*01a0*/                   IADD3 R7, R0, -0x1, RZ ;                             /* 0xffffffff00077810 */
                                                                                        /* 0x000fe40007ffe0ff */
                                   // P0  = x_exp - 0x1 > 0xfd
        /*01b0*/                   ISETP.GT.U32.AND P0, PT, R9, 0xfd, PT ;              /* 0x000000fd0900780c */
                                                                                        /* 0x000fc80003f04070 */
                                   // P0  = y_exp - 0x1 > 0xfd
        /*01c0*/                   ISETP.GT.U32.OR P0, PT, R7, 0xfd, P0 ;               /* 0x000000fd0700780c */
                                                                                        /* 0x000fd80000704470 */
        /*01d0*/              @!P0 IMAD.MOV.U32 R5, RZ, RZ, RZ ;                        /* 0x000000ffff058224 */
                                                                                        /* 0x000fe200078e00ff */
        /*01e0*/              @!P0 BRA 0x360 ;                                          /* 0x0000017000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R6  = y
                                   // R10 = x
                                   // P0(y_is_nan) = y == nan
                                   // P1(x_is_nan) = x == nan
                                   // P0 =  y_is_nan or x_is_nan
        /*01f0*/                   FSETP.GTU.FTZ.AND P0, PT, |R6|, +INF , PT ;          /* 0x7f8000000600780b */
                                                                                        /* 0x000fe40003f1c200 */
        /*0200*/                   FSETP.GTU.FTZ.AND P1, PT, |R10|, +INF , PT ;         /* 0x7f8000000a00780b */
                                                                                        /* 0x000fc80003f3c200 */
        /*0210*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;            /* 0x000000000000781c */
                                                                                        /* 0x000fd80000703570 */
        /*0220*/               @P0 BRA 0x740 ;                                          /* 0x0000051000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R3  = y
                                   // R4  = x
                                   // P0  = (R4 or R3) and 0x7fffffff
        /*0230*/                   LOP3.LUT P0, RZ, R4, 0x7fffffff, R3, 0xc8, !PT ;     /* 0x7fffffff04ff7812 */
                                                                                        /* 0x000fd8000780c803 */
        /*0240*/              @!P0 BRA 0x720 ;                                          /* 0x000004d000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R6  = y
                                   // R10 = x
                                   // P2 = !isinf(y)
                                   // P1 = !isinf(x)
                                   // P0 = !isinf(y)
        /*0250*/                   FSETP.NEU.FTZ.AND P2, PT, |R6|, +INF , PT ;          /* 0x7f8000000600780b */
                                                                                        /* 0x000fe40003f5d200 */
        /*0260*/                   FSETP.NEU.FTZ.AND P1, PT, |R10|, +INF , PT ;         /* 0x7f8000000a00780b */
                                                                                        /* 0x000fe40003f3d200 */
        /*0270*/                   FSETP.NEU.FTZ.AND P0, PT, |R6|, +INF , PT ;          /* 0x7f8000000600780b */
                                                                                        /* 0x000fd40003f1d200 */
        /*0280*/              @!P1 BRA !P2, 0x720 ;                                     /* 0x0000049000009947 */
                                                                                        /* 0x000fea0005000000 */
                                   // P2 = y_not_zero = y and 0x7fffffff
        /*0290*/                   LOP3.LUT P2, RZ, R3, 0x7fffffff, RZ, 0xc0, !PT ;     /* 0x7fffffff03ff7812 */
                                                                                        /* 0x000fc8000784c0ff */
                                   // P1 = !y_not_zero or !x_not_inf
        /*02a0*/                   PLOP3.LUT P1, PT, P1, P2, PT, 0x2a, 0x0 ;            /* 0x000000000000781c */
                                                                                        /* 0x000fd80000f24572 */
        /*02b0*/               @P1 BRA 0x700 ;                                          /* 0x0000044000001947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R3  = y
                                   // R4  = x
                                   // P0  = y_not_inf  = !isinf(y)
                                   // P1  = x_not_zero = x and 0x7fffffff
        /*02c0*/                   LOP3.LUT P1, RZ, R4, 0x7fffffff, RZ, 0xc0, !PT ;     /* 0x7fffffff04ff7812 */
                                                                                        /* 0x000fc8000782c0ff */
                                   // P0  = !x_not_zero || !y_not_inf
        /*02d0*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0x2a, 0x0 ;            /* 0x000000000000781c */
                                                                                        /* 0x000fd80000702572 */
        /*02e0*/               @P0 BRA 0x6d0 ;                                          /* 0x000003e000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R7  =  y_exp - 0x1 = ((y >> 0x17) and 0xff - 0x1)
                                   // R9  =  x_exp - 0x1 = ((x >> 0x17) and 0xff - 0x1)
                                   // P0  =  ((int32_t) (y_exp - 0x1)) >= 0
                                   // P1  =  ((int32_t) (x_exp - 0x1)) >= 0
        /*02f0*/                   ISETP.GE.AND P0, PT, R7, RZ, PT ;                    /* 0x000000ff0700720c */
                                                                                        /* 0x000fe40003f06270 */
        /*0300*/                   ISETP.GE.AND P1, PT, R9, RZ, PT ;                    /* 0x000000ff0900720c */
                                                                                        /* 0x000fd40003f26270 */
                                   // R0  = y_exp = (x >> 0x17) and 0xff
                                   // R2  = x_exp = (x >> 0x17) and 0xff
                                   // R3  = y0
                                   // R4  = x0
                                   // R5  = exp_fixup
                                   // R6  = y
                                   // R7  = y_exp - 0x1 = ((y >> 0x17) and 0xff - 0x1)
                                   // R10 = x
        /*0310*/               @P0 IMAD.MOV.U32 R5, RZ, RZ, RZ ;                        /* 0x000000ffff050224 */
                                                                                        /* 0x000fe400078e00ff */
        /*0320*/              @!P0 FFMA R3, R6, 1.84467440737095516160e+19, RZ ;        /* 0x5f80000006038823 */
                                                                                        /* 0x000fe400000000ff */
        /*0330*/              @!P0 IMAD.MOV.U32 R5, RZ, RZ, -0x40 ;                     /* 0xffffffc0ff058424 */
                                                                                        /* 0x000fe400078e00ff */
        /*0340*/              @!P1 FFMA R4, R10, 1.84467440737095516160e+19, RZ ;       /* 0x5f8000000a049823 */
                                                                                        /* 0x000fc600000000ff */
        /*0350*/              @!P1 IADD3 R5, R5, 0x40, RZ ;                             /* 0x0000004005059810 */
                                                                                        /* 0x000fc40007ffe0ff */
                                   // R7 = (x_exp << 0x17) + 0xc0800000
        /*0360*/                   LEA R7, R2, 0xc0800000, 0x17 ;                       /* 0xc080000002077811 */
                                                                                        /* 0x000fe400078eb8ff */
                                   // R0 = y_exp - 0x7f
        /*0370*/                   IADD3 R0, R0, -0x7f, RZ ;                            /* 0xffffff8100007810 */
                                                                                        /* 0x000fc60007ffe0ff */
                                   // R7 = x0 = x0 - ((x_exp << 0x17) + 0xc0800000)
        /*0380*/                   IMAD.IADD R7, R4, 0x1, -R7 ;                         /* 0x0000000104077824 */
                                                                                        /* 0x000fe200078e0a07 */
                                   // R2 = y_exp - 0x7f - x_exp + 0x7f = y_exp - x_exp
        /*0390*/                   IADD3 R2, R0.reuse, 0x7f, -R2 ;                      /* 0x0000007f00027810 */
                                                                                        /* 0x040fe20007ffe802 */
                                   // R3 = - (y_exp - 0x7f) * 0x800000 + y0
                                   // R3 = y0 = y0 - ((y_exp - 0x7f) << 0x17)
        /*03a0*/                   IMAD R3, R0, -0x800000, R3 ;                         /* 0xff80000000037824 */
                                                                                        /* 0x000fe400078e0203 */
        /*03b0*/                   FADD.FTZ R6, -R7, -RZ ;                              /* 0x800000ff07067221 */
                                                                                        /* 0x000fe40000010100 */
                                   // R3 =  y0
                                   // R6 = -x0
                                   // R7 =  x0
                                   // R4 =  r0
        /*03c0*/                   MUFU.RCP R4, R7 ;                                    /* 0x0000000700047308 */
                                                                                        /* 0x000e220000001000 */
                                   // R2  = R2 + R5 = y_exp - x_exp + exp_fixup
        /*03d0*/                   IMAD.IADD R2, R2, 0x1, R5 ;                          /* 0x0000000102027824 */
                                                                                        /* 0x000fe400078e0205 */
                                   // R9  = dr1 = __builtin_fmaf(r0_f32, -x0_f32, 1.0)
        /*03e0*/                   FFMA R9, R4, R6, 1 ;                                 /* 0x3f80000004097423 */
                                                                                        /* 0x001fc80000000006 */
                                   // R10 = r1  = __builtin_fmaf(r0_f32, dr1, r0_f32)
        /*03f0*/                   FFMA R10, R4, R9, R4 ;                               /* 0x00000009040a7223 */
                                                                                        /* 0x000fc80000000004 */
                                   // R4  = q0  = __builtin_fmaf(y0, r1, 0.0)
        /*0400*/                   FFMA R4, R3, R10, RZ ;                               /* 0x0000000a03047223 */
                                                                                        /* 0x000fc800000000ff */
                                   // R9  = dq1  = __builtin_fmaf(-x0, q0, y0)
        /*0410*/                   FFMA R9, R6, R4, R3 ;                                /* 0x0000000406097223 */
                                                                                        /* 0x000fc80000000003 */
                                   // R9  = q1  = __builtin_fmaf(r1, dq1, q0)
        /*0420*/                   FFMA R9, R10, R9, R4 ;                               /* 0x000000090a097223 */
                                                                                        /* 0x000fc80000000004 */
                                   // R6  = dq2  = __builtin_fmaf(-x0, q1, y0)
        /*0430*/                   FFMA R6, R6, R9, R3 ;                                /* 0x0000000906067223 */
                                                                                        /* 0x000fc80000000003 */
                                   // R3  = q2  = __builtin_fmaf(r1, dq2, q1)
        /*0440*/                   FFMA R3, R10, R6, R9 ;                               /* 0x000000060a037223 */
                                                                                        /* 0x000fca0000000009 */
                                   // R0  = q2_exp = (R3 >> 0x17 and) 0xff;
        /*0450*/                   SHF.R.U32.HI R0, RZ, 0x17, R3 ;                      /* 0x00000017ff007819 */
                                                                                        /* 0x000fc80000011603 */
        /*0460*/                   LOP3.LUT R0, R0, 0xff, RZ, 0xc0, !PT ;               /* 0x000000ff00007812 */
                                                                                        /* 0x000fca00078ec0ff */
                                   // R4 = q_exp = R0 + R2 = q2_exp + exp_fixup
        /*0470*/                   IMAD.IADD R4, R0, 0x1, R2 ;                          /* 0x0000000100047824 */
                                                                                        /* 0x000fca00078e0202 */
        /*0480*/                   IADD3 R0, R4, -0x1, RZ ;                             /* 0xffffffff04007810 */
                                                                                        /* 0x000fc80007ffe0ff */
        /*0490*/                   ISETP.GE.U32.AND P0, PT, R0, 0xfe, PT ;              /* 0x000000fe0000780c */
                                                                                        /* 0x000fd80003f06070 */
        /*04a0*/              @!P0 BRA 0x6b0 ;                                          /* 0x0000020000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   // P0 = q3 > 0xfe
        /*04b0*/                   ISETP.GT.AND P0, PT, R4, 0xfe, PT ;                  /* 0x000000fe0400780c */
                                                                                        /* 0x000fd80003f04270 */
        /*04c0*/               @P0 BRA 0x680 ;                                          /* 0x000001b000000947 */
                                                                                        /* 0x000fea0003800000 */
                                   // P0 = q3 >= 0x1
        /*04d0*/                   ISETP.GE.AND P0, PT, R4, 0x1, PT ;                   /* 0x000000010400780c */
                                                                                        /* 0x000fd80003f06270 */
        /*04e0*/               @P0 BRA 0x750 ;                                          /* 0x0000026000000947 */
                                                                                        /* 0x000fea0003800000 */
        /*04f0*/                   ISETP.GE.AND P0, PT, R4, -0x18, PT ;                 /* 0xffffffe80400780c */
                                                                                        /* 0x000fe40003f06270 */
                                   // R3 = q3 = (q2 & 0x80000000)
        /*0500*/                   LOP3.LUT R3, R3, 0x80000000, RZ, 0xc0, !PT ;         /* 0x8000000003037812 */
                                                                                        /* 0x000fd400078ec0ff */
        /*0510*/              @!P0 BRA 0x750 ;                                          /* 0x0000023000008947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R0 = q2_rz
                                   // R3 = q3 = (q2 & 0x80000000)
                                   // R4 = q_exp = R0 + R2 = q2_exp + y_exp - x_exp + exp_fixup
                                   // R5 = q2_rd
        /*0520*/                   FFMA.RZ R0, R10, R6.reuse, R9.reuse ;                /* 0x000000060a007223 */
                                                                                        /* 0x180fe2000000c009 */
                                   // R7 = q_exp + 0x20
        /*0530*/                   IADD3 R7, R4, 0x20, RZ ;                             /* 0x0000002004077810 */
                                                                                        /* 0x000fe20007ffe0ff */
                                   // R5 = q2_rd
        /*0540*/                   FFMA.RM R5, R10, R6.reuse, R9.reuse ;                /* 0x000000060a057223 */
                                                                                        /* 0x180fe20000004009 */
                                   // P2 = q_exp != 0
        /*0550*/                   ISETP.NE.AND P2, PT, R4, RZ, PT ;                    /* 0x000000ff0400720c */
                                                                                        /* 0x000fe40003f45270 */
                                   // R2 = q2_rz_mantis = q2_rz and 0x7fffff
        /*0560*/                   LOP3.LUT R2, R0, 0x7fffff, RZ, 0xc0, !PT ;           /* 0x007fffff00027812 */
                                                                                        /* 0x000fe200078ec0ff */
                                   // ru
        /*0570*/                   FFMA.RP R0, R10, R6, R9 ;                            /* 0x000000060a007223 */
                                                                                        /* 0x000fe20000008009 */
                                   // P1 = q_exp != 0
        /*0580*/                   ISETP.NE.AND P1, PT, R4, RZ, PT ;                    /* 0x000000ff0400720c */
                                                                                        /* 0x000fe20003f25270 */
                                   // R4 = -q_exp
        /*0590*/                   IMAD.MOV R4, RZ, RZ, -R4 ;                           /* 0x000000ffff047224 */
                                                                                        /* 0x000fe200078e0a04 */
                                   // R2 = (q2_rz and 0x7fffff) or 0x800000
        /*05a0*/                   LOP3.LUT R2, R2, 0x800000, RZ, 0xfc, !PT ;           /* 0x0080000002027812 */
                                                                                        /* 0x000fe400078efcff */
                                   // P0 = !(q2_ru == q2_rd)
        /*05b0*/                   FSETP.NEU.FTZ.AND P0, PT, R0, R5, PT ;               /* 0x000000050000720b */
                                                                                        /* 0x000fc40003f1d000 */
                                   // R7 = q_exp + 0x20
                                   // R2 = (q2_rz and 0x7fffff) or 0x800000
                                   // R7 = R2 << R7
        /*05c0*/                   SHF.L.U32 R7, R2, R7, RZ ;                           /* 0x0000000702077219 */
                                                                                        /* 0x000fe400000006ff */
                                   // if(P2)
                                   // {R5 = -q_exp;}
                                   // else
                                   // {R5 = 0;}
        /*05d0*/                   SEL R5, R4, RZ, P2 ;                                 /* 0x000000ff04057207 */
                                                                                        /* 0x000fe40001000000 */
                                   // P1 = (R7 != 0 and q_exp != 0)
        /*05e0*/                   ISETP.NE.AND P1, PT, R7, RZ, P1 ;                    /* 0x000000ff0700720c */
                                                                                        /* 0x000fe40000f25270 */
                                   // R5 = R2 >> R5
        /*05f0*/                   SHF.R.U32.HI R5, RZ, R5, R2 ;                        /* 0x00000005ff057219 */
                                                                                        /* 0x000fe40000011602 */
                                   // P0 = P0 or P1
        /*0600*/                   PLOP3.LUT P0, PT, P0, P1, PT, 0xa8, 0x0 ;            /* 0x000000000000781c */
                                                                                        /* 0x000fe40000703570 */
                                   // R7 = R5 >> 0x1
        /*0610*/                   SHF.R.U32.HI R7, RZ, 0x1, R5 ;                       /* 0x00000001ff077819 */
                                                                                        /* 0x000fc40000011605 */
                                   // if(!(P0 or P1))
                                   // {R0 = 0;}
                                   // else
                                   // {R0 = 0x1;}
        /*0620*/                   SEL R0, RZ, 0x1, !P0 ;                               /* 0x00000001ff007807 */
                                                                                        /* 0x000fc80004000000 */
                                   // R0 = R0 or (0x1 and R7)
        /*0630*/                   LOP3.LUT R0, R0, 0x1, R7, 0xf8, !PT ;                /* 0x0000000100007812 */
                                                                                        /* 0x000fc800078ef807 */
                                   // R0 = R0 and R5
        /*0640*/                   LOP3.LUT R0, R0, R5, RZ, 0xc0, !PT ;                 /* 0x0000000500007212 */
                                                                                        /* 0x000fca00078ec0ff */
                                   // R0 = R7 + R0
        /*0650*/                   IMAD.IADD R0, R7, 0x1, R0 ;                          /* 0x0000000107007824 */
                                                                                        /* 0x000fca00078e0200 */
                                   // R3 = R0 or R3
        /*0660*/                   LOP3.LUT R3, R0, R3, RZ, 0xfc, !PT ;                 /* 0x0000000300037212 */
                                                                                        /* 0x000fe200078efcff */
        /*0670*/                   BRA 0x750 ;                                          /* 0x000000d000007947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R3 = q2
                                   // R3 = q2 & 0x80000000 | 0x7f800000
                                   // R3 = inf
        /*0680*/                   LOP3.LUT R3, R3, 0x80000000, RZ, 0xc0, !PT ;         /* 0x8000000003037812 */
                                                                                        /* 0x000fc800078ec0ff */
        /*0690*/                   LOP3.LUT R3, R3, 0x7f800000, RZ, 0xfc, !PT ;         /* 0x7f80000003037812 */
                                                                                        /* 0x000fe200078efcff */
        /*06a0*/                   BRA 0x750 ;                                          /* 0x000000a000007947 */
                                                                                        /* 0x000fea0003800000 */
                                   // R2 = y_exp - x_exp + exp_fixup;
                                   // R3 = R2 * 0x800000 + R3;
        /*06b0*/                   IMAD R3, R2, 0x800000, R3 ;                          /* 0x0080000002037824 */
                                                                                        /* 0x000fe200078e0203 */
        /*06c0*/                   BRA 0x750 ;                                          /* 0x0000008000007947 */
                                   // R3 =  ( ( x ^ y ) & 0x80000000 ) | 0x7f800000     /* 0x000fea0003800000 */
                                   // R3 =  inf
        /*06d0*/                   LOP3.LUT R3, R4, 0x80000000, R3, 0x48, !PT ;         /* 0x8000000004037812 */
                                                                                        /* 0x000fc800078e4803 */
        /*06e0*/                   LOP3.LUT R3, R3, 0x7f800000, RZ, 0xfc, !PT ;         /* 0x7f80000003037812 */
                                                                                        /* 0x000fe200078efcff */
        /*06f0*/                   BRA 0x750 ;                                          /* 0x0000005000007947 */
                                                                                        /* 0x000fea0003800000 */
        /*0700*/                   LOP3.LUT R3, R4, 0x80000000, R3, 0x48, !PT ;         /* 0x8000000004037812 */
                                                                                        /* 0x000fe200078e4803 */
        /*0710*/                   BRA 0x750 ;                                          /* 0x0000003000007947 */
                                                                                        /* 0x000fea0003800000 */
        /*0720*/                   MUFU.RSQ R3, -QNAN  ;                                /* 0xffc0000000037908 */
                                                                                        /* 0x000e220000001400 */
        /*0730*/                   BRA 0x750 ;                                          /* 0x0000001000007947 */
                                                                                        /* 0x000fea0003800000 */
        /*0740*/                   FADD.FTZ R3, R6, c[0x0][0x16c] ;                     /* 0x00005b0006037621 */
                                                                                        /* 0x000fc80000010000 */
        /*0750*/                   IMAD.MOV.U32 R0, RZ, RZ, R3 ;                        /* 0x000000ffff007224 */
                                                                                        /* 0x001fe400078e0003 */
        /*0760*/                   IMAD.MOV.U32 R2, RZ, RZ, R8 ;                        /* 0x000000ffff027224 */
                                                                                        /* 0x000fe400078e0008 */
        /*0770*/                   IMAD.MOV.U32 R3, RZ, RZ, 0x0 ;                       /* 0x00000000ff037424 */
                                                                                        /* 0x000fcc00078e00ff */
        /*0780*/                   RET.REL.NODEC R2 0x0 ;                               /* 0xfffff87002007950 */
                                                                                        /* 0x000fea0003c3ffff */
        /*0790*/                   BRA 0x790;                                           /* 0xfffffff000007947 */
                                                                                        /* 0x000fc0000383ffff */
        /*07a0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*07b0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*07c0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*07d0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*07e0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
        /*07f0*/                   NOP;                                                 /* 0x0000000000007918 */
                                                                                        /* 0x000fc00000000000 */
		..........



Fatbin ptx code:
================
arch = sm_75
code version = [7,8]
host = linux
compile_size = 64bit
compressed
