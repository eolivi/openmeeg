#------------------------------------------------------------
# Atlas library
#------------------------------------------------------------

if (USE_ATLAS)
    find_package(Atlas ${FIND_MODE} MODULE)
    if (Atlas_FOUND)
        include_directories(${Atlas_INCLUDE_DIR})
        set(LAPACK_LIBRARIES ${Atlas_LIBRARIES})
        # set the found BLASLAPACK_IMPLEMENTATION (in case it was Auto)
        set(BLASLAPACK_IMPLEMENTATION "Atlas" CACHE STRING "${BLASLAPACK_IMPLEMENTATION_DOCSTRING}" FORCE)
        list(APPEND OpenMEEG_DEPENDENCIES Atlas)
    endif()
endif()
