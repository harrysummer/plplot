# Copyright 2002 Gary Bishop and Alan W. Irwin
# This file is part of PLplot.

# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Library General Public License as published by
# the Free Software Foundation; version 2 of the License.

# This file is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.

# You should have received a copy of the GNU Library General Public License
# along with the file; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA

# Wrap raw python interface to C API, plplotc, with this user-friendly version
# which implements some useful variations of the argument lists.

from plplotc import *
import types
import Numeric

#  Redefine plcont to have the user-friendly interface
#  Allowable syntaxes:

#  plcont( z, [kx, lx, ky, ly], clev, [pltr, [pltr_data] or [xg, yg, [wrap]])
#  N.B. Brackets represent options here and not python lists!

#  All unbracketed arguments within brackets must all be present or all be
#  missing.  Furthermore, z must be a 2D array, kx, lx, ky, ly must all be
#  integers, clev must be a 1D array, pltr can be a function reference or
#  string, pltr_data is an optional arbitrary data object, xg and yg are 
#  optional 1D or 2D arrays and wrap (which only works if xg and yg
#  are specified) is 0, 1, or 2.

#  If pltr is a string it must be either "pltr0", "pltr1", or "pltr2" to
#  refer to those built-in transformation functions.  Alternatively, the
#  function names pltr0, pltr1, or pltr2 may be specified to refer to
#  the built-in transformation functions or an arbitrary name for a
#  user-defined transformation function may be specified.  Such functions
#  must have x, y, and optional pltr_data arguments and return arbitrarily
#  transformed x' and y' in a tuple.  The built-in pltr's such as pltr1 and
#  pltr2 use pltr_data = tuple(xg, yg), and for this oft-used case (and any
#  other user-defined pltr which uses a tuple of two arrays for pltr_data),
#  we also provide optional xg and yg arguments separately as an alternative
#  to the tuple method of providing these data. Note, that pltr_data cannot
#  be in the argument list if xg and yg are there, and vice versa. Also note
#  that the built-in pltr0 and some user-defined transformation functions
#  ignore the auxiliary pltr_data (or the alternative xg and yg) in which
#  case neither pltr_data nor xg and yg need to be specified.

_plcont = plcont
def plcont(z, *args):
    z = Numeric.asarray(z)
    if len(z.shape) != 2:
	raise ValueError, 'Expected 2D z array'

    if len(args) > 4 and type(args[0]) == types.IntType:
	for i in range(1,4):
	    if type(args[i]) != types.IntType:
		raise ValueError, 'Expected 4 ints for kx,lx,ky,ly'

	else:
	    # these 4 args are the kx, lx, ky, ly ints
	    ifdefault_range = 0
	    kx,lx,ky,ly = args[0:4]
	    args = args[4:]
    else:
	default_range = 1

    if len(args) > 0:
	clev = Numeric.asarray(args[0])
	if len(clev.shape) !=1:
	    raise ValueError, 'Expected 1D clev array'
	args = args[1:]
    else:
	raise ValueError, 'Missing clev argument'

    if len(args) > 0 and (
    type(args[0]) == types.StringType or
    type(args[0]) == types.BuiltinFunctionType):
	pltr = args[0]
	# Handle the string names for the callbacks though specifying the
	# built-in function name directly (without the surrounding quotes) 
	# or specifying any user-defined transformation function 
	# (following above rules) works fine too.
	if type(pltr) == types.StringType:
	    if pltr == 'pltr0':
		pltr = pltr0
	    elif pltr == 'pltr1':
		pltr = pltr1
	    elif pltr == 'pltr2':
		pltr = pltr2
	    else:
		raise ValueError, 'pltr string is unrecognized'

	args = args[1:]
	# Handle pltr_data or separate xg, yg, [wrap]
	if len(args) == 0:
	    # Default pltr_data
	    pltr_data = None
	elif len(args) == 1:
	    #Must be pltr_data
	    pltr_data = args[0]
	elif len(args) == 2 or len(args) == 3:
	    xg = Numeric.asarray(args[0])
	    if len(xg.shape) < 1 or len(xg.shape) > 2:
		raise ValueError, 'xg must be 1D or 2D array'
	    yg = Numeric.asarray(args[1])
	    if len(yg.shape) < 1 or len(yg.shape) > 2:
		raise ValueError, 'yg must be 1D or 2D array'
	    # wrap only relevant if xg and yg specified.
	    if len(args) == 3:
	     if type(args[-1]) == types.IntType:
	      wrap = args[-1]
	      if len(xg.shape) == 2 and len(yg.shape) == 2:
		# handle wrap
		if wrap == 1:
		    z = Numeric.resize(z, (z.shape[0]+1, z.shape[1]))
		    xg = Numeric.resize(xg, (xg.shape[0]+1, xg.shape[1]))
		    yg = Numeric.resize(yg, (yg.shape[0]+1, yg.shape[1]))
		elif wrap == 2:
		    z = Numeric.transpose(Numeric.resize(
		    Numeric.transpose(z), (z.shape[1]+1, z.shape[0])))
		    xg = Numeric.transpose(Numeric.resize(
		    Numeric.transpose(xg), (xg.shape[1]+1, xg.shape[0])))
		    yg = Numeric.transpose(Numeric.resize(
		    Numeric.transpose(yg), (yg.shape[1]+1, yg.shape[0])))
		elif wrap != 0:
		    raise ValueError, "Invalid wrap specifier, must be 0, 1 or 2."
	      elif wrap != 0:
		  raise ValueError, 'Non-zero wrap specified and xg and yg are not 2D arrays'
	     else:
		 raise ValueError, 'Specified wrap is not an integer'
	    pltr_data = (xg, yg)
	else:
	    raise ValueError, 'Must have 0-3 arguments after pltr'
    else:
	# default is identity transformation
	pltr = pltr0
	pltr_data = None
    if default_range:
	# Default is to take full range (still using fortran convention
	# for indices which is embedded in the PLplot library API)
	kx = 1
	lx = z.shape[0]
	ky = 1
	ly = z.shape[1]
    _plcont(z, kx, lx, ky, ly, clev, pltr, pltr_data)
