#------------------------------------------------------------
# GIFTI C library
#------------------------------------------------------------

option(USE_GIFTI "Use GIFTI IO support" OFF)
mark_as_advanced(USE_GIFTI)

if (USE_GIFTI)
    find_package(EXPAT)
    find_package(ZLIB)
    find_library(NIFTI_LIBRARY niftiio)
    find_library(GIFTI_LIBRARIES giftiio)
    find_library(ZNZ_LIBRARY znz)
    set(NIFTI_LIBRARIES ${EXPAT_LIBRARIES} ${ZLIB_LIBRARIES} ${NIFTI_LIBRARY} ${ZNZ_LIBRARY} m)
    find_path(GIFTI_INCLUDE_PATH gifti_io.h PATHS /usr/include/gifti /usr/local/include/gifti)
    find_path(NIFTI_INCLUDE_PATH nifti1_io.h PATHS /usr/include/nifti /usr/local/include/nifti)
    set(GIFTI_INCLUDE_DIRS ${GIFTI_INCLUDE_PATH} ${NIFTI_INCLUDE_PATH})
    list(APPEND OpenMEEG_OTHER_INCLUDE_DIRS ${GIFTI_INCLUDE_DIRS})
    list(APPEND GIFTI_LIBRARIES ${NIFTI_LIBRARIES})
endif()
