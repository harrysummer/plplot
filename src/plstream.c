/* $Id$
   $Log$
   Revision 1.7  1993/07/31 08:19:25  mjl
   Utility function added for allocating a PLDev structure.

 * Revision 1.6  1993/07/16  22:37:04  mjl
 * Eliminated obsolete functions, moved function for setting filename here.
 *
 * Revision 1.5  1993/07/01  22:13:43  mjl
 * Changed all plplot source files to include plplotP.h (private) rather than
 * plplot.h.  Rationalized namespace -- all externally-visible internal
 * plplot functions now start with "plP_".
 *
 * Revision 1.4  1993/04/26  19:57:59  mjl
 * Fixes to allow (once again) output to stdout and plrender to function as
 * a filter.  A type flag was added to handle file vs stream differences.
*/

/*	plstream.c

	Stream & device support functions.
*/

#include "plplotP.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plstream.h"

/*----------------------------------------------------------------------*\
* color_def()
*
* Initializes color table entries by RGB values.
* Does nothing if: color already set, or palette entry exceeds number
* of colors in the palette.
\*----------------------------------------------------------------------*/

static void
color_def(PLStream *pls, PLINT i, U_CHAR r, U_CHAR g, U_CHAR b)
{
    if (!pls->cmap0setcol[i] && (i < pls->ncol0)) {
	pls->cmap0[i].r = r;
	pls->cmap0[i].g = g;
	pls->cmap0[i].b = b;
	pls->cmap0setcol[i] = 1;
    }
}

/*----------------------------------------------------------------------*\
* plCmaps_init()
*
* Initializes color maps.
* Do not initialize if already done.
*
* Initial RGB values for color map 0 taken from HPUX 8.07 X-windows 
* rgb.txt file, and may not accurately represent the described colors on 
* all systems.
*
* Note the background color is not set, since the device driver may be
* able to detect if a monochrome output device is being used, in which
* case I want to choose the default background color there.
\*----------------------------------------------------------------------*/

void
plCmaps_init(PLStream *pls)
{
    int itype, ihfinit = 0;
    PLFLT param[6];

/* If the user hasn't specified, the number of colors default to 16 */

    if (pls->ncol0 == 0)
	pls->ncol0 = 16;

/* Color map 0 */

    color_def(pls, 0, 255, 114, 86);	/* coral */
    color_def(pls, 1, 255, 0, 0);	/* red */
    color_def(pls, 2, 255, 255, 0);	/* yellow */
    color_def(pls, 3, 0, 255, 0);	/* green */
    color_def(pls, 4, 50, 191, 193);	/* aquamarine */
    color_def(pls, 5, 255, 181, 197);	/* pink */
    color_def(pls, 6, 245, 222, 179);	/* wheat */
    color_def(pls, 7, 126, 126, 126);	/* grey */
    color_def(pls, 8, 165, 42, 42);	/* brown */
    color_def(pls, 9, 0, 0, 255);	/* blue */
    color_def(pls, 10, 138, 43, 226);	/* Blue Violet */
    color_def(pls, 11, 0, 255, 255);	/* cyan */
    color_def(pls, 12, 25, 204, 223);	/* turquoise */
    color_def(pls, 13, 255, 0, 255);	/* magenta */
    color_def(pls, 14, 233, 150, 122);	/* salmon */
    color_def(pls, 15, 255, 255, 255);	/* white */

/* Color map 1 */

    if (!pls->cmap1set) {

	switch (ihfinit) {

	case 0:
	default:

/*
* The default map plots height levels at full color intensity, going from
* blue-violet (low), to green (medium), to red (high).
*/
	    itype = 0;		/* HLS model */
	    param[0] = 280.;	/* h -- low: blue-violet */
	    param[1] = -20.;	/* h -- high: red */
	    param[2] = 1.;	/* l -- low */
	    param[3] = 1.;	/* l -- high */
	    param[4] = 1.;	/* s -- low */
	    param[5] = 1.;	/* s -- high */
	    break;
	}

	plscm1f1(itype, param);
    }
}

/*----------------------------------------------------------------------*\
* plOpenFile()
*
* Opens file for output, prompting if not set.
* Prints extra newline at end to make output look better in batch runs.
* A file name of "-" indicates output to stdout.
\*----------------------------------------------------------------------*/

void
plOpenFile(PLStream *pls)
{
    int i = 0;
    char line[256];

    while (!pls->OutFile) {
	if (!pls->fileset) {
	    printf("Enter desired name for graphics output file: ");
	    fgets(line, sizeof(line), stdin);
	    line[strlen(line) - 1] = '\0';

	    plP_sfnam(pls, line);
	}
	if (!strcmp(pls->FileName, "-")) {
	    pls->OutFile = stdout;
	    pls->output_type = 1;
	    break;
	}
	if (pls->family) {
	    (void) sprintf(pls->FileName, "%s.%i",
			   pls->FamilyName, pls->member);
	}

	if (i++ > 10)
	    plexit("Too many tries.");

	if ((pls->OutFile = fopen(pls->FileName, BINARY_WRITE)) == NULL) {
	    printf("Can't open %s.\n", pls->FileName);
	    pls->fileset = 0;
	}
	else
	    printf("Created %s\n", pls->FileName);
    }
}

