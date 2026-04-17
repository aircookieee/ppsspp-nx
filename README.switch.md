# Nintendo Switch Port of PPSSPP

This repository provides support for running PPSSPP on the Nintendo Switch. The port utilizes libnx and OpenGL ES 3.0 for core emulation.

## Technical Changes and Implementation

The following modifications were implemented to enable a functional and stable experience on Horizon OS:

### Build System and Toolchain
- Integrated a custom CMake toolchain for devkitA64 and libnx.
- Configured dedicated build scripts (build_switch.bat) and environment setup utilities.
- Resolved architecture-specific linking requirements for FFmpeg, including explicit dependencies for libbz2 and dav1d.

### Filesystem and VFS
- Implemented explicit hardware mounting for SDMC and RomFS at the application level.
- Corrected the Virtual File System (VFS) mapping to resolve dual-pathing issues.
- Established primary application directory structure at sdmc:/switch/ppsspp/.

### Graphics Backend (OpenGL ES 3.0)
- Configured native GLES3 header inclusion for the Switch platform.
- Disabled unstable OpenGL extensions reported by the driver that caused system-wide crashes, including:
    - ARB_buffer_storage and EXT_buffer_storage (invalid memory mapping prevention).
    - Dual Source Blending (ARB_blend_func_extended).
    - Copy Image extensions (OES_copy_image, NV_copy_image, etc.).
- Bypassed the gl3stub initialization in favor of static linking against libGLESv2 provided by the portlibs.

### Platform Stability
- Added native Switch socket initialization and diagnostic logging through nxlink.
- Resolved ambiguous template deductions in the core engine caused by LP64 architecture differences.
- Patched external dependencies such as glslang and ImGui to support the Switch's unique environment.

## Usage and Asset Placement

To ensure the user interface displays correctly, assets must be placed in the following directory:

`sdmc:/switch/ppsspp/assets/`

Failure to provide the assets folder at this location will result in missing text, icons, and background images.

## JIT Support
- Full ARM64 JIT support is enabled and functioning within the Switch homebrew environment.

## Disclosure
This Switch port was developed with the assistance of Antigravity, an AI coding assistant from Google DeepMind.
