#----------------------------------------------------------------------------
# $Id$
#----------------------------------------------------------------------------

# Does a series of 3-d plots for a given data set, with different
# viewing options in each plot.

# Routine for restoring colour map1 to default.
# See static void plcmap1_def(void) in plctrl.c for reference.
proc restore_cmap1 {w} {
   # For center control points, pick black or white, whichever is closer to bg 
   # Be careful to pick just short of top or bottom else hue info is lost
   $w cmd plgcolbg rbg gbg bbg
   set vertex [expr ($rbg + $gbg + $bbg)/(3.*255.)]
   if {$vertex < 0.5} {
      set vertex 0.01
      set midpt 0.10
   } else {
      set vertex 0.99
      set midpt 0.90
   }
   # Independent variable of control points.
   matrix i f 6 = {0., 0.44, 0.50, 0.50, 0.56, 1.}
   # Hue for control points.  Blue-violet to red
   matrix h f 6 = {260., 260., 260., 0., 0., 0.}
   # Lightness ranging from medium to vertex to medium
   matrix l f 6 = {0.5, $midpt, $vertex, $vertex, $midpt, 0.5}
   # Saturation is complete for default
   matrix s f 6 = {1., 1., 1., 1., 1., 1.}
   # Integer flag array is zero (no interpolation along far-side of colour
   # figure
   matrix rev i 6 = {0, 0, 0, 0, 0, 0}
   # Default number of cmap1 colours
   $w cmd plscmap1n 128
   # Interpolate between control points to set up default cmap1.
   $w cmd plscmap1l 0 6 i h l s rev
}

# Routine for initializing color map 1 in HLS space.
# Basic grayscale variation from half-dark (which makes more interesting
# looking plot compared to dark) to light.
proc cmap1_init {w} {
   # Independent variable of control points.
   matrix i f 2 = {0., 1.}
   # Hue for control points.  Doesn't matter since saturation is zero.
   matrix h f 2 = {0., 0.}
   # Lightness ranging from half-dark (for interest) to light.
   matrix l f 2 = {0.5, 1.}
   # Gray scale has zero saturation.
   matrix s f 2 = {0., 0.}
   # Integer flag array is zero (no interpolation along far-side of colour
   # figure
   matrix rev i 2 = {0, 0}
   # Number of cmap1 colours is 256 in this case. 
   $w cmd plscmap1n 256
   # Interpolate between control points to set up default cmap1.
   $w cmd plscmap1l 0 2 i h l s rev
}

proc x08 {{w loopback}} {

    matrix opt i 4 = {1, 2, 3, 3}
    matrix alt f 4 = {60.0, 20.0, 60.0, 60.0}
    matrix az  f 4 = {30.0, 60.0, 120.0, 160.0}

    set xpts 35
    set ypts 46
    set n_col 256
    set two_pi [expr 2.0 * 3.14159265358979323846 ]

    matrix x f $xpts
    matrix y f $ypts
    matrix z f $xpts $ypts

    for {set i 0} {$i < $xpts} {incr i} {
	x $i = [expr ($i - ($xpts/2)) / double($xpts/2) ]
    }

    for {set i 0} {$i < $ypts} {incr i} {
	y $i = [expr ($i - ($ypts/2)) / double($ypts/2) ]
    }

    for {set i 0} {$i < $xpts} {incr i} {
	set xx [x $i]
	for {set j 0} {$j < $ypts} {incr j} {
	    set yy [y $j]
	    set r [expr sqrt( $xx * $xx + $yy * $yy ) ]

	    z $i $j = [expr exp(-$r * $r) * cos( $two_pi * $r ) ]
	}
    }
    $w cmd pllightsource 1. 1. 1.
    cmap1_init $w
    for {set k 0} {$k < 4} {incr k} {
       for {set ifshade 0} {$ifshade < 2} {incr ifshade} {
  	  $w cmd pladv 0
  	  $w cmd plvpor 0.0 1.0 0.0 0.9
  	  $w cmd plwind -1.0 1.0 -0.9 1.1
  	  $w cmd plcol0 1
  	  $w cmd plw3d 1.0 1.0 1.0 -1.0 1.0 -1.0 1.0 -1.0 1.0 [alt $k] [az $k]
  	  $w cmd plbox3 "bnstu" "x axis" 0.0 0 \
	    "bnstu" "y axis" 0.0 0 \
	    "bcdmnstuv" "z axis" 0.0 0
  	  $w cmd plcol0 2
	  if {$ifshade == 1} {
	     $w cmd plotsh3d x y z 0
	  } else {
	     $w cmd plot3d x y z [opt $k] 1
	  }
  	  $w cmd plcol0 3
  	  set title [format "#frPLplot Example 8 - Alt=%.0f, Az=%.0f, Opt=%d" \
	    [alt $k] [az $k] [opt $k] ]
  	  $w cmd plmtex "t" 1.0 0.5 0.5 $title
       }
    }

# Restore defaults
    $w cmd plcol0 1
    restore_cmap1 $w
}
