:: This script can be used to checkout any/all branch(es) of any/all components of GDSP on local systems.
:: author: shubham.gulati

@echo off
setlocal enableDelayedExpansion

cls
echo =============== STARTING CHECKOUT ===============
echo.
echo ======== Initiating system ========
echo.

:: Do not change SVN_BIN and SVN_URL
set SVN_BIN=C:\Program Files\TortoiseSVN\bin
set SVN_URL=http://trac2.gdsp.uk.logica.com/svn

:: Performing system checks
IF NOT EXIST "%SVN_BIN%\svn.exe" (
	echo.
	echo [ERROR] Missing svn.exe at %SVN_BIN%\svn.exe.
	echo [ERROR] Please re-install TortoiseSVN with commandline tools checked.
	echo [ERROR] Script will now exit...
	echo.
	pause
	exit /b
	)

echo -- Setting variables --
echo.

:: Configure SOURCE and BRANCH as required.
set SOURCE=C:\Data\CGI\Projects\Vodafone\GDSP
set BRANCH=FD_18_2

set /p SOURCE= Enter the checkout location to proceed [default is "%SOURCE%"]: 
set /p BRANCH= Enter a default branch to proceed [default is "%BRANCH%"]: 
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
echo Choose a checkout mode:
echo  -- 'u' if you want to update existing local source with new components or new branches.
echo  -- 'i' if you want to initialize a new local source repository.
echo.
set /p MODE= Please enter 'u' or 'i' to proceed [default mode is "%MODE%"]: 
echo.

if "!MODE!" == "i" (

	:: Check if selected checkout location exists.
	if exist "%SOURCE%" (

		:: Check if existing checkout location is empty. If not then offer to choose another checkout location.
		set IS_EMPTY=y

		:: This will check for any existing directories or files in LOCAL SOURCE
		rem for for /F %%i in ('dir /b %SOURCE%\*.*') do (
		rem 	set IS_EMPTY=n
		rem 	)

		:: This will ignore existing files and only check for existing directories in LOCAL SOURCE (RECOMMENDED)
		for /d %%d in (%SOURCE%\*.*) do (
			set IS_EMPTY=n
			)

		if "!IS_EMPTY!" == "n" (
			echo Chosen local source checkout location is not empty: [%SOURCE%]
			echo.
			set SOURCE=!SOURCE!_Temp
			set /p SOURCE= Enter a different checkout location to proceed [default is "%SOURCE%_Temp"]:
			)
		)

	:: Check if selected checkout location does not exist and offer to create a new checkout location.
	if not exist "!SOURCE!" (
		set CREATE_NEW=y
		echo Chosen local source checkout location does not exist: [!SOURCE!]
		echo.
		echo Do you want to create new directory for source? [!SOURCE!]
		set /p CREATE_NEW= Please enter 'y' or 'n' to proceed [default is "!CREATE_NEW!"]: 
		if "!CREATE_NEW!" == "y" (
			mkdir !SOURCE!
			if "!errorlevel!" EQU "0" (
				echo New source location created. [!SOURCE!]
				) else (
				echo Error while creating new source. [!SOURCE!]
				echo Script can not proceed without a valid checkout location.
				echo Exiting...
				pause
				exit /b
				)
				) else (
				echo Script can not proceed without a valid checkout location.
				echo Exiting...
				pause
				exit /b
				)
				)

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
			echo.
			if !CONFIRM_CHECKOUT_COMPONENT! == y (

				:: Checkout only immediate children of %COMPONENT% including folders
				echo -- Checking out %SVN_URL%/%%d
				echo.
				set CONFIRM_ACTION=y
				set /p CONFIRM_ACTION= Please press 'y' or 'n' to proceed [default is "!CONFIRM_ACTION!"]: 
				echo.
				if !CONFIRM_ACTION! == y (
					"%SVN_BIN%\svn.exe" checkout --depth=immediates "%SVN_URL%/%%d" "%SOURCE%\%%d"
					echo.
					echo -- Checkout of %SVN_URL%/%%d Done.
					echo.
					echo ========================================================================================
					echo.
					)

				:: Checkout only immediate children of %COMPONENT%\branches including folders
				echo -- Checking out %SVN_URL%/%%d/branches
				echo.
				set CONFIRM_ACTION=y
				set /p CONFIRM_ACTION= Please press 'y' or 'n' to proceed [default is "!CONFIRM_ACTION!"]: 
				echo.
				if !CONFIRM_ACTION! == y (
					"%SVN_BIN%\svn.exe" checkout --depth=immediates "%SVN_URL%/%%d/branches" "%SOURCE%\%%d\branches"
					echo.
					echo -- Checkout of %SVN_URL%/%%d/branches Done.
					echo.
					echo ========================================================================================
					echo.
					)

				:: Checkout %COMPONENT%\branches\!BRANCH!
				echo -- Checking out a branch of [ %%d ]
				echo.
				set CONFIRM_ACTION=y
				set /p CONFIRM_ACTION= Please press 'y' or 'n' to proceed [default is "!CONFIRM_ACTION!"]: 
				echo.
				if !CONFIRM_ACTION! == y (

					:: Prompt user to choose a branch
					set /p BRANCH= Please enter a branch to proceed [default is "!BRANCH!"]: 
					echo.
					echo Checking out branch: ["!BRANCH!"]
					echo.

					"%SVN_BIN%\svn.exe" checkout --depth=infinity "%SVN_URL%/%%d/branches/!BRANCH!" "%SOURCE%\%%d\branches\!BRANCH!"
					echo.
					echo -- Checkout of %SVN_URL%/%%d/branches/!BRANCH! Done.
					echo.
					echo ========================================================================================
					echo.
					)
				)
			)
		)

	echo.
	echo -- Checkout of GDSP Components Done.
	echo.
	)

