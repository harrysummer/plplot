# --*-perl-*--
# plapi.tpl
# PLplot API template specification file.
# Geoffrey Furnish
# 28 June 1995
#
# This file specifies the PLplot API in a form suitable for input to
# pltclgen, the Perl script which autogenerates a set of Tcl command
# procedures for gaining access to the PLplot API from Tcl.  This file
# was constructed by inserting plplot.h, and then converting the C
# prototype to the form suitable to pltclgen.  Note that not all
# functions can be autogenerated.  As the PLplot Tcl API definition
# matures, the prototypes for the unneeded functions should just be
# eliminated from this file.
#
# $Id$
#
# $Log$
# Revision 1.6  1995/10/16 18:25:24  mjl
# Much cleaning up.  Changes: input characters strings are now specified as
# "const char *", output character strings by "char *".  Input single chars
# are specified as "char" and output chars by "char&" (used in plsesc/plgesc).
# Added entries for: plgfnam, plsdev, plgdev, plgver, plsesc, plgesc,
# plmkstrm.
#
# Revision 1.5  1995/07/01  20:26:22  furnish
# Implemented plot3d and plmesh, so prototypes removed from here.  Many
# other things still require cleaning, however.
#
# Revision 1.4  1995/06/30  13:57:03  furnish
# Tyop introduced last update, grrrr.
#
# Revision 1.3  1995/06/30  13:47:02  furnish
# Fix typo in one of the function names.
#
# Revision 1.2  1995/06/29  20:21:43  furnish
# Also, pltclgen now supports pointer args, so the plapi.tpl file has
# been embellished to cause autogeneration of all interface functions
# taking 1-d arrays in places where the C function took a pointer.
#
# Revision 1.1  1995/06/28  14:55:48  furnish
# PLplot API template specification file which defines the PLplot API in
# a manner suitable for autogeneration of the Tcl command procedure
# interface functions.  This initial version specifies 73 functions.
# These are all the "easy" ones, including many that return values.  Of
# course several of the "hard" ones (mostly 2-d API functions) are still
# implemented in tclAPI.c.
#
###############################################################################

# Advance to subpage "page", or to the next one if "page" = 0.

pltclcmd pladv void
page	PLINT Def: 0

# This functions similarly to plbox() except that the origin of the axes
# is placed at the user-specified point (x0, y0).

pltclcmd plaxes void
x0	PLFLT
y0	PLFLT
xopt	const char *
xtick	PLFLT
nxsub	PLINT
yopt	const char *
ytick	PLFLT
nysub	PLINT

# Plot a histogram using x to store data values and y to store frequencies

pltclcmd plbin void
nbin	PLINT
x	PLFLT *
y	PLFLT *
center	PLINT

# Start new page.  Should only be used with pleop().

pltclcmd plbop void

# This draws a box around the current viewport.

pltclcmd plbox void
xopt	const char *
xtick	PLFLT
nxsub	PLINT
yopt	const char *
ytick	PLFLT
nysub	PLINT

# This is the 3-d analogue of plbox().

pltclcmd plbox3 void
xopt	const char *
xlabel	const char *
xtick	PLFLT
nsubx	PLINT
yopt	const char *
ylabel	const char *
ytick	PLFLT
nsuby	PLINT
zopt	const char *
zlabel	const char *
ztick	PLFLT
nsubz	PLINT

# Set color, map 0.  Argument is integer between 0 and 15.

pltclcmd plcol0 void
icol0	PLINT

# Set color, map 1.  Argument is a float between 0. and 1.

pltclcmd plcol1 void
col1	PLFLT

# Converts input values from relative device coordinates to relative plot
# coordinates.

pltclcmd pldid2pc void
xmin	PLFLT&
ymin	PLFLT&
xmax	PLFLT&
ymax	PLFLT&

# Converts input values from relative plot coordinates to relative
# device coordinates.

pltclcmd pldip2dc void
xmin	PLFLT&
ymin	PLFLT&
xmax	PLFLT&
ymax	PLFLT&

# End a plotting session for all open streams.

pltclcmd plend void

# End a plotting session for the current stream only.

pltclcmd plend1 void

# Simple interface for defining viewport and window.

pltclcmd plenv void
xmin	PLFLT
xmax	PLFLT
ymin	PLFLT
ymax	PLFLT
just	PLINT
axis	PLINT

# End current page.  Should only be used with plbop().

pltclcmd pleop void

# Plot horizontal error bars (xmin(i),y(i)) to (xmax(i),y(i))

pltclcmd plerrx void
n	PLINT
xmin	PLFLT *
xmax	PLFLT *
y	PLFLT *

