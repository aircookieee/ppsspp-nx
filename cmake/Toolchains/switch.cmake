# CMake toolchain file for Nintendo Switch (devkitPro / libnx)
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/switch.cmake ..
#
# This wraps devkitPro's official Switch.cmake toolchain and sets PPSSPP-specific
# options to enable the existing Switch code paths in the codebase.

# Locate devkitPro - check environment variable, then common paths
if(NOT DEFINED ENV{DEVKITPRO} AND NOT DEVKITPRO)
    # Try common installation paths
    if(EXISTS "C:/devkitPro")
        set(ENV{DEVKITPRO} "C:/devkitPro")
    elseif(EXISTS "/opt/devkitpro")
        set(ENV{DEVKITPRO} "/opt/devkitpro")
    else()
        message(FATAL_ERROR
            "DEVKITPRO environment variable not set and devkitPro not found in standard locations.\n"
            "Please set DEVKITPRO to your devkitPro installation path.\n"
            "  Windows: set DEVKITPRO=C:\\devkitPro\n"
            "  Linux:   export DEVKITPRO=/opt/devkitpro"
        )
    endif()
endif()

if(NOT DEVKITPRO)
    set(DEVKITPRO $ENV{DEVKITPRO})
endif()

# Validate installation
if(NOT EXISTS "${DEVKITPRO}/devkitA64")
    message(FATAL_ERROR "devkitA64 not found at ${DEVKITPRO}/devkitA64. Install it via dkp-pacman.")
endif()
if(NOT EXISTS "${DEVKITPRO}/libnx")
    message(FATAL_ERROR "libnx not found at ${DEVKITPRO}/libnx. Install it via dkp-pacman.")
endif()

# Add devkitPro cmake modules to path so NintendoSwitch.cmake platform file is found
list(APPEND CMAKE_MODULE_PATH "${DEVKITPRO}/cmake")

# Include the official devkitPro Switch toolchain
# This sets:
#   CMAKE_SYSTEM_NAME = NintendoSwitch
#   CMAKE_SYSTEM_PROCESSOR = aarch64
#   CMAKE_C/CXX_COMPILER = aarch64-none-elf-gcc/g++
#   All the nx_create_nro(), nx_generate_nacp() functions
#   NX_ARCH_SETTINGS, NX_COMMON_FLAGS, NX_LINKER_FLAGS, etc.
include("${DEVKITPRO}/cmake/Switch.cmake")

# ---- PPSSPP-specific settings ----

# Enable the Switch code paths throughout PPSSPP
set(USE_LIBNX ON CACHE BOOL "Building for Switch (libnx)" FORCE)

# Force the correct CPU target
set(FORCED_CPU "aarch64" CACHE STRING "" FORCE)
