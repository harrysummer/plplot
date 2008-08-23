-- $Id$

-- Thin Ada binding to PLplot

-- Copyright (C) 2006-2007 Jerry Bauck

-- This file is part of PLplot.

-- PLplot is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Library Public License as published
-- by the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- PLplot is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Library General Public License for more details.

-- You should have received a copy of the GNU Library General Public License
-- along with PLplot; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

--------------------------------------------------------------------------------

-- SOME NOTES ABOUT THE ADA BINDINGS (JB)
-- Some C-arguments of the form PLINT *a are supposed to point at 8-bit unsigned chars
-- and are said to carry information out of the function, according to the PLplot docs.
-- I hope that this is wrong and that they are really PLINTs like the API says.
-- I converted these as a : out PLINT. These are the only *-ed quantities that I set to "outs".

-- I made the final arg in plscmap1l, rev, an array of PLBOOLs, not an in out 
-- parameter; impossible to tell from C syntax which is intended, but I think 
-- this is right.

with
    PLplot_Auxiliary,
    Interfaces.C,
    Interfaces.C.Pointers,
    System,
    Ada.Text_IO,
    Ada.Strings.Bounded,
    Ada.Strings.Unbounded;
use
    PLplot_Auxiliary,
    Interfaces.C,
    Ada.Text_IO,
    Ada.Strings.Bounded,
    Ada.Strings.Unbounded;

-- COMMENT THIS LINE IF YOUR COMPILER DOES NOT INCLUDE THESE 
-- DEFINITIONS, FOR EXAMPLE, IF IT IS NOT ADA 2005 WITH ANNEX G.3 COMPLIANCE.
--with Ada.Numerics.Long_Real_Arrays; use Ada.Numerics.Long_Real_Arrays;
@Ada_Is_2007_With_and_Use_Numerics@
    
package PLplot_Thin is
    subtype PLINT  is Integer;
    subtype PLFLT  is Long_Float;
    PLfalse : constant Integer := 0;
    PLtrue  : constant Integer := 1;
    subtype PLBOOL is Integer range PLfalse..PLtrue;
    type PLUNICODE is mod 2**32;
--    subtype Unsigned_Int is mod 2**32; -- for e.g. plseed
--    subtype Unsigned_Int is Integer range 0 .. 2**31 - 1; -- for e.g. plseed fix this

    subtype PL_Integer_Array  is Integer_Array_1D;
    subtype PL_Float_Array    is Real_Vector;
    subtype PL_Float_Array_2D is Real_Matrix;
    type PL_Bool_Array        is array (Integer range <>) of PLBOOL;
    subtype PLPointer         is System.Address; -- non-specific pointer to something
            
    -- Types to pass 2D arrays (matrix) defined in Ada.Numerics.Generic_Real_Arrays
    -- (and its instances) to C functions. Have only Long_Float capability for now.
    type Long_Float_Pointer is access all Long_Float;
    type Long_Float_Pointer_Array is array (Integer range <>) of aliased Long_Float_Pointer;


--------------------------------------------------------------------------------
-- Utility for passing matrices to C                                          --
--------------------------------------------------------------------------------

    function Matrix_To_Pointers(x : Real_Matrix) return Long_Float_Pointer_Array;


--------------------------------------------------------------------------------
-- PLplot-specific things                                                     --
--------------------------------------------------------------------------------

    -- Make a string and array therefore for legends that is compatible with the 
    -- C code of plstripc which creates a strip chart. The C code will accept 
    -- any length of string and each of the four strings can be different lengths.
    -- These types are a bit of a hack whereby each of the legend strings is the 
    -- same length, so that they can be accessed as an array. They are 41 
    -- characters long here including a null terminator; I suppose any length 
    -- will work since the stripchart program doesn't seem to mind. The user 
    -- will probably never see this type since he is allowed to set up the 
    -- legend strings as an array of unbounded strings. Only in preparing to 
    -- call the underlying C are the fixed-length strings used. If the user 
    -- specifies unbounded legend strings that are longer than allowed here, 
    -- they are truncated or padded with spaces, as appropriate, to meet the 
    -- required length. Although that length is now 41, it is OK to make it 
    -- longer or shorter simply by changing the following line, since everything
    -- else (padding, truncation, conversion to C-style) works automatically. 
    -- See the fix this note in plplot.adb and plplot_traditional.adb about how 
    -- all this somehow doesn't work correctly, causing all four stripchart 
    -- legends to be the same and equal to the fourth one.
    subtype PL_Stripchart_String is String(1 .. 41);
    type PL_Stripchart_String_Array is array (1 .. 4) of access PL_Stripchart_String;
    Temp_C_Stripchart_String : aliased PL_Stripchart_String;


    -- Access-to-procedure type for Draw_Vector_Plot and its kin.
    type Transformation_Procedure_Pointer_Type is access 
        procedure (x, y : PLFLT; tx, ty : out PLFLT; pltr_data : PLpointer);
    pragma Convention (Convention => C, Entity => Transformation_Procedure_Pointer_Type);
    
    
    -- Access-to-procedure to e.g. to plfill, used by plshade, plshade1, plshades.
    -- Needs C calling convention because it is passed eventually to plfill aka 
    -- c_plfill in plplot.h. plfill is said in the documentation to be possibly 
    -- supplemented in the future. 
    type Fill_Procedure_Pointer_Type is access
        procedure(length : Integer; x, y : Real_Vector);
    pragma Convention (Convention => C, Entity => Fill_Procedure_Pointer_Type);
        

    -- Access-to-function type for Shade_Regions (aka plshades).
    -- Returns 1 if point is to be plotted, 0 if not.
    type Mask_Function_Pointer_Type is access
        function (x, y : PLFLT) return Integer;
        

    -- Access-to-procedure type for plotting map outlines (continents).
    -- Length_Of_x is x'Length or y'Length; this is the easiest way to match the 
    -- C formal arguments.
    type Map_Form_Function_Pointer_Type is access
        procedure (Length_Of_x : Integer; x, y : in out Real_Vector);
    pragma Convention(Convention => C, Entity => Map_Form_Function_Pointer_Type);
    
    
    -- Access-to-function type for making contour plots from irregularly 
    -- spaced data which is stored in a 2D array accessed by a single pointer.
    -- Examples of such functions are in plplot.h and are called plf2eval, 
    -- plf2eval2, plf2evalr.
    type Function_Evaluator_Pointer_Type is access
        function (ix, iy : PLINT; Irregular_Data : PLpointer) return PLFLT;


--------------------------------------------------------------------------------
-- Argument parsing things                                                    --
--------------------------------------------------------------------------------

    Gnat_argc : aliased Integer;
    pragma Import (C, Gnat_argc);

    Gnat_argv : System.Address; -- Just get the base address to argv, like C
    pragma Import (C, Gnat_argv);


