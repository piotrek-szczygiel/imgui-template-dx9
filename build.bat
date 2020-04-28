@echo off

set root=%~dp0

if /i "%1" == "clean" (
    if exist "%root%\build" rd /s /q %root%\build
    exit /b
)

where /q cl
if errorlevel 0 goto :build

for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -property installationPath`) do (
    if exist "%%i" (
        set vcvarsall=%%i\VC\Auxiliary\Build\vcvarsall.bat
    )
)

if "%vcvarsall%" == "" (
    echo Unable to find Visual Studio installation
    exit /b 1
)

call "%vcvarsall%" x64

:build
if not exist "%root%\build" mkdir "%root%\build"
pushd "%root%\build"

del *.pdb > NUL 2> NUL

set cl_flags=/nologo /WL /W4 /diagnostics:column /FC /D UNICODE /D _UNICODE /I"%root%\imgui" /Fe:finder.exe
set ld_flags=/incremental:no d3d9.lib

if /i "%1" == "release" (
    set cl_flags=%cl_flags% /O2 /MT /Gm- /GR- /EHs-c- /fp:fast /fp:except-
    set ld_flags=%ld_flags% /opt:ref /subsystem:windows
) else (
    set cl_flags=%cl_flags% /Z7 /MTd
)

cl "%root%\*.cpp" "%root%\imgui\*.cpp" %cl_flags% /link %ld_flags%

popd
