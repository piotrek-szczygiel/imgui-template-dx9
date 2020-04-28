@echo off

set root=%~dp0

if /i "%1" == "clean" (
    if exist "%root%\debug" rd /s /q "%root%\debug"
    if exist "%root%\release" rd /s /q "%root%\release"
    exit /b
)

if /i "%1" == "fmt" (
    pushd "%root%\src"
    clang-format -i *.cpp *.h
    popd
    exit /b
)

if not "%VisualStudioVersion%" == "" goto :build

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
set cl_flags=/nologo /WL /W4 /diagnostics:column /FC /D UNICODE /D _UNICODE /I"%root%\imgui" /Fe:program.exe
set ld_flags=/incremental:no d3d9.lib

if /i "%1" == "release" (
    set build=%root%\release
    set cl_flags=%cl_flags% /O2 /MT /Gm- /GR- /EHs-c- /fp:fast /fp:except-
    set ld_flags=%ld_flags% /opt:ref /subsystem:windows
) else (
    set build=%root%\debug
    set cl_flags=%cl_flags% /Z7 /MTd
)

if not exist "%build%" mkdir "%build%"
pushd "%build%"

del *.pdb >nul 2>&1

set compile=cl "%root%\src\*.cpp" "%root%\imgui\*.cpp" %cl_flags% /link %ld_flags%
REM echo %compile%
%compile%

if errorlevel 1 goto :end

if /i "%1" == "release" (
    del *.obj >nul 2>&1
    xcopy /S /Q /Y "%root%\data" "%root%\release"
)

:end
popd
