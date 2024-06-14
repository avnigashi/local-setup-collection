@echo off
setlocal enabledelayedexpansion

:: Check for admin rights
openfiles >nul 2>&1
if not %errorlevel% == 0 (
    echo This script requires administrative privileges.
    pause
    exit /b 1
)

:menu
cls
echo.
echo Select an option to install:
echo.
echo 1. Install PHP
echo 2. Install Composer
echo 3. Install PHP and Composer
echo 4. Exit
echo.
set /p option="Enter your choice (1-4): "

if "%option%"=="1" goto select_php_version
if "%option%"=="2" goto install_composer
if "%option%"=="3" goto select_php_version_and_composer
if "%option%"=="4" exit /b 0
goto menu

:select_php_version
echo.
echo Select PHP version to install:
echo.
echo 1. PHP 7.4.33
echo 2. PHP 8.0.30
echo 3. PHP 8.1.29
echo 4. PHP 8.2.20
echo 5. PHP 8.3.8
echo 6. Back to main menu
echo.
set /p php_version_option="Enter your choice (1-6): "

if "%php_version_option%"=="1" set PHP_VERSION=7.4.33 & set PHP_URL=https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x64.zip
if "%php_version_option%"=="2" set PHP_VERSION=8.0.30 & set PHP_URL=https://windows.php.net/downloads/releases/php-8.0.30-Win32-vs16-x64.zip
if "%php_version_option%"=="3" set PHP_VERSION=8.1.29 & set PHP_URL=https://windows.php.net/downloads/releases/php-8.1.29-Win32-vs16-x64.zip
if "%php_version_option%"=="4" set PHP_VERSION=8.2.20 & set PHP_URL=https://windows.php.net/downloads/releases/php-8.2.20-Win32-vs16-x64.zip
if "%php_version_option%"=="5" set PHP_VERSION=8.3.8 & set PHP_URL=https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x64.zip
if "%php_version_option%"=="6" goto menu

goto install_php

:select_php_version_and_composer
echo.
echo Select PHP version to install:
echo.
echo 1. PHP 7.4.33
echo 2. PHP 8.0.30
echo 3. PHP 8.1.29
echo 4. PHP 8.2.20
echo 5. PHP 8.3.8
echo 6. Back to main menu
echo.
set /p php_version_option="Enter your choice (1-6): "

if "%php_version_option%"=="1" set PHP_VERSION=7.4.33 & set PHP_URL=https://windows.php.net/downloads/releases/php-7.4.33-Win32-vc15-x64.zip
if "%php_version_option%"=="2" set PHP_VERSION=8.0.30 & set PHP_URL=https://windows.php.net/downloads/releases/php-8.0.30-Win32-vs16-x64.zip
if "%php_version_option%"=="3" set PHP_VERSION=8.1.29 & set PHP_URL=https://windows.php.net/downloads/releases/php-8.1.29-Win32-vs16-x64.zip
if "%php_version_option%"=="4" set PHP_VERSION=8.2.20 & set PHP_URL=https://windows.php.net/downloads/releases/php-8.2.20-Win32-vs16-x64.zip
if "%php_version_option%"=="5" set PHP_VERSION=8.3.8 & set PHP_URL=https://windows.php.net/downloads/releases/php-8.3.8-Win32-vs16-x64.zip
if "%php_version_option%"=="6" goto menu

goto install_php_and_composer

:: PHP installation
:install_php
echo Installing PHP...
powershell -Command "try { $response = Invoke-WebRequest -Uri '%PHP_URL%' -UseBasicParsing; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"

if %errorlevel%==0 (
    powershell -Command "Invoke-WebRequest -Uri %PHP_URL% -OutFile php.zip; Expand-Archive php.zip -DestinationPath 'C:\Program Files\PHP\php-%PHP_VERSION%'; Remove-Item php.zip"
    echo PHP %PHP_VERSION% installation completed successfully!
    :: Add PHP to system PATH
    setx PATH "%PATH%;C:\Program Files\PHP\php-%PHP_VERSION%"
    echo PHP has been added to the system PATH. Please restart your terminal or log out and log back in for the changes to take effect.
) else (
    echo PHP download failed. Installation cancelled.
)
pause
goto menu

:: Composer installation
:install_composer
echo Installing Composer...
if not exist "C:\Program Files\PHP\composer.phar" (
    powershell -Command "Invoke-WebRequest -Uri https://getcomposer.org/installer -OutFile composer-setup.php; php composer-setup.php --install-dir='C:\Program Files\PHP' --filename=composer.phar; Remove-Item composer-setup.php"
)
echo Composer installation completed successfully!
pause
goto menu

:: PHP and Composer installation
:install_php_and_composer
echo Installing PHP and Composer...
powershell -Command "try { $response = Invoke-WebRequest -Uri '%PHP_URL%' -UseBasicParsing; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }"

if %errorlevel%==0 (
    powershell -Command "Invoke-WebRequest -Uri %PHP_URL% -OutFile php.zip; Expand-Archive php.zip -DestinationPath 'C:\Program Files\PHP\php-%PHP_VERSION%'; Remove-Item php.zip"
    echo PHP %PHP_VERSION% installation completed successfully!
    :: Add PHP to system PATH
    setx PATH "%PATH%;C:\Program Files\PHP\php-%PHP_VERSION%"
    echo PHP has been added to the system PATH. Please restart your terminal or log out and log back in for the changes to take effect.

    if not exist "C:\Program Files\PHP\composer.phar" (
        powershell -Command "Invoke-WebRequest -Uri https://getcomposer.org/installer -OutFile composer-setup.php; php composer-setup.php --install-dir='C:\Program Files\PHP' --filename=composer.phar; Remove-Item composer-setup.php"
    )
    echo Composer installation completed successfully!
) else (
    echo PHP download failed. Installation cancelled.
)
pause
goto menu

exit /b 0
