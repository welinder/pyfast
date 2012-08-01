

# Re-declare the function we want from the C-library.
cdef extern from "fast.h":
    ctypedef struct xy:
        int x
        int y

    ctypedef unsigned char byte

    int fast9_corner_score(byte *p, int pixel[], int bstart)
    int fast10_corner_score(byte *p, int pixel[], int bstart)
    int fast11_corner_score(byte *p, int pixel[], int bstart)
    int fast12_corner_score(byte *p, int pixel[], int bstart)

    xy* fast9_detect(byte *im, int xsize, int ysize, int stride, 
                     int b, int *ret_num_corners)
    xy* fast10_detect(byte *im, int xsize, int ysize, int stride, 
                      int b, int *ret_num_corners)
    xy* fast11_detect(byte *im, int xsize, int ysize, int stride,
                      int b, int *ret_num_corners)
    xy* fast12_detect(byte *im, int xsize, int ysize, int stride,
                      int b, int *ret_num_corners)

    int* fast9_score(byte *i, int stride, xy *corners, 
                     int num_corners, int b)
    int* fast10_score(byte *i, int stride, xy *corners,
                      int num_corners, int b)
    int* fast11_score(byte *i, int stride, xy *corners,
                      int num_corners, int b)
    int* fast12_score(byte *i, int stride, xy *corners,
                      int num_corners, int b)

    xy* fast9_detect_nonmax(byte *im, int xsize, int ysize, int stride,
                            int b, int *ret_num_corners)
    xy* fast10_detect_nonmax(byte *im, int xsize, int ysize, int stride,
                             int b, int *ret_num_corners)
    xy* fast11_detect_nonmax(byte *im, int xsize, int ysize, int stride,
                             int b, int *ret_num_corners)
    xy* fast12_detect_nonmax(byte *im, int xsize, int ysize, int stride,
                             int b, int *ret_num_corners)

    xy* nonmax_suppression(xy *corners, int *scores,
                           int num_corners, int *ret_num_nonmax)

from libc.stdlib cimport free
from cpython cimport PyObject, Py_INCREF
from cython.view cimport array as cvarray

import numpy as np
cimport numpy as np
np.import_array()

# Define functions in Cython that use the C-library.
def fast_detect2(np.ndarray[np.uint8_t,ndim=2] im):
    cdef int xsize = <int> im.shape[1]
    cdef int ysize = <int> im.shape[0]
    cdef int num_ret
    cdef xy *ret 
    ret = fast9_detect(<byte*> im.data, xsize, ysize, 
                       xsize, 50, &num_ret)
    n = 2*num_ret
    cdef cvarray my_cython_array = <xy[:n]> ret
    my_cython_array.callback_free_data = free
    ndarray = np.asarray(my_cython_array)
    return ndarray

# Define functions in Cython that use the C-library.
def fast_detect(np.ndarray[np.uint8_t,ndim=2] im):
    cdef int xsize = <int> im.shape[1]
    cdef int ysize = <int> im.shape[0]
    cdef int num_ret
    cdef xy *ret 
    ret = fast9_detect(<byte*> im.data, xsize, ysize, 
                       xsize, 50, &num_ret)
    dets = []
    for i in range(num_ret):
        dets.append((ret[i].x, ret[i].y))
    return dets
