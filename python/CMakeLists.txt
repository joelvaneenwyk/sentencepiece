set(PY_VERSION_SUFFIX "")
set(PY_FULL_VERSION ${PROJECT_VERSION}${PY_VERSION_SUFFIX})
set(Py_LIMITED_API 0x03070000 CACHE STRING
    "CPython stable ABI version. Should match abi3_minimum_cpython_version")

# Make sure that the Python and CMake versions match
if (DEFINED PY_BUILD_CMAKE_PROJECT_VERSION)
    if (NOT "${PY_BUILD_CMAKE_PROJECT_VERSION}" MATCHES "^${PY_FULL_VERSION}$")
        message(FATAL_ERROR "Version number does not match "
                             "(${PY_BUILD_CMAKE_PROJECT_VERSION} - ${PY_FULL_VERSION}).")
    endif()
endif()

# Find Python
if (CMAKE_CROSSCOMPILING AND NOT (APPLE AND "$ENV{CIBUILDWHEEL}" STREQUAL "1"))
    find_package(Python 3.8 REQUIRED COMPONENTS Development.Module
                                     OPTIONAL_COMPONENTS Development.SABIModule)
else()
    find_package(Python 3.8 REQUIRED COMPONENTS Interpreter Development.Module
                                     OPTIONAL_COMPONENTS Development.SABIModule)
endif()

# Function to fix the Python SOABI extension suffix for the generated module
function(configure_python_soabi target abi)
    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
        set_property (TARGET ${target} PROPERTY SUFFIX ".pyd")
    endif()
    if (abi)
        get_property (suffix TARGET ${target} PROPERTY SUFFIX)
        if (NOT suffix)
            set (suffix "${CMAKE_SHARED_MODULE_SUFFIX}")
        endif()
        set_property (TARGET ${target} PROPERTY SUFFIX ".${abi}${suffix}")
    endif()
endfunction()

# Find the SWIG package to generate Python bindings
include(../cmake/swig.cmake)
find_swig_python_first()
set(UseSWIG_MODULE_VERSION 2)
include(UseSWIG)

# Create a SWIG module with Python bindings for sentencepiece.cpp
set_source_files_properties("src/ext/sentencepiece.i" PROPERTIES CPLUSPLUS ON)
swig_add_library(sentencepiece TYPE MODULE LANGUAGE python
    SOURCES "src/sentenceppiece/sentencepience.i" "src/sentencepiece_wrap.cxx")
set_target_properties(sentencepiece PROPERTIES
    SWIG_USE_TARGET_INCLUDE_DIRECTORIES TRUE
    SWIG_COMPILE_OPTIONS "-Wall")
target_compile_definitions(sentencepiece PRIVATE VERSION_INFO="${PY_FULL_VERSION}")

# Link to the correct Python library and configure the appropriate ABI
if (Python_INTERPRETER_ID STREQUAL "Python")
    if (NOT TARGET Python::SABIModule)
        message(SEND_ERROR "CPython requires component Development.SABIModule")
    endif()
    message(STATUS "Using CPython stable ABI (${Py_LIMITED_API} - ${Python_SOSABI})")
    set_target_properties(sentencepiece PROPERTIES
        SWIG_COMPILE_DEFINITIONS Py_LIMITED_API=${Py_LIMITED_API})
    target_compile_definitions(sentencepiece PRIVATE Py_LIMITED_API=${Py_LIMITED_API})
    target_link_libraries(sentencepiece PRIVATE Python::SABIModule)
    configure_python_soabi(sentencepiece "${Python_SOSABI}")
else()
    message(STATUS "Using default ABI (${Python_SOABI})")
    target_link_libraries(sentencepiece PRIVATE Python::Module)
    configure_python_soabi(sentencepiece "${Python_SOABI}")
endif()

# Hide all symbols by default (including external libraries on Linux)
set_target_properties(sentencepiece PROPERTIES
    CXX_VISIBILITY_PRESET "hidden"
    VISIBILITY_INLINES_HIDDEN true)
if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    target_link_options(sentencepiece PRIVATE "LINKER:--exclude-libs,ALL")
endif()

# Install the Python module
install(TARGETS sentencepiece
        EXCLUDE_FROM_ALL
        COMPONENT python_modules
        DESTINATION ${PY_BUILD_CMAKE_IMPORT_NAME})
install(FILES $<TARGET_PROPERTY:sentencepiece,SWIG_SUPPORT_FILES>
        EXCLUDE_FROM_ALL
        COMPONENT python_modules
        DESTINATION ${PY_BUILD_CMAKE_IMPORT_NAME})
