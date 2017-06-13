
set(ACML_LIB_SEARCHPATH
    /usr/lib64/acml/sse3 /usr/lib/acml/sse3 /usr/lib/sse3
    /usr/lib64/acml/sse2 /usr/lib/acml/sse2 /usr/lib/sse2
    /usr/lib64/acml /usr/lib/acml /usr/lib/acml-base /usr/lib64/acml-base
    /usr/lib64/ /usr/lib/ ${ACML_DIR}/lib)

macro(find_acml_lib)
    foreach (LIB ${ARGN})
        message("Searching: ${LIB}")
        set(LIBNAMES ${LIB})
        find_library(${LIB}_PATH
            NAMES ${LIBNAMES}
            PATHS ${ACML_LIB_SEARCHPATH})
        if (${LIB}_PATH)
            get_filename_component(LAPACK_ROOT_DIR ${${LIB}_PATH} DIRECTORY)
            set(ACML_LIBRARIES ${ACML_LIBRARIES} ${${LIB}_PATH})
            mark_as_advanced(${LIB}_PATH)
            break()
        endif()
    endforeach()
endmacro()

set(CMAKE_FIND_DEBUG_MODE 1)

find_path(ACML_INCLUDE_DIR acml.h PATHS /usr/include ${ACML_DIR} PATH_SUFFIXES include)

find_acml_lib(acml)

if(ACML_LIBRARIES AND ACML_INCLUDE_DIR)
    set(ACML_FOUND true)
    mark_as_advanced(ACML_INCLUDE_DIR)
else()
    unset(ACML_INCLUDE_DIR CACHE)
endif()
