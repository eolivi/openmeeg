#------------------------------------------------------------
# VTK library
#------------------------------------------------------------

option(USE_VTK "Use VTK" OFF)

if (USE_VTK)
    find_package(VTK COMPONENTS vtkIOXML vtkIOLegacy NO_MODULE)
    if (VTK_FOUND)
        if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            add_compile_options(-Wno-inconsistent-missing-override)
        endif()
        if (NOT VTK_LIBRARY_DIRS)
            # hack because else it is not defined
            set(VTK_LIBRARY_DIRS ${VTK_DIR}/../..)
        endif()
        list(APPEND OpenMEEG_OTHER_LIBRARY_DIRS ${VTK_LIBRARY_DIRS})
        list(APPEND OpenMEEG_OTHER_INCLUDE_DIRS ${VTK_INCLUDE_DIRS})
        list(APPEND OpenMEEG_DEPENDENCIES VTK)
    else()
        message(FATAL_ERROR "Please set VTK_DIR")
    endif()
endif()
