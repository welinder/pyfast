

# declare the functions we want from the C-library.
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

# using cvarray and free to map data onto numpy arrays
from libc.stdlib cimport free
from cython.view cimport array as cvarray
# for support of input/outputs as ndarrays
import numpy as np
cimport numpy as np
np.import_array()

def fast_detect(np.ndarray[np.uint8_t,ndim=2] im, int thresh, n=9,
                nonmax=False):
    """Detect FAST corners.
    """
    cdef int xsize = <int> im.shape[1]
    cdef int ysize = <int> im.shape[0]
    # detect corners
    cdef int n_corners
    cdef xy *corners
    if n == 9:
       corners = fast9_detect(<byte*> im.data, xsize, ysize, 
                              xsize, thresh, &n_corners)
    elif n == 10:
       corners = fast10_detect(<byte*> im.data, xsize, ysize, 
                               xsize, thresh, &n_corners)
    elif n == 11:
       corners = fast11_detect(<byte*> im.data, xsize, ysize, 
                               xsize, thresh, &n_corners)
    elif n == 12:
       corners = fast12_detect(<byte*> im.data, xsize, ysize, 
                               xsize, thresh, &n_corners)
    else:
        raise ValueError, "n must be set to 9, 10, 11, or 12"
    # convert to numpy array
    cdef cvarray tmp_array
    tmp_array = <xy[:n_corners]> corners
    tmp_array.callback_free_data = free
    out_array = np.asarray(tmp_array)
    return out_array

    # # map onto numpy array
    # cdef xy *nm_ret
    # cdef int *scores
    # cdef int num_ret_nm
    # if nonmax:
    #     if ncontig == 9:
    #         scores = fast9_score(<byte*> im.data, xsize, ret, 
    #                              num_ret, thresh)
    #     elif ncontig == 10:
    #         scores = fast10_score(<byte*> im.data, xsize, ret, 
    #                               num_ret, thresh)
    #     elif ncontig == 11:
    #         scores = fast11_score(<byte*> im.data, xsize, ret, 
    #                               num_ret, thresh)
    #     elif ncontig == 12:
    #         scores = fast12_score(<byte*> im.data, xsize, ret, 
    #                               num_ret, thresh)
    #     nm_ret = nonmax_suppression(ret, scores,
    #                                 num_ret, &num_ret_nm)
    #     # TODO: free all those temporary variables we used
    #     my_cython_array = <xy[:num_ret_nm]> nm_ret
    #     my_cython_array.callback_free_data = free
    #     ndarray = np.asarray(my_cython_array)
    #     return ndarray
    # else:
    #     my_cython_array = <xy[:num_ret]> ret
    #     my_cython_array.callback_free_data = free
    #     ndarray = np.asarray(my_cython_array)
    #     return ndarray
