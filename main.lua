------------------------------------------------------------------------------------------------------------------------------------
-- DEEP VORTEX Corona SDK Template
------------------------------------------------------------------------------------------------------------------------------------
-- Developed by Deep Blue Apps.com [www.deepbueapps.com]
------------------------------------------------------------------------------------------------------------------------------------
-- Abstract: Move the player around, avoiding the obsticles.
------------------------------------------------------------------------------------------------------------------------------------
-- Release Version 3.0
-- Code developed for CORONA SDK STABLE RELEASE 2014.2189
-- 30th April February 2014
------------------------------------------------------------------------------------------------------------------------------------
-- main.lua
------------------------------------------------------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

-- require controller module
local composer = require( "composer" )
local scene = composer.newScene()

local physics 						= require( "physics" )
local myGlobalData 					= require( "globalData" )
local loadsave 						= require("loadsave")
local device 						= require("device")
local levelTrys 					= require("levelAttemtsData")
bmf 								= require( "bmf" )					-- This is to use bitmap fonts

levelTrys.attemps 					= 1	--Reset the LEVEL Attempts counter (but not on the level reset / trys)
levelTrys.lastDistance				= 0

myGlobalData.FONT_DIR 				= "Fonts/"
myGlobalData.fontAvengeanceBlk	 	= bmf:load( 'avengeanceBlk-hd', 	myGlobalData.FONT_DIR )
myGlobalData.fontAvengeanceWht	 	= bmf:load( 'avengeanceWhite-hd', 	myGlobalData.FONT_DIR )
myGlobalData.fontAvengeanceWhtBlkSh	= bmf:load( 'avengeanceWhiteBlackBorderShadow-hd', 	myGlobalData.FONT_DIR )


math.randomseed( os.time() )

--scaleFactor = 0.5

-- GET SCREEN COORDINATES
_G.left    = 0 + display.screenOriginX
_G.top     = 0 + display.screenOriginY
_G.right   = display.contentWidth  - display.screenOriginX
_G.bottom  = display.contentHeight - display.screenOriginY
_G.deviceW = display.contentWidth  - display.screenOriginX*2
_G.deviceH = display.contentHeight - display.screenOriginY*2
_G.centerX = display.contentWidth * 0.5
_G.centerY = display.contentHeight * 0.5
_G.screenW = deviceW
_G.screenH = deviceH


myGlobalData._w 					= display.contentWidth  		-- Get the devices Width
myGlobalData._h 					= display.contentHeight 		-- Get the devices Height

myGlobalData.levelSizeW 			= display.contentHeight 		-- the screen / BOUNDRY SIZE for each level
myGlobalData.levelSizeH 			= display.contentHeight 		-- the screen / BOUNDRY SIZE for each level

myGlobalData.imagePath				= "_Assets/Images/"
myGlobalData.audioPath				= "_Assets/Audio/"
myGlobalData.levelPath				= "_Assets/Levels/"
myGlobalData.levelPathR				= "_Assets.Levels."

------------------------------------------------------------------------------------------------------------------------------------
-- NOTE: We load the spriteData module AFTER the imagePath has been defined !
-- We also hold the data as a GLOBAL so it's permanently in memory (for speed)
------------------------------------------------------------------------------------------------------------------------------------
SpriteData							= require("spriteData") 
------------------------------------------------------------------------------------------------------------------------------------

_G.level							= 1	

myGlobalData.Android				= false
myGlobalData.iPhone5				= false	
myGlobalData.deviceExtraX 			= 0
myGlobalData.deviceExtraY 			= 0


myGlobalData.volumeSFX				= 0.7							-- Define the SFX Volume
myGlobalData.volumeMusic			= 0.5							-- Define the Music Volume
myGlobalData.resetVolumeSFX			= myGlobalData.volumeSFX		-- Define the SFX Volume Reset Value
myGlobalData.resetVolumeMusic		= myGlobalData.volumeMusic		-- Define the Music Volume Reset Value
myGlobalData.soundON				= true							-- Is the sound ON or Off?
myGlobalData.musicON				= true							-- Is the sound ON or Off?

