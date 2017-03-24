#-----------------------------------------------
# packaging
#-----------------------------------------------

option(ENABLE_PACKAGING "Enable Packaging" ON)

if (ENABLE_PACKAGING)
    set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/packaging ${CMAKE_MODULE_PATH})

    set(CPACK_PACKAGE_NAME "OpenMEEG")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "OpenMEEG Project")
    set(CPACK_PACKAGE_VENDOR "INRIA-ENPC")
    set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
    set(CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_SOURCE_DIR}/README.rst")
    set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE.txt")
    set(CPACK_PACKAGE_CONTACT "openmeeg-info@lists.gforge.inria.fr")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "OpenMEEG")
    set(CPACK_SOURCE_STRIP_FILES "")

    if (UNIX)
        set(CPACK_SET_DESTDIR true)
        set(CPACK_INSTALL_PREFIX "Packaging")
        set(SYSTEMDIR linux)
        if (APPLE)
            set(SYSTEMDIR apple)
        endif()
    else()
        set(CPACK_SET_DESTDIR false)
        set(CPACK_INSTALL_PREFIX "")
        set(SYSTEMDIR windows)
    endif()
    include(${SYSTEMDIR}/PackagingConfiguration)

    set(PACKAGE_OPTIONS ${BLASLAPACK_IMPLEMENATION})

    if (USE_OMP)
        set(PACKAGE_OPTIONS ${PACKAGE_NAME}-OpenMP)
    endif()

    if (USE_VTK)
        set(PACKAGE_OPTIONS ${PACKAGE_NAME}-vtk)
    endif()

    if (ENABLE_PYTHON)
        set(PACKAGE_OPTIONS ${PACKAGE_OPTIONS}-python)
    endif()

    set(PACKAGE_OPTIONS ${PACKAGE_OPTIONS}-${BLASLAPACK_IMPLEMENTATION})

    if (BUILD_SHARED_LIBS)
        set(PACKAGE_OPTIONS ${PACKAGE_OPTIONS}-shared)
    else()
        set(PACKAGE_OPTIONS ${PACKAGE_OPTIONS}-static)
    endif()

    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${PACKAGE_ARCH_SHORT}${PACKAGE_OPTIONS}")

    include(InstallRequiredSystemLibraries)
    include(CPack)

endif()
