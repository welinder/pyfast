# Python wrapper for the FAST corner detector #

This is a python wrapper for the FAST corner detector written in Cython.
It is a wrapper around the original C implementation, so it is very fast.

FAST is a super fast corner detector developed by Edward Rosten and 
Tom Drummond. For more information, visit Rosten's project page:

http://www.edwardrosten.com/work/fast.html

There are many other wrappers and implementations for FAST, for example
in OpenCV. I wrote this wrapper for two reasons (1) to have a simple standalone
wrapper for python, and (2) to learn how to use Cython.

# Installation #

You can download or clone this repository and then run:

    python setup.py build_ext -i

This will compile the module in the current directory (assuming Cython and 
numpy are installed), but not install it on your system. Great approach if you
just want to try it out. If you want to install it, you just run:

    python setup.py install

# Use #

To use `pyfast`, just import the module and run the `detect`
function. For example, the most basic use is

    import pyfast
    detections, scores = pyfast.detect(image, threshold)

where `image` is the image represented as a 2D UINT8 numpy array, and
`threshold` is the threshold parameter for the FAST algorithm. Setting
`threshold` to a value between 20 to 100 usually yields good
results. Smaller values of the threshold run slower but returns more
corners, higher values run faster but return fewer corners.
See the Figure 11 in the
[[http://www.edwardrosten.com/work/rosten_2005_tracking.pdf][original paper (PDF)]]
for more information about the tradeoff between speed and the number
of corners detected.

Check out `demo/demo.py` for a real example of how to use the
wrapper. It's really quite simple.

# License and copyright #

Licensed under the same license as the original FAST implementation. See 
`LICENSE` and `fast/LICENSE`. The `fast/` directory contains the original
(unmodified) fast C implementaton.

Copyright (c) 2012 Peter Welinder