myGlobalData.factorX				= 0.4166	--2.400
myGlobalData.factorY				= 0.46875	--2.133

myGlobalData.defaultPlayer			= 102 -- the default player character. [player1.png] = id 100


-- Enable debug by setting to [true] to see FPS and Memory usage.
local doDebug 						= false						-- show the Memory and FPS box?
myGlobalData.showDebugGrid			= false						-- Show a grid to help positioning...

_G.saveDataTable		= {}							-- Define the Save/Load base Table to hold our data

myGlobalData.saveDataFileName		= "GeometryDashTemplate_V001"

-- Load in the saved data to our game table
-- check the files exists before !
if loadsave.fileExists(myGlobalData.saveDataFileName..".json", system.DocumentsDirectory) then
	saveDataTable = loadsave.loadTable(myGlobalData.saveDataFileName..".json")
else
	saveDataTable.highScore 			= 0
	-- Save the NEW json file, for referencing later..
	loadsave.saveTable(saveDataTable, myGlobalData.saveDataFileName..".json")
end

--Now load in the Data
saveDataTable = loadsave.loadTable(myGlobalData.saveDataFileName..".json")

--Now assign the LOADED level to the Game Variable to control the levels the user can select.
myGlobalData.highScore				= saveDataTable.highScore		-- Saved HighScore value
myGlobalData.gameScore				= 0								-- Set the Starting value of the score to ZERO ( 0 )

if ( device.isApple ) then
	myGlobalData.Android	= false
	print("Running on iOS")	
	if ( device.is_iPad ) then
		myGlobalData.iPad = true
		print("Device Type: iPad")
	else
		myGlobalData.iPad = false
		if (display.pixelHeight > 960) then
			myGlobalData.iPhone5 = true
			print("Device Type: iPhone 5-6")
		else
			myGlobalData.iPhone5 = false
			print("Device Type: iPhone 3-4")
		end
	end
else
	myGlobalData.Android = true
	myGlobalData.iPad = false
	myGlobalData.iPhone5 = false
	print("Running on Android")
end



-------------------------------------------------------------------------------------------------------------
if (myGlobalData.iPhone5) then
	myGlobalData.deviceExtraX = 44
	--myGlobalData.ideviceExtraY = -44
end
-------------------------------------------------------------------------------------------------------------
if (device.is_iPad) then
	myGlobalData.deviceExtraX = -10
	myGlobalData.deviceExtraY = 40
end
-------------------------------------------------------------------------------------------------------------



-- Debug Data
if (doDebug) then
	composer.isDebug = true
	local fps = require("fps")
	local performance = fps.PerformanceOutput.new();
	performance.group.x, performance.group.y = (display.contentWidth/2)-40,  display.contentWidth/2;
	performance.alpha = 0.3; -- So it doesn't get in the way of the rest of the scene
end


--Set the Music Volume
audio.setVolume( myGlobalData.volumeMusic, 	{ channel=0 } ) -- set the volume on channel 1
audio.setVolume( myGlobalData.volumeMusic, 	{ channel=1 } ) -- set the volume on channel 1
audio.setVolume( myGlobalData.volumeMusic, 	{ channel=2 } ) -- set the volume on channel 2
audio.setVolume( myGlobalData.volumeMusic, 	{ channel=3 } ) -- set the volume on channel 3

for i = 4, 32 do
	audio.setVolume( myGlobalData.volumeSFX, { channel=i } )
end 


function startGame()
	composer.gotoScene( "screenMenu")	--This is our main menu
end


------------------------------------------------------------------------------------------------------------------------------------
-- Preload Audio, music, sfx
------------------------------------------------------------------------------------------------------------------------------------
--musicStart 				= audio.loadSound( myGlobalData.audioPath.."musicDBA001.mp3" )
myGlobalData.musicGame		= audio.loadSound( myGlobalData.audioPath.."level1MusicClean.mp3" )

--sfx_Victory				= audio.loadSound( myGlobalData.audioPath.."sfx_Victory.mp3" )
myGlobalData.Sfx_Hit		= audio.loadSound( myGlobalData.audioPath.."Sfx_Hit.mp3" )


--Start Game after a short delay.
timer.performWithDelay(5, startGame )