# Plot vertical error bars (x,ymin(i)) to (x(i),ymax(i))

pltclcmd plerry void
n	PLINT
x	PLFLT *
ymin	PLFLT *
ymax	PLFLT *

# Advance to the next family file on the next new page

pltclcmd plfamadv void

# Pattern fills the polygon bounded by the input points.

pltclcmd plfill void
n	PLINT
x	PLFLT *
y	PLFLT *

# Flushes the output stream.  Use sparingly, if at all.

pltclcmd plflush void

# Sets the global font flag to 'ifont'.

pltclcmd plfont void
ifont	PLINT

# Load specified font set.

pltclcmd plfontld void
fnt	PLINT

# Get character default height and current (scaled) height.

pltclcmd plgchr void
def	PLFLT&
ht	PLFLT&

# Returns 8 bit RGB values for given color from color map 0.

pltclcmd plgcol0 void
icol0	PLINT
r	PLINT *
g	PLINT *
b	PLINT *

# Returns the background color by 8 bit RGB value.
# Will the autogenerated one produce useful values in Tcl ???
# Can this be implemented using PLINT& ???

# void
# c_plgcolbg(PLINT *r, PLINT *g, PLINT *b);

# Retrieve current window into device space.

pltclcmd plgdidev void
mar	PLFLT&
aspect	PLFLT&
jx	PLFLT&
jy	PLFLT&

# Get plot orientation .

pltclcmd plgdiori void
rot	PLFLT&

# Retrieve current window into plot space.

pltclcmd plgdiplt void
xmin	PLFLT&
ymin	PLFLT&
xmax	PLFLT&
ymax	PLFLT&

# Get family file parameters.

pltclcmd plgfam void
fam	PLINT&
num	PLINT&
bmax	PLINT&

# Get output device parameters.

pltclcmd plgpage void
xp	PLFLT&
yp	PLFLT&
xleng	PLINT&
yleng	PLINT&
xoff	PLINT&
yoff	PLINT&

# Switches to graphics screen.

pltclcmd plgra void

# Get subpage boundaries in absolute coordinates.

pltclcmd plgspa void
xmin	PLFLT&
xmax	PLFLT&
ymin	PLFLT&
ymax	PLFLT&

# Get current stream number.
# NOTE: Providing this feature from Tcl will finally provide a
# reliable mechanism for binding a C++ plstream object to a Tk plframe
# widget.  Query the frame for it's stream id, then pass this to the
# C++ side and use it to initialize the plstream object.

pltclcmd plgstrm void
strm	PLINT&

# Get the current library version number.

pltclcmd plgver void
ver	char *

# Get x axis labeling parameters.

pltclcmd plgxax void
digmax	PLINT&
digits	PLINT&

# Get y axis labeling parameters.

pltclcmd plgyax void
digmax	PLINT&
digits	PLINT&

# Get z axis labeling parameters.

pltclcmd plgzax void
digmax	PLINT&
digits	PLINT&

# Draws a histogram of n values of a variable in array data[0..n-1].
# pltclgen not able to handle Tcl Matricies yet.

pltclcmd plhist void
n	PLINT
data	PLFLT *
datmin	PLFLT
datmax	PLFLT
nbin	PLINT
oldwin	PLINT

# Set current color (map 0) by hue, lightness, and saturation.

pltclcmd plhls void
h	PLFLT
l	PLFLT
s	PLFLT

# Initializes PLplot, using preset or default options.

pltclcmd plinit void

# Draws a line segment from (x1, y1) to (x2, y2).

pltclcmd pljoin void
x1	PLFLT
y1	PLFLT
x2	PLFLT
y2	PLFLT

# Simple routine for labelling graphs.

pltclcmd pllab void
xlabel	const char *
ylabel	const char *
tlabel	const char *

# Draws line segments connecting a series of points.
# The original tclAPI.c version of this had a defaultable n capability,
# which we don't have...

pltclcmd plline void
n	PLINT
x	PLFLT *
y	PLFLT *

# Draws a line in 3 space.
# pltclgen...

pltclcmd plline3 void
n	PLINT
x	PLFLT *
y	PLFLT *
z	PLFLT *

# Set line style.

pltclcmd pllsty void
lin	PLINT

# Creates a new stream and makes it the default.

pltclcmd plmkstrm void
strm	PLINT&

# Prints out "text" at specified position relative to viewport.

pltclcmd plmtex void
side	const char *
disp	PLFLT
pos	PLFLT
just	PLFLT
text	const char *

# Set fill pattern directly.

pltclcmd plpat void
nlin	PLINT
inc	PLINT *
del	PLINT *