--------------------------------------------------------------------------------
-- More PLplot-specific things                                                --
--------------------------------------------------------------------------------

    -- Switches for escape function call. 
    -- Some of these are obsolete but are retained in order to process
    -- old metafiles 

    PLESC_SET_RGB         : constant Integer := 1;	-- obsolete 
    PLESC_ALLOC_NCOL      : constant Integer := 2;	-- obsolete 
    PLESC_SET_LPB         : constant Integer := 3;	-- obsolete 
    PLESC_EXPOSE          : constant Integer := 4;	-- handle window expose 
    PLESC_RESIZE          : constant Integer := 5;	-- handle window resize 
    PLESC_REDRAW          : constant Integer := 6;	-- handle window redraw 
    PLESC_TEXT            : constant Integer := 7;	-- switch to text screen 
    PLESC_GRAPH           : constant Integer := 8;	-- switch to graphics screen 
    PLESC_FILL            : constant Integer := 9;	-- fill polygon 
    PLESC_DI              : constant Integer := 10;	-- handle DI command 
    PLESC_FLUSH           : constant Integer := 11;	-- flush output 
    PLESC_EH              : constant Integer := 12; -- handle Window events 
    PLESC_GETC            : constant Integer := 13;	-- get cursor position 
    PLESC_SWIN            : constant Integer := 14;	-- set window parameters 
    PLESC_DOUBLEBUFFERING : constant Integer := 15;	-- configure double buffering 
    PLESC_XORMOD          : constant Integer := 16;	-- set xor mode 
    PLESC_SET_COMPRESSION : constant Integer := 17;	-- AFR: set compression 
    PLESC_CLEAR           : constant Integer := 18; -- RL: clear graphics region 
    PLESC_DASH            : constant Integer := 19;	-- RL: draw dashed line 
    PLESC_HAS_TEXT        : constant Integer := 20;	-- driver draws text 
    PLESC_IMAGE           : constant Integer := 21;	-- handle image 
    PLESC_IMAGEOPS        : constant Integer := 22; -- plimage related operations 
    PLESC_PL2DEVCOL       : constant Integer := 23;	-- convert PLColor to device color 
    PLESC_DEV2PLCOL       : constant Integer := 24;	-- convert device color to PLColor 
    PLESC_SETBGFG         : constant Integer := 25;	-- set BG, FG colors 
    PLESC_DEVINIT         : constant Integer := 26;	-- alternate device initialization 

    -- image operations 
    ZEROW2B : constant Integer := 1;
    ZEROW2D : constant Integer := 2;
    ONEW2B  : constant Integer := 3;
    ONEW2D  : constant Integer := 4;

    -- Window parameter tags 

    PLSWIN_DEVICE : constant Integer := 1; -- device coordinates 
    PLSWIN_WORLD  : constant Integer := 2; -- world coordinates 

    -- PLplot Option table & support constants 

    -- Option-specific settings 

    PL_OPT_ENABLED   : constant Integer := 16#0001#; -- Obsolete 
    PL_OPT_ARG       : constant Integer := 16#0002#; -- Option has an argment 
    PL_OPT_NODELETE  : constant Integer := 16#0004#; -- Don't delete after processing 
    PL_OPT_INVISIBLE : constant Integer := 16#0008#; -- Make invisible 
    PL_OPT_DISABLED  : constant Integer := 16#0010#; -- Processing is disabled 

    -- Option-processing settings -- mutually exclusive 

    PL_OPT_FUNC   : constant Integer := 16#0100#; -- Call handler function 
    PL_OPT_BOOL   : constant Integer := 16#0200#; -- Set *var = 1 
    PL_OPT_INT    : constant Integer := 16#0400#; -- Set *var = atoi(optarg) 
    PL_OPT_FLOAT  : constant Integer := 16#0800#; -- Set *var = atof(optarg) 
    PL_OPT_STRING : constant Integer := 16#1000#; -- Set var = optarg 

    -- Global mode settings 
    -- These override per-option settings 
    
    type Parse_Mode_Type is range 16#0000# .. 16#0001# + 16#0002# + 16#0004# + 
        16#0008# + 16#0010# + 16#0020# + 16#0040# + 16#0080#;
    
    PL_PARSE_PARTIAL   : constant Parse_Mode_Type := 16#0000#; -- For backward compatibility 
    PL_PARSE_FULL      : constant Parse_Mode_Type := 16#0001#; -- Process fully & exit if error 
    PL_PARSE_QUIET     : constant Parse_Mode_Type := 16#0002#; -- Don't issue messages 
    PL_PARSE_NODELETE  : constant Parse_Mode_Type := 16#0004#; -- Don't delete options after processing 
    PL_PARSE_SHOWALL   : constant Parse_Mode_Type := 16#0008#; -- Show invisible options 
    PL_PARSE_OVERRIDE  : constant Parse_Mode_Type := 16#0010#; -- Obsolete 
    PL_PARSE_NOPROGRAM : constant Parse_Mode_Type := 16#0020#; -- Program name NOT in *argv[0].. 
    PL_PARSE_NODASH    : constant Parse_Mode_Type := 16#0040#; -- Set if leading dash NOT required 
    PL_PARSE_SKIP      : constant Parse_Mode_Type := 16#0080#; -- Skip over unrecognized args 

    -- FCI (font characterization integer) related constants. 
    PL_FCI_MARK                : constant Integer := 16#10000000#;
    PL_FCI_IMPOSSIBLE          : constant Integer := 16#00000000#;
    PL_FCI_HEXDIGIT_MASK       : constant Integer := 16#f#;
    PL_FCI_HEXPOWER_MASK       : constant Integer := 16#7#;
    PL_FCI_HEXPOWER_IMPOSSIBLE : constant Integer := 16#f#;
    -- These define hexpower values corresponding to each font attribute. 
    PL_FCI_FAMILY : constant Integer := 16#0#;
    PL_FCI_STYLE  : constant Integer := 16#1#;
    PL_FCI_WEIGHT : constant Integer := 16#2#;
    -- These are legal values for font family attribute 
    PL_FCI_SANS   : constant Integer := 16#0#;
    PL_FCI_SERIF  : constant Integer := 16#1#;
    PL_FCI_MONO   : constant Integer := 16#2#;
    PL_FCI_SCRIPT : constant Integer := 16#3#;
    PL_FCI_SYMBOL : constant Integer := 16#4#;
    -- These are legal values for font style attribute 
    PL_FCI_UPRIGHT : constant Integer := 16#0#;
    PL_FCI_ITALIC  : constant Integer := 16#1#;
    PL_FCI_OBLIQUE : constant Integer := 16#2#;
    -- These are legal values for font weight attribute 
    PL_FCI_MEDIUM : constant Integer := 16#0#;
    PL_FCI_BOLD   : constant Integer := 16#1#;

    -- fix this
    --type PLOptionTable is
    --    record
    --        opt : char_array;
    --        int  (*handler)	(char *, char *, void *);
    --        void *client_data;
    --        void *var;
    --        mode : long;
    --        syntax : char_array;
    --        desc : char_array;
    --    end record;

    -- PLplot Graphics Input structure 


    PL_MAXKEY : constant Integer := 16;
    
    type PLGraphicsIn is
        record
            Event_Type : Integer; -- of event (CURRENTLY UNUSED)
            state      : unsigned; -- key or button mask 
            keysym     : unsigned; -- key selected 
            button     : unsigned; -- mouse button selected 
            subwindow  : PLINT;    -- subwindow (alias subpage, alias subplot) number 
            T_String   : String(1 .. PL_MAXKEY);
            pX, pY     : integer;  -- absolute device coordinates of pointer 
            dX, dY     : PLFLT;    -- relative device coordinates of pointer 
            wX, wY     : PLFLT;    -- world coordinates of pointer 
        end record;


    -- Structure for describing the plot window 

    PL_MAXWINDOWS : constant Integer := 64;	-- Max number of windows/page tracked 

    type PLWindow is
        record
            dxmi, dxma, dymi, dyma : PLFLT;	-- min, max window rel dev coords 
            wxmi, wxma, wymi, wyma : PLFLT;	-- min, max window world coords 
        end record;

    -- Structure for doing display-oriented operations via escape commands 
    -- May add other attributes in time 

    type PLDisplay is
        record
            x, y          : unsigned; -- upper left hand corner 
            width, height : unsigned; -- window dimensions 
        end record;

    -- Macro used (in some cases) to ignore value of argument 
    -- I don't plan on changing the value so you can hard-code it 

    PL_NOTSET : constant := -42;
    PL_NOTSET_Float : constant := -42.0; -- Added for Ada binding.

    -- See plcont.c for examples of the following 


    -- PLfGrid is for passing (as a pointer to the first element) an arbitrarily
    -- dimensioned array.  The grid dimensions MUST be stored, with a maximum of 3
    -- dimensions assumed for now.
     

    -- fix this  I don't think Ada needs this. If otherwise, set an object of 
    -- type PLpointer to the 'Address attribute of the array.
    -- type PLfGrid is
    --    record
    --        f          : PL_Float_Array;
    --        nx, ny, nz : PLINT;
    --    end record;

    --
    -- PLfGrid2 is for passing (as an array of pointers) a 2d function array.  The
    -- grid dimensions are passed for possible bounds checking.
     

    -- fix this  I don't think Ada needs this since we use the procedure
    -- Matrix_To_Pointers.
    -- type PLfGrid2 is
    --    record
    --        f      : PL_Float_Array;
    --        nx, ny : PLINt;
    --    end record;

    --
    -- NOTE: a PLfGrid3 is a good idea here but there is no way to exploit it yet
    -- so I'll leave it out for now.
     

    -- PLcGrid is for passing (as a pointer to the first element) arbitrarily
    -- dimensioned coordinate transformation arrays.  The grid dimensions MUST be
    -- stored, with a maximum of 3 dimensions assumed for now.

    -- This variant record emulates PLcGrid. Use it in plvect, plcont, plfcont, 
    -- plshade, c_plshade1, c_plshades, plfshade, plf2eval2, plf2eval, plf2evalr, 
    -- PLcGrid and Ada counterparts thereof.
    type Transformation_Data_Type (x_Last, y_Last, z_Last : Natural) is
        record
            xg : PL_Float_Array(0 .. x_Last);
            yg : PL_Float_Array(0 .. y_Last);
            zg : PL_Float_Array(0 .. z_Last);
            nx : Natural := x_Last + 1;
            ny : Natural := y_Last + 1;
            nz : Natural := z_Last + 1;
        end record;

    -- PLcGrid2 is for passing (as arrays of pointers) 2d coordinate
    -- transformation arrays.  The grid dimensions are passed for possible bounds
    -- checking.
          
    -- This variant record emulates PLcGrid2.
    type Transformation_Data_Type_2 (x_Last, y_Last : Natural) is
        record
            xg : PL_Float_Array_2D(0 .. x_Last, 0 .. y_Last);
            yg : PL_Float_Array_2D(0 .. x_Last, 0 .. y_Last);
            zg : PL_Float_Array_2D(0 .. x_Last, 0 .. y_Last);
            nx : Natural := x_Last + 1;
            ny : Natural := y_Last + 1;
        end record;


    --NOTE: a PLcGrid3 is a good idea here but there is no way to exploit it yet
    --so I'll leave it out for now.
     

    -- PLColor is the usual way to pass an rgb color value. 
    -- fix this
    -- This can't be converted to Ada without knowing what "name" is used for.
    -- There is nothing in the documentation about this structure nor is it used 
    -- in any of the examples.
    --type PLColor is
    --    record
    --        r : unsigned_char; -- red fix this surely these can be mod 2**3
    --        g : unsigned_char; -- green
    --        b : unsigned_char; -- blue
    --        name : char_array;
    --    end record;

    -- PLControlPt is how cmap1 control points are represented. 

    type PLControlPt is
        record
            h   : PLFLT;   -- hue 
            l   : PLFLT;   -- lightness 
            s   : PLFLT;   -- saturation 
            p   : PLFLT;   -- position 
            rev : Integer; -- if set, interpolate through h=0 
        end record;

    -- A PLBufferingCB is a control block for interacting with devices
    -- that support double buffering. 

    type PLBufferingCB is
        record
            cmd    : PLINT;
            result : PLINT;
        end record;

    PLESC_DOUBLEBUFFERING_ENABLE  : constant Integer := 1;
    PLESC_DOUBLEBUFFERING_DISABLE : constant Integer := 2;
    PLESC_DOUBLEBUFFERING_QUERY   : constant Integer := 3;


