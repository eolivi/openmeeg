#pragma once

// #include <BlasLapackImplementations/FortranCInterface.h>
#define FC_GLOBAL(name,NAME) name##_

// extern "C" {
    // #include "acml.h"
// }

#include <cblas.h>
#include <lapacke.h>
#undef I // undefine this def due to complex.h that causes issues later
// Those macros are not used yet
// #define BLAS(x,X) x
#define BLAS(x,X) cblas_ ## x
// #define LAPACK(x,X) FC_GLOBAL(x,X)
#define LAPACK(x,X) LAPACKE_ ## x
#define CLAPACK_INTERFACE

#define DLANGE(X1,X2,X3,X4,X5,X6)       LAPACK(dlange,DLANGE)(LAPACK_COL_MAJOR,X1,X2,X3,X4,X5)

#define DSPTRF(X1,X2,X3,X4,X5)          LAPACK(dsptrf,DSPTRF)(LAPACK_COL_MAJOR,X1,X2,X3,X4)
#define DSPTRS(X1,X2,X3,X4,X5,X6,X7,X8) LAPACK(dsptrs,DSPTRS)(LAPACK_COL_MAJOR,X1,X2,X3,X4,X5,X6,X7)
#define DSPTRI(X1,X2,X3,X4,X5,X6)       LAPACK(dsptri,DSPTRI)(LAPACK_COL_MAJOR,X1,X2,X3,X4)
#define DPPTRF(X1,X2,X3,X4)             LAPACK(dpptrf,DPPTRF)(LAPACK_COL_MAJOR,X1,X2,X3)
#define DPPTRI(X1,X2,X3,X4)             LAPACK(dpptri,DPPTRI)(LAPACK_COL_MAJOR,X1,X2,X3)
#define DGETRF(X1,X2,X3,X4,X5)          LAPACK(dgetrf,DGETRF)(LAPACK_COL_MAJOR,X1,X2,X3,X4,X5)
#define DGETRI(X1,X2,X3,X4)             LAPACK(dgetri,DGETRI)(LAPACK_COL_MAJOR,X1,X2,X3,X4)

#define DGESDD(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,X13,X14) LAPACK(dgesdd,DGESDD)(LAPACK_COL_MAJOR,X1,X2,X3,X4,X5,X6,X7,X8,X9,X10)

#include <BlasLapackImplementations/OpenMEEGMathsCBlasLapack.h>
/*
extern "C" void vrda_sin (int n, double *t, double *p);
extern "C" void vrda_cos (int n, double *t, double *p);
extern "C" void vrda_exp (int n, double *t, double *p);
extern "C" void vrda_log (int n, double *t, double *p);

extern "C" {
    void FC_GLOBAL(dgesdd,DGESDD)(const char&,const int&,const int&,double*,const int&,double*,double*,const int&,double*,const int&,double*,const int&,int*,int&);
    void FC_GLOBAL(dpotf2,DPOTF2)(const char&,const int&,double*,const int&,int&);
    double FC_GLOBAL(dlange,DLANGE)(const char&,const int&,const int&,const double*,const int&,double*);
    void FC_GLOBAL(dsptrf,DSPTRF)(const char&,const int&,double*,int*,int&);
    void FC_GLOBAL(dtptri,DTPTRI)(const char&,const char&,const int&,double*,int&,int&);
    void FC_GLOBAL(dsptri,DSPTRI)(const char&,const int&,double*,int*,double*,int&);
    void FC_GLOBAL(dpptrf,DPPTRF)(const char&,const int&,double*,int&);
    void FC_GLOBAL(dpptri,DPPTRI)(const char&,const int&,double*,int&);
    void FC_GLOBAL(dspevd,DSPEVD)(const char&,const char&,const int&,double*,double*,double*,const int&,double*,const int&,int*,const int&,int&);
    void FC_GLOBAL(dsptrs,DSPTRS)(const char&,const int&,const int&,double*,int*,double*,const int&,int&);
} */

// #define DGESDD FC_GLOBAL(dgesdd,DGESDD)
// #define DPOTF2 FC_GLOBAL(dpotf2,DPOTF2)
// #define DLANGE FC_GLOBAL(dlange,DLANGE)

// #define DSPTRF FC_GLOBAL(dsptrf,DSPTRF)
// #define DTPTRI FC_GLOBAL(dtptri,DTPTRI)
// #define DPPTRF FC_GLOBAL(dpptrf,DPPTRF)
// #define DPPTRI FC_GLOBAL(dpptri,DPPTRI)
// #define DSPEVD FC_GLOBAL(dspevd,DSPEVD)
// #define DSPTRS FC_GLOBAL(dsptrs,DSPTRS)

