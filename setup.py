# This distutils script does the following steps:
import numpy
from os.path import join
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

fast_src_files = ["fast", "fast_9", "fast_10", "fast_11", "fast_12", "nonmax"]
sources = [join("fast", fn + ".c") for fn in fast_src_files]
sources += ["pyfast.pyx"]

# Use distutils to compile the C-extension and link it to the Cython module.
ext_modules = [Extension(name="pyfast", sources=sources,
                         include_dirs=[numpy.get_include(), "fast"])]

# Create the setup.
setup(name='pyfast',
      cmdclass={ 'build_ext': build_ext },
      ext_modules=ext_modules)
