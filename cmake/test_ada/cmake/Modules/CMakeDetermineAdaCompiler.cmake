
#=============================================================================
# Copyright 2002-2009 Kitware, Inc.
# Copyright 2015 Alan W. Irwin
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the names of Kitware, Inc., the Insight Software Consortium,
#   nor the names of their contributors may be used to endorse or promote
#   products derived from this software without specific prior written
#   permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================

# determine the compiler to use for Ada programs
# NOTE, a generator may set CMAKE_Ada_COMPILER before
# loading this file to force a compiler.
# use environment variable ADA first if defined by user, next use
# the cmake variable CMAKE_GENERATOR_ADA which can be defined by a generator
# as a default compiler
#
# Sets the following variables:
#   CMAKE_Ada_COMPILER
#   CMAKE_COMPILER_IS_GNUADA
#   CMAKE_AR
#   CMAKE_RANLIB
#

include(${CMAKE_ROOT}/Modules/CMakeDetermineCompiler.cmake)

# Load system-specific compiler preferences for this language.
include(Platform/${CMAKE_SYSTEM_NAME}-Ada OPTIONAL)
if(NOT CMAKE_Ada_COMPILER_NAMES)
  set(CMAKE_Ada_COMPILER_NAMES gnatgcc)
endif()

if(${CMAKE_GENERATOR} MATCHES "Visual Studio")
elseif("${CMAKE_GENERATOR}" MATCHES "Xcode")
else()
  if(NOT CMAKE_Ada_COMPILER)
    set(CMAKE_Ada_COMPILER_INIT NOTFOUND)

    # prefer the environment variable ADA
    if(NOT $ENV{ADA} STREQUAL "")
      get_filename_component(CMAKE_Ada_COMPILER_INIT $ENV{ADA} PROGRAM PROGRAM_ARGS CMAKE_Ada_FLAGS_ENV_INIT)
      if(CMAKE_Ada_FLAGS_ENV_INIT)
        set(CMAKE_Ada_COMPILER_ARG1 "${CMAKE_Ada_FLAGS_ENV_INIT}" CACHE STRING "First argument to Ada compiler")
      endif()
      if(NOT EXISTS ${CMAKE_Ada_COMPILER_INIT})
        message(FATAL_ERROR "Could not find compiler set in environment variable ADA:\n$ENV{ADA}.\n${CMAKE_Ada_COMPILER_INIT}")
      endif()
    endif()

    # next prefer the generator specified compiler
    if(CMAKE_GENERATOR_ADA)
      if(NOT CMAKE_Ada_COMPILER_INIT)
        set(CMAKE_Ada_COMPILER_INIT ${CMAKE_GENERATOR_ADA})
      endif()
    endif()

    # finally list compilers to try
    if(NOT CMAKE_Ada_COMPILER_INIT)
      set(CMAKE_Ada_COMPILER_LIST gnatgcc gcc)
    endif()

    _cmake_find_compiler(Ada)
  else()
    _cmake_find_compiler_path(Ada)
  endif()
  mark_as_advanced(CMAKE_Ada_COMPILER)

endif()

# Set ID variables by brute force for this gnatmake case rather than
# using the normal compiler identification script supplied by CMake.
# As far as I can tell, CMAKE_Ada_COMPILER_ID is required to set up a
# proper include of the relevant Platform file as well as in the
# logic stanza below while CMAKE_Ada_PLATFORM_ID is only needed in the
# logic stanza below.
set(CMAKE_Ada_COMPILER_ID GNU)
set(CMAKE_Ada_PLATFORM_ID)
if(MINGW)
  set(CMAKE_Ada_PLATFORM_ID MinGW)
endif(MINGW)
if(CYGWIN)
  set(CMAKE_Ada_PLATFORM_ID Cygwin)
endif(CYGWIN)

if(CMAKE_Ada_COMPILER_ID STREQUAL "GNU")
  set(CMAKE_COMPILER_IS_GNUADA 1)
endif()
if(CMAKE_Ada_PLATFORM_ID MATCHES "MinGW")
  set(CMAKE_COMPILER_IS_MINGW 1)
elseif(CMAKE_Ada_PLATFORM_ID MATCHES "Cygwin")
  set(CMAKE_COMPILER_IS_CYGWIN 1)
endif()

# configure all variables set in this file
# FIXME: This specific location needs to be changed whenever the
# location of the Ada support files are changed.
#configure_file(${CMAKE_ROOT}/Modules/CMakeAdaCompiler.cmake.in
configure_file(${CMAKE_SOURCE_DIR}/cmake/Modules/CMakeAdaCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeAdaCompiler.cmake
  @ONLY
  )

set(CMAKE_Ada_COMPILER_ENV_VAR "ADA")