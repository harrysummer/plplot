SET(CMAKE_WINDOWS_OBJECT_PATH 1)
SET(CMAKE_LIBRARY_PATH_FLAG "-LIBPATH:")
SET(CMAKE_LINK_LIBRARY_FLAG "")
SET(WIN32 1)
IF(CMAKE_VERBOSE_MAKEFILE)
  SET(CMAKE_CL_NOLOGO)
ELSE(CMAKE_VERBOSE_MAKEFILE)
  SET(CMAKE_CL_NOLOGO "/nologo")
ENDIF(CMAKE_VERBOSE_MAKEFILE)

SET(CMAKE_Fortran_CREATE_SHARED_LIBRARY
 "link ${CMAKE_CL_NOLOGO} ${CMAKE_START_TEMP_FILE}  /out:<TARGET> /dll  <LINK_FLAGS> <OBJECTS> <LINK_LIBRARIES> ${CMAKE_END_TEMP_FILE}")

SET(CMAKE_Fortran_CREATE_SHARED_MODULE ${CMAKE_Fortran_CREATE_SHARED_LIBRARY})

# create a C++ static library
SET(CMAKE_Fortran_CREATE_STATIC_LIBRARY  "lib ${CMAKE_CL_NOLOGO} <LINK_FLAGS> /out:<TARGET> <OBJECTS> ")

# compile a C++ file into an object file
SET(CMAKE_Fortran_COMPILE_OBJECT
    "<CMAKE_Fortran_COMPILER>  ${CMAKE_START_TEMP_FILE} ${CMAKE_CL_NOLOGO} /object:<OBJECT> <FLAGS> /compile_only <SOURCE>${CMAKE_END_TEMP_FILE}")

SET(CMAKE_COMPILE_RESOURCE "rc <FLAGS> /fo<OBJECT> <SOURCE>")

SET(CMAKE_Fortran_LINK_EXECUTABLE
    "<CMAKE_Fortran_COMPILER> ${CMAKE_CL_NOLOGO} ${CMAKE_START_TEMP_FILE} <FLAGS> <OBJECTS> /exe:<TARGET> /link /force <CMAKE_Fortran_LINK_FLAGS> <LINK_FLAGS> <LINK_LIBRARIES>${CMAKE_END_TEMP_FILE}")

SET(CMAKE_CREATE_WIN32_EXE /winapp)
SET(CMAKE_CREATE_CONSOLE_EXE )

IF(CMAKE_GENERATOR MATCHES "Visual Studio 6")
   SET (CMAKE_NO_BUILD_TYPE 1)
ENDIF(CMAKE_GENERATOR MATCHES "Visual Studio 6")
IF(CMAKE_GENERATOR MATCHES "Visual Studio 7" OR CMAKE_GENERATOR MATCHES "Visual Studio 8")
  SET (CMAKE_NO_BUILD_TYPE 1)
  SET (CMAKE_CONFIGURATION_TYPES "Debug;Release;MinSizeRel;RelWithDebInfo" CACHE STRING
     "Semicolon separated list of supported configuration types, only supports Debug, Release, MinSizeRel, and RelWithDebInfo, anything else will be ignored.")
ENDIF(CMAKE_GENERATOR MATCHES "Visual Studio 7" OR CMAKE_GENERATOR MATCHES "Visual Studio 8")
# does the compiler support pdbtype and is it the newer compiler

SET(CMAKE_BUILD_TYPE_INIT Debug)
SET (CMAKE_Fortran_FLAGS_INIT "")
SET (CMAKE_Fortran_FLAGS_DEBUG_INIT "/debug:full")
SET (CMAKE_Fortran_FLAGS_MINSIZEREL_INIT "/Optimize:2 /Define:NDEBUG")
SET (CMAKE_Fortran_FLAGS_RELEASE_INIT "/Optimize:1 /Define:NDEBUG")
SET (CMAKE_Fortran_FLAGS_RELWITHDEBINFO_INIT "/Optimize:1 /debug:full /Define:NDEBUG")

SET (CMAKE_Fortran_STANDARD_LIBRARIES_INIT "user32.lib")

# executable linker flags
# Note (AM, 1 february 2007):
# To prevent problems with inconsistent compile options, added the
# /force flag
SET (CMAKE_LINK_DEF_FILE_FLAG "/DEF:")
SET (CMAKE_EXE_LINKER_FLAGS_INIT " /INCREMENTAL:YES /force")
IF (CMAKE_COMPILER_SUPPORTS_PDBTYPE)
  SET (CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT "/force /debug /pdbtype:sept")
  SET (CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT "/force /debug /pdbtype:sept")
ELSE (CMAKE_COMPILER_SUPPORTS_PDBTYPE)
  SET (CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT "/force /debug")
  SET (CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT "/force /debug")
ENDIF (CMAKE_COMPILER_SUPPORTS_PDBTYPE)

SET (CMAKE_SHARED_LINKER_FLAGS_INIT ${CMAKE_EXE_LINKER_FLAGS_INIT})
SET (CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT ${CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT})
SET (CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO_INIT ${CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT})
SET (CMAKE_MODULE_LINKER_FLAGS_INIT ${CMAKE_SHARED_LINKER_FLAGS_INIT})
SET (CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT ${CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT})
SET (CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO_INIT ${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO_INIT})
