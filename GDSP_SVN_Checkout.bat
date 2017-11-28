:: This script can be used to checkout any branch of all components of GDSP on local systems.
:: author: shubham.gulati

@echo off
setlocal enableDelayedExpansion

cls
echo =============== CHECKOUT VODAFONE GDSP ===============
echo.
echo ======== Initiating system instance variables ========
echo -- Setting the variables --
echo.

:: Configure SOURCE and VERSION as required.
set SOURCE=C:\Data\CGI\Projects\Vodafone\GDSP
set VERSION=RFD_17_2

:: Do not change SVN_URL and SVN_BIN
set SVN_URL=http://trac2.gdsp.uk.logica.com/svn
set SVN_BIN=C:\Program Files\TortoiseSVN\bin

echo SVN URL = %SVN_URL%
echo Checkout Location = %SOURCE%
echo Code Version = %VERSION%
echo SVN BIN = %SVN_BIN%
echo.
echo -- Done setting variables.
echo.

set IGNORED_COMPONENTS=batch-loader mail-server PIG
echo Following components result in global update error, so they will not be checked out.
echo Ignored Components: [%IGNORED_COMPONENTS%]
echo.

echo ======== Starting Checkout of GDSP Root ========
echo.
echo -- Checking out %SVN_URL%
set CONFIRM_CHECKOUT_ROOT=y
set /p CONFIRM_CHECKOUT_ROOT= Please press 'y' or 'n' to proceed [default is 'y']: 
echo.

if "%CONFIRM_CHECKOUT_ROOT%" == "y" (
	"%SVN_BIN%\svn.exe" checkout --depth=immediates "%SVN_URL%" %SOURCE%
	echo.
	echo -- Checkout of %SVN_URL% Done.
	echo.

	echo ======== Starting Checkout of GDSP Components ========

	cd %SOURCE%
	for /d %%d in (*) do (

		echo.
		echo -- Checking out %SVN_URL%/%%d
		set CONFIRM_CHECKOUT_COMPONENT=y
		:: set /p CONFIRM_CHECKOUT_COMPONENT= Please press 'y' or 'n' to proceed [default is 'y']: 
		if !CONFIRM_CHECKOUT_COMPONENT! == y if not %%d == batch-loader if not %%d == mail-server if not %%d == PIG (

			:: Update the existing source before checking out new component
			echo.
			echo -- Updating %SOURCE% from %SVN_URL%
			echo -- Running update --
			"%SVN_BIN%\svn.exe" update %SOURCE%
			echo -- Update Done.
			echo.

			:: Checkout only immediate children of %COMPONENT% including folders
			echo -- Checking out %SVN_URL%/%%d
			echo.
			"%SVN_BIN%\svn.exe" checkout --depth=immediates "%SVN_URL%/%%d" "%SOURCE%\%%d"
			echo.
			echo -- Checkout of %SVN_URL%/%%d Done.
			echo.
			echo ========================================================================================
			echo.

			:: Checkout only immediate children of %COMPONENT%\branches including folders
			echo -- Checking out %SVN_URL%/%%d/branches
			echo.
			"%SVN_BIN%\svn.exe" checkout --depth=immediates "%SVN_URL%/%%d/branches" "%SOURCE%\%%d\branches"
			echo.
			echo -- Checkout of %SVN_URL%/%%d/branches Done.
			echo.
			echo ========================================================================================
			echo.

			:: Checkout %COMPONENT%\branches\%VERSION%
			echo -- Checking out %SVN_URL%/%%d/branches/%VERSION%
			echo.
			"%SVN_BIN%\svn.exe" checkout --depth=infinity "%SVN_URL%/%%d/branches/%VERSION%" "%SOURCE%\%%d\branches\%VERSION%"
			echo.
			echo -- Checkout of %SVN_URL%/%%d/branches/%VERSION% Done.
			echo.
			echo ========================================================================================
		)
	)

	echo.
	echo -- Checkout of GDSP Components Done.
)

:: Update the source for the final time to confirm there were no issues.
echo.
echo -- Updating %SOURCE% from %SVN_URL%
echo -- Running update --
"%SVN_BIN%\svn.exe" update %SOURCE%
echo -- Update Done.
echo.

echo ======== GDSP CHECKOUT COMPLETE ========
echo.
pause
