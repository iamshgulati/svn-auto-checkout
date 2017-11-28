:: This script can be used to checkout any branch of all components of GDSP on local systems.
:: author: shubham.gulati

@echo off
setlocal enableDelayedExpansion

cls
echo =============== STARTING CHECKOUT ===============
echo.
echo ======== Initiating system ========

:: Do not change SVN_BIN and SVN_URL
set SVN_BIN=C:\Program Files\TortoiseSVN\bin
set SVN_URL=http://trac2.gdsp.uk.logica.com/svn

echo -- Setting variables --
echo.

:: Configure SOURCE and BRANCH as required.
set SOURCE=C:\Data\CGI\Projects\Vodafone\GDSP
set BRANCH=RFD_17_3

set /p SOURCE= Enter the checkout location to proceed [default is "%SOURCE%"]: 
set /p BRANCH= Enter a branch to proceed [default is "%BRANCH%"]: 
echo.

echo SVN BIN = %SVN_BIN%
echo SVN URL = %SVN_URL%
echo.

echo Checkout Location = %SOURCE%
echo Checkout Branch = %BRANCH%
echo.

echo -- Done setting variables.
echo.

:: Set ignored components
set IGNORED_COMPONENTS_LIST="batch-loader mail-server PIG"
echo Following components result in global update error, so they will not be checked out.
echo Ignored Components: [%IGNORED_COMPONENTS_LIST%]
echo.

:: Prompt user to continue checking out without ignored components.
set ACCEPT_IGNORED_COMPONENTS=y
set /p ACCEPT_IGNORED_COMPONENTS= Please press 'y' or 'n' to proceed [default is "%ACCEPT_IGNORED_COMPONENTS%"]: 
echo.
if "%ACCEPT_IGNORED_COMPONENTS%" == "n" (
	exit /b
)

:: Prompt user to initialize the root directory.
set MODE=u
echo Do you want to delete everything in !SOURCE! and make a fresh start?
echo NOTE: If you just want to checkout another branch along side existing branches please choose 'u'.
echo.
set /p MODE= Please enter 'u' for 'Update' or 'i' for 'Initialize' to proceed [default mode is "%MODE%"]: 
echo.

if "!MODE!" == "i" (

	echo ======== Starting Checkout of GDSP Root ========
	echo.
	echo -- Checking out %SVN_URL%
	set CONFIRM_CHECKOUT_ROOT=y
	set /p CONFIRM_CHECKOUT_ROOT= Please press 'y' or 'n' to proceed [default is "!CONFIRM_CHECKOUT_ROOT!"]: 
	echo.

	if "!CONFIRM_CHECKOUT_ROOT!" == "y" (
		"%SVN_BIN%\svn.exe" checkout --depth=immediates "%SVN_URL%" %SOURCE%
		echo.
		echo -- Checkout of %SVN_URL% Done.
		echo.
	)

	echo ======== Starting Checkout of GDSP Components ========
	echo.

	:: Prompt user to choose a branch
	set /p BRANCH= Please enter a branch to proceed [default is "!BRANCH!"]: 
	echo.
	echo Branch to checkout: ["!BRANCH!"]
	echo.

	cd %SOURCE%
	for /d %%d in (*) do (

		set CHECKOUT_FLAG=y

		:: Check if component is in ignored components
		if %%d == batch-loader (
			set CHECKOUT_FLAG=n
		)
		if %%d == mail-server (
			set CHECKOUT_FLAG=n
		)
		if %%d == PIG (
			set CHECKOUT_FLAG=n
		)

		if !CHECKOUT_FLAG! == y (

			:: Start checking out component
			echo.
			echo -- Checking out %SVN_URL%/%%d
			set CONFIRM_CHECKOUT_COMPONENT=n
			set /p CONFIRM_CHECKOUT_COMPONENT= Please press 'y' or 'n' to proceed [default is "!CONFIRM_CHECKOUT_COMPONENT!"]: 
			if !CONFIRM_CHECKOUT_COMPONENT! == y (

				rem :: Update the existing source before checking out new component
				rem echo.
				rem echo -- Updating %SOURCE% from %SVN_URL%
				rem echo -- Running update --
				rem "%SVN_BIN%\svn.exe" update %SOURCE%
				rem echo -- Update Done.
				rem echo.

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

				:: Checkout %COMPONENT%\branches\!BRANCH!
				echo -- Checking out %SVN_URL%/%%d/branches/!BRANCH!
				echo.
				"%SVN_BIN%\svn.exe" checkout --depth=infinity "%SVN_URL%/%%d/branches/!BRANCH!" "%SOURCE%\%%d\branches\!BRANCH!"
				echo.
				echo -- Checkout of %SVN_URL%/%%d/branches/!BRANCH! Done.
				echo.
				echo ========================================================================================
			)
		)
	)

	echo.
	echo -- Checkout of GDSP Components Done.
	echo.
)