plcont.__doc__ = _plcont.__doc__
  
_plstyl = plstyl
def plstyl(*args):
  if len(args) == 3:
    n,m,s = args
  else:
    m,s = args
    n = 1

  if n == 0:
    m = []
    s = []
  if type(m) == types.IntType:
    m = [m]
  if type(s) == types.IntType:
    s = [s]

  _plstyl(m,s)
plstyl.__doc__ = _plstyl.__doc__

_plshades = plshades
def plshades(z, xmin, xmax, ymin, ymax, clevel, fill_width, cont_color, cont_width, rect,
             *args):
  pltr = pltr0
  xg = None
  yg = None
  if len(args) >= 3:
    pltr, xg, yg = args[0:3]
    args = args[3:]

  wrap = 0
  if len(args) == 1:
    wrap = args[0]
  elif len(args) != 0:
    raise 'ValueError', 'too many arguments'

  if wrap == 1:
    z = Numeric.resize(z, (z.shape[0]+1, z.shape[1]))
    if xg:
      xg = Numeric.resize(xg, (xg.shape[0]+1, xg.shape[1]))
    if yg:
      yg = Numeric.resize(yg, (yg.shape[0]+1, yg.shape[1]))
  elif wrap == 2:
    z = Numeric.transpose(Numeric.resize(Numeric.transpose(z), (z.shape[1]+1, z.shape[0])))
    if xg:
      xg =  Numeric.transpose(Numeric.resize(Numeric.transpose(xg), (xg.shape[1]+1, xg.shape[0])))
    if yg:
      yg =  Numeric.transpose(Numeric.resize(Numeric.transpose(yg), (yg.shape[1]+1, yg.shape[0])))
  elif wrap != 0:
    raise ValueError, "Invalid wrap specifier, must be 0, 1 or 2."

  # handle the string names for the callbacks though the function works fine too
  if type(pltr) == types.StringType:
    if pltr == 'pltr0':
      pltr = pltr0
    elif pltr == 'pltr1':
      pltr = pltr1
    elif pltr == 'pltr2':
      pltr = pltr2
    else:
      raise ValueError, 'pltr is unrecognized'

  pltr_data = None
  if xg and yg:
    pltr_data = (xg, yg)
  else:
    pltr_data = None

  _plshades(z,  xmin, xmax, ymin, ymax, clevel, fill_width, cont_color, cont_width,
            rect, pltr, pltr_data)
plshades.__doc__ = _plshades.__doc__
  
