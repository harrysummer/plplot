/* $Id$
   $Log$
   Revision 1.6  1993/10/18 19:45:50  mjl
   Added user-contributed plarrows function.

 * Revision 1.5  1993/07/01  22:13:45  mjl
 * Changed all plplot source files to include plplotP.h (private) rather than
 * plplot.h.  Rationalized namespace -- all externally-visible internal
 * plplot functions now start with "plP_".
*/

/*	plsym.c

	Point and symbol plotting routines.
*/

#include "plplotP.h"
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>

extern short int *fntlkup;
extern short int numberfonts, numberchars;

/*----------------------------------------------------------------------*\
* void plsym()
*
* Plots single precision array y against x for n points using
* Hershey symbol "code".
\*----------------------------------------------------------------------*/

void
c_plsym(PLINT n, PLFLT *x, PLFLT *y, PLINT code)
{
    PLINT i;
    PLINT level;

    plP_glev(&level);
    if (level < 3)
	plexit("plsym: Please set up window first.");

    if (code < 0)
	plexit("plsym: Invalid code.");

    for (i = 0; i < n; i++)
	plhrsh(code, plP_wcpcx(x[i]), plP_wcpcy(y[i]));
}

/*----------------------------------------------------------------------*\
* void plpoin()
*
* Plots single precision array y against x for n points using
* ASCII code "code".
\*----------------------------------------------------------------------*/

void
c_plpoin(PLINT n, PLFLT *x, PLFLT *y, PLINT code)
{
    PLINT i;
    PLINT level, sym, font, col;

    plP_glev(&level);
    if (level < 3)
	plexit("plpoin: Please set up window first.");

    if (code < 0 || code > 127)
	plexit("plpoin: Invalid code.");

    plP_gatt(&font, &col);
    sym = *(fntlkup + (font - 1) * numberchars + code);

    for (i = 0; i < n; i++)
	plhrsh(sym, plP_wcpcx(x[i]), plP_wcpcy(y[i]));
}

/*----------------------------------------------------------------------*\
* void plhrsh()
*
* Writes the Hershey symbol "ch" centred at the physical
* coordinate (x,y).
\*----------------------------------------------------------------------*/

void
plhrsh(PLINT ch, PLINT x, PLINT y)
{
    PLINT cx, cy, k, penup;
    SCHAR *xygrid;
    PLFLT symdef, symht, scale, xscale, yscale, xpmm, ypmm;

    plP_gsym(&symdef, &symht);
    plP_gpixmm(&xpmm, &ypmm);
    penup = 1;
    scale = 0.05 * symht;

    if (!plcvec(ch, &xygrid)) {
	plP_movphy(x, y);
	return;
    }

    /* Compute how many physical pixels correspond to a character pixel */

    xscale = scale * xpmm;
    yscale = scale * ypmm;

    k = 4;
    for (;;) {
	cx = xygrid[k++];
	cy = xygrid[k++];
	if (cx == 64 && cy == 64) {
	    plP_movphy(x, y);
	    return;
	}
	else if (cx == 64 && cy == 0)
	    penup = 1;
	else {
	    if (penup != 0) {
		plP_movphy(ROUND(x + xscale * cx), ROUND(y + yscale * cy));
		penup = 0;
	    }
	    else
		plP_draphy(ROUND(x + xscale * cx), ROUND(y + yscale * cy));
	}
    }
}

/*----------------------------------------------------------------------*\
 * void plarrows()
 *
 * simple arrow plotter
 * copyright 1993 Wesley Ebisuzaki
 *
 * an arrow is defined by its location (x, y) and its direction (u, v)
 *
 * inputs:
 *   u[i], v[i]      arrow's horizontal and vertical projection
 *   x[i], y[i]      arrow's location (world coordinates)
 *   n               number of arrows to draw
 *   scale           > 0  scaling factor for arrows
 *                   0    default scaling factor
 *                   < 0  default scaling factor * (-scale)
 *   dx, dy          distance between arrows
 *                   used when calculating the default arrow scaling
 *                   so that arrows don't overlap
 *
\*----------------------------------------------------------------------*/

#define SCALE0 2.0

/* definition of original arrow: 2 line segments */

static PLFLT arrow_x[4] = {0.5, -0.5, -0.27, -0.5};
static PLFLT arrow_y[4] = {0.0, 0.0, 0.0, 0.20};

void plarrows(PLFLT *u, PLFLT *v, PLFLT *x, PLFLT *y, PLINT n,
	PLFLT scale, PLFLT dx, PLFLT dy) {

	PLFLT uu, vv;
	PLINT i, j;
	PLINT px0, py0, dpx, dpy;
	PLINT a_x[4], a_y[4];
	PLFLT max_u, max_v;
	double t;

	if (n <= 0) return;

	if (scale <= 0.0) {
		/* automatic scaling */
		/* find max / min values of data */
		max_u = u[0];
		max_v = v[0];
		for (i = 1; i < n; i++) {
			t = fabs((double) u[i]);
			max_u = t > max_u ? t : max_u;
			t = fabs((double) v[i]);
			max_v = t > max_v ? t : max_v;
		}

		/* measure distance in grid boxs */
		max_u = max_u / fabs( (double) dx);
		max_v = max_v / fabs( (double) dy);

		t = (max_u > max_v ? max_u : max_v);
		t = SCALE0 / t;
		if (scale < 0) {
			scale = -scale * t;
		}
		else {
			scale = t;
		}
	}
#ifdef DEBUG
	printf("scale factor=%lf n=%d\n", scale,n);
#endif

	for (i = 0; i < n; i++) {
		uu = scale * u[i];
		vv = scale * v[i];
		if (uu == 0.0 && uu == 0.0) continue;

		/* conversion to physical coordinates */
		px0 = wcpcx(x[i]);
		py0 = wcpcy(y[i]);

#ifdef DEBUG
	printf("%f %f %d %d\n",x[i],y[i],px0,py0);
#endif
		dpx = wcpcx(x[i] + 0.5*uu) - px0;
		dpy = wcpcy(y[i] + 0.5*vv) - py0;

		/* tranform arrow -> a */
		for (j = 0; j < 4; j++) {
			a_x[j] = arrow_x[j] * dpx -
				arrow_y[j] * dpy + px0;
			a_y[j] = arrow_x[j] * dpy +
				arrow_y[j] * dpx + py0;
		}
		/* draw the arrow */
		movphy(a_x[0], a_y[0]);
		draphy(a_x[1], a_y[1]);
		movphy(a_x[2], a_y[2]);
		draphy(a_x[3], a_y[3]);
	}
}
