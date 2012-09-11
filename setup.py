import sys
from os.path import join
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy

# find all source files in the fast-directory
fast_src_files = ["fast", "fast_9", "fast_10", "fast_11", "fast_12", "nonmax"]
sources = [join("fast", fn + ".c") for fn in fast_src_files]
sources += ["pyfast.pyx"]

# fix for windows
extra_compile_args = []
if sys.platform == 'win32':
    extra_compile_args.append("-march=i486")

# use distutils to compile the C-extension and link it to the Cython module.
ext_modules = [Extension(name="pyfast", sources=sources,
                         include_dirs=[numpy.get_include(), "fast"],
                         extra_compile_args=extra_compile_args)]

# create the setup.
setup(name='pyfast',
      version='0.1',
      description='Python wrapper for the FAST corner detector',
      author='Peter Welinder',
      author_email='peter@welinder.se',
      url='https://github.com/welinder/pyfast',
      cmdclass={ 'build_ext': build_ext },
      ext_modules=ext_modules)