--------------------------------------------------------------------------
--       Function Prototypes                                            --
--------------------------------------------------------------------------

    -- set the format of the contour labels 

    procedure
    pl_setcontlabelformat(lexp : PLINT; sigdig : PLINT);
    pragma Import(C, pl_setcontlabelformat, "c_pl_setcontlabelformat");


    -- set offset and spacing of contour labels 

    procedure
    pl_setcontlabelparam(offset : PLFLT; size : PLFLT; spacing : PLFLT; active : PLINT);
    pragma Import(C, pl_setcontlabelparam, "c_pl_setcontlabelparam");


    -- Advance to subpage "page", or to the next one if "page" = 0. 

    procedure
    pladv(page : PLINT);
    pragma Import(C, pladv, "c_pladv");


    -- simple arrow plotter. 

    procedure
    plvect(u : Long_Float_Pointer_Array; v : Long_Float_Pointer_Array; 
        nx : PLINT; ny : PLINT; scale : PLFLT;
        pltr : Transformation_Procedure_Pointer_Type; pltr_data : PLpointer);
    pragma Import(C, plvect, "c_plvect");


    procedure
    plsvect(arrowx : PL_Float_Array; arrowy : PL_Float_Array; npts : PLINT; fill : PLINT);
    pragma Import(C, plsvect, "c_plsvect");


    -- This functions similarly to plbox() except that the origin of the axes 
    -- is placed at the user-specified point (x0, y0). 

    procedure
    plaxes(x0 : PLFLT; y0 : PLFLT; xopt : char_array; xtick : PLFLT; nxsub : PLINT;
         yopt : char_array; ytick : PLFLT; nysub : PLINT);
    pragma Import(C, plaxes, "c_plaxes");


    -- Plot a histogram using x to store data values and y to store frequencies 

    -- Flags for the opt argument in plbin
    PL_Bin_Default  : constant Integer := 0;
    PL_Bin_Centred  : constant Integer := 1;
    PL_Bin_Noexpand : constant Integer := 2;
    PL_Bin_Noempty  : constant Integer := 4;
    
    procedure
    plbin(nbin : PLINT; x : PL_Float_Array; y : PL_Float_Array; center : PLINT);
    pragma Import(C, plbin, "c_plbin");


    -- Start new page.  Should only be used with pleop(). 

    procedure
    plbop;
    pragma Import(C, plbop, "c_plbop");


    -- This draws a box around the current viewport. 

    procedure
    plbox(xopt : char_array; xtick : PLFLT; nxsub : PLINT;
        yopt : char_array; ytick : PLFLT; nysub : PLINT);
    pragma Import(C, plbox, "c_plbox");


    -- This is the 3-d analogue of plbox(). 

    procedure
    plbox3(xopt : char_array; xlabel : char_array; xtick : PLFLT; nsubx : PLINT;
           yopt : char_array; ylabel : char_array; ytick : PLFLT; nsuby : PLINT;
           zopt : char_array; zlabel : char_array; ztick : PLFLT; nsubz : PLINT);
    pragma Import(C, plbox3, "c_plbox3");


    -- Calculate world coordinates and subpage from relative device coordinates. 

    procedure
    plcalc_world(rx : PLFLT; ry : PLFLT; wx : out PLFLT; wy : out PLFLT; window : out PLINT);
    pragma Import(C, plcalc_world, "c_plcalc_world");


    -- Clear current subpage. 

    procedure
    plclear;
    pragma Import(C, plclear, "c_plclear");


    -- Set color, map 0.  Argument is integer between 0 and 15. 

    procedure
    plcol0(icol0 : PLINT);
    pragma Import(C, plcol0, "c_plcol0");


    -- Set color, map 1.  Argument is a float between 0. and 1. 

    procedure
    plcol1(col1 : PLFLT);
    pragma Import(C, plcol1, "c_plcol1");


    -- Draws a contour plot from data in f(nx,ny).  Is just a front-end to
    -- plfcont, with a particular choice for f2eval and f2eval_data.
 
    procedure
    plcont(z : Long_Float_Pointer_Array; nx, ny : Integer; 
        kx, lx, ky, ly : Integer; clevel : PL_Float_Array; nlevel : Integer; 
        pltr : Transformation_Procedure_Pointer_Type; pltr_data : PLpointer);
    pragma Import(C, plcont, "c_plcont");


    -- Draws a contour plot using the function evaluator f2eval and data stored
    -- by way of the f2eval_data pointer.  This allows arbitrary organizations
    -- of 2d array data to be used.
 
    procedure
    plfcont(f2eval : Function_Evaluator_Pointer_Type;
        Irregular_Data : PLpointer;
        nx, ny : PLINT; 
        kx, lx, ky, ly: PLINT; clevel : PL_Float_Array; nlevel : PLINT;
        pltr : Transformation_Procedure_Pointer_Type; pltr_data : PLpointer);
    pragma Import(C, plfcont, "plfcont");


    -- Copies state parameters from the reference stream to the current stream. 

    procedure
    plcpstrm(iplsr : PLINT; flags : PLINT);
    pragma Import(C, plcpstrm, "c_plcpstrm");


    -- Converts input values from relative device coordinates to relative plot 
    -- coordinates. 

    procedure
    pldid2pc(xmin : PL_Float_Array; ymin : PL_Float_Array; xmax : PL_Float_Array; ymax : PL_Float_Array);
    pragma Import(C, pldid2pc, "pldid2pc");

    -- Converts input values from relative plot coordinates to relative 
    -- device coordinates. 

    procedure
    pldip2dc(xmin : PL_Float_Array; ymin : PL_Float_Array; xmax : PL_Float_Array; ymax : PL_Float_Array);
    pragma Import(C, pldip2dc, "pldip2dc");

    -- End a plotting session for all open streams. 

    procedure
    plend;
    pragma Import(C, plend, "c_plend");


    -- End a plotting session for the current stream only. 

    procedure
    plend1;
    pragma Import(C, plend1, "c_plend1");


    -- Simple interface for defining viewport and window. 

    procedure
    plenv(xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT;
        just : PLINT; axis : PLINT);
    pragma Import(C, plenv, "c_plenv");



    -- similar to plenv() above, but in multiplot mode does not advance the subpage,
    -- instead the current subpage is cleared 

    procedure
    plenv0(xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT;
        just : PLINT; axis : PLINT);
    pragma Import(C, plenv0, "c_plenv0");


    -- End current page.  Should only be used with plbop(). 

    procedure
    pleop;
    pragma Import(C, pleop, "c_pleop");


    -- Plot horizontal error bars (xmin(i),y(i)) to (xmax(i),y(i)) 

    procedure
    plerrx(n : PLINT; xmin : PL_Float_Array; xmax : PL_Float_Array; y : PL_Float_Array);
    pragma Import(C, plerrx, "c_plerrx");


    -- Plot vertical error bars (x,ymin(i)) to (x(i),ymax(i)) 

    procedure
    plerry(n : PLINT; x : PL_Float_Array; ymin : PL_Float_Array; ymax : PL_Float_Array);
    pragma Import(C, plerry, "c_plerry");


    -- Advance to the next family file on the next new page 

    procedure
    plfamadv;
    pragma Import(C, plfamadv, "c_plfamadv");


    -- Pattern fills the polygon bounded by the input points. 

    procedure
    plfill(n : PLINT; x : PL_Float_Array; y : PL_Float_Array);
    pragma Import(C, plfill, "c_plfill");


    -- Pattern fills the 3d polygon bounded by the input points. 

    procedure
    plfill3(n : PLINT; x : PL_Float_Array; y : PL_Float_Array; z : PL_Float_Array);
    pragma Import(C, plfill3, "c_plfill3");


    -- Flushes the output stream.  Use sparingly, if at all. 

    procedure
    plflush;
    pragma Import(C, plflush, "c_plflush");


    -- Sets the global font flag to 'ifont'. 

    procedure
    plfont(ifont : PLINT);
    pragma Import(C, plfont, "c_plfont");


    -- Load specified font set. 

    procedure
    plfontld(fnt : PLINT);
    pragma Import(C, plfontld, "c_plfontld");


    -- Get character default height and current (scaled) height 

    procedure
    plgchr(p_def : out PLFLT; p_ht : out PLFLT);
    pragma Import(C, plgchr, "c_plgchr");


    -- Returns 8 bit RGB values for given color from color map 0 

    procedure
    plgcol0(icol0 : PLINT; r : out PLINT; g : out PLINT; b : out PLINT);
    pragma Import(C, plgcol0, "c_plgcol0");
    
    
    -- Returns 8 bit RGB values for given color from color map 0 and alpha value

    procedure
    plgcol0a(icol0 : PLINT; r, g, b: out PLINT; a : out PLFLT);
    pragma Import(C, plgcol0a, "c_plgcol0a");


    -- Returns the background color by 8 bit RGB value 

    procedure
    plgcolbg(r : out PLINT; g : out PLINT; b : out PLINT);
    pragma Import(C, plgcolbg, "c_plgcolbg");


    -- Returns the background color by 8 bit RGB value and alpha value

    procedure
    plgcolbga(r, g, b : out PLINT; a : out PLFLT);
    pragma Import(C, plgcolbga, "c_plgcolbga");


    -- Returns the current compression setting 

    procedure
    plgcompression(compression : out PLINT);
    pragma Import(C, plgcompression, "c_plgcompression");


    -- Get the current device (keyword) name 

    procedure
    plgdev(p_dev : out char_array);
    pragma Import(C, plgdev, "c_plgdev");


    -- Retrieve current window into device space 

    procedure
    plgdidev(p_mar : out PLFLT; p_aspect : out PLFLT; p_jx : out PLFLT; p_jy : out PLFLT);
    pragma Import(C, plgdidev, "c_plgdidev");


    -- Get plot orientation 

    procedure
    plgdiori(p_rot : out PLFLT);
    pragma Import(C, plgdiori, "c_plgdiori");


    -- Retrieve current window into plot space 

    procedure
    plgdiplt(p_xmin : out PLFLT; p_ymin : out PLFLT; p_xmax : out PLFLT; p_ymax : out PLFLT);
    pragma Import(C, plgdiplt, "c_plgdiplt");


    -- Get FCI (font characterization integer) 

    procedure
    plgfci(pfci : out PLUNICODE);
    pragma Import(C, plgfci, "c_plgfci");
    
    
    -- Get family, style and weight of the current font

    procedure
    plgfont(p_family, p_style, p_weight : out PLINT);
    pragma Import(C, plgfont, "c_plgfont");


    -- Get family file parameters 

    procedure
    plgfam(p_fam : out PLINT; p_num : out PLINT; p_bmax : out PLINT);
    pragma Import(C, plgfam, "c_plgfam");


    -- Get the (current) output file name.  Must be preallocated to >80 bytes 

    procedure
    plgfnam(fnam : out char_array);
    pragma Import(C, plgfnam, "c_plgfnam");


    -- Get the (current) run level.  

    procedure
    plglevel(p_level : out PLINT);
    pragma Import(C, plglevel, "c_plglevel");


    -- Get output device parameters. 

    procedure
    plgpage(p_xp : out PLFLT; p_yp : out PLFLT;
          p_xleng : out PLINT; p_yleng : out PLINT; p_xoff : out PLINT; p_yoff : out PLINT);
    pragma Import(C, plgpage, "c_plgpage");


    -- Switches to graphics screen. 

    procedure
    plgra;
    pragma Import(C, plgra, "c_plgra");


      -- grid irregularly sampled data 
    -- Note that since z_Gridded is passed as an array of pointers, this is 
    -- effectively the same as pass-by-reference so "in out" is not required for 
    -- the formal argument zg in plgriddata.

    procedure
    plgriddata(x : PL_Float_Array; y : PL_Float_Array; z : PL_Float_Array; npts : PLINT;
           xg : PL_Float_Array; nptsx : PLINT; yg : PL_Float_Array;  nptsy : PLINT;
           zg : Long_Float_Pointer_Array; grid_type : PLINT; data : PLFLT); --"type" re-named "grid_type" for Ada
    pragma Import(C, plgriddata, "c_plgriddata");


      -- type of gridding algorithm for plgriddata() 

    GRID_CSA    : constant Integer := 1; -- Bivariate Cubic Spline approximation
    GRID_DTLI   : constant Integer := 2; -- Delaunay Triangulation Linear Interpolation
    GRID_NNI    : constant Integer := 3; -- Natural Neighbors Interpolation
    GRID_NNIDW  : constant Integer := 4; -- Nearest Neighbors Inverse Distance Weighted
    GRID_NNLI   : constant Integer := 5; -- Nearest Neighbors Linear Interpolation
    GRID_NNAIDW : constant Integer := 6; -- Nearest Neighbors Around Inverse Distance Weighted

    -- Get subpage boundaries in absolute coordinates 

    procedure
    plgspa(xmin : out PLFLT; xmax : out PLFLT; ymin : out PLFLT; ymax : out PLFLT);
    pragma Import(C, plgspa, "c_plgspa");


    -- Get current stream number. 

    procedure
    plgstrm(p_strm : out PLINT);
    pragma Import(C, plgstrm, "c_plgstrm");


    -- Get the current library version number 

    procedure
    plgver(p_ver : out char_array);
    pragma Import(C, plgver, "c_plgver");


    -- Get viewport boundaries in normalized device coordinates 

    procedure
    plgvpd(p_xmin : out PLFLT; p_xmax : out PLFLT; p_ymin : out PLFLT; p_ymax : out PLFLT);
    pragma Import(C, plgvpd, "c_plgvpd");


    -- Get viewport boundaries in world coordinates 

    procedure
    plgvpw(p_xmin : out PLFLT; p_xmax : out PLFLT; p_ymin : out PLFLT; p_ymax : out PLFLT);
    pragma Import(C, plgvpw, "c_plgvpw");


    -- Get x axis labeling parameters 

    procedure
    plgxax(p_digmax : out PLINT; p_digits : out PLINT);
    pragma Import(C, plgxax, "c_plgxax");


    -- Get y axis labeling parameters 

    procedure
    plgyax(p_digmax : out PLINT; p_digits : out PLINT);
    pragma Import(C, plgyax, "c_plgyax");


    -- Get z axis labeling parameters 

    procedure
    plgzax(p_digmax : out PLINT; p_digits : out PLINT);
    pragma Import(C, plgzax, "c_plgzax");


    -- Draws a histogram of n values of a variable in array data[0..n-1] 

    -- Flags for the opt argument in plhist
    PL_Hist_Default         : constant Integer := 0;
    PL_Hist_Noscaling       : constant Integer := 1;
    PL_Hist_Ignore_Outliers : constant Integer := 2;
    PL_Hist_Noexpand        : constant Integer := 8;
    PL_Hist_Noempty         : constant Integer := 16;

    procedure
    plhist(n : PLINT; data : PL_Float_Array; datmin : PLFLT; datmax : PLFLT;
         nbin : PLINT; oldwin : PLINT);
    pragma Import(C, plhist, "c_plhist");


    -- Set current color (map 0) by hue, lightness, and saturation. 

    procedure
    plhls(h : PLFLT; l : PLFLT; s : PLFLT);
    pragma Import(C, plhls, "c_plhls");


    -- Functions for converting between HLS and RGB color space 

    procedure
    plhlsrgb(h : PLFLT; l : PLFLT; s : PLFLT; p_r : out PLFLT; p_g : out PLFLT; p_b : out PLFLT);
    pragma Import(C, plhlsrgb, "c_plhlsrgb");


    -- Initializes PLplot, using preset or default options 

    procedure
    plinit;
    pragma Import(C, plinit, "c_plinit");


    -- Draws a line segment from (x1, y1) to (x2, y2). 

    procedure
    pljoin(x1 : PLFLT; y1 : PLFLT; x2 : PLFLT; y2 : PLFLT);
    pragma Import(C, pljoin, "c_pljoin");


    -- Simple routine for labelling graphs. 

    procedure
    pllab(xlabel : char_array; ylabel : char_array; tlabel : char_array);
    pragma Import(C, pllab, "c_pllab");


    -- Sets position of the light source 

    procedure
    pllightsource(x : PLFLT; y : PLFLT; z : PLFLT);
    pragma Import(C, pllightsource, "c_pllightsource");


    -- Draws line segments connecting a series of points. 

    procedure
    plline(n : PLINT; x : PL_Float_Array; y : PL_Float_Array);
    pragma Import(C, plline, "c_plline");


    -- Draws a line in 3 space.  

    procedure
    plline3(n : PLINT; x : PL_Float_Array; y : PL_Float_Array; z : PL_Float_Array);
    pragma Import(C, plline3, "c_plline3");


    -- Set line style. 

    procedure
    pllsty(lin : PLINT);
    pragma Import(C, pllsty, "c_pllsty");


    -- plot continental outline in world coordinates 

    procedure
    plmap(mapform : Map_Form_Function_Pointer_Type; Map_Kind_C_String : char_array;
             minlong : PLFLT; maxlong : PLFLT; minlat : PLFLT; maxlat : PLFLT);
    pragma Import(C, plmap, "c_plmap");


    -- Plot the latitudes and longitudes on the background. 

    procedure
    plmeridians(mapform : Map_Form_Function_Pointer_Type;
                   dlong : PLFLT; dlat : PLFLT;
                   minlong : PLFLT; maxlong : PLFLT; minlat : PLFLT; maxlat : PLFLT);
    pragma Import(C, plmeridians, "c_plmeridians");


    -- Plots a mesh representation of the function z(x, y). 

    procedure
    plmesh(x : PL_Float_Array; y : PL_Float_Array; z : Long_Float_Pointer_Array; nx : PLINT; ny : PLINT; opt : PLINT);
    pragma Import(C, plmesh, "c_plmesh");


    -- Plots a mesh representation of the function z(x, y) with contour 

    procedure
    plmeshc(x : PL_Float_Array; y : PL_Float_Array; z : Long_Float_Pointer_Array; nx : PLINT; ny : PLINT; opt : PLINT;
          clevel : PL_Float_Array; nlevel : PLINT);
    pragma Import(C, plmeshc, "c_plmeshc");


    -- Creates a new stream and makes it the default.  

    procedure
    plmkstrm(p_strm : out PLINT);
    pragma Import(C, plmkstrm, "c_plmkstrm");


    -- Prints out "text" at specified position relative to viewport 

    procedure
    plmtex(side : char_array; disp : PLFLT; pos : PLFLT; just : PLFLT;
         text : char_array);
    pragma Import(C, plmtex, "c_plmtex");


    -- Prints out "text" at specified position relative to viewport (3D)

    procedure
    plmtex3(side : char_array; disp, pos, just : PLFLT; text : char_array);
    pragma Import(C, plmtex3, "c_plmtex3");


    -- Plots a 3-d representation of the function z(x, y). 

    procedure
    plot3d(x : PL_Float_Array; y : PL_Float_Array; z : Long_Float_Pointer_Array;
         nx : PLINT; ny : PLINT; opt : PLINT; side : PLINT);
    pragma Import(C, plot3d, "c_plot3d");


    -- Plots a 3-d representation of the function z(x, y) with contour. 

    procedure
    plot3dc(x : PL_Float_Array; y : PL_Float_Array; z : Long_Float_Pointer_Array;
         nx : PLINT; ny : PLINT; opt : PLINT;
         clevel : PL_Float_Array; nlevel : PLINT);
    pragma Import(C, plot3dc, "c_plot3dc");


    -- Plots a 3-d representation of the function z(x, y) with contour and
    -- y index limits. 

    procedure
    plot3dcl(x : PL_Float_Array; y : PL_Float_Array; z : Long_Float_Pointer_Array;
         nx : PLINT; ny : PLINT; opt : PLINT;
         clevel : PL_Float_Array; nlevel : PLINT; 
         ixstart : PLINT; ixn : PLINT; indexymin : PL_Integer_Array; indexymax : PL_Integer_Array);
    pragma Import(C, plot3dcl, "c_plot3dcl");


    -- definitions for the opt argument in plot3dc() and plsurf3d()

    -- DRAW_LINEX *must* be 1 and DRAW_LINEY *must* be 2, because of legacy code!
 
    DRAW_LINEX  : constant Integer := 1;   -- draw lines parallel to the X axis
    DRAW_LINEY  : constant Integer := 2;   -- draw lines parallel to the Y axis
    DRAW_LINEXY : constant Integer := 3;   -- draw lines parallel to both the X and Y axis
    MAG_COLOR   : constant Integer := 4;   -- draw the mesh with a color dependent of the magnitude
    BASE_CONT   : constant Integer := 8;   -- draw contour plot at bottom xy plane
    TOP_CONT    : constant Integer := 16;  -- draw contour plot at top xy plane
    SURF_CONT   : constant Integer := 32;  -- draw contour plot at surface
    DRAW_SIDES  : constant Integer := 64;  -- draw sides
    FACETED     : constant Integer := 128; -- draw outline for each square that makes up the surface
    MESH        : constant Integer := 256; -- draw mesh

       --  valid options for plot3dc():
       --
       --  DRAW_SIDES, BASE_CONT, TOP_CONT (not yet),
       --  MAG_COLOR, DRAW_LINEX, DRAW_LINEY, DRAW_LINEXY.
       --
       --  valid options for plsurf3d():
       --
       --  MAG_COLOR, BASE_CONT, SURF_CONT, FACETED, DRAW_SIDES.
   

    -- Set fill pattern directly. 

    procedure
    plpat(nlin : PLINT; inc : PL_Integer_Array; del : PL_Integer_Array);
    pragma Import(C, plpat, "c_plpat");


    -- Plots array y against x for n points using ASCII code "code".

    procedure
    plpoin(n : PLINT; x : PL_Float_Array; y : PL_Float_Array; code : PLINT);
    pragma Import(C, plpoin, "c_plpoin");


    -- Draws a series of points in 3 space. 

    procedure
    plpoin3(n : PLINT; x : PL_Float_Array; y : PL_Float_Array; z : PL_Float_Array; code : PLINT);
    pragma Import(C, plpoin3, "c_plpoin3");


    -- Draws a polygon in 3 space.  

    procedure
    plpoly3(n : PLINT; x : PL_Float_Array; y : PL_Float_Array; z : PL_Float_Array; draw : PL_Bool_Array; ifcc : PLBOOL);
    pragma Import(C, plpoly3, "c_plpoly3");


    -- Set the floating point precision (in number of places) in numeric labels. 

    procedure
    plprec(setp : PLINT; prec : PLINT);
    pragma Import(C, plprec, "c_plprec");


    -- Set fill pattern, using one of the predefined patterns.

    procedure
    plpsty(patt : PLINT);
    pragma Import(C, plpsty, "c_plpsty");


    -- Prints out "text" at world cooordinate (x,y). 

    procedure
    plptex(x : PLFLT; y : PLFLT; dx : PLFLT; dy : PLFLT; just : PLFLT; text : char_array);
    pragma Import(C, plptex, "c_plptex");


    -- Prints out "text" at world cooordinate (x,y,z).

    procedure
    plptex3(wx, wy, wz, dx, dy, dz, sx, sy, sz, just : PLFLT; text : char_array);
    pragma Import(C, plptex3, "c_plptex3");


    -- Random number generator based on Mersenne Twister.
    -- Obtain real random number in range [0,1].

    function
    plrandd return Long_Float;
    pragma Import(C, plrandd, "c_plrandd");


    -- Replays contents of plot buffer to current device/file. 

    procedure
    plreplot;
    pragma Import(C, plreplot, "c_plreplot");


    -- Set line color by red, green, blue from  0. to 1. 

    procedure
    plrgb(r : PLFLT; g : PLFLT; b : PLFLT);
    pragma Import(C, plrgb, "c_plrgb");


    -- Set line color by 8 bit RGB values. 

    procedure
    plrgb1(r : PLINT; g : PLINT; b : PLINT);
    pragma Import(C, plrgb1, "c_plrgb1");


    -- Functions for converting between HLS and RGB color space 

    procedure
    plrgbhls(r : PLFLT; g : PLFLT; b : PLFLT; p_h : out PLFLT; p_l : out PLFLT; p_s : out PLFLT);
    pragma Import(C, plrgbhls, "c_plrgbhls");


    -- Set character height. 

    procedure
    plschr(def : PLFLT; scale : PLFLT);
    pragma Import(C, plschr, "c_plschr");


    -- Set color map 0 colors by 8 bit RGB values 

    procedure
    plscmap0(r : PL_Integer_Array; g : PL_Integer_Array; b : PL_Integer_Array; ncol0 : PLINT);
    pragma Import(C, plscmap0, "c_plscmap0");


    -- Set color map 0 colors by 8 bit RGB values and alpha values

    procedure
    plscmap0a(r, g, b : PL_Integer_Array; a : PL_Float_Array; ncol0 : PLINT);
    pragma Import(C, plscmap0a, "c_plscmap0a");


    -- Set number of colors in cmap 0 

    procedure
    plscmap0n(ncol0 : PLINT);
    pragma Import(C, plscmap0n, "c_plscmap0n");


    -- Set color map 1 colors by 8 bit RGB values 

    procedure
    plscmap1(r : PL_Integer_Array; g : PL_Integer_Array; b : PL_Integer_Array; ncol1 : PLINT);
    pragma Import(C, plscmap1, "c_plscmap1");


    -- Set color map 1 colors by 8 bit RGB and alpha values

    procedure
    plscmap1a(r, g, b : PL_Integer_Array; a : PL_Float_Array; ncol1 : PLINT);
    pragma Import(C, plscmap1a, "c_plscmap1a");


    -- Set color map 1 colors using a piece-wise linear relationship between 
    -- intensity [0,1] (cmap 1 index) and position in HLS or RGB color space. 

    procedure
    plscmap1l(itype : PLINT; npts : PLINT; intensity : PL_Float_Array;
        coord1 : PL_Float_Array; coord2 : PL_Float_Array; coord3 : PL_Float_Array; 
        rev : PL_Bool_Array);
    pragma Import(C, plscmap1l, "c_plscmap1l");


    -- Set color map 1 colors using a piece-wise linear relationship between
    -- intensity [0,1] (cmap 1 index) and position in HLS or RGB color space.
    -- Will also linear interpolate alpha values.

    procedure
    plscmap1la(itype : PLINT; npts : PLINT;
        intensity, coord1, coord2, coord3, a : PL_Float_Array; 
        rev : PL_Bool_Array);
    pragma Import(C, plscmap1la, "c_plscmap1la");


    -- Set number of colors in cmap 1 

    procedure
    plscmap1n(ncol1 : PLINT);
    pragma Import(C, plscmap1n, "c_plscmap1n");


    -- Set a given color from color map 0 by 8 bit RGB value 

    procedure
    plscol0(icol0 : PLINT; r : PLINT; g : PLINT; b : PLINT);
    pragma Import(C, plscol0, "c_plscol0");


    -- Set a given color from color map 0 by 8 bit RGB value and alpha value

    procedure
    plscol0a(icol0 : PLINT; r, g, b : PLINT; a : PLFLT);
    pragma Import(C, plscol0a, "c_plscol0a");


    -- Set the background color by 8 bit RGB value 

    procedure
    plscolbg(r : PLINT; g : PLINT; b : PLINT);
    pragma Import(C, plscolbg, "c_plscolbg");


    -- Set the background color by 8 bit RGB value and alpha value

    procedure
    plscolbga(r, g, b : PLINT; a : PLFLT);
    pragma Import(C, plscolbga, "c_plscolbga");


    -- Used to globally turn color output on/off 

    procedure
    plscolor(color : PLINT);
    pragma Import(C, plscolor, "c_plscolor");


    -- Set the compression level 

    procedure
    plscompression(compression : PLINT);
    pragma Import(C, plscompression, "c_plscompression");


    -- Set the device (keyword) name 

    procedure
    plsdev(devname : char_array);
    pragma Import(C, plsdev, "c_plsdev");


    -- Set window into device space using margin, aspect ratio, and 
    -- justification 

    procedure
    plsdidev(mar : PLFLT; aspect : PLFLT; jx : PLFLT; jy : PLFLT);
    pragma Import(C, plsdidev, "c_plsdidev");


    -- Set up transformation from metafile coordinates. 

    procedure
    plsdimap(dimxmin : PLINT; dimxmax : PLINT; dimymin : PLINT; dimymax : PLINT;
           dimxpmm : PLFLT; dimypmm : PLFLT);
    pragma Import(C, plsdimap, "c_plsdimap");


    -- Set plot orientation, specifying rotation in units of pi/2. 

    procedure
    plsdiori(rot : PLFLT);
    pragma Import(C, plsdiori, "c_plsdiori");


    -- Set window into plot space 

    procedure
    plsdiplt(xmin : PLFLT; ymin : PLFLT; xmax : PLFLT; ymax : PLFLT);
    pragma Import(C, plsdiplt, "c_plsdiplt");


    -- Set window into plot space incrementally (zoom) 

    procedure
    plsdiplz(xmin : PLFLT; ymin : PLFLT; xmax : PLFLT; ymax : PLFLT);
    pragma Import(C, plsdiplz, "c_plsdiplz");


    -- Set seed for internal random number generator

    procedure
    plseed(s : unsigned);
    pragma Import(C, plseed, "c_plseed");


    -- Set the escape character for text strings. 

    procedure
    plsesc(esc : char);
    pragma Import(C, plsesc, "c_plsesc");


    -- Set family file parameters 

    procedure
    plsfam(fam : PLINT; num : PLINT; bmax : PLINT);
    pragma Import(C, plsfam, "c_plsfam");


    -- Set FCI (font characterization integer) 

    procedure
    plsfci(fci : PLUNICODE);
    pragma Import(C, plsfci, "c_plsfci");
    
    
    -- Set the font family, style and weight

    procedure
    plsfont(family, style, weight : PLINT);
    pragma Import(C, plsfont, "c_plsfont");


    -- Set the output file name. 

    procedure
    plsfnam(fnam : char_array);
    pragma Import(C, plsfnam, "c_plsfnam");


    -- Shade region. 

    procedure
    plshade(a : Long_Float_Pointer_Array; nx : PLINT; ny : PLINT; defined : Mask_Function_Pointer_Type;
          left : PLFLT; right : PLFLT; bottom : PLFLT; top : PLFLT;
          shade_min : PLFLT; shade_max : PLFLT;
          sh_cmap : PLINT; sh_color : PLFLT; sh_width : PLINT;
          min_color : PLINT; min_width : PLINT;
          max_color : PLINT; max_width : PLINT;
          fill : Fill_Procedure_Pointer_Type; rectangular : PLINT;
          pltr : Transformation_Procedure_Pointer_Type; pltr_data : PLpointer);
    pragma Import(C, plshade, "c_plshade");


    procedure
    plshade1(a : PL_Float_Array_2D; nx : PLINT; ny : PLINT; defined : Mask_Function_Pointer_Type;
          left : PLFLT; right : PLFLT; bottom : PLFLT; top : PLFLT;
          shade_min : PLFLT; shade_max : PLFLT;
          sh_cmap : PLINT; sh_color : PLFLT; sh_width : PLINT;
          min_color : PLINT; min_width : PLINT;
          max_color : PLINT; max_width : PLINT;
          fill : Fill_Procedure_Pointer_Type; rectangular : PLINT;
          pltr : Transformation_Procedure_Pointer_Type; pltr_data : PLpointer);
    pragma Import(C, plshade1, "c_plshade1");


    procedure
    plshades(z : Long_Float_Pointer_Array; nx : PLINT; ny : PLINT; defined : Mask_Function_Pointer_Type;
          xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT;
          clevel : PL_Float_Array; nlevel : PLINT; fill_width : PLINT;
          cont_color : PLINT; cont_width : PLINT;
          fill : Fill_Procedure_Pointer_Type; rectangular : PLINT;
          pltr : Transformation_Procedure_Pointer_Type; pltr_data : PLpointer);
    pragma Import(C, plshades, "c_plshades");


