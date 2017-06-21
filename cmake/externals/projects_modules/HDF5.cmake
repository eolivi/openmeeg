# OpenMEEG
#
# Copyright (c) INRIA 2013-2017. All rights reserved.
# See LICENSE.txt for details.
# 
#  This software is distributed WITHOUT ANY WARRANTY; without even
#  the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#  PURPOSE.

macro(hdf5_find_package)
#   Do nothing let OpenMEEG do the work.
endmacro()

function(hdf5_project)

    # Prepare the project and list dependencies

    EP_Initialisation(HDF5 BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
    EP_SetDependencies(${ep}_dependencies ${MSINTTYPES} ZLIB)

    # Define repository where get the sources

    if (NOT DEFINED ${ep}_SOURCE_DIR)
        # set(location GIT_REPOSITORY "${GIT_PREFIX}github.com/openmeeg/hdf5-matio.git")
        # set(location GIT_REPOSITORY "${GIT_PREFIX}github.com/live-clones/hdf5.git" GIT_TAG master)
        set(location
            URL "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.17/src/hdf5-1.8.17.tar.bz2"
            URL_MD5 "34bd1afa5209259201a41964100d6203")
    endif()

    # set compilation flags

    if (UNIX)
        set(${ep}_c_flags "${${ep}_c_flags} -w")
    endif()

    set(cmake_args
        ${ep_common_cache_args}
        ${ep_optional_args}
        -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON
        ${ZLIB_CMAKE_FLAGS}
        -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
        -DCMAKE_C_FLAGS:STRING=${${ep}_c_flags}
        -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
        -DCMAKE_SHARED_LINKER_FLAGS:STRING=${${ep}_shared_linker_flags}  
        -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS_${ep}}
        -DHDF5_INSTALL_LIB_DIR:STRING=${INSTALL_LIB_DIR}
        -DBUILD_TESTING:BOOL=OFF
    )

    # Check if patch has to be applied

    #ep_GeneratePatchCommand(${ep} PATCH_COMMAND hdf5-config.patch)
    ep_GeneratePatchCommand(${ep} PATCH_COMMAND)

    # Add external-project

    ExternalProject_Add(${ep}
        ${ep_dirs}
        ${location}
        ${PATCH_COMMAND}
        CMAKE_GENERATOR ${gen}
        CMAKE_ARGS ${cmake_args}
        DEPENDS ${${ep}_dependencies}
    )

    # Set variable to provide infos about the project

    ExternalProject_Get_Property(${ep} install_dir)
    if (NOT WIN32)
        set(${ep}_CMAKE_INSTALL_DIR share/cmake)
    endif()
    set(${ep}_CMAKE_FLAGS -D${ep}_DIR:FILEPATH=${install_dir}/${${ep}_CMAKE_INSTALL_DIR} PARENT_SCOPE)

    # Add custom targets

    EP_AddCustomTargets(${ep})

endfunction()