# Plots array y against x for n points using ASCII code "code".
# The original tclAPI.c version of this had a defaultable n capability,
# which we don't have...

pltclcmd plpoin void
n	PLINT
x	PLFLT *
y	PLFLT *
code	PLINT

# Draws a series of points in 3 space.

pltclcmd plpoin3 void
n	PLINT
x	PLFLT *
y	PLFLT *
z	PLFLT *
code	PLINT

# Draws a polygon in 3 space.

pltclcmd plpoly3 void
n	PLINT
x	PLFLT *
y	PLFLT *
z	PLFLT *
draw	PLINT *

# Set the floating point precision (in number of places) in numeric labels.

pltclcmd plprec void
setp	PLINT
prec	PLINT

# Set fill pattern, using one of the predefined patterns.

pltclcmd plpsty void
patt	PLINT

# Prints out "text" at world cooordinate (x,y).

pltclcmd plptex void
x	PLFLT
y	PLFLT
dx	PLFLT
dy	PLFLT
just	PLFLT
text	const char *

# Replays contents of plot buffer to current device/file.

pltclcmd plreplot void

# Set line color by red, green, blue from  0. to 1.

pltclcmd plrgb void
r	PLFLT
g	PLFLT
b	PLFLT

# Set line color by 8 bit RGB values.

pltclcmd plrgb1 void
r	PLINT
g	PLINT
b	PLINT

# Set character height.

pltclcmd plschr void
def	PLFLT
scale	PLFLT

# Set number of colors in cmap 0.

pltclcmd plscmap0n void
ncol0	PLINT

# Set number of colors in cmap 1.

pltclcmd plscmap1n void
ncol1	PLINT

# Set color map 0 colors by 8 bit RGB values.

pltclcmd plscmap0 void
r	PLINT *
g	PLINT *
b	PLINT *
ncol0	PLINT

# Set color map 1 colors by 8 bit RGB values.

pltclcmd plscmap1 void
r	PLINT *
g	PLINT *
b	PLINT *
ncol1	PLINT

# Set color map 1 colors using a piece-wise linear relationship between
# intensity [0,1] (cmap 1 index) and position in HLS or RGB color space.

pltclcmd plscmap1l void
itype		PLINT
npts		PLINT
intensity	PLFLT *
coord1		PLFLT *
coord2		PLFLT *
coord3		PLFLT *
rev		PLINT *

# Set a given color from color map 0 by 8 bit RGB value.

pltclcmd plscol0 void
icol0	PLINT
r	PLINT
g	PLINT
b	PLINT

# Set the background color by 8 bit RGB value.

pltclcmd plscolbg void
r	PLINT
g	PLINT
b	PLINT

# Used to globally turn color output on/off.

pltclcmd plscolor void
color	PLINT

# Set the device (keyword) name

pltclcmd plsdev void
devnam	const char *

# Get the device (keyword) name

pltclcmd plgdev void
devnam	char *

# Set window into device space using margin, aspect ratio, and
# justification.

pltclcmd plsdidev void
mar	PLFLT
aspect	PLFLT
jx	PLFLT
jy	PLFLT

# Set up transformation from metafile coordinates.

pltclcmd plsdimap void
dimxmin	PLINT
dimxmax	PLINT
dimymin	PLINT
dimymax	PLINT
dimxpmm	PLFLT
dimypmm	PLFLT

# Set plot orientation, specifying rotation in units of pi/2.

pltclcmd plsdiori void
rot	PLFLT

# Set window into plot space.

pltclcmd plsdiplt void
xmin	PLFLT
ymin	PLFLT
xmax	PLFLT
ymax	PLFLT

# Set window into plot space incrementally (zoom).

pltclcmd plsdiplz void
xmin	PLFLT
ymin	PLFLT
xmax	PLFLT
ymax	PLFLT

# Set the escape character for text strings.

pltclcmd plsesc void
esc	char

# Get the escape character for text strings.

pltclcmd plgesc void
esc	char&

# Set family file parameters

pltclcmd plsfam void
fam	PLINT
num	PLINT
bmax	PLINT

# Set the output file name.

pltclcmd plsfnam void
fnam	const char *

# Get the output file name.

pltclcmd plgfnam void
fnam	char *

# Set up lengths of major tick marks.

pltclcmd plsmaj void
def	PLFLT
scale	PLFLT

# Set up lengths of minor tick marks.

pltclcmd plsmin void
def	PLFLT
scale	PLFLT

# Set orientation.  Must be done before calling plinit.

pltclcmd plsori void
ori	PLINT

# Set output device parameters.  Usually ignored by the driver.

