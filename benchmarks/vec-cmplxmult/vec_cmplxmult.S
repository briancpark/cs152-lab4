// See LICENSE for license details.

//**************************************************************************
// Vectorized complex multiply
//--------------------------------------------------------------------------

    .text
    .align 2

    .global cmplxmult
    .type cmplxmult,@function
/*
 * void cmplxmult(size_t n, const struct Complex a[], const struct Complex b[], struct Complex c[]);
 *
 * Calling convention:
 *     a0: size_t n
 *     a1: struct Complex *a
 *     a2: struct Complex *b
 *     a3: struct Complex *c
 */
cmplxmult:
    vsetvli t0, a0, e32, m4     # configure SEW=32 LMUL=4

    vlseg2e32.v v0, (a1)        # load a[i].real and a[i].imag
    vlseg2e32.v v8, (a2)        # load b[i].real and b[i].imag

    vfmul.vv v16, v0, v8        # compute c[i].real = (a[i].real * b[i].real) - (a[i].imag * b[i].imag)
    vfnmsac.vv v16, v4, v12

    vfmul.vv v20, v0, v12       # compute c[i].imag = (a[i].real * b[i].imag) + (a[i].imag * b[i].real)    
    vfmacc.vv v20, v4, v8

    vsseg2e32.v v16, (a3)       # store c[i].real and c[i].imag

    sub a0, a0, t0              # decrement n (a0)

    slli t0, t0, 3              # bump pointers
    add a1, a1, t0
    add a2, a2, t0
    add a3, a3, t0

    bnez a0, cmplxmult         # loop

    ret
