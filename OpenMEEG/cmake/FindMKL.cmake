# - Try to find the Intel Math Kernel Library
# Once done this will define
#
#  MKL_FOUND - system has MKL
#  MKL_ROOT_DIR - path to the MKL base directory
#  MKL_INCLUDE_DIR - the MKL include directory
#  MKL_LIBRARIES - MKL libraries
#
# There are few sets of libraries:
# Array indexes modes:
# LP - 32 bit indexes of arrays
# ILP - 64 bit indexes of arrays
# Threading:
# SEQUENTIAL - no threading
# INTEL - Intel threading library
# GNU - GNU threading library
# MPI support
# NOMPI - no MPI support
# INTEL - Intel MPI library
# OPEN - Open MPI library
# SGI - SGI MPT Library


#set(CMAKE_FIND_DEBUG_MODE 1)

set(MKL_POSSIBLE_LOCATIONS
    $ENV{MKLDIR}
    /opt/intel/mkl
    /opt/intel/cmkl
    /Library/Frameworks/Intel_MKL.framework/Versions/Current/lib/universal
    "C:/Program Files (x86)/Intel/ComposerXE-2011/mkl"
    "C:/Program Files (x86)/Intel/Composer XE 2013/mkl"
    "C:/Program Files/Intel/MKL/*/"
    "C:/Program Files/Intel/ComposerXE-2011/mkl"
    "C:/Program Files/Intel/Composer XE 2013/mkl"
    "C:/Program Files (x86)/Intel/Composer XE 2015/mkl/"
    "C:/Program Files/Intel/Composer XE 2015/mkl/"
    "C:/Program Files (x86)/IntelSWTools/compilers_and_libraries/windows/mkl/"
)

# get the MKL ROOT
find_path(MKL_ROOT_DIR NAMES include/mkl_cblas.h PATHS ${MKL_POSSIBLE_LOCATIONS})
# from symlinks to real paths
get_filename_component(MKL_ROOT_DIR ${MKL_ROOT_DIR} REALPATH)

if (NOT MKL_ROOT_DIR)
    if (MKL_FIND_REQUIRED)
        MESSAGE(FATAL_ERROR "Could not find MKL: please provide MKL_DIR or environment {MKLDIR}")
    else()
        unset(MKL_ROOT_DIR CACHE)
    endif()