-- fix this
--    procedure
--    plfshade(PLFLT (*f2eval) ( : PLINT;  : PLINT; PLPointer),
--         PLPointer f2eval_data,
--         PLFLT (*c2eval) ( : PLINT;  : PLINT; PLPointer),
--         PLPointer c2eval_data,
--         nx : PLINT; ny : PLINT;
--         left : PLFLT; right : PLFLT; bottom : PLFLT; top : PLFLT;
--         shade_min : PLFLT; shade_max : PLFLT;
--         sh_cmap : PLINT; sh_color : PLFLT; sh_width : PLINT;
--         min_color : PLINT; min_width : PLINT;
--         max_color : PLINT; max_width : PLINT;
--         void (*fill) ( : PLINT;  : PL_Float_Array;  : PL_Float_Array), rectangular : PLINT;
--         void (*pltr) ( : PLFLT;  : PLFLT;  : PL_Float_Array;  : PL_Float_Array; PLPointer),
--         PLPointer pltr_data);
--    pragma Import(C, plfshade, "plfshade");

    -- Set up lengths of major tick marks. 

    procedure
    plsmaj(def : PLFLT; scale : PLFLT);
    pragma Import(C, plsmaj, "c_plsmaj");


    -- Set the memory area to be plotted (with the 'mem' driver) 

    procedure
    plsmem(maxx : PLINT; maxy : PLINT; plotmem : PLPointer);
    pragma Import(C, plsmem, "c_plsmem");


    -- Set up lengths of minor tick marks. 

    procedure
    plsmin(def : PLFLT; scale : PLFLT);
    pragma Import(C, plsmin, "c_plsmin");


    -- Set orientation.  Must be done before calling plinit. 

    procedure
    plsori(ori : PLINT);
    pragma Import(C, plsori, "c_plsori");


    -- Set output device parameters.  Usually ignored by the driver. 

    procedure
    plspage(xp : PLFLT; yp : PLFLT; xleng : PLINT; yleng : PLINT;
          xoff : PLINT; yoff : PLINT);
    pragma Import(C, plspage, "c_plspage");


    -- Set the pause (on end-of-page) status 

    procedure
    plspause(pause : PLINT);
    pragma Import(C, plspause, "c_plspause");


    -- Set stream number.  

    procedure
    plsstrm(strm : PLINT);
    pragma Import(C, plsstrm, "c_plsstrm");


    -- Set the number of subwindows in x and y 

    procedure
    plssub(nx : PLINT; ny : PLINT);
    pragma Import(C, plssub, "c_plssub");


    -- Set symbol height. 

    procedure
    plssym(def : PLFLT; scale : PLFLT);
    pragma Import(C, plssym, "c_plssym");


    -- Initialize PLplot, passing in the windows/page settings. 

    procedure
    plstar(nx : PLINT; ny : PLINT);
    pragma Import(C, plstar, "c_plstar");


    -- Initialize PLplot, passing the device name and windows/page settings. 

    procedure
    plstart(devname : char_array; nx : PLINT; ny : PLINT);
    pragma Import(C, plstart, "c_plstart");


    -- Add a point to a stripchart.  

    procedure
    plstripa(id : PLINT; pen : PLINT; x : PLFLT; y : PLFLT);
    pragma Import(C, plstripa, "c_plstripa");


    -- Create 1d stripchart 

    procedure
    plstripc(id : out PLINT; xspec : char_array; yspec : char_array;
        xmin : PLFLT; xmax : PLFLT; xjump : PLFLT; ymin : PLFLT; ymax : PLFLT;
        xlpos : PLFLT; ylpos : PLFLT;
        y_ascl : PLBOOL; acc : PLBOOL;
        colbox : PLINT; collab : PLINT;
        colline : PL_Integer_Array; styline : PL_Integer_Array; legline : PL_Stripchart_String_Array;
        labx : char_array; laby : char_array; labtop : char_array);
    pragma Import(C, plstripc, "c_plstripc");


    -- Deletes and releases memory used by a stripchart.  

    procedure
    plstripd(id : PLINT);
    pragma Import(C, plstripd, "c_plstripd");


    -- plots a 2d image (or a matrix too large for plshade() )

    procedure 
    plimagefr(data : Long_Float_Pointer_Array; nx : PLINT; ny : PLINT;
        xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT; zmin : PLFLT; zmax : PLFLT;
        valuemin :PLFLT; valuemax : PLFLT;
        pltr : Transformation_Procedure_Pointer_Type;
        pltr_data : PLpointer);
    pragma Import(C, plimagefr, "c_plimagefr");


      -- plots a 2d image (or a matrix too large for plshade() ) 

    procedure
    plimage(data : Long_Float_Pointer_Array; nx : PLINT; ny : PLINT;
         xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT; zmin : PLFLT; zmax : PLFLT;
         Dxmin : PLFLT; Dxmax : PLFLT; Dymin : PLFLT; Dymax : PLFLT);
    pragma Import(C, plimage, "c_plimage");

    -- Set up a new line style 

    procedure
    plstyl(nms : PLINT; mark : PL_Integer_Array; space : PL_Integer_Array);
    pragma Import(C, plstyl, "c_plstyl");


    -- Plots the 3d surface representation of the function z(x, y). 

    procedure
    plsurf3d(x : PL_Float_Array; y : PL_Float_Array; z : Long_Float_Pointer_Array; nx : PLINT; ny :  PLINT;
           opt : PLINT; clevel : PL_Float_Array; nlevel : PLINT);
    pragma Import(C, plsurf3d, "c_plsurf3d");


    -- Plots the 3d surface representation of the function z(x, y) with y
    -- index limits. 

    procedure
    plsurf3dl(x : PL_Float_Array; y : PL_Float_Array; z : PL_Float_Array_2D; nx : PLINT; ny : PLINT;
           opt : PLINT; clevel : PL_Float_Array; nlevel : PLINT;
           ixstart : PLINT; ixn : PLINT; indexymin : out PLINT; indexymax : out PLINT);
    pragma Import(C, plsurf3dl, "c_plsurf3dl");


    -- Sets the edges of the viewport to the specified absolute coordinates 

    procedure
    plsvpa(xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT);
    pragma Import(C, plsvpa, "c_plsvpa");


    -- Set x axis labeling parameters 

    procedure
    plsxax(digmax : PLINT; field_digits : PLINT); -- "digits" changed to "field_digits".
    pragma Import(C, plsxax, "c_plsxax");


    -- Set inferior X window 

    procedure
    plsxwin(window_id : PLINT);
    pragma Import(C, plsxwin, "plsxwin");

    -- Set y axis labeling parameters 

    procedure
    plsyax(digmax : PLINT; field_digits : PLINT); -- "digits" changed to "field_digits".
    pragma Import(C, plsyax, "c_plsyax");


    -- Plots array y against x for n points using Hershey symbol "code" 

    procedure
    plsym(n : PLINT; x : PL_Float_Array; y : PL_Float_Array; code : PLINT);
    pragma Import(C, plsym, "c_plsym");


    -- Set z axis labeling parameters 

    procedure
    plszax(digmax : PLINT; field_digits : PLINT); -- "digits" changed to "field_digits".
    pragma Import(C, plszax, "c_plszax");


    -- Switches to text screen. 

    procedure
    pltext;
    pragma Import(C, pltext, "c_pltext");
    

    -- Set the format for date / time labels

    procedure
    pltimefmt(fmt : char_array);
    pragma Import(C, pltimefmt, "c_pltimefmt");


    -- Sets the edges of the viewport with the given aspect ratio, leaving 
    -- room for labels. 

    procedure
    plvasp(aspect : PLFLT);
    pragma Import(C, plvasp, "c_plvasp");


    -- Creates the largest viewport of the specified aspect ratio that fits 
    -- within the specified normalized subpage coordinates. 

    procedure
    plvpas(xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT; aspect : PLFLT);
    pragma Import(C, plvpas, "c_plvpas");


    -- Creates a viewport with the specified normalized subpage coordinates. 

    procedure
    plvpor(xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT);
    pragma Import(C, plvpor, "c_plvpor");


    -- Defines a "standard" viewport with seven character heights for 
    -- the left margin and four character heights everywhere else. 

    procedure
    plvsta;
    pragma Import(C, plvsta, "c_plvsta");


    -- Set up a window for three-dimensional plotting. 

    procedure
    plw3d(basex : PLFLT; basey : PLFLT; height : PLFLT; xmin0 : PLFLT;
        xmax0 : PLFLT; ymin0 : PLFLT; ymax0 : PLFLT; zmin0 : PLFLT;
        zmax0 : PLFLT; alt : PLFLT; az : PLFLT);
    pragma Import(C, plw3d, "c_plw3d");


    -- Set pen width. 

    procedure
    plwid(width : PLINT);
    pragma Import(C, plwid, "c_plwid");


    -- Set up world coordinates of the viewport boundaries (2d plots). 

    procedure
    plwind(xmin : PLFLT; xmax : PLFLT; ymin : PLFLT; ymax : PLFLT);
    pragma Import(C, plwind, "c_plwind");


    --  set xor mode; mode = 1-enter, 0-leave, status = 0 if not interactive device  

    procedure
    plxormod(mode : PLINT; status : out PLINT);
    pragma Import(C, plxormod, "c_plxormod");