/*
#define DGER(X1,X2,X3,X4,X5,X6,X7,X8,X9) BLAS(dger,DGER)(X1,X2,X3,X4,X5,X6,X7,X8,X9)
#define DSPMV(X1,X2,X3,X4,X5,X6,X7,X8,X9) BLAS(dspmv,DSPMV)(X1,X2,X3,X4,X5,X6,X7,X8,X9)
#define DTPMV(X1,X2,X3,X4,X5,X6,X7) BLAS(dtpmv,DTPMV)(X1,X2,X3,X4,X5,X6,X7)
#define DSYMM(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12) BLAS(dsymm,DSYMM)(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12)
#define DGEMV(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11) BLAS(dgemv,DGEMV)(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11)
#define DGEMM(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,X13) BLAS(dgemm,DGEMM)(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,X13)
#define DTRMM(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11) BLAS(dtrmm,DTRMM)(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11)
#define DGETRF LAPACK(dgetrf,DGETRF)
#define DGETRI(X1,X2,X3,X4,X5,X6,X7) LAPACK(dgetri,DGETRI)(X1,X2,X3,X4,X7)
#define DSPTRI(X1,X2,X3,X4,X5,X6) LAPACK(dsptri,DSPTRI)(X1,X2,X3,X4,X6)
*/

/*
#include <BlasLapackImplementations/OpenMEEGMathsCBlasLapack.h>
#include <BlasLapackImplementations/OpenMEEGMathsFBlasLapack1.h>

#define DGETRF LAPACK(dgetrf,DGETRF)
#define DGETRI(X1,X2,X3,X4,X5,X6,X7) LAPACK(dgetri,DGETRI)(X1,X2,X3,X4,X7)
// #define DSPTRI(X1,X2,X3,X4,X5,X6)    LAPACK(dsptri,DSPTRI)(X1,X2,X3,X4,X6)
*/

/*
 *     #elif USE_ACML
 dcopy(sz,data()+istart+(jstart+j)*nlin(),1,a.data()+j*isize,1);
 DGEMV(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11) BLAS(dgemv,DGEMV)(CblasColMajor,X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11)
#define DGEMM(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,X13) BLAS(dgemm,DGEMM)(CblasColMajor,X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,X13)
#define DTRMM(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11) BLAS(dtrmm,DTRMM)(CblasColMajor,X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11)
#if defined(USE_ATLAS)
#ifdef __APPLE__
#define DGETRF(X1,X2,X3,X4,X5,X6) LAPACK(dgetrf,DGETRF)(&X1,&X2,X3,&X4,X5,&X6)
// #define DGETRF(X1,X2,X3,X4,X5,X6) LAPACK(dgetrf,DGETRF)(CblasColMajor,X1,X2,X3,X4,X5)
#define DGETRI(X1,X2,X3,X4,X5,X6,X7) LAPACK(dgetri,DGETRI)(&X1,X2,&X3,X4,X5,&X6,&X7)
// #define DGETRI(X1,X2,X3,X4,X5,X6,X7) LAPACK(dgetri,DGETRI)(CblasColMajor,X1,X2,X3,X4)
#else
#define DGETRF(X1,X2,X3,X4,X5) LAPACK(dgetrf,DGETRF)(CblasColMajor,X1,X2,X3,X4,X5)
#define DGETRI(X1,X2,X3,X4)    LAPACK(dgetri,DGETRI)(CblasColMajor,X1,X2,X3,X4)
#endif
#else
#define DGETRF(X1,X2,X3,X4,X5,X6) LAPACK(dgetrf,DGETRF)(X1,X2,X3,X4,X5,X6)
#define DGETRI(X1,X2,X3,X4,X5,X6,X7) LAPACK(dgetri,DGETRI)(X1,X2,X3,X4,X5,X6,X7)
#endif
#define DSPTRI(X1,X2,X3,X4,X5,X6) FC_GLOBAL(dsptri,DSPTRI)(X1,X2,X3,X4,X5,X6)
#else
#define DGER(X1,X2,X3,X4,X5,X6,X7,X8,X9) BLAS(dger,DGER)(X1,X2,X3,X4,X5,X6,X7,X8,X9)
#define DSPMV(X1,X2,X3,X4,X5,X6,X7,X8,X9) BLAS(dspmv,DSPMV)(X1,X2,X3,X4,X5,X6,X7,X8,X9)
#define DTPMV(X1,X2,X3,X4,X5,X6,X7) BLAS(dtpmv,DTPMV)(X1,X2,X3,X4,X5,X6,X7)
#define DSYMM(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12) BLAS(dsymm,DSYMM)(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12)
#define DGEMV(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11) BLAS(dgemv,DGEMV)(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11)
#define DGEMM(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,X13) BLAS(dgemm,DGEMM)(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11,X12,X13)
#define DTRMM(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11) BLAS(dtrmm,DTRMM)(X1,X2,X3,X4,X5,X6,X7,X8,X9,X10,X11)
#define DGETRF LAPACK(dgetrf,DGETRF)
#if defined(USE_ACML)
#define DGETRI(X1,X2,X3,X4,X5,X6,X7) LAPACK(dgetri,DGETRI)(X1,X2,X3,X4,X7)
#define DSPTRI(X1,X2,X3,X4,X5,X6) LAPACK(dsptri,DSPTRI)(X1,X2,X3,X4,X6)
#else

 * */
