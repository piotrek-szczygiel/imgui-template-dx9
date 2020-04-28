@echo off

set root=%~dp0

if not "%WindowsSdkDir%" == "" goto :build

for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -property installationPath`) do (
    if exist "%%i" (
        set vcvarsall=%%i\VC\Auxiliary\Build\vcvarsall.bat
    )
)

echo %vcvarsall%

if "%vcvarsall%" == "" (
    echo Unable to find Visual Studio installation
    exit /b 1
)

call "%vcvarsall%" x64

:build
if not exist %root%\build mkdir %root%\build
pushd %root%\build

del *.pdb > NUL 2> NUL

set cl_flags=/nologo /WL /W4 /diagnostics:column /FC 
set cl_flags=%cl_flags% /D UNICODE /D _UNICODE /I%root%\imgui /I "%WindowsSdkDir%Include\um" /I "%WindowsSdkDir%Include\shared" /Fefinder
set ld_flags=/incremental:no d3d12.lib d3dcompiler.lib dxgi.lib

if "%1" == "release" (
    set cl_flags=%cl_flags% /O2 /Gm- /GR- /EHs-c- /fp:fast /fp:except-
    set ld_flags=%ld_flags% /opt:ref
) else (
    set cl_flags=%cl_flags% /Z7
)

cl %cl_flags%  %root%\*.cpp %root%\imgui\*.cpp /link %ld_flags%

popd
