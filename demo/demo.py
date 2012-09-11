"""
Example of how to use the python wrapper. Run this demo from the command.
There are two ways to run the demo:

(1) Show corners extracted in an example image:

    python demo.py show_corners

Can also be run with additional arguments for thresh, n, and nms parameters.

    python demo.py show_corners 10 100 true

(2) Time how fast the algorithm is:

    python demo.py time

Can also be run with additional arguments for thresh and n parameters.

    python demo.py time 10 100

The demo image, pantheon.jpg, was taken from Wikipedia:
http://en.wikipedia.org/wiki/File:The_Pantheon.jpg
"""
import sys
try:
    import pyfast
except:
    # import pyfast from parent directory.
    sys.path.append('..')
    import pyfast
from timeit import timeit
import numpy as np
import matplotlib.pylab as plt
from PIL import Image

############################################################################
### PARAMETERS FOR FAST

# threshold for algorithm
thresh = 50
# number of contiguous pixels around the circle to use
n = 9
# apply non-maximum supression (ignored for timing)
nms = False

############################################################################
### DEMO TASKS
if len(sys.argv) < 2:
    print "Provide a task to run."
    sys.exit()
else:
    task = sys.argv[1]
# parse other command line arguments
if len(sys.argv) > 2:
    thresh = int(sys.argv[2])
if len(sys.argv) > 3:
    n = int(sys.argv[3])
if len(sys.argv) > 4:
    nms = (sys.argv[4] == "1") or (sys.argv[4].lower() == "true")

if task == "show_corners":
    print """
    Showing the output of the FAST algorithm on an example image.
    """
    # load grayscale version of image and convert to numpy array
    image = Image.open('pantheon.jpg').convert("L")
    im = np.asarray(image)
    # run FAST
    if nms:
        dets = pyfast.detect(im, thresh, n=n, nms=True)
    else:
        dets, scores = pyfast.detect(im, thresh, n=n, nms=False, return_scores=True)
    print "Found {} corners in the image.".format(len(dets))
    # plot results
    fig = plt.figure(1)
    fig.clear()
    ax = fig.add_subplot(1,1,1)
    axes = ax.get_axes()
    ax.imshow(im, cmap=plt.cm.gray)
    x, y = [d[0] for d in dets], [d[1] for d in dets]
    ax.plot(x, y, 'r.')
    ax.set_axes(axes)
    ax.set_axis_off()
    fig.canvas.draw()
    # prevent program from exiting
    raw_input("Press enter to close.")

if task == "time":
    print """
    Benchmarking FAST.
    """
    # number of times to run FAST
    number = 100
    r = timeit(stmt="pyfast.detect(im, thresh, n=n)",
               setup="import pyfast\n" + 
                     "import numpy as np\n" +
                     "from PIL import Image\n" +
                     "image = Image.open('pantheon.jpg').convert('L')\n" +
                     "im = np.asarray(image)\n" +
                     "thresh, n = {}, {}\n".format(thresh, n),
               number=number)
    print "Running at %.1f Hz" % (number/r,)