if "!MODE!" == "u" (

	:: Update the existing source before checking out new component
	echo.
	echo -- Updating %SOURCE% from %SVN_URL%
	echo -- Running update --
	"%SVN_BIN%\svn.exe" update %SOURCE%
	echo -- Update Done.
	echo.

	echo ======== Starting Update of GDSP Components ========
	echo.

	:: Prompt user to choose a branch
	set /p BRANCH= Please enter a branch to proceed [default is "!BRANCH!"]: 
	echo.
	echo Branch to checkout: ["!BRANCH!"]

	cd %SOURCE%
	for /d %%d in (*) do (

		set CHECKOUT_FLAG=y

		:: Check if component is in ignored components
		if %%d == batch-loader (
			set CHECKOUT_FLAG=n
		)
		if %%d == mail-server (
			set CHECKOUT_FLAG=n
		)
		if %%d == PIG (
			set CHECKOUT_FLAG=n
		)

		if !CHECKOUT_FLAG! == y (

			:: Start checking out component
			echo.
			echo -- Checking out %SVN_URL%/%%d
			set CONFIRM_CHECKOUT_COMPONENT=n
			set /p CONFIRM_CHECKOUT_COMPONENT= Please press 'y' or 'n' to proceed [default is "!CONFIRM_CHECKOUT_COMPONENT!"]: 
			if !CONFIRM_CHECKOUT_COMPONENT! == y (

				rem :: Update the existing source before checking out new component
				rem echo.
				rem echo -- Updating %SOURCE% from %SVN_URL%
				rem echo -- Running update --
				rem "%SVN_BIN%\svn.exe" update %SOURCE%
				rem echo -- Update Done.
				rem echo.

				rem :: Checkout only immediate children of %COMPONENT% including folders
				rem echo -- Checking out %SVN_URL%/%%d
				rem echo.
				rem "%SVN_BIN%\svn.exe" checkout --depth=immediates "%SVN_URL%/%%d" "%SOURCE%\%%d"
				rem echo.
				rem echo -- Checkout of %SVN_URL%/%%d Done.
				rem echo.
				rem echo ========================================================================================
				rem echo.

				rem :: Checkout only immediate children of %COMPONENT%\branches including folders
				rem echo -- Checking out %SVN_URL%/%%d/branches
				rem echo.
				rem "%SVN_BIN%\svn.exe" checkout --depth=immediates "%SVN_URL%/%%d/branches" "%SOURCE%\%%d\branches"
				rem echo.
				rem echo -- Checkout of %SVN_URL%/%%d/branches Done.
				rem echo.
				rem echo ========================================================================================
				rem echo.

				:: Checkout %COMPONENT%\branches\!BRANCH!
				echo -- Checking out %SVN_URL%/%%d/branches/!BRANCH!
				echo.
				"%SVN_BIN%\svn.exe" checkout --depth=infinity "%SVN_URL%/%%d/branches/!BRANCH!" "%SOURCE%\%%d\branches\!BRANCH!"
				echo.
				echo -- Checkout of %SVN_URL%/%%d/branches/!BRANCH! Done.
				echo.
				echo ========================================================================================
			)
		)
	)

	echo.
	echo -- Update of GDSP Components Done.
	echo.
)

rem :: Update the source for the final time to confirm there were no issues.
rem echo.
rem echo -- Updating %SOURCE% from %SVN_URL%
rem echo -- Running update --
rem "%SVN_BIN%\svn.exe" update %SOURCE%
rem echo -- Update Done.
rem echo.

echo ======== CHECKOUT COMPLETE ========
echo.
pause
