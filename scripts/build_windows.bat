@echo off
REM ============================================
REM  Lilt - Windows 构建脚本
REM  用法: build_windows.bat [debug|release]
REM ============================================

setlocal
set BUILD_MODE=%1
if "%BUILD_MODE%"=="" set BUILD_MODE=release

echo ========================================
echo   Lilt - Windows 构建
echo   模式: %BUILD_MODE%
echo ========================================
echo.

REM 安装依赖
call flutter pub get
if %errorlevel% neq 0 (
    echo [FAIL] 依赖安装失败
    exit /b 1
)

REM 代码检查
echo [CHECK] 代码静态分析...
call flutter analyze
if %errorlevel% neq 0 (
    echo [WARN] 静态分析发现问题
)

REM 运行测试
echo [TEST] 运行单元测试...
call flutter test

REM 构建
if "%BUILD_MODE%"=="release" (
    echo [BUILD] 构建 release 版本...
    call flutter build windows --release
) else (
    echo [BUILD] 构建 debug 版本...
    call flutter build windows --debug
)

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   [OK] 构建成功!
    echo   产物: build\windows\x64\runner\%BUILD_MODE%\
    echo ========================================
) else (
    echo.
    echo ========================================
    echo   [FAIL] 构建失败
    echo ========================================
    exit /b 1
)
endlocal
