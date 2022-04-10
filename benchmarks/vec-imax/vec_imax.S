// See LICENSE for license details.

//**************************************************************************
// Vectorized index of maximum
//--------------------------------------------------------------------------

    .text
    .align 2

    .global imax
    .type imax,@function
/*
 * size_t imax(size_t n, const float x[]);
 *
 * Calling convention:
 *     a0: size_t n
 *     a1: const float *x
 * Return value:
 *     a0: index
 */
imax:
1:  auipc t0, %pcrel_hi(input_inf)
    flw ft0, %pcrel_lo(1b)(t0)  # initialize maximum to -infinity
    vsetvli zero, zero, e32, m8 # preconfigure vector state
    vfmv.s.f v24, ft0           # move -infinity to scalar in v24;
                                # may be useful for reductions
    li t1, 0                    # initialize index
    mv t2, a0                   # save n for index calculations

imax_loop:
    vsetvli t0, a0, e32, m8     # configure SEW=32 LMUL=8

    vle32.v v0, (a1)            # load x[k] vector
    vredmax.vs v16, v0, v24     # find maximum value in vector
    vfmv.f.s ft1, v16           # compare against global maximum
    flt.s t3, ft1, ft0
    bnez t3, skip

    vmfge.vf v8, v0, ft1        # locate position of maximum element; compute new index
    vfirst.m t1, v8
    add t3, t1, t2              # update index as necessary
    sub t1, t3, a0
    vfmv.f.s ft0, v16           # update maximum as necessary
skip:
    sub a0, a0, t0              # decrement n
    slli t0, t0, 2              # scale VL to byte offset
    add a1, a1, t0              # bump pointer x
    bnez a0, imax_loop          # loop

    mv a0, t1                   # set return value

    ret

    .section .rodata
input_inf:
    .float -inf
