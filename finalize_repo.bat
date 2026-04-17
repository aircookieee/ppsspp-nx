@echo off
setlocal

echo Committing inside submodules...

:: Handle aemu_postoffice
if exist "ext\aemu_postoffice" (
    cd ext\aemu_postoffice
    git add .
    git commit -m "Switch: Adapt socket headers and implementations"
    cd ..\..
)

:: Handle glslang
if exist "ext\glslang" (
    cd ext\glslang
    git add .
    git commit -m "Switch: Enable OSDependent/Unix for Switch target"
    cd ..\..
)

echo Staging main repository changes...
:: Using -A to commit everything as requested, including bloat/environmental changes
git add -A

echo Creating final commit...
git commit -m "Add Nintendo Switch support (GLES3, libnx)"

echo.
echo Done! You can now 'git push' to your fork.
pause
