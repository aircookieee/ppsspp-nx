@echo off
REM ============================================================================
REM  PPSSPP Nintendo Switch Homebrew Build Script (Windows / devkitPro)
REM ============================================================================
REM  Prerequisites:
REM    - devkitPro with devkitA64, libnx, switch-sdl2 installed
REM    - CMake 3.16+ on PATH
REM    - Ninja or Make on PATH (Ninja recommended - ships with devkitPro)
REM ============================================================================

setlocal EnableDelayedExpansion

REM --- Locate devkitPro ---
if defined DEVKITPRO (
    echo [INFO] Using DEVKITPRO from environment: %DEVKITPRO%
) else if exist "C:\devkitPro" (
    set "DEVKITPRO=C:\devkitPro"
    echo [INFO] Using devkitPro at C:\devkitPro
) else (
    echo [ERROR] devkitPro not found. Set DEVKITPRO environment variable.
    exit /b 1
)

REM --- Add devkitPro tools to PATH ---
set "PATH=%DEVKITPRO%\devkitA64\bin;%DEVKITPRO%\tools\bin;%DEVKITPRO%\portlibs\switch\bin;%DEVKITPRO%\msys2\usr\bin;%PATH%"

REM --- Verify compiler ---
where aarch64-none-elf-gcc >nul 2>&1
if errorlevel 1 (
    echo [ERROR] aarch64-none-elf-gcc not found. Check devkitA64 installation.
    exit /b 1
)
echo [INFO] Compiler found: 
aarch64-none-elf-gcc --version 2>&1 | findstr /R "^aarch64"

REM --- Verify switch tools ---
where elf2nro >nul 2>&1
if errorlevel 1 (
    echo [ERROR] elf2nro not found. Install switch-tools via dkp-pacman.
    exit /b 1
)
echo [INFO] elf2nro found

REM --- Parse arguments ---
set "BUILD_TYPE=Release"
set "GENERATOR=Ninja"
set "BUILD_DIR=build_switch"
set "CLEAN=0"

:parse_args
if "%~1"=="" goto done_args
if /i "%~1"=="debug" set "BUILD_TYPE=Debug"
if /i "%~1"=="release" set "BUILD_TYPE=Release"
if /i "%~1"=="relwithdebinfo" set "BUILD_TYPE=RelWithDebInfo"
if /i "%~1"=="clean" set "CLEAN=1"
if /i "%~1"=="--makefiles" set "GENERATOR=Unix Makefiles"
shift
goto parse_args
:done_args

echo.
echo ============================================================================
echo  PPSSPP Switch Build Configuration
echo  Build Type:  %BUILD_TYPE%
echo  Generator:   %GENERATOR%
echo  Build Dir:   %BUILD_DIR%
echo  DEVKITPRO:   %DEVKITPRO%
echo ============================================================================
echo.

REM --- Clean if requested ---
if "%CLEAN%"=="1" (
    echo [INFO] Cleaning build directory...
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
)

REM --- Create build directory ---
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

REM --- Configure with CMake ---
echo [INFO] Configuring CMake...
cmake -S . -B "%BUILD_DIR%" ^
    -G "%GENERATOR%" ^
    -DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/switch.cmake ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    -DUSE_LIBNX=ON ^
    -DUSE_FFMPEG=ON ^
    -DUSE_DISCORD=OFF ^
    -DUSE_MINIUPNPC=OFF

if errorlevel 1 (
    echo.
    echo [ERROR] CMake configuration failed!
    exit /b 1
)

REM --- Build ---
echo.
echo [INFO] Building PPSSPP for Nintendo Switch...
cmake --build "%BUILD_DIR%" --parallel

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed!
    exit /b 1
)

echo.
echo ============================================================================
echo  Build completed successfully!
echo ============================================================================

REM --- Check for output files ---
if exist "%BUILD_DIR%\PPSSPPSDL.nro" (
    echo  NRO file: %BUILD_DIR%\PPSSPPSDL.nro
) else if exist "%BUILD_DIR%\PPSSPPSDL.elf" (
    echo  ELF file: %BUILD_DIR%\PPSSPPSDL.elf
    echo  [INFO] NRO not generated automatically. Converting manually...
    
    REM Manual conversion
    nacptool --create "PPSSPP" "PPSSPP Team" "1.18.1" "%BUILD_DIR%\ppsspp.nacp"
    elf2nro "%BUILD_DIR%\PPSSPPSDL.elf" "%BUILD_DIR%\PPSSPPSDL.nro" --nacp="%BUILD_DIR%\ppsspp.nacp"
    
    if exist "%BUILD_DIR%\PPSSPPSDL.nro" (
        echo  NRO file: %BUILD_DIR%\PPSSPPSDL.nro
    ) else (
        echo  [WARNING] Failed to create NRO file
    )
)

echo.
echo  To install on Nintendo Switch:
echo    1. Copy %BUILD_DIR%\PPSSPPSDL.nro to SD:\switch\ppsspp\PPSSPPSDL.nro
echo    2. Copy the assets\ folder to SD:\switch\ppsspp\assets\
echo    3. Launch from Homebrew Menu (hbmenu)
echo ============================================================================

endlocal
