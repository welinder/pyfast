

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

def detect(np.ndarray[np.uint8_t,ndim=2] im, int thresh, n=9,
           nms=False, return_scores=True):
    """Detect FAST corners.
    """
    cdef int xsize = <int> im.shape[1]
    cdef int ysize = <int> im.shape[0]
    cdef int stride = <int> im.strides[0]
    # detect corners
    cdef int n_corners
    cdef xy *corners
    cdef cvarray tmp_corner_array
    if n == 9:
       corners = fast9_detect(<byte*> im.data, xsize, ysize, 
                              stride, thresh, &n_corners)
    elif n == 10:
       corners = fast10_detect(<byte*> im.data, xsize, ysize, 
                               stride, thresh, &n_corners)
    elif n == 11:
       corners = fast11_detect(<byte*> im.data, xsize, ysize, 
                               stride, thresh, &n_corners)
    elif n == 12:
       corners = fast12_detect(<byte*> im.data, xsize, ysize, 
                               stride, thresh, &n_corners)
    else:
        raise ValueError, "n must be set to 9, 10, 11, or 12"
    # extract scores and run nms if asked for
    cdef int *scores
    cdef cvarray tmp_score_array
    cdef int n_corners_nms
    cdef xy *corners_nms
    if return_scores:
        if n == 9:
            scores = fast9_score(<byte*> im.data, stride, corners,
                                 n_corners, thresh)
        elif n == 10:
            scores = fast10_score(<byte*> im.data, stride, corners,
                                  n_corners, thresh)
        elif n == 11:
            scores = fast11_score(<byte*> im.data, stride, corners, 
                                  n_corners, thresh)
        elif n == 12:
            scores = fast12_score(<byte*> im.data, stride, corners, 
                                  n_corners, thresh)
        if nms:
            # run non-maximum suppression
            corners_nms = nonmax_suppression(corners, scores,
                                             n_corners, &n_corners_nms)
            # clean up non-nms corners and scores
            free(corners)
            free(scores)
            # convert to numpy array
            tmp_corner_array = <xy[:n_corners_nms]> corners_nms
            tmp_corner_array.callback_free_data = free
            corners_ndarray = np.asarray(tmp_corner_array)
            return corners_ndarray
        else:
            # corners
            tmp_corner_array = <xy[:n_corners]> corners
            tmp_corner_array.callback_free_data = free
            corners_ndarray = np.asarray(tmp_corner_array)
            # scores
            tmp_score_array = <int[:n_corners]> scores
            tmp_score_array.callback_free_data = free
            scores_ndarray = np.asarray(tmp_score_array)
            return corners_ndarray, scores_ndarray
    else:
        tmp_corner_array = <xy[:n_corners]> corners
        tmp_corner_array.callback_free_data = free
        corners_ndarray = np.asarray(tmp_corner_array)
        return corners_ndarray
