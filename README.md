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

    python setup.py

# Use #

Check out `demo/demo.py` for how to use the wrapper. It's really quite simple.

# License and copyright #

Licensed under the same license as the original FAST implementation. See 
`LICENSE` and `fast/LICENSE`. The `fast/` directory contains the original
(unmodified) fast C implementaton.

Copyright (c) 2012 Peter Welinder