--------------------------------------------------------------------------------
--         Functions for use from C or C++ only                               --
--         (Not really ;).                                                    --
--------------------------------------------------------------------------------
-- THESE FUNCTIONS ^^^ ARE NOT IMPLEMENTED FOR THE ADA BINDING
-- EXCEPT FOR THE FOLLOWING.

    -- plparseopts here is an exact copy (exept for the name) of 
    -- Parse_Command_Line_Arguments in the thick binding. The reason for
    -- departing from the usual method of simply pragma Import-ing as in
    -- most or all of the other interfaces to C is because of the need to 
    -- figure out what the command lines arguments are by also pragma 
    -- Import-ing Gnat_Argc and Gnat_Argv. A single-argment version is made 
    -- at the request of the development team rather than the three-argument 
    -- version of the documetation. The caller specifies only the parse mode.
    
    -- Process options list using current options info.
    procedure plparseopts(Mode : Parse_Mode_Type);


    -- This is a three-argument version of plparseopts as indicated in the
    -- documentation.

    -- Process options list using current options info.
    procedure plparseopts
       (Gnat_Argc : Integer;
        Gnat_Argv : System.Address;
        Mode      : Parse_Mode_Type);


    -- Process input strings, treating them as an option and argument pair.
    procedure
    plsetopt(opt, optarg : char_array);
    pragma Import(C, plsetopt, "c_plsetopt");
    

	-- Transformation routines

    -- pltr0, pltr1, and pltr2 had to be re-written in Ada in order to make the 
    -- callback work while also passing the data structure along, e.g. 
    -- pltr_data in the formal names below. The machinery surrounding this idea  
    -- also allows for easy user-defined plot transformation subprograms to be
    -- written.

    -- Identity transformation. Re-write of pltr0 in plcont.c in Ada.
    procedure pltr0
       (x, y      : PLFLT;
        tx, ty    : out PLFLT;
        pltr_data : PLplot_thin.PLpointer);
    pragma Convention (Convention => C, Entity => pltr0);


    -- Re-write of pltr1 in Ada.
    procedure pltr1
       (x, y      : PLFLT;
        tx, ty    : out PLFLT;
        pltr_data : PLplot_thin.PLpointer);
    pragma Convention (Convention => C, Entity => pltr1);


    -- Re-write of pltr2 in Ada.
    -- Does linear interpolation from doubly dimensioned coord arrays
    -- (column dominant, as per normal C 2d arrays).
    procedure pltr2
       (x, y      : PLFLT;
        tx, ty    : out PLFLT;
        pltr_data : PLplot_thin.PLpointer);
    pragma Convention (Convention => C, Entity => pltr2);
    
    
    -- Wait for graphics input event and translate to world coordinates.
    procedure plGetCursor(gin : out PLGraphicsIn);
    pragma Import (C, plGetCursor, "plGetCursor");

end PLplot_Thin;