if "!MODE!" == "u" (

	:: Update the existing source before checking out new component
	rem echo.
	rem echo -- Updating %SOURCE% from %SVN_URL%
	rem echo -- Running update --
	rem "%SVN_BIN%\svn.exe" update %SOURCE%
	rem echo -- Update Done.
	rem echo.

	echo ======== Starting Update of GDSP Root ========
	echo.
	echo -- Checking out %SVN_URL%
	set CONFIRM_UPDATE_ROOT=y
	set /p CONFIRM_UPDATE_ROOT= Please press 'y' or 'n' to proceed [default is "!CONFIRM_UPDATE_ROOT!"]: 
	echo.

	if "!CONFIRM_UPDATE_ROOT!" == "y" (
		"%SVN_BIN%\svn.exe" update --depth=immediates %SOURCE%
		echo.
		echo -- Update of %SOURCE% Done.
		echo.
		)

	echo ======== Starting Update of GDSP Components ========
	echo.

	cd %SOURCE%
	for /d %%d in (*) do (

		set UPDATE_FLAG=y

		:: Check if component is in ignored components
		if %%d == batch-loader (
			set UPDATE_FLAG=n
			)
		if %%d == mail-server (
			set UPDATE_FLAG=n
			)
		if %%d == PIG (
			set UPDATE_FLAG=n
			)

		if !UPDATE_FLAG! == y (

			:: Start updating component
			echo.
			echo -- Updating %SVN_URL%/%%d
			set CONFIRM_UPDATE_COMPONENT=n
			set /p CONFIRM_UPDATE_COMPONENT= Please press 'y' or 'n' to proceed [default is "!CONFIRM_UPDATE_COMPONENT!"]: 
			echo.
			if !CONFIRM_UPDATE_COMPONENT! == y (

				:: Update only immediate children of %COMPONENT% including folders
				echo -- Updating %SOURCE%\%%d
				echo.
				set CONFIRM_ACTION=y
				set /p CONFIRM_ACTION= Please press 'y' or 'n' to proceed [default is "!CONFIRM_ACTION!"]: 
				echo.
				if !CONFIRM_ACTION! == y (
					"%SVN_BIN%\svn.exe" update --depth=immediates "%SOURCE%\%%d"
					echo.
					echo -- Update of %SOURCE%\%%d Done.
					echo.
					echo ========================================================================================
					echo.
					)

				:: Update only immediate children of %COMPONENT%\branches including folders
				echo -- Updating %SOURCE%\%%d\branches
				echo.
				set CONFIRM_ACTION=y
				set /p CONFIRM_ACTION= Please press 'y' or 'n' to proceed [default is "!CONFIRM_ACTION!"]: 
				echo.
				if !CONFIRM_ACTION! == y (
					"%SVN_BIN%\svn.exe" update --depth=immediates "%SOURCE%\%%d\branches"
					echo.
					echo -- Update of %SOURCE%\%%d\branches Done.
					echo.
					echo ========================================================================================
					echo.
					)

				:: Checkout %COMPONENT%\branches\!BRANCH!
				echo -- Checking out a branch of [ %%d ]
				echo.
				set CONFIRM_ACTION=y
				set /p CONFIRM_ACTION= Please press 'y' or 'n' to proceed [default is "!CONFIRM_ACTION!"]: 
				echo.
				if !CONFIRM_ACTION! == y (

					:: Prompt user to choose a branch
					set /p BRANCH= Please enter a branch to proceed [default is "!BRANCH!"]: 
					echo.
					echo Checking out branch: ["!BRANCH!"]
					echo.

					"%SVN_BIN%\svn.exe" checkout --depth=infinity "%SVN_URL%/%%d/branches/!BRANCH!" "%SOURCE%\%%d\branches\!BRANCH!"
					echo.
					echo -- Checkout of %SVN_URL%/%%d/branches/!BRANCH! Done.
					echo.
					echo ========================================================================================
					echo.
					)
				)
			)
		)

	echo.
	echo -- Checkout of GDSP Components Done.
	echo.
	)

echo ======== CHECKOUT COMPLETE ========
echo.
pause