else()
    set(MKL_INCLUDE_DIR ${MKL_ROOT_DIR}/include)

    # user defined options
    option(MKL_USE_parallel "Use MKL parallel" True)
    option(MKL_USE_sdl "Single Dynamic Library or static/dynamic" False)
    set(MKL_USE_interface "lp64" CACHE STRING "for Intel(R)64 compatible arch: lp64 or for ia32 arch: cdecl or stdcall")

    # set arguments to call the MKL provided tool for linking
	set(COMMANDE ${MKL_ROOT_DIR}/tools/mkl_link_tool)

    if (WIN32)
        set(COMMANDE ${MKL_ROOT_DIR}/tools/mkl_link_tool.exe)
    endif()
    
    # check that the tools exists or quit
    if (NOT EXISTS "${COMMANDE}")
        message(FATAL_ERROR "cannot find MKL tool: ${COMMANDE}")
    endif()

    # first the libs
    list(APPEND COMMANDE  "-libs")

    # possible versions
    # <11.3|11.2|11.1|11.0|10.3|10.2|10.1|10.0|ParallelStudioXE2016|ParallelStudioXE2015|ComposerXE2013SP1|ComposerXE2013|ComposerXE2011|CompilerPro>

    # not older than MKL 10 (2011)
    if (MKL_INCLUDE_DIR MATCHES "Composer.*2013")
        list(APPEND COMMANDE  "--mkl=ComposerXE2013")
    elseif (MKL_INCLUDE_DIR MATCHES "Composer.*2011")
        list(APPEND COMMANDE  "--mkl=ComposerXE2011")
    elseif (MKL_INCLUDE_DIR MATCHES "10.3")
        list(APPEND COMMANDE  "--mkl=10.3")
    elseif(MKL_INCLUDE_DIR MATCHES "2013") # version 11 ...
        list(APPEND COMMANDE  "--mkl=11.1")
    elseif(MKL_INCLUDE_DIR MATCHES "2015")
        list(APPEND COMMANDE  "--mkl=11.2")
    elseif(MKL_INCLUDE_DIR MATCHES "2016")
        list(APPEND COMMANDE  "--mkl=11.3")
    elseif(MKL_INCLUDE_DIR MATCHES "2017")
        list(APPEND COMMANDE  "--mkl=11.3")
    elseif (MKL_INCLUDE_DIR MATCHES "10")
        list(APPEND COMMANDE  "--mkl=10.2")
    else()
        list(APPEND COMMANDE "--mkl=11.3")
    endif()

    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        list(APPEND COMMANDE "--compiler=clang")
	elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel")
		list(APPEND COMMANDE "--compiler=intel_c")
	elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
		list(APPEND COMMANDE "--compiler=ms_c")
	else()
		list(APPEND COMMANDE "--compiler=gnu_c")
    endif()

    if (APPLE)
        list(APPEND COMMANDE "--os=mac")
    elseif(WIN32)
        list(APPEND COMMANDE "--os=win")
    else()
        list(APPEND COMMANDE "--os=lnx")
    endif()

	set(MKL_LIB_DIR)
    if (${CMAKE_SIZEOF_VOID_P} EQUAL 8 AND NOT FORCE_BUILD_32BITS)
        list(APPEND COMMANDE "--arch=intel64")
		set(MKL_LIB_DIR "intel64")
    else()
        list(APPEND COMMANDE "--arch=ia-32")
		set(MKL_LIB_DIR "ia32")
    endif()

    if (MKL_USE_sdl)
        list(APPEND COMMANDE "--linking=sdl")
    else()
        if (NOT BUILD_SHARED_LIBS)
            list(APPEND COMMANDE "--linking=static")
        else()
            list(APPEND COMMANDE "--linking=dynamic")
        endif()
    endif()

    if (MKL_USE_parallel)
        list(APPEND COMMANDE "--parallel=yes")
    else()
        list(APPEND COMMANDE "--parallel=no")
    endif()

    if (FORCE_BUILD_32BITS)
        list(APPEND COMMANDE "--interface=cdecl")
        set(MKL_USE_interface "cdecl" CACHE STRING "disabled by FORCE_BUILD_32BITS" FORCE)
    else()
        list(APPEND COMMANDE "--interface=${MKL_USE_interface}")
    endif()

    if (MKL_USE_parallel)
        if (USE_OMP)
            list(APPEND COMMANDE "--openmp=gomp")
        else()
            list(APPEND COMMANDE "--threading-library=iomp5")
            list(APPEND COMMANDE "--openmp=iomp5")
        endif()
    endif()

    execute_process(COMMAND ${COMMANDE} OUTPUT_VARIABLE RESULT_LIBS TIMEOUT 2 RESULT_VARIABLE COMMAND_WORKED)

    set(MKL_LIBRARIES)

    MESSAGE("--------------- ${COMMAND_WORKED} : RESULT_LIBS ${RESULT_LIBS}")

    if (NOT ${COMMAND_WORKED} EQUAL 0)
        MESSAGE(FATAL_ERROR "Cannot find the MKL libraries correctly. Please check your MKL input variables and mkl_link_tool. The command executed was:\n ${COMMANDE}.")
    endif()

    if (WIN32)
        # remove unwanted break
        string(REGEX REPLACE "\n" "" RESULT_LIBS ${RESULT_LIBS})

        # get the list of libs
        separate_arguments(RESULT_LIBS)
        foreach(i ${RESULT_LIBS})
            message("i=${i}")
            find_library(FULLPATH_LIB ${i} PATHS "${MKL_ROOT_DIR}/lib/${MKL_LIB_DIR}/" "${MKL_ROOT_DIR}/../compiler/lib/${MKL_LIB_DIR}")

            if (FULLPATH_LIB)
                list(APPEND MKL_LIBRARIES ${FULLPATH_LIB})
            elseif(i)
                list(APPEND MKL_LIBRARIES ${i})
            endif()
            unset(FULLPATH_LIB CACHE)
        endforeach()

    else() # UNIX and macOS
        # remove unwanted break
		string(REGEX REPLACE "\n" "" RESULT_LIBS ${RESULT_LIBS}) 

        if (COMMANDE MATCHES "static")
            string(REPLACE "$(MKLROOT)" "${MKL_ROOT_DIR}" MKL_LIBRARIES ${RESULT_LIBS})
            # hack for lin with libiomp5.a
            string(REPLACE "-liomp5" "${MKL_ROOT_DIR}/../compiler/lib/${MKL_LIB_DIR}/libiomp5.a" MKL_LIBRARIES ${MKL_LIBRARIES})
            separate_arguments(MKL_LIBRARIES)
            message("--STATIC--> ${MKL_LIBRARIES}")

        else() # dynamic or sdl
            # get the lib dirs
            message("--DYN---> : ${RESULT_LIBS}")
            string(REGEX REPLACE "^.*-L[^/]+([^\ ]+).*" "${MKL_ROOT_DIR}\\1" INTEL_LIB_DIR ${RESULT_LIBS})

            # get the list of libs
            separate_arguments(RESULT_LIBS)

            # set full path to libs
            foreach(i ${RESULT_LIBS})
                string(REGEX REPLACE " -" "-" i ${i})
                string(REGEX REPLACE "-l([^\ ]+)" "\\1" i ${i})
                string(REGEX REPLACE "-L.*" "" i ${i})

                find_library(FULLPATH_LIB ${i} PATHS ${INTEL_LIB_DIR} "${MKL_ROOT_DIR}/../compiler/lib/${MKL_LIB_DIR}")

                if (FULLPATH_LIB)
                    list(APPEND MKL_LIBRARIES ${FULLPATH_LIB})
                elseif(i)
                    list(APPEND MKL_LIBRARIES ${i})
                endif()
                unset(FULLPATH_LIB CACHE)
                message("----> ${i} : ${FULLPATH_LIB}")
            endforeach()

        endif()

		# now definitions
		string(REPLACE "-libs" "-opts" COMMANDE "${COMMANDE}")
		execute_process(COMMAND ${COMMANDE} OUTPUT_VARIABLE RESULT_OPTS TIMEOUT 2)
		string(REGEX REPLACE "\ -I[^\ ]+" "" RESULT_OPTS ${RESULT_OPTS})
		string(REGEX REPLACE "^\ " "" RESULT_OPTS ${RESULT_OPTS})
    endif()

    message("..........COMMANDE =.......${COMMANDE}......................MKL_LIBRARIES.${MKL_LIBRARIES}.............................RESULT_OPTS ${RESULT_OPTS}.")
    message(".....................MKL_CXX_FLAGS = ..${MKL_CXX_FLAGS}. \n.MKL_LIBRARIES..${MKL_LIBRARIES}.\nTMP_VAR............................. ${RESULT_LIBS}.")

    add_definitions(${RESULT_OPTS})

    message("..enfin..........COMMANDE =.......${COMMANDE}...................RESULT_OPTS ${RESULT_OPTS}.")

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(MKL DEFAULT_MSG MKL_INCLUDE_DIR MKL_LIBRARIES)

    mark_as_advanced(MKL_CORE_LIBRARY MKL_LP_LIBRARY MKL_ILP_LIBRARY
        MKL_SEQUENTIAL_LIBRARY MKL_INTELTHREAD_LIBRARY MKL_GNUTHREAD_LIBRARY MKL_INCLUDE_DIR
        MKL_LIBRARIES)
endif()
