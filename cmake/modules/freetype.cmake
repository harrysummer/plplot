# cmake/modules/freetype.cmake
#
# Copyright (C) 2006  Andrew Ross
#
# This file is part of PLplot.
#
# PLplot is free software; you can redistribute it and/or modify
# it under the terms of the GNU Library General Public License as published
# by the Free Software Foundation; version 2 of the License.
#
# PLplot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public License
# along with the file PLplot; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
#
# Configuration for the freetype support in plplot.

option(
WITH_FREETYPE 
"Enable driver options for using freetype library for fonts"
ON
)

# Look for freetype libraries
if (WITH_FREETYPE)
  find_package(Freetype)
  if (NOT FREETYPE_FOUND)
    set(WITH_FREETYPE OFF CACHE BOOL "Enable driver options for using freetype library for fonts" FORCE)
  endif (NOT FREETYPE_FOUND)
endif (WITH_FREETYPE)

if (WITH_FREETYPE)

if (NOT PL_FREETYPE_FONT_DIR)
  if(WINDOWS)
    set(PL_FREETYPE_FONT_DIR "c:/windows/fonts")
  else(WINDOWS)
    set(PL_FREETYPE_FONT_DIR "/usr/share/fonts/truetype/freefont")
  endif(WINDOWS)
endif (NOT PL_FREETYPE_FONT_DIR)
# We need a trailing slash. 
set(PL_FREETYPE_FONT_DIR "${PL_FREETYPE_FONT_DIR}/")

set(PL_FREETYPE_FONT_LIST
"PL_FREETYPE_MONO:FreeMono.ttf:cour.ttf"
"PL_FREETYPE_MONO_BOLD:FreeMonoBold.ttf:courbd.ttf"
"PL_FREETYPE_MONO_BOLD_ITALIC:FreeMonoBoldOblique.ttf:courbi.ttf"
"PL_FREETYPE_MONO_BOLD_OBLIQUE:FreeMonoBoldOblique.ttf:courbi.ttf"
"PL_FREETYPE_MONO_ITALIC:FreeMonoOblique.ttf:couri.ttf"
"PL_FREETYPE_MONO_OBLIQUE:FreeMonoOblique.ttf:couri.ttf"
"PL_FREETYPE_SANS:FreeSans.ttf:arial.ttf"
"PL_FREETYPE_SANS_BOLD:FreeSansBold.ttf:arialbd.ttf"
"PL_FREETYPE_SANS_BOLD_ITALIC:FreeSansBoldOblique.ttf:arialbi.ttf"
"PL_FREETYPE_SANS_BOLD_OBLIQUE:FreeSansBoldOblique.ttf:arialbi.ttf"
"PL_FREETYPE_SANS_ITALIC:FreeSansOblique.ttf:ariali.ttf"
"PL_FREETYPE_SANS_OBLIQUE:FreeSansOblique.ttf:ariali.ttf"
"PL_FREETYPE_SCRIPT:FreeSerif.ttf:arial.ttf"
"PL_FREETYPE_SCRIPT_BOLD:FreeSerifBold.ttf:arialbd.ttf"
"PL_FREETYPE_SCRIPT_BOLD_ITALIC:FreeSerifBoldItalic.ttf:arialbi.ttf"
"PL_FREETYPE_SCRIPT_BOLD_OBLIQUE:FreeSerifBoldItalic.ttf:arialbi.ttf"
"PL_FREETYPE_SCRIPT_ITALIC:FreeSerifItalic.ttf:ariali.ttf"
"PL_FREETYPE_SCRIPT_OBLIQUE:FreeSerifItalic.ttf:ariali.ttf"
"PL_FREETYPE_SERIF:FreeSerif.ttf:times.ttf"
"PL_FREETYPE_SERIF_BOLD:FreeSerifBold.ttf:timesbd.ttf"
"PL_FREETYPE_SERIF_BOLD_ITALIC:FreeSerifBoldItalic.ttf:timesbi.ttf"
"PL_FREETYPE_SERIF_BOLD_OBLIQUE:FreeSerifBoldItalic.ttf:timesbi.ttf"
"PL_FREETYPE_SERIF_ITALIC:FreeSerifItalic.ttf:timesi.ttf"
"PL_FREETYPE_SERIF_OBLIQUE:FreeSerifItalic.ttf:timesi.ttf"
"PL_FREETYPE_SYMBOL:FreeSerif.ttf:times.ttf"
"PL_FREETYPE_SYMBOL_BOLD:FreeSerifBold.ttf:timesbd.ttf"
"PL_FREETYPE_SYMBOL_BOLD_ITALIC:FreeSerifBoldItalic.ttf:timesbi.ttf"
"PL_FREETYPE_SYMBOL_BOLD_OBLIQUE:FreeSerifBoldItalic.ttf:timesbi.ttf"
"PL_FREETYPE_SYMBOL_ITALIC:FreeSerifItalic.ttf:timesi.ttf"
"PL_FREETYPE_SYMBOL_OBLIQUE:FreeSerifItalic.ttf:timesi.ttf"
)

foreach(FONT_ENTRY ${PL_FREETYPE_FONT_LIST}) 
  string(REGEX REPLACE "^(.*):.*:.*$" "\\1" NAME ${FONT_ENTRY})
  if (windows)
    string(REGEX REPLACE "^.*:.*:(.*)$" "\\1" FONT ${FONT_ENTRY})
  else (windows)
    string(REGEX REPLACE "^.*:(.*):.*$" "\\1" FONT ${FONT_ENTRY})
  endif (windows)
  if (NOT ${NAME})
    set(${NAME} ${FONT})
  endif (NOT ${NAME})
endforeach(FONT_ENTRY PL_FREETYPE_FONT_LIST) 

# Check a couple of fonts actually exists
if (EXISTS ${PL_FREETYPE_FONT_DIR}${PL_FREETYPE_SANS})
  if (EXISTS ${PL_FREETYPE_FONT_DIR}${PL_FREETYPE_SYMBOL})  
  else (EXISTS ${PL_FREETYPE_FONT_DIR}${PL_FREETYPE_SYMBOL})
    message("Fonts not found - disabling freetype")
    set(WITH_FREETYPE OFF CACHE BOOL 
    "Enable driver options for using freetype library for fonts" FORCE
    )  
  endif (EXISTS ${PL_FREETYPE_FONT_DIR}${PL_FREETYPE_SYMBOL})  
else (EXISTS ${PL_FREETYPE_FONT_DIR}${PL_FREETYPE_SANS})
  message("Fonts not found - disabling freetype")
  set(WITH_FREETYPE OFF CACHE BOOL 
  "Enable driver options for using freetype library for fonts" FORCE
  )
endif (EXISTS ${PL_FREETYPE_FONT_DIR}${PL_FREETYPE_SANS})

endif (WITH_FREETYPE)

if (WITH_FREETYPE)
  set(HAVE_FREETYPE ON)
endif (WITH_FREETYPE)