pltclcmd plspage void
xp	PLFLT
yp	PLFLT
xleng	PLINT
yleng	PLINT
xoff	PLINT
yoff	PLINT

# Set the pause (on end-of-page) status.

pltclcmd plspause void
paus	PLINT

# Set stream number.

pltclcmd plsstrm void
strm	PLINT

# Set the number of subwindows in x and y.

pltclcmd plssub void
nx	PLINT
ny	PLINT

# Set symbol height.

pltclcmd plssym void
def	PLFLT
scale	PLFLT

# Set up a new line style.

pltclcmd plstyl void
nms	PLINT
mark	PLINT *
space	PLINT *

# Sets the edges of the viewport to the specified absolute coordinates.

pltclcmd plsvpa void
xmin	PLFLT
xmax	PLFLT
ymin	PLFLT
ymax	PLFLT

# Set x axis labeling parameters.

pltclcmd plsxax void
digmax	PLINT
digits	PLINT

# Set y axis labeling parameters.

pltclcmd plsyax void
digmax	PLINT
digits	PLINT	Def: 0

# Plots array y against x for n points using Hershey symbol "code".
# The original tclAPI.c version of this had a defaultable n capability,
# which we don't have...

pltclcmd plsym void
n	PLINT
x	PLFLT *
y	PLFLT *
code	PLINT

# Set z axis labeling parameters.

pltclcmd plszax void
digmax	PLINT
digits	PLINT

# Switches to text screen.

pltclcmd pltext void

# Sets the edges of the viewport with the given aspect ratio, leaving
# room for labels.

pltclcmd plvasp void
aspect	PLFLT

# Creates the largest viewport of the specified aspect ratio that fits
# within the specified normalized subpage coordinates.

pltclcmd plvpas void
xmin	PLFLT
xmax	PLFLT
ymin	PLFLT
ymax	PLFLT
aspect	PLFLT

# Creates a viewport with the specified normalized subpage coordinates.

pltclcmd plvpor void
xmin	PLFLT
xmax	PLFLT
ymin	PLFLT
ymax	PLFLT

# Defines a "standard" viewport with seven character heights for the
# left margin and four character heights everywhere else.

pltclcmd plvsta void

# Set up a window for three-dimensional plotting.

pltclcmd plw3d void
basex	PLFLT
basey	PLFLT
height	PLFLT
xmin0	PLFLT
xmax0	PLFLT
ymin0	PLFLT
ymax0	PLFLT
zmin0	PLFLT
zmax0	PLFLT
alt	PLFLT
az	PLFLT

# Set pen width.

pltclcmd plwid void
width	PLINT

# Set up world coordinates of the viewport boundaries (2d plots).

pltclcmd plwind void
xmin	PLFLT
xmax	PLFLT
ymin	PLFLT
ymax	PLFLT

###############################################################################
# The rest are kept in as reminders to how Tcl API might be improved 

# Draws a contour plot from data in f(nx,ny).  Is just a front-end to
# plfcont, with a particular choice for f2eval and f2eval_data. 

# void
# c_plcont(PLFLT **f, PLINT nx, PLINT ny, PLINT kx, PLINT lx,
# 	 PLINT ky, PLINT ly, PLFLT *clevel, PLINT nlevel,
# 	 void (*pltr) (PLFLT, PLFLT, PLFLT *, PLFLT *, PLPointer),
# 	 PLPointer pltr_data);

# Draws a contour plot using the function evaluator f2eval and data stored
# by way of the f2eval_data pointer.  This allows arbitrary organizations
# of 2d array data to be used. 

# void
# plfcont(PLFLT (*f2eval) (PLINT, PLINT, PLPointer),
# 	PLPointer f2eval_data,
# 	PLINT nx, PLINT ny, PLINT kx, PLINT lx,
# 	PLINT ky, PLINT ly, PLFLT *clevel, PLINT nlevel,
# 	void (*pltr) (PLFLT, PLFLT, PLFLT *, PLFLT *, PLPointer),
# 	PLPointer pltr_data);

# plot continental outline in world coordinates.

# void
# plmap(void (*mapform)(PLINT, PLFLT *, PLFLT *), char *type,
#       PLFLT minlong, PLFLT maxlong, PLFLT minlat, PLFLT maxlat);

# Plot the latitudes and longitudes on the background.

# void 
# plmeridians(void (*mapform)(PLINT, PLFLT *, PLFLT *), 
# 	    PLFLT dlong, PLFLT dlat,
# 	    PLFLT minlong, PLFLT maxlong, PLFLT minlat, PLFLT maxlat);

# Shade region.

