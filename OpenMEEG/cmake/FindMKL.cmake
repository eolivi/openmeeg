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

    set(MKL_LIB_SEARCHPATH $ENV{ICC_LIB_DIR} $ENV{MKL_LIB_DIR} "${MKL_ROOT_DIR}/lib/${MKL_ARCH_DIR}" "${MKL_ROOT_DIR}/../compiler" "${MKL_ROOT_DIR}/../compiler/lib/${MKL_ARCH_DIR}")

    # user defined options
    option(MKL_USE_parallel "Use MKL parallel" True)
    option(MKL_USE_sdl "Single Dynamic Library or static/dynamic" False)
    # option(MKL_USE_ILP64 "Support very large data arrays" False)

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
	elseif(("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel") OR ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC"))
		list(APPEND COMMANDE "--compiler=intel_c")
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

    if (${CMAKE_SIZEOF_VOID_P} EQUAL 8 AND NOT FORCE_BUILD_32BITS)
        list(APPEND COMMANDE "--arch=intel64")
    else()
        list(APPEND COMMANDE "--arch=ia-32")
    endif()

    if (MKL_USE_sdl)
        list(APPEND COMMANDE "--linking=sdl")
        set(MKL_USE_parallel False CACHE BOOL "disabled by MKL_USE_sdl" FORCE)
    else()
        if (NOT BUILD_SHARED_LIBS_OpenMEEG)
            list(APPEND COMMANDE "--linking=static")
        else()
            list(APPEND COMMANDE "--linking=dynamic")
        endif()
        if (MKL_USE_parallel)
            list(APPEND COMMANDE "--parallel=yes")
        else()
            list(APPEND COMMANDE "--parallel=no")
        endif()

        if (FORCE_BUILD_32BITS)
            list(APPEND COMMANDE "--interface=cdecl")
        else()
            #if (MKL_USE_ILP64)
            #    list(APPEND COMMANDE "--interface=ilp64")
            #else()
            list(APPEND COMMANDE "--interface=lp64")
            #endif()
        endif()

        if (MKL_USE_parallel)
            if (USE_OMP)
                list(APPEND COMMANDE "--openmp=gomp")
            else()
                list(APPEND COMMANDE "--threading-library=iomp5")
                list(APPEND COMMANDE "--openmp=iomp5")
            endif()
        endif()
    endif()

    execute_process(COMMAND ${COMMANDE} OUTPUT_VARIABLE TMP_VAR TIMEOUT 2)

    set(MKL_LIBRARIES)

    if (WIN32)
		# remove unwanted break
		string(REGEX REPLACE "\n" "" TMP_VAR ${TMP_VAR})

		# get the list of libs
		set(MKL_CXX_FLAGS)
		separate_arguments(TMP_VAR)
		foreach(i ${TMP_VAR})
		message("i=${i}")
			if (i MATCHES "lib")
				list(APPEND MKL_LIBRARIES ${MKL_ROOT_DIR}/lib/${iA}/${i})
			elseif (i MATCHES "/Q")
				list(APPEND MKL_CXX_FLAGS ${i})
			endif()
		endforeach()
		list(APPEND CMAKE_CXX_FLAGS ${MKL_CXX_FLAGS})
		message(".....................MKL_CXX_FLAGS = ..${MKL_CXX_FLAGS}. \n.......MKL_LIBRARIES..${MKL_LIBRARIES}.\n...........................TMP_VAR ${TMP_VAR}.")

		# now definitions
		STRING(REPLACE "-libs" "-opts" COMMANDE "${COMMANDE}")
		execute_process(COMMAND ${COMMANDE} OUTPUT_VARIABLE TMP_VAR TIMEOUT 2)
		message("..........COMMANDE =.......${COMMANDE}...................................................................TMP_VAR ${TMP_VAR}.")

    else() # UNIX and macOS
		# remove unwanted break
		string(REGEX REPLACE "\n" "" TMP_VAR ${TMP_VAR}) 

        if (COMMANDE MATCHES "static")
            string(REPLACE "$(MKLROOT)" "${MKL_ROOT_DIR}" MKL_LIBRARIES ${TMP_VAR})
            separate_arguments(MKL_LIBRARIES)
            message("--> ${MKL_LIBRARIES}")

        else() # dynamic or sdl

            # get the lib dirs
            message("-----> : ${TMP_VAR}")
            string(REGEX REPLACE "^.*-L[^/]+([^\ ]+).*" "${MKL_ROOT_DIR}\\1" INTEL_LIB_DIR ${TMP_VAR})

            # get the list of libs
            separate_arguments(TMP_VAR)

            # set full path to libs
            foreach(i ${TMP_VAR})
                string(REGEX REPLACE " -" "-" i ${i})
                string(REGEX REPLACE "-l([^\ ]+)" "\\1" i ${i})
                string(REGEX REPLACE "-L.*" "" i ${i})
                if (COMMANDE MATCHES "intel64")
                    find_library(TMP_VAR3 ${i} PATHS ${INTEL_LIB_DIR} "${MKL_ROOT_DIR}/../compiler/lib/intel64")
                else()
                    find_library(TMP_VAR3 ${i} PATHS ${INTEL_LIB_DIR} "${MKL_ROOT_DIR}/../compiler/lib/ia-32")
                endif()
                if (TMP_VAR3)
                    list(APPEND MKL_LIBRARIES ${TMP_VAR3})
                elseif(i)
                    list(APPEND MKL_LIBRARIES ${i})
                endif()
                unset(TMP_VAR3 CACHE)
                message("----> ${i} : ${TMP_VAR3}")
            endforeach()

        endif()

		# now definitions
		string(REPLACE "-libs" "-opts" COMMANDE "${COMMANDE}")
		execute_process(COMMAND ${COMMANDE} OUTPUT_VARIABLE TMP_VAR TIMEOUT 2)
		string(REGEX REPLACE "\ -I.*" "" TMP_VAR ${TMP_VAR})
		string(REGEX REPLACE "^\ " "" TMP_VAR ${TMP_VAR})

		message("..........COMMANDE =.......${COMMANDE}......................MKL_LIBRARIES.${MKL_LIBRARIES}............................................TMP_VAR ${TMP_VAR}.")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
    endif()

    add_definitions(${TMP_VAR})

    message("..enfin..........COMMANDE =.......${COMMANDE}...................TMP_VAR ${TMP_VAR}.")

    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(MKL DEFAULT_MSG MKL_INCLUDE_DIR MKL_LIBRARIES)

    mark_as_advanced(MKL_CORE_LIBRARY MKL_LP_LIBRARY MKL_ILP_LIBRARY
        MKL_SEQUENTIAL_LIBRARY MKL_INTELTHREAD_LIBRARY MKL_GNUTHREAD_LIBRARY MKL_INCLUDE_DIR
        MKL_LIBRARIES)
endif()
