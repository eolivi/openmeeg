#------------------------------------------------------------
# ACML library
#------------------------------------------------------------

if (USE_ACML)
    set(ACML_LIB_SEARCH_PATHS
        /lib/
        /lib64/
        /usr/lib
        /usr/lib64
        /usr/local/lib
        /usr/local/lib64
        ${ACML_DIR}/lib
        $ENV{ACML_DIR}/lib
        )

    find_package(ACML ${FIND_MODE} MODULE)
    find_library(Lapacke_LIB NAMES lapacke PATHS ${ACML_LIB_SEARCH_PATHS})
    find_library(cblas_LIB NAMES cblas PATHS ${ACML_LIB_SEARCH_PATHS})
    message("--------------------------------- ${Lapacke_LIB} ")

    if (ACML_FOUND AND Lapacke_LIB)
        include_directories(${ACML_INCLUDE_DIR})
        message("---------------------------------${ACML_INCLUDE_DIR} ")
        set(LAPACK_LIBRARIES ${ACML_LIBRARIES} ${Lapacke_LIB} ${cblas_LIB})
        message("---------------------------------${LAPACK_LIBRARIES} ")
        list(APPEND OpenMEEG_DEPENDENCIES ACML)
    elseif(${FIND_MODE} STREQUAL "REQUIRED")
        message(FATAL_ERROR "Could not find ACML")
    endif()
endif()
