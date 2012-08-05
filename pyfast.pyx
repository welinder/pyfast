

# Re-declare the function we want from the C-library.
cdef extern from "fast.h":
    ctypedef struct xy:
        int x
        int y

    ctypedef unsigned char byte

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
def fast_detect(np.ndarray[np.uint8_t,ndim=2] im, int thresh, 
                ncontig=9, nonmax=False):
    cdef int xsize = <int> im.shape[1]
    cdef int ysize = <int> im.shape[0]
    cdef int num_ret
    cdef xy *ret
    cdef xy *nm_ret
    cdef int *scores
    cdef int num_ret_nm
    cdef cvarray my_cython_array
    if ncontig == 9:
       ret = fast9_detect(<byte*> im.data, xsize, ysize, 
                          xsize, thresh, &num_ret)
    elif ncontig == 10:
       ret = fast10_detect(<byte*> im.data, xsize, ysize, 
                           xsize, thresh, &num_ret)
    elif ncontig == 11:
       ret = fast11_detect(<byte*> im.data, xsize, ysize, 
                           xsize, thresh, &num_ret)
    elif ncontig == 12:
       ret = fast12_detect(<byte*> im.data, xsize, ysize, 
                           xsize, thresh, &num_ret)
    # map onto numpy array
    if nonmax:
        if ncontig == 9:
            scores = fast9_score(<byte*> im.data, xsize, ret, 
                                 num_ret, thresh)
        elif ncontig == 10:
            scores = fast10_score(<byte*> im.data, xsize, ret, 
                                  num_ret, thresh)
        elif ncontig == 11:
            scores = fast11_score(<byte*> im.data, xsize, ret, 
                                  num_ret, thresh)
        elif ncontig == 12:
            scores = fast12_score(<byte*> im.data, xsize, ret, 
                                  num_ret, thresh)
        nm_ret = nonmax_suppression(ret, scores,
                                    num_ret, &num_ret_nm)
        # TODO: free all those temporary variables we used
        n = 2*num_ret_nm
        my_cython_array = <xy[:n]> nm_ret
        my_cython_array.callback_free_data = free
        ndarray = np.asarray(my_cython_array)
        return ndarray
    else:
        n = 2*num_ret
        my_cython_array = <xy[:n]> ret
        my_cython_array.callback_free_data = free
        ndarray = np.asarray(my_cython_array)
        return ndarray