/*----------------------------------------------------------------------*\
* plP_sfnam()
*
* Sets up file name & family stem name.
* Reserve some extra space (5 chars) to hold an optional member number.
\*----------------------------------------------------------------------*/

void
plP_sfnam(PLStream *pls, char *fnam)
{
    pls->OutFile = NULL;
    pls->fileset = 1;

    if (pls->FileName != NULL)
	free((void *) pls->FileName);

    pls->FileName = (char *)
	malloc(6 + (strlen(fnam)) * sizeof(char));

    strcpy(pls->FileName, fnam);

    if (pls->FamilyName != NULL)
	free((void *) pls->FamilyName);

    pls->FamilyName = (char *)
	malloc(6 + (strlen(fnam)) * sizeof(char));

    strcpy(pls->FamilyName, fnam);
}

/*----------------------------------------------------------------------*\
* plFamInit()
*
* Initializes family file parameters.
\*----------------------------------------------------------------------*/

void
plFamInit(PLStream *pls)
{
    if (pls->family) {
	pls->bytecnt = 0;
	if (!pls->member)
	    pls->member = 1;
	if (!pls->bytemax)
	    pls->bytemax = PL_FILESIZE_KB * 1000;
    }
}

/*----------------------------------------------------------------------*\
* plGetFam()
*
* Starts new member file of family file set if necessary.
*
* Note each member file is a complete graphics file (can be printed
* individually), although 'plrender' will treat a family as a single
* logical file if given the family name instead of the member name.
\*----------------------------------------------------------------------*/

void
plGetFam(PLStream *pls)
{
    if (pls->family) {
	if (pls->bytecnt > pls->bytemax || pls->famadv) {
	    plP_tidy();
	    pls->fileset = 1;
	    pls->member++;
	    pls->famadv = 0;
	    plP_init();
	    return;
	}
    }
}

/*----------------------------------------------------------------------*\
* plGetInt()
*
* Prompts human to input an integer in response to given message.
\*----------------------------------------------------------------------*/

PLINT
plGetInt(char *s)
{
    PLINT m;
    int i = 0;
    char line[256];

    while (i++ < 10) {
	printf(s);
	fgets(line, sizeof(line), stdin);
#ifdef MSDOS
	m = atoi(line);
	return (m);
#else
	if (sscanf(line, "%d", &m) == 1)
	    return (m);
	printf("No value or value out of range; please try again\n");
#endif
    }
    plexit("Too many tries.");
    return (0);
}

/*----------------------------------------------------------------------*\
* plGetFlt()
*
* Prompts human to input a float in response to given message.
\*----------------------------------------------------------------------*/

PLFLT
plGetFlt(char *s)
{
    PLFLT m;
    int i = 0;
    char line[256];

    while (i++ < 10) {
	printf(s);
	fgets(line, sizeof(line), stdin);
#ifdef MSDOS
	m = atof(line);
	return (m);
#else
	if (sscanf(line, "%f", &m) == 1)
	    return (m);
	printf("No value or value out of range; please try again\n");
#endif
    }
    plexit("Too many tries.");
    return (0.);
}

/*----------------------------------------------------------------------*\
* plRotPhy()
*
* Rotates physical coordinates if necessary for given orientation.
* Each time orient is incremented, the plot is rotated 90 deg clockwise.
* Note: this is now used only to rotate by 90 degrees for devices that
* expect portrait mode.
\*----------------------------------------------------------------------*/

void
plRotPhy(PLINT orient, PLDev *dev, int *px1, int *py1, int *px2, int *py2)
{
    int x1, y1, x2, y2;

    x1 = *px1;
    y1 = *py1;
    x2 = *px2;
    y2 = *py2;

    switch (orient%4) {

    case 1:
	*px1 = dev->xmin + (y1 - dev->ymin);
	*py1 = dev->ymin + (dev->xmax - x1);
	*px2 = dev->xmin + (y2 - dev->ymin);
	*py2 = dev->ymin + (dev->xmax - x2);
	break;

    case 2:
	*px1 = dev->xmin + (dev->xmax - x1);
	*py1 = dev->ymin + (dev->ymax - y1);
	*px2 = dev->xmin + (dev->xmax - x2);
	*py2 = dev->ymin + (dev->ymax - y2);
	break;

    case 3:
	*px1 = dev->xmin + (dev->ymax - y1);
	*py1 = dev->ymin + (x1 - dev->xmin);
	*px2 = dev->xmin + (dev->ymax - y2);
	*py2 = dev->ymin + (x2 - dev->xmin);
	break;

    default:
	break;			/* do nothing */
    }
}

/*----------------------------------------------------------------------*\
* plAllocDev()
*
* Allocates a standard PLDev structure for device-specific data, stores
* the address in pls->dev, and returns the address as well.
\*----------------------------------------------------------------------*/

PLDev *
plAllocDev(PLStream *pls)
{
    if (pls->dev != NULL)
	free((void *) pls->dev);

    pls->dev = calloc(1, (size_t) sizeof(PLDev));
    if (pls->dev == NULL)
	plexit("plAllocDev: cannot allocate memory\n");

    return (PLDev *) pls->dev;
}