# void 
# c_plshade(PLFLT **a, PLINT nx, PLINT ny, const char **defined,
# 	  PLFLT left, PLFLT right, PLFLT bottom, PLFLT top,
# 	  PLFLT shade_min, PLFLT shade_max,
# 	  PLINT sh_cmap, PLFLT sh_color, PLINT sh_width,
# 	  PLINT min_color, PLINT min_width,
# 	  PLINT max_color, PLINT max_width,
# 	  void (*fill) (PLINT, PLFLT *, PLFLT *), PLINT rectangular,
# 	  void (*pltr) (PLFLT, PLFLT, PLFLT *, PLFLT *, PLPointer),
# 	  PLPointer pltr_data);

# void 
# plshade1(PLFLT *a, PLINT nx, PLINT ny, const char *defined,
# 	 PLFLT left, PLFLT right, PLFLT bottom, PLFLT top,
# 	 PLFLT shade_min, PLFLT shade_max,
# 	 PLINT sh_cmap, PLFLT sh_color, PLINT sh_width,
# 	 PLINT min_color, PLINT min_width,
# 	 PLINT max_color, PLINT max_width,
# 	 void (*fill) (PLINT, PLFLT *, PLFLT *), PLINT rectangular,
# 	 void (*pltr) (PLFLT, PLFLT, PLFLT *, PLFLT *, PLPointer),
# 	 PLPointer pltr_data);

# void 
# plfshade(PLFLT (*f2eval) (PLINT, PLINT, PLPointer),
# 	 PLPointer f2eval_data,
# 	 PLFLT (*c2eval) (PLINT, PLINT, PLPointer),
# 	 PLPointer c2eval_data,
# 	 PLINT nx, PLINT ny, 
# 	 PLFLT left, PLFLT right, PLFLT bottom, PLFLT top,
# 	 PLFLT shade_min, PLFLT shade_max,
# 	 PLINT sh_cmap, PLFLT sh_color, PLINT sh_width,
# 	 PLINT min_color, PLINT min_width,
# 	 PLINT max_color, PLINT max_width,
# 	 void (*fill) (PLINT, PLFLT *, PLFLT *), PLINT rectangular,
# 	 void (*pltr) (PLFLT, PLFLT, PLFLT *, PLFLT *, PLPointer),
# 	 PLPointer pltr_data);

# Returns a list of file-oriented device names and their menu strings

# void
# plgFileDevs(char ***p_menustr, char ***p_devname, int *p_ndev);

# Set the function pointer for the keyboard event handler

# void
# plsKeyEH(void (*KeyEH) (PLGraphicsIn *, void *, int *), void *KeyEH_data);

# Set the function pointer for the (mouse) button event handler

# void
# plsButtonEH(void (*ButtonEH) (PLGraphicsIn *, void *, int *),
# 	    void *ButtonEH_data);

# Sets an optional user exit handler.

# void
# plsexit(int (*handler) (char *));

# Command line parsing utilities

# Clear internal option table info structure.

# void
# plClearOpts(void);

# Reset internal option table info structure.

# void
# plResetOpts(void);

# Merge user option table into internal info structure.

# int
# plMergeOpts(PLOptionTable *options, char *name, char **notes);

# Set the strings used in usage and syntax messages.

# void
# plSetUsage(char *program_string, char *usage_string);

# Process input strings, treating them as an option and argument pair.

# int
# plSetOpt(char *opt, char *optarg);

# Process options list using current options info.

# int
# plParseOpts(int *p_argc, char **argv, PLINT mode);

# Print usage & syntax message.

# void
# plOptUsage(void);

# Set the output file pointer

# void
# plgfile(FILE **p_file);

# Get the output file pointer

# void
# plsfile(FILE *file);

# Front-end to driver escape function.

# void
# pl_cmd(PLINT op, void *ptr);

# Return full pathname for given file if executable

# int 
# plFindName(char *p);

# Looks for the specified executable file according to usual search path.

# char *
# plFindCommand(char *fn);

# Gets search name for file by concatenating the dir, subdir, and file
# name, allocating memory as needed. 

# void
# plGetName(char *dir, char *subdir, char *filename, char **filespec);

# Functions for converting between HLS and RGB color space

# void
# plHLS_RGB(PLFLT h, PLFLT l, PLFLT s, PLFLT *p_r, PLFLT *p_g, PLFLT *p_b);

# void
# plRGB_HLS(PLFLT r, PLFLT g, PLFLT b, PLFLT *p_h, PLFLT *p_l, PLFLT *p_s);

# Wait for graphics input event and translate to world coordinates

# int
# plGetCursor(PLGraphicsIn *gin);

# Translates relative device coordinates to world coordinates. 

# int
# plTranslateCursor(PLGraphicsIn *gin);
