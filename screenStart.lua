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
-- screenStart.lua
------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------
-- Require all of the external modules for this level
---------------------------------------------------------------
collectgarbage("collect")

local composer 			= require( "composer" )
local scene 			= composer.newScene()

local myGlobalData 		= require("globalData")
local loadsave 			= require("loadsave")
local levelTrys 		= require("levelAttemtsData")
local collisionData 	= require("spriteFilters")
local attemptsString

--levelTrys.Attemps 					= 0	--Reset the LEVEL Attempts counter


-----------------------------------------------------------------
-- Setup the Physics World
-----------------------------------------------------------------
local physics 			= require("physics")
physics.start()
physics.setScale( 30 )
physics.setGravity( 0, 20 )
physics.setPositionIterations(6)
-- un-comment to see the Physics world over the top of the Sprites
--physics.setDrawMode( "hybrid" )


---------------------------------------------------------------
-- Define our SCENE variables and sprite object variables
---------------------------------------------------------------
local scene 					= composer.newScene()
local json 						= require("json")
local pex 						= require("pex")
local particleData 				= pex.load( SpriteData.Particles_Path.."floorSparks.pex", SpriteData.Particles_Path.."floorSparksTexture.png" )
local cTrans 					= require( "colorTransition" )

local cameraMoveTimer 			= {}
local scrollZones				= {}
local zones 					= {}
local zoneColour				= {}


-------PLACE VARIABLES INTO A TABLE -----
local vars = {

			gridSz					= 32,
			zoneTableW	 			= 0, -- This is how LONG the level is. This will be overrideen by the level load function.
			zoneTableH 				= 0,
			stopObjectSpawns		= false,
			collectItemMaterial,
			lastBGColour,
			image_outline,
			myLevel,
			gameObject,
			theSprite,
			getType,
			tapJump,
			emitter,
			gameMusic,
			crashSFX,
			gameOver				= false,
			invincibleMode 			= false,   -- set to true to NEVER GET KILLED!
			collectScene,
			buildLevelTimer,
			meterMaxWidth			= 300,
			meterPosY 				= top + 20,
			distanceMeter			= nil,
			gameOverBool			= false,
			triggerGameOver			= false,
			levelCompleted			= false,
			levelFailed				= false,
			basePhysicsBox			= nil,
			scrollStart				= false,
			gameStart				= false,
			scrollSpeed 			= 0,	-- This value is controlled from the LEVEL data.
			bgScrollSpeed 			= 1,
			fgScrollSpeed 			= 3,
			scrollCount 			= 0,
			scrollHeight 			= 0,
			startOffsetX			= -(32 * 0.5),
			startOffsetY			= -64 - (32 * 0.5),
			playerJumpStyle			= 2,
			addBGLayer				= true,
			addFGLayer				= false,
			addBaseLayer			= true,
			sceneEffectIn			= false,
			sceneEffectOut			= false,

			

}

--playerJumpStyle: 0 - Simple Jump, 1-Jump 90º turn, 2-Jump 180º turn, 3-Jump 360º turn, 4 Jump hold fly.

--local meterMaxWidth				= 300
--local meterPosY					= top + 20
--local vars.distanceMeter
--local distanceMeterBase


--local basePhysicsBox

--local scrollStart				= false
--local gameStart				= false
--local vars.scrollSpeed 			= 0		-- This value is controlled from the LEVEL data.
--local scrollCount 			= 0
--local scrollHeight 			= 0 
--local startOffsetX			= -(vars.gridSz * 0.5)
--local startOffsetY			= -64 - (vars.gridSz * 0.5)

local startGame			= false
--local gameDirection		= "left_to_Right"		--Can be: "left_to_Right", "right_to_Left"
local gameDirection		= "right_to_Left"		--Can be: "left_to_Right", "right_to_Left"

local lastBlockX		= deviceW - 64 -- This is the Devices WIDTH + a bit.. To start the Zone building.
local blocksArray = {}
local arrayIndex

local highlight -- This sits over the top of the Ground layer

local playerSelection = myGlobalData.defaultPlayer --The player image (default is 100)
local player
--local playerPhysics
local playerFlying
--local playerFlyingPhysics

local levelOffset 			= 1--1--170--1--312 --Used to set a position within the level !!! Good for testing :-) !
local previousPositionX 	= levelOffset
local playerFixedXPosition = centerX - 64
local playerFixedYPosition = 0 --updated after the player is created
local cameraMaxHeight 		= 100+(22)--(display.contentHeight/2) + (myGlobalData.deviceExtraY) --100

local standardJumpHeight = 160--64 --Standard Height to Jump
local bonusHeight = 0 --Extra Height from power up


local groundArray = {}
local bgArray = {}
local fgArray = {}

local playerIsJumping 			= false
local playOnPlatform			= true
local playerOnFloor				= true

local playerCanFly				= false
local playerFlyingAngle			= 0

local coinSmall_Collected = 0
local coinLarge_Collected = 0

local playerReachedGoal	= false
local enteredPortal		= false

local BGColour_1 = {0,42,255} 	-- blue
local BGColour_2 = {248,36,36} 	-- red colour
--local BGColour_3 = {0,219,15} 	-- green colour

local fadeColourSpeed = 2000	-- How quickly the background colour changes
local fadeColourDelay = 100	-- How long to hold the background colour, before a change.

local bgTopColourRect
local bgBaseColourRect = {}
local backTransition
local baseTransition

local startRings = {}
local endRing = {}

local startRingFillColour1 = {255,184,91}
local startRingFillColour2 = {62,253,152} 
local startRingStrokeColour1 = {255,255,255}
local startRingStrokeColour2 = {226,252,8} 
local startRing1FillAlpha = 0.0
local startRing2FillAlpha = 0.0
local startRing1StrokeAlpha = 0.5
local startRing2StrokeAlpha = 0.5
local startRing1StrokeWidth = 1
local startRing1StrokeWidth = 1

local dieRingColour1 = {189,243,248}
local dieRingColour2 = {255,255,255}
local dieColourExplosion = {0,214,40}

--[[
local PlayerFilterData = { categoryBits = 1, maskBits = 1022 }
local PlatformFilterData = { categoryBits = 2, maskBits = 1 }
local BounceFilterData = { categoryBits = 4, maskBits = 1 }
local PitFilterData = { categoryBits = 8, maskBits = 1 }
local SpikeFilterData = { categoryBits = 16, maskBits = 1 }
local GroundFilterData = { categoryBits = 32, maskBits = 1 }
local BounceFloorFilterData = { categoryBits = 64, maskBits = 1 }
local BounceAirFilterData = { categoryBits = 128, maskBits = 1 }
local Coin1FilterData = { categoryBits = 256, maskBits = 1 }
local Coin2FilterData = { categoryBits = 512, maskBits = 1 }
--]]

local backgroundGroup 		= display.newGroup()

local backgroundScoll1Group = display.newGroup()
local backgroundScoll2Group = display.newGroup()
local foregroundScoll1Group = display.newGroup()
local foregroundScoll2Group = display.newGroup()
local platform1Group 		= display.newGroup()
local platform2Group 		= display.newGroup()

local platform3Group 		= display.newGroup()
local obsticlesGroup 		= display.newGroup()
local playerGroup 			= display.newGroup()
local playerStartEndGroup 	= display.newGroup()
local cameraGroup 			= display.newGroup()
local cameraRotateGroup 	= display.newGroup() -- Used to control the Rotation of the camera.
local hudGroup 				= display.newGroup()

display.setDefault( "anchorX", 0.5 )
display.setDefault( "anchorY", 0.5 )



local restartButton
local homeButton

--Math functions
local Cos = math.cos
local Sin = math.sin
local Rad = math.rad
local Atan2 = math.atan2
local Deg = math.deg 
local degrees = 1
local angle = 0 --Start angle



local scoreNumber = 0
local scoreDisplay
local highScoreDisplay

local scoreTimertimer


local audioLoops = 1

local startTime = system.getTimer()


---------------------------------------------------------------------------------------------------------
-- Localise some global variables
---------------------------------------------------------------------------------------------------------
local imagePath = myGlobalData.imagePath

--If we're NOT on an iPhone 5 - have less pixels  things going on!....
local maxCircles = 3
local maxStars = 6

--If we're on an iPhone 5 - have more pixels n stars etc !
if (myGlobalData.iPhone5 == true) then
	 maxCircles = 3
	 maxStars = 5
end



----------------------------------------------------------------------------------------------------
-- Extra cleanup routines
----------------------------------------------------------------------------------------------------
local coronaMetaTable = getmetatable(display.getCurrentStage())
	isDisplayObject = function(aDisplayObject)
	return (type(aDisplayObject) == "table" and getmetatable(aDisplayObject) == coronaMetaTable)
end

local function cleanGroups ( objectOrGroup )
    if(not isDisplayObject(objectOrGroup)) then return end
		if objectOrGroup.numChildren then
			-- we have a group, so first clean that out
			while objectOrGroup.numChildren > 0 do
				-- clean out the last member of the group (work from the top down!)
				cleanGroups ( objectOrGroup[objectOrGroup.numChildren])
			end
		end
			objectOrGroup:removeSelf()
    return
end



---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

-- "scene:create()"
function scene:create( event )


   local sceneGroup = self.view

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end

-- "scene:show()"
function scene:show( event )
	
   local screenGroup = self.view
   local phase = event.phase
   
   composer.removeScene( "screenMenu" )

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).

	local memUsage_str = string.format( "MEMORY= %.3f KB", collectgarbage( "count" ) )
	print( "Attempt #"..levelTrys.attemps.." | "..memUsage_str .. " | TEXTURE= "..(system.getInfo("textureMemoryUsed")/1048576) )

    ---------------------------------------------------------------
	-- Touch Left & Right areas
	---------------------------------------------------------------
	vars.tapJump = display.newRect(0,0,deviceW, deviceH)
	vars.tapJump.x = centerX
	vars.tapJump.y = centerY
	vars.tapJump:setFillColor(0,0,0)
	vars.tapJump.alpha=0.1
	screenGroup:insert( vars.tapJump )
	

	--[[
	-----------------------------------------------------------------
	-- Add Score
	-----------------------------------------------------------------
	local scoreHudPanel = display.newImageRect(imagePath.."hudPanel.png",164,56)
	scoreHudPanel.anchorX = 1
	scoreHudPanel.anchorY = 0
	scoreHudPanel.xScale = 2.0
	scoreHudPanel.yScale = 2.0
	scoreHudPanel.x = sizeGetW+100
	scoreHudPanel.y = -40
	scoreHudPanel.alpha = 0.0
	screenGroup:insert( scoreHudPanel )

	scoreDisplay = display.newText("Score: "..scoreNumber,0,0, "HelveticaNeue-Condensed", 20)
	scoreDisplay:setFillColor(1,1,1)
	scoreDisplay.anchorX = 0
	scoreDisplay.x = sizeGetW - 130
	scoreDisplay.y = 20
	scoreDisplay.alpha = 1
	screenGroup:insert( scoreDisplay )

	-----------------------------------------------------------------
	-- Show HighScore
	-----------------------------------------------------------------
	local scoreHudPanel = display.newImageRect(imagePath.."hudPanel.png",164,56)
	scoreHudPanel.anchorX = 1
	scoreHudPanel.anchorY = 0
	scoreHudPanel.xScale = -2.0
	scoreHudPanel.yScale = 2.0
	scoreHudPanel.x = -100
	scoreHudPanel.y = -40
	scoreHudPanel.alpha = 0.0
	screenGroup:insert( scoreHudPanel )

	highScoreDisplay = display.newText("High score: "..saveDataTable.highScore,0,0, "HelveticaNeue-Condensed", 20)
	highScoreDisplay:setFillColor(1,1,1)
	highScoreDisplay.anchorX = 0
	highScoreDisplay.x = 20
	highScoreDisplay.y = 20
	highScoreDisplay.alpha = 0.6
	screenGroup:insert( highScoreDisplay )

	--]]
	
	vars.myLevel = "level"..level
	vars.collectScene = require(myGlobalData.levelPathR..vars.myLevel) --We dynamically load the correct level.
	
	
	--resetScore = gameScore
	--gameScore = resetScore
	
	-----------------------------------------------------------------
	--Collect some other LEVEL specific data from the level.lua file
	-----------------------------------------------------------------
	scrollHeight 		= 	vars.collectScene.numberOfZones
	vars.zoneTableW			=	vars.collectScene.collectZoneLength
	vars.zoneTableH	 		=	vars.collectScene.collectZoneHeight
	scrollZones 		=	vars.collectScene.scrollZonesData
	zones 				=	vars.collectScene.zoneData
	zoneColour			=	vars.collectScene.zoneColourData
	vars.scrollSpeed			=	vars.collectScene.scrollSpeedData
	-----------------------------------------------------------------
	--package.loaded[myGlobalData.levelPathR..vars.myLevel] = nil

	---------------------------------------------------------------
	--Add the Background Colour | This colour can be changed over time.
	---------------------------------------------------------------	
	vars.lastBGColour = zoneColour[1] -- We get the START colour from the level file. SHOULD ALWAYS be the 1st entry in the table!
	bgTopColourRect = display.newRect(centerX, centerY, deviceW, deviceH)
	bgTopColourRect.fill = {returnRGB(vars.lastBGColour[1]), returnRGB(vars.lastBGColour[2]), returnRGB(vars.lastBGColour[3])}
	backgroundGroup:insert( bgTopColourRect )

	---------------------------------------------------------------
	--Add the Base Platform Physics Box (The player slides on)
	---------------------------------------------------------------
	vars.basePhysicsBox = display.newRect(centerX, centerY, deviceW, 64)
	vars.basePhysicsBox.fill = {returnRGB(vars.lastBGColour[1]), returnRGB(vars.lastBGColour[2]), returnRGB(vars.lastBGColour[3])}


	local basePhysicsBoxMaterial = { "static", density=10000.0, friction=0.2, bounce=0.2, filter=collisionData.Platform_FD }
	physics.addBody( vars.basePhysicsBox, basePhysicsBoxMaterial )
	vars.basePhysicsBox.isFixedRotation = true
	vars.basePhysicsBox.myName = "floor"
	vars.basePhysicsBox.rotation = 0
	vars.basePhysicsBox.gravityScale = 0
	vars.basePhysicsBox.y = bottom - (vars.basePhysicsBox.height*0.5)
	platform3Group:insert( vars.basePhysicsBox )


	---------------------------------------------------------------
	--Add the Background Pattern
	---------------------------------------------------------------
	if (vars.addBGLayer == true ) then
		for i=1,2 do
			bgArray[i] = display.newImageRect(SpriteData.GameArt_Path.."bgRepeat.png",512,512)
			bgArray[i].x = (left + (i-1)*512)
			bgArray[i].y = centerY
			backgroundScoll1Group:insert( bgArray[i] )
		end

		for i=1,2 do
			bgArray[i] = display.newImageRect(SpriteData.GameArt_Path.."bgRepeat.png",512,512)
			bgArray[i].x = (left + (i-1)*512)
			bgArray[i].y = centerY
			backgroundScoll2Group:insert( bgArray[i] )
		end

		backgroundScoll1Group.speed = vars.bgScrollSpeed
		backgroundScoll2Group.speed = vars.bgScrollSpeed
		backgroundScoll2Group.x = 1024 --Offset the 2nd layer for the scrolling base
	end

	---------------------------------------------------------------
	--Add the Foreground Parallax 
	---------------------------------------------------------------
	if (vars.addFGLayer == true ) then
		for i=1,2 do
			fgArray[i] = display.newImageRect(SpriteData.GameArt_Path.."fgRepeat.png",512,512)
			fgArray[i].x = (left + (i-1)*512)
			fgArray[i].y = centerY
			foregroundScoll1Group:insert( fgArray[i] )
		end

		for i=1,2 do
			fgArray[i] = display.newImageRect(SpriteData.GameArt_Path.."fgRepeat.png",512,512)
			fgArray[i].x = (left + (i-1)*512)
			fgArray[i].y = centerY
			foregroundScoll2Group:insert( fgArray[i] )
		end
		foregroundScoll1Group.speed = vars.fgScrollSpeed
		foregroundScoll2Group.speed = vars.fgScrollSpeed
		foregroundScoll2Group.x = 1024 --Offset the 2nd layer for the scrolling base
	end

	---------------------------------------------------------------
	--Add the Ground (Base Platform)
	---------------------------------------------------------------
	if (vars.addBaseLayer == true ) then
		for i=1,5 do
			groundArray[i] = display.newImageRect(SpriteData.GameArt_Path.."platform.png",128,128)
			groundArray[i].x = (left + (i-1)*128)
			groundArray[i].y = bottom
			platform1Group:insert( groundArray[i] )
		end

		for i=1,5 do
			groundArray[i] = display.newImageRect(SpriteData.GameArt_Path.."platform.png",128,128)
			groundArray[i].x = (left + (i-1)*128)
			groundArray[i].y = bottom
			platform2Group:insert( groundArray[i] )
		end

		platform1Group.speed = vars.scrollSpeed
		platform2Group.speed = vars.scrollSpeed
		platform2Group.x = 640 --Offset the 2nd layer for the scrolling base
	end

	---------------------------------------------------------------
	--Add the base platform Highlight
	---------------------------------------------------------------
	highlight = display.newImageRect(SpriteData.GameArt_Path.."baseLine.png",384,1)
	highlight.x = centerX - 64
	highlight.alpha = 0.8
	highlight.y = vars.basePhysicsBox.y- (vars.basePhysicsBox.height/2)
	platform3Group:insert( highlight )
	
	
	---------------------------------------------------------------
	--Add the player
	---------------------------------------------------------------
	vars.emitter = display.newEmitter(particleData)
	playerGroup:insert( vars.emitter )

	local playerSpriteRef = SpriteData.spriteSetup[playerSelection]
	local getStartPlayerPath = playerSpriteRef.path
	local getStartPlayerName = playerSpriteRef.name
	local getStartPlayerWidth = playerSpriteRef.sx
	local getStartPlayerHeight = playerSpriteRef.sy

	player = display.newImageRect(getStartPlayerPath..getStartPlayerName..".png", getStartPlayerWidth, getStartPlayerHeight)
	playerPhysics= { "dynamic", density=50.0, friction=0.2, bounce=0.0, radius=playerSpriteRef.rad, filter=collisionData.Player_FD }


	physics.addBody( player, playerPhysics )
	player.isFixedRotation 			= true
	player.isSensor 				= playerSpriteRef.se
	player.myName 					= playerSpriteRef.cn
	player.rotation 				= 0
	player.x 						= playerFixedXPosition
	player.y 						= (vars.basePhysicsBox.y - (vars.basePhysicsBox.height * 0.5)) - (player.height * 0.5)- 20
	playerFixedYPosition 			= player.y --Define the Players Start Y Position.
	playerGroup:insert( player )
	
	--Sparks from the player
	vars.emitter.x = player.x - (player.width/2)
	vars.emitter.y = player.y + (player.height)
	vars.emitter.alpha = 0.0



	---------------------------------------------------------------
	--Add the Flying Player (invisible until activated)
	---------------------------------------------------------------
	--vars.emitter = display.newEmitter(particleData)
	--playerGroup:insert( vars.emitter )

	local playerSpriteRef = SpriteData.spriteSetup[140]
	local getStartPlayerPath = playerSpriteRef.path
	local getStartPlayerName = playerSpriteRef.name
	local getStartPlayerWidth = playerSpriteRef.sx
	local getStartPlayerHeight = playerSpriteRef.sy
	playerFlyingPhysics = playerSpriteRef.spritePhysics
	

	playerFlying = display.newImageRect(getStartPlayerPath..getStartPlayerName..".png", getStartPlayerWidth, getStartPlayerHeight)
	--local playerMaterial = { "dynamic", density=50.0, friction=0.2, bounce=0.0, radius=playerSpriteRef.rad, filter=collisionData.Player_FD }

	--physics.addBody( playerFlying, playerFlyingPhysics )

	--playerFlying.isFixedRotation 		= true
	playerFlying.isSensor 				= playerSpriteRef.se
	playerFlying.myName 				= playerSpriteRef.cn
	playerFlying.rotation 				= 0
	playerFlying.x 						= playerFixedXPosition
	playerFlying.y 						= player.y	-- (vars.basePhysicsBox.y - (vars.basePhysicsBox.height * 0.5)) - (player.height * 0.5)- 20
	playerFixedYPosition 				= playerFlying.y --Define the Players Start Y Position.
	
	-- Set the FLYING player very small and transparent
	-- Also note: We have NO physics body on the flying Player
	-- We add the body, when it's called on.
	playerFlying.xScale = 0.1
	playerFlying.yScale = 0.1
	playerFlying.alpha = 0.0

	playerGroup:insert( playerFlying )
	
	--Sparks from the player
	--vars.emitter.x = player.x - (player.width/2)
	--vars.emitter.y = player.y + (player.height)
	--vars.emitter.alpha = 0.0



	---------------------------------------------------------------
	--Distance Meter Bar
	---------------------------------------------------------------
	local distanceMeterColour = {0,201,9}
	vars.distanceMeter = display.newRoundedRect(centerX, centerY, 3, 3, 1.5)
	vars.distanceMeter:setFillColor( returnRGB(distanceMeterColour[1]), returnRGB(distanceMeterColour[2]), returnRGB(distanceMeterColour[3]) )
	vars.distanceMeter.anchorX = 0.0
	vars.distanceMeter.anchorY = 0.5
	vars.distanceMeter.y = vars.meterPosY
	vars.distanceMeter.width = 1
	hudGroup:insert(vars.distanceMeter)	

	local barWidth = 300
	local meterBase = display.newRoundedRect(centerX, centerY, barWidth, 4, 2)
	meterBase:setFillColor( 0,0,0,0.0 )
	meterBase:setStrokeColor( 1, 1 , 1, 1.0 )
	meterBase.strokeWidth = 1
	meterBase.anchorX = 0.5
	meterBase.anchorY = 0.5
	meterBase.y = vars.meterPosY
	meterBase.width = barWidth
	hudGroup:insert(meterBase)	
	meterBase:toBack()


	--[[
	meterBase = display.newImageRect(SpriteData.GameArt_Path.."meter.png",372, 6)
	meterBase.anchorX = 0.5
	meterBase.anchorY = 0.5
	meterBase.x = centerX
	meterBase.y = vars.distanceMeter.y
	hudGroup:insert(meterBase)
	meterBase:toBack()
	--]]	
	
	----------------------------------------------------------------------------------------------------
	--Draw the Attempt text when the game begins
	----------------------------------------------------------------------------------------------------
--	attemptsString = display.newText( "Attempt "..levelTrys.attemps, 100, 200, native.systemFont, 40 )
	attemptsString = bmf:newString( myGlobalData.fontAvengeanceWhtBlkSh, "Attempt "..levelTrys.attemps )
	attemptsString.align = "center"
	attemptsString.xScale = 0.4
	attemptsString.yScale = 0.4
	attemptsString.alpha = 0.0
	attemptsString.x = deviceW + 500
	attemptsString.y = centerY
	hudGroup:insert(attemptsString)
	
	local function cleanUpText()
		--attemptsString:removeSelf()
		display.remove(attemptsString)
		attemptsString=nil
		homeButton.alpha = 0.6 -- Show the home Buttone
		restartButton.alpha = 0.6 -- Show the home Buttone
	end
	
	local function moveAttemptsOffScreen()
		local moveAttemptsBanner2 = transition.to(attemptsString, {time=300, x=-200, alpha=0.0,transition=easing.inBack,  delay=700, onComplete=cleanUpText } )
--		local moveAttemptsBanner2 = transition.to(attemptsString, {time=300, x=-200, alpha=0.0,transition=easing.inBack,  delay=700, onComplete=function(event) display.remove(attemptsString) end} )
	end
	
	local moveAttemptsBanner1 = transition.to(attemptsString, {time=300, x=centerX, alpha=1.0, transition=easing.outBack, onComplete=moveAttemptsOffScreen} )
	
	
	--Move the meter indicator to the start pos.
	vars.distanceMeter.x = meterBase.x - (meterBase.width*0.5) + 1--.5
	
	--startCreating the level
	--vars.buildLevelTimer = timer.performWithDelay( 120, checkTime, vars.zoneTableW )
	--previousPositionX = previousPositionX + 1
	buildZone() --starts ball rolling.

	-----------------------------------------------------------------
	--Set the BASE Platforms scrolling
	-----------------------------------------------------------------
	if (vars.addBaseLayer == true ) then
		platform1Group.enterFrame = scrollPlatform
		Runtime:addEventListener("enterFrame", platform1Group)

		platform2Group.enterFrame = scrollPlatform
		Runtime:addEventListener("enterFrame", platform2Group)
    end
	-----------------------------------------------------------------

	-----------------------------------------------------------------
	--Set the BACKDROUND Platforms scrolling
	-----------------------------------------------------------------
	if (vars.addBGLayer == true ) then
		backgroundScoll1Group.enterFrame = bgPlatform
		Runtime:addEventListener("enterFrame", backgroundScoll1Group)

		backgroundScoll2Group.enterFrame = bgPlatform
		Runtime:addEventListener("enterFrame", backgroundScoll2Group)
    end
	-----------------------------------------------------------------

	-----------------------------------------------------------------
	--Set the FOREGROUND Platforms scrolling
	-----------------------------------------------------------------
	if (vars.addFGLayer == true ) then
		foregroundScoll1Group.enterFrame = bgPlatform
		Runtime:addEventListener("enterFrame", foregroundScoll1Group)

		foregroundScoll2Group.enterFrame = bgPlatform
		Runtime:addEventListener("enterFrame", foregroundScoll2Group)
    end
	-----------------------------------------------------------------




	---------------------------------------------------------------
	--restart button
	---------------------------------------------------------------
	restartButton = display.newImageRect(SpriteData.GUI_Path.."buttonReset.png",38,38)
	restartButton.xScale = 1.4
	restartButton.yScale = 1.4
	restartButton.x = 45
	restartButton.y = 60--sizeGetH-45
	restartButton.alpha = 0.0
	hudGroup:insert( restartButton )

	---------------------------------------------------------------
	--quit/home button
	---------------------------------------------------------------
	local sizeGetW = myGlobalData._w
	local sizeGetH = myGlobalData._h

	homeButton = display.newImageRect(SpriteData.GUI_Path.."buttonHome.png",38,38)
	homeButton.xScale = 1.4
	homeButton.yScale = 1.4
	homeButton.x = sizeGetW-45
	homeButton.y = 60--sizeGetH-45
	homeButton.alpha = 0.0
	hudGroup:insert( homeButton )

	-----------------------------------------------------------------
	--Insert all the actors/sprites into correct screen groups
	-----------------------------------------------------------------
	screenGroup:insert( backgroundGroup )
	screenGroup:insert( backgroundScoll1Group )
	screenGroup:insert( backgroundScoll2Group )
	
	cameraGroup:insert( foregroundScoll1Group )
	cameraGroup:insert( foregroundScoll2Group )
	
	cameraGroup:insert( playerStartEndGroup )
	cameraGroup:insert( platform3Group )
	cameraGroup:insert( platform1Group )
	cameraGroup:insert( platform2Group )
	cameraGroup:insert( obsticlesGroup )
	cameraGroup:insert( playerGroup )
	cameraRotateGroup:insert( cameraGroup )
	screenGroup:insert( cameraRotateGroup )
	screenGroup:insert( hudGroup )


	-----------------------------------------------------------------
	--Reserve Channels 1, 2, 3 for Specific audio
	-----------------------------------------------------------------
	audio.reserveChannels( 4 )

   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
      
	-----------------------------------------------------------------
	-- Stop the GAME music playing on channel 2
	-----------------------------------------------------------------
 	audio.stop(1)

	-----------------------------------------------------------------
	-- Start the MENU Music - Looping
	-----------------------------------------------------------------		
	vars.gameMusic = audio.play(myGlobalData.musicGame, {channel=1, loops = -1})


	---------------------------------------------------------------
	-- Add event listeners to the touch areas
	---------------------------------------------------------------
	vars.tapJump:addEventListener( "touch", tapJumpEvent)
	restartButton:addEventListener( "touch", restartTouched )
	homeButton:addEventListener( "touch", homeTouched )
	Runtime:addEventListener( "key", onKeyEvent )

	-- start game running procedures
	--startGameRunning()


	local getPlayerXPos = player.x
	local getPlayerYPos = player.y
	
	player.y = player.y-64
	
	--local function endProcedure()
	--	startGame = true
	--end

	local function endProcedure()
		startGame = true	-- This is picked up in the UpdateTick function and starts the game.
		local showPlayer = transition.to(player, {time=300, xScale=1.0, yScale=1.0, alpha=1.0, onComplete=function() vars.emitter.alpha=1.0 end} )

		
		for i=#startRings,1,-1 do
		  local child = table.remove(startRings, i)    -- Remove from table
		  if child ~= nil then
			--child:removeSelf()
			display.remove(child)
			child = nil
		  end
		end


	end

	player.alpha	= 0.0
	player.xScale	= 0.1
	player.yScale	= 0.1
	---------------------------------------------------------------------------------------------------------
	-- Create 2 x Expanding circles before the player / game begins.
	---------------------------------------------------------------------------------------------------------
	math.randomseed( os.time() )
	for i=1,3 do
		local scaleRandom = math.random(2,8)
		startRings[i] = display.newCircle( getPlayerXPos, getPlayerYPos+(player.height/2), math.random(4,12) )
		startRings[i]:setFillColor(  returnRGB(startRingFillColour1[1]), returnRGB(startRingFillColour1[2]), returnRGB(startRingFillColour1[3]), startRing1FillAlpha  )
		startRings[i].strokeWidth = startRing1StrokeWidth
		startRings[i]:setStrokeColor( returnRGB(startRingStrokeColour1[1]), returnRGB(startRingStrokeColour1[2]), returnRGB(startRingStrokeColour1[3]), startRing1StrokeAlpha  )
		playerStartEndGroup:insert( startRings[i] )
		local expandRing = transition.scaleTo(startRings[i], {time=300, xScale=scaleRandom, yScale=scaleRandom, alpha=0.0, onComplete=endProcedure} )
	end

	for i=4,7 do
		local scaleRandom = math.random(2,8)
		startRings[i] = display.newCircle( getPlayerXPos, getPlayerYPos+(player.height/2), math.random(40,70) )
		startRings[i]:setFillColor(  returnRGB(startRingFillColour2[1]), returnRGB(startRingFillColour2[2]), returnRGB(startRingFillColour2[3]), startRing2FillAlpha  )
		startRings[i].strokeWidth = startRing2StrokeWidth
		startRings[i]:setStrokeColor(   returnRGB(startRingStrokeColour2[1]), returnRGB(startRingStrokeColour2[2]), returnRGB(startRingStrokeColour2[3]), startRing2StrokeAlpha  )
		playerStartEndGroup:insert( startRings[i] )
		local expandRing = transition.scaleTo(startRings[i], {time=600, xScale=0.1, yScale=0.1, alpha=0.0, onComplete = function(event) display.remove(startRings[i]) end} )
	end




	--changeScreenDirection()
	
	
	--temp
	--enterPortalRoutine()
	
	
   end
end

-----------------------------------------------------------------
--Update the Scrolling elements
-----------------------------------------------------------------		

function scrollPlatform(self,event)
	if (vars.gameOver==false) then
		if self.x <= -637 then
			self.x = 640 - vars.scrollSpeed
		else 
			self.x = self.x - self.speed
		end
	end
end


function bgPlatform(self,event)
	if (vars.gameOver==false) then
		if self.x <= -1021 then
			self.x = 1024 - vars.scrollSpeed
		else 
			self.x = self.x - self.speed
		end
	end
end


local function touch( event )
		player.x, player.y = event.x, event.y
	return true
end

function returnRGB(value)
	return value/255
end


function changeScreenDirection()
	
	local systemCameraMaxHeight = cameraMaxHeight
	
	if ( gameDirection == "left_to_Right" ) then
	
		cameraGroup.anchorChildren = true
		cameraGroup.rotation = 0
		cameraRotateGroup.y = 0

	else

		--cameraMaxHeight = -100
		cameraGroup.anchorChildren = true

		cameraRotateGroup.anchorX = 0.5
		cameraRotateGroup.anchorY = 0.5

		cameraGroup.anchorX = 0.5
		cameraGroup.anchorY = 0.5

		cameraGroup.rotation = 180
		--cameraGroup.y = centerY+300
		--cameraRotateGroup.y = 50
		cameraRotateGroup.x = centerX-256
		cameraRotateGroup.y=0
		--cameraGroup.anchorChildren = false
	end

end


--[[
-----------------------------------------------------------------
-- Fade the Background Colours - loop
-----------------------------------------------------------------
 function fadeColour1(obj)
	cTrans:colorTransition(obj, BGColour_1, BGColour_2, 1200, { onComplete=fadeColour2} )
end
 function fadeColour2()
	cTrans:colorTransition(obj, BGColour_2, BGColour_3, 1200, { onComplete=fadeColour3} )
end
 function fadeColour3()
	cTrans:colorTransition(obj, BGColour_3, BGColour_1, 1200, { onComplete=fadeColour1} )
end
--]]

---------------------------------------------------------------------------------------------------------
-- create a exploding sequence for each of the biscuit parts
---------------------------------------------------------------------------------------------------------
local function explodePlayer(gotDieX, gotDieY)

	---------------------------------------------------------------------------------------------------------
	-- explode player properties 
	---------------------------------------------------------------------------------------------------------
	local numOfexplodeParticleParticles	= 40
	local explodeParticleFadeTime 		= 600
	local explodeParticleFadeDelay 		= 80
	local minexplodeParticleVelocityX 	= -500
	local maxexplodeParticleVelocityX 	= 300
	local minexplodeParticleVelocityY 	= -400
	local maxexplodeParticleVelocityY 	= 0
	local explodeChoppedProp 			= {density = 1.0, friction = 0.3, bounce = 0.2, filter = {categoryBits = 4, maskBits = 8} } 
	local explodeTransition
	local explodeParticle
	local explodeParticleArray = {}

	---------------------------------------------------------------------------------------------------------
	-- Create 2 x Expanding circles when player dies.
	---------------------------------------------------------------------------------------------------------
	endRing[1] = display.newCircle( gotDieX, gotDieY, 20 )
	endRing[1].fill = { returnRGB(dieRingColour1[1]), returnRGB(dieRingColour1[2]), returnRGB(dieRingColour1[3])}
	endRing[1].alpha = 0.8
	playerStartEndGroup:insert( endRing[1] )

	endRing[2] = display.newCircle( gotDieX, gotDieY, 10 )
	endRing[2].fill = { returnRGB(dieRingColour2[1]), returnRGB(dieRingColour2[2]), returnRGB(dieRingColour2[3])}
	endRing[2].alpha = 0.8
	playerStartEndGroup:insert( endRing[2] )

	local expandRing1 = transition.to(endRing[1], {time=400, xScale=3.5, yScale=3.5, alpha=0.0, onComplete = function(event) display.remove(endRing[1]) end} )
	local expandRing2 = transition.to(endRing[2], {time=300, xScale=4.0, yScale=4.0, alpha=0.0, onComplete = function(event) display.remove(endRing[2]) end} )

	---------------------------------------------------------------------------------------------------------
	-- Create a series of pixels to give effect of explosion.
	---------------------------------------------------------------------------------------------------------
	for  i = 1, numOfexplodeParticleParticles do
		local random = math.random
		local rndSize = random(4,4)
		explodeParticle = display.newRect(0,0,rndSize,rndSize)
		playerStartEndGroup:insert( explodeParticle )
		explodeParticle:setFillColor( returnRGB(dieColourExplosion[1]), returnRGB(dieColourExplosion[2]), returnRGB(dieColourExplosion[3]) )
		explodeParticle.x = gotDieX
		explodeParticle.y = gotDieY
		explodeParticle.xScale = 1.3
		explodeParticle.yScale = 1.3
		--explodeChoppedProp.radius = explodeParticle.width *0.5
		local explodeMaterial = { "dynamic", density=10.0, friction=1.2, bounce=0.6, radius=explodeParticle.width *0.5, filter=collisionData.Player_FD }
		physics.addBody(explodeParticle, explodeMaterial)

		---------------------------------------------------------------------------------------------------------
		-- set each of the exploded bit with a random X, Y velocity.
		---------------------------------------------------------------------------------------------------------
		local xVelocity = random(minexplodeParticleVelocityX, maxexplodeParticleVelocityX)
		local yVelocity = random(minexplodeParticleVelocityY, maxexplodeParticleVelocityY)
		explodeParticle:setLinearVelocity(xVelocity, yVelocity)
		explodeTransition = transition.to(explodeParticle, {time = explodeParticleFadeTime, delay = explodeParticleFadeDelay, alpha=0, onComplete = function(event) display.remove(explodeParticle) end})		
	end				
end


---------------------------------------------------------------
--Handle Collisions
---------------------------------------------------------------
local function onGlobalCollision( event )

	if ( vars.gameOver==false) then
		if ( vars.invincibleMode==false) then
	
			if ( event.phase == "began" ) then
	
				--print( "Global report: " .. event.object1.myName .. " & " .. event.object2.myName .. " collision began" )
				----------------------------------------------------------------------------------------------------
				-- Check if we're on a platform (to enable a jump)
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "platform" and event.object2.myName == "player") then
					playOnPlatform = true
					playerOnFloor = true
					if (playerCanFly == true) then
						vars.gameOver = true
						gameOverStartRoutine("restart")
					end
				elseif (event.object1.myName == "player" and event.object2.myName == "platform") then
					playOnPlatform = true
					playerOnFloor = true
					if (playerCanFly == true) then
						vars.gameOver = true
						gameOverStartRoutine("restart")
					end
				else
					playerOnFloor = false
				end 


				----------------------------------------------------------------------------------------------------
				-- Check if we're on a Block (to enable a jump)
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "floor" and event.object2.myName == "player") then
					playOnPlatform = true
					playerOnFloor = true
				elseif (event.object1.myName == "player" and event.object2.myName == "floor") then
					playOnPlatform = true
					playerOnFloor = true
				else
					playerOnFloor = false
				end 


				----------------------------------------------------------------------------------------------------
				-- Check if we've reached the Goal Post at the end
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "goal" and event.object2.myName == "player") then
					goalReachedRoutine()
				elseif (event.object1.myName == "player" and event.object2.myName == "goal") then
					goalReachedRoutine()
				end 


				----------------------------------------------------------------------------------------------------
				-- Check if we've gone through a portal
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "portal" and event.object2.myName == "player") then
					enterPortalRoutine()
				elseif (event.object1.myName == "player" and event.object2.myName == "portal") then
					enterPortalRoutine()
				end 


				----------------------------------------------------------------------------------------------------
				-- Check if we've hit a hazard - trigger a reset
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "hazard" and event.object2.myName == "player") then
					vars.gameOver = true
					gameOverStartRoutine("restart")
				elseif (event.object1.myName == "player" and event.object2.myName == "hazard") then
					vars.gameOver = true
					gameOverStartRoutine("restart")
				end 

				----------------------------------------------------------------------------------------------------
				-- Check if we've landed in a pit - trigger a reset
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "pit" and event.object2.myName == "player") then
					vars.gameOver = true
					gameOverStartRoutine("restart")
				elseif (event.object1.myName == "player" and event.object2.myName == "pit") then
					vars.gameOver = true
					gameOverStartRoutine("restart")
				end 

				----------------------------------------------------------------------------------------------------
				-- Check if we've collected a coin type 1 (small?)
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "coin1" and event.object2.myName == "player") then
					if (event.object1.alpha > 0.0) then
						coinSmall_Collected = coinSmall_Collected + 1
						event.object1.alpha = 0.0
						print("Small Coins = "..coinSmall_Collected)
					end
				elseif (event.object1.myName == "player" and event.object2.myName == "coin1") then
					if (event.object2.alpha > 0.0) then
						coinSmall_Collected = coinSmall_Collected + 1
						event.object2.alpha = 0.0
						print("Small Coins = "..coinSmall_Collected)
					end
				end 

				----------------------------------------------------------------------------------------------------
				-- Check if we've collected a coin type 1 (big?)
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "coin2" and event.object2.myName == "player") then
					if (event.object1.alpha > 0.0) then
						coinLarge_Collected = coinLarge_Collected + 1
						event.object1.alpha = 0.0
						print("Large Coins = "..coinLarge_Collected)
					end
				elseif (event.object1.myName == "player" and event.object2.myName == "coin2") then
					if (event.object2.alpha > 0.0) then
						coinLarge_Collected = coinLarge_Collected + 1
						event.object2.alpha = 0.0
						print("Large Coins = "..coinLarge_Collected)
					end
				end 

				----------------------------------------------------------------------------------------------------
				-- Check if we hit a AUTO jump trigger
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "bounceFloor" and event.object2.myName == "player") then
					tapJumpEvent("force")
				end 


				----------------------------------------------------------------------------------------------------
				-- Check if we hit a mid air jump sprite
				----------------------------------------------------------------------------------------------------
				if (event.object1.myName == "bounceAir" and event.object2.myName == "player") then
					bonusHeight	= standardJumpHeight
					playerIsJumping = false
					playOnPlatform = true
					--tapJumpEvent("force")
				end 
				
				
			
				
				--[[
				--Check to see if it's game over!
				if (event.object1.myName == "hazard" and event.object2.myName == "player") then
					local function gameEnd()
						vars.gameOver = true
						audio.play(myGlobalData.Sfx_Hit)
						--Call the Explode Player functions
						explodePlayer()
					end
					timer.performWithDelay(2, gameEnd )
				end 
				--]]
				
			elseif ( event.phase == "ended" and vars.gameOver==false) then
	
			end
	
		end
	end
	
end


--function checkTime(event)
--	previousPositionX = previousPositionX + 1 --PreviousPositionX is the Zone COLUMNS
--	buildZone()--zones[scrollCount+1])
--	--print(previousPositionX)
--end



--[[
function startGameRunning()

	local getPlayerXPos = player.x
	local getPlayerYPos = player.y
	
	player.y = player.y-64
	
	--local function endProcedure()
	--	startGame = true
	--end

	local function endProcedure()
		startGame = true	-- This is picked up in the UpdateTick function and starts the game.
		local showPlayer = transition.to(player, {time=300, xScale=1.0, yScale=1.0, alpha=1.0, onComplete=function() vars.emitter.alpha=1.0 end} )

		--tapJumpEvent("force")
		
		--Clean up: Remove the rings from memory.
		for i=1,#startRings do
			local v = startRings[i]
			if ( v  ) then
				v:removeSelf( )
				table.remove( startRings,i )
			end
			v = nil
		end
		
	end

	player.alpha	= 0.0
	player.xScale	= 0.1
	player.yScale	= 0.1
	---------------------------------------------------------------------------------------------------------
	-- Create 2 x Expanding circles before the player / game begins.
	---------------------------------------------------------------------------------------------------------
	math.randomseed( os.time() )
	for i=1,3 do
		local scaleRandom = math.random(2,8)
		startRings[i] = display.newCircle( getPlayerXPos, getPlayerYPos+(player.height/2), math.random(4,12) )
		startRings[i]:setFillColor(1,1,1,0.0)
		startRings[i].strokeWidth = 1
		startRings[i]:setStrokeColor(1,1,1,0.5)
		playerStartEndGroup:insert( startRings[i] )
		local expandRing = transition.scaleTo(startRings[i], {time=300, xScale=scaleRandom, yScale=scaleRandom, alpha=0.0, onComplete=endProcedure} )
	end

	for i=4,7 do
		local scaleRandom = math.random(2,8)
		startRings[i] = display.newCircle( getPlayerXPos, getPlayerYPos+(player.height/2), math.random(40,70) )
		startRings[i]:setFillColor(1,1,1,0.0)
		startRings[i].strokeWidth = 1
		startRings[i]:setStrokeColor(1,1,1,0.5)
		playerStartEndGroup:insert( startRings[i] )
		local expandRing = transition.scaleTo(startRings[i], {time=600, xScale=0.1, yScale=0.1, alpha=0.0} )
	end


end
--]]




---------------------------------------------------------------
-- Update Animations every tick/cycle
---------------------------------------------------------------
function updateTick(event)

	
	--print("BLOCK X POS: "..lastBlockX)
	
	if (vars.gameOver == false and startGame == true ) then
		
		--print("Flying Player X: "..playerFlying.x)
		--print("Fixed X Position X: "..playerFixedXPosition)
	
	
		if (playerCanFly == true ) then
			
			--Sparks from the flying player
			vars.emitter.x = playerFlying.x - (playerFlying.width/2)
			vars.emitter.y = playerFlying.y+10

			local getPlayerY = math.round(math.abs(playerFlying.y-playerFixedXPosition))
			local cameraY = math.round(cameraGroup.y)
			local cameraX = math.round(cameraGroup.x)
			
			cameraGroup.y = getPlayerY-100
			--[[
			if ( getPlayerY > cameraMaxHeight and cameraY == 0 ) then
				cameraMoveTimer[1] = transition.moveTo( cameraGroup, { y=(getPlayerY),x=cameraX, time=400 } )
			elseif  ( getPlayerY < (cameraMaxHeight - 10) and cameraY > 0 ) then
				cameraMoveTimer[2] = transition.moveTo( cameraGroup, { y=0, time=400 } )
			end
			--]]
	
			local vx, vy = playerFlying:getLinearVelocity()
			playerFlying.x = playerFixedXPosition
			--print(vy)
			
			--if (vy > 0 ) then
				--playerFlying.angularVelocity = 10
				--playerFlying:applyAngularImpulse( -100 )
			--end
			
			--local arAngle = math.atan2(vy, vx)
			--playerFlying.rotation = arAngle * 180 / math.pi

			
			local maxAngle = 35
			--if (playerFlying.rotation >= 0 ) then
			--	playerFlying.rotation = playerFlyingAngle + (vy/10)
			--else
				playerFlying.rotation = (vy/10)
			--end
			
			if (playerFlying.rotation < -maxAngle ) then
				playerFlying.rotation = -maxAngle
			elseif (playerFlying.rotation > maxAngle ) then
				playerFlying.rotation = maxAngle
			else			
			end
			
			--if (playerFlying.rotation >-45 and playerFlying.rotation < 45 ) then
				--playerFlying.rotation =  playerFlying.rotation + (vy/1000)
				--playerFlying.rotation = playerFlyingAngle + (vy/10)
			--end
			--local flyRotation = transition.moveTo( playerFlying, { rotation = (vy/10), time=100 } )


		elseif (playerCanFly == false ) then
			
			--Sparks from the ground running player
			vars.emitter.x = player.x - (player.width/2)
			vars.emitter.y = player.y + (player.height/2)

			local getPlayerY = math.round(math.abs(player.y-playerFixedXPosition))
			local cameraY = math.round(cameraGroup.y)
			local cameraX = math.round(cameraGroup.x)
			--print ("----------------------------------")
			--print ("PLAYER Y: "..getPlayerY)
			--print ("CAMERA Y: "..cameraY)
			--print ("----------------------------------")

			--if(playerIsJumping==false) then
			--cameraGroup.y = getPlayerY

		
		if ( gameDirection == "left_to_Right" ) then
			if ( getPlayerY > cameraMaxHeight and cameraY == 0 ) then
				cameraGroupcameraMoveTimer[1] = transition.moveTo( cameraGroup, { y=(getPlayerY+myGlobalData.deviceExtraY), time=400 } )
			elseif  ( getPlayerY < ((cameraMaxHeight+myGlobalData.deviceExtraY)-10) and cameraY > 0 ) then
				cameraMoveTimer[2] = transition.moveTo( cameraGroup, { y=0, time=400 } )
			end
		else
	
		if ( getPlayerY > cameraMaxHeight and cameraY == 0 ) then
			--print ("Adjusting Camera Y UP!")
			cameraMoveTimer[1] = transition.moveTo( cameraGroup, { y=(getPlayerY),x=cameraX, time=400 } )
		elseif  ( getPlayerY < (cameraMaxHeight - 10) and cameraY > 0 ) then
			--print ("Adjusting Camera Y DOWN!")
			--if (cameraMoveTimer[1]) then
			--transition.cancel( cameraMoveTimer[1] )
			--else
			cameraMoveTimer[2] = transition.moveTo( cameraGroup, { y=0, time=400 } )
			--end
		end
		
end
	
	end
		
		
		--Make sure the player is locked in the X Axis
		--This will get overridden later !
		--player.x = playerFixedXPosition
		
		--Check if the players have been hit BACKWARDS
		-- This would mean they've hit a block/platform
		-- So it's Game Over !
		if(player.x < (playerFixedXPosition-6)) then
			vars.gameOver = true
			gameOverStartRoutine("restart")
		end

		if(playerFlying.x < (playerFixedXPosition-6)) then
			vars.gameOver = true
			gameOverStartRoutine("restart")
		end
		
		--[[
		--Track the players X/Y Pos for the vars.emitter (sparks)		
		if (playerCanFly == true ) then
		else
		end
		--]]

		if( playerOnFloor == true) then
			--transition.from( highlight, { time=200, alpha=0.8 } )
			--highlight.alpha = 0.8
		else
			--transition.from( highlight, { time=200, alpha=0.0 } )
			--highlight.alpha = 0.0
		end

		function destroyBlock(event)
		
		end

		for i = 1, #blocksArray do
			local box = blocksArray[i]
			--box.x = box.x - vars.scrollSpeed

			if ( box.destroy ) then
				display.remove(box)
				box=nil
			end


			if (box and box.trackable and box.destroy==false) then
			
				box.x = box.x - vars.scrollSpeed
				
				if ( vars.sceneEffectOut == true ) then
					if (box.x < left+(box.width*2)) then
						local AnimationTransition = transition.fadeOut( box, { time=100, x=(left+(box.width*0.5)), alpha=0.0, onComplete=function() box.destroy=true end} )
					end
				elseif (box.x < left) then
					box.destroy=true
				end
				-- update the distance meter
				if (box.x <= centerX and box.positionRegistered == false) then
					box.positionRegistered = true
					vars.distanceMeter.width = ((vars.meterMaxWidth / vars.zoneTableW) * previousPositionX) - (100/vars.zoneTableW)-- + 1.3
				end

				--box:update()
				lastBlockX = blocksArray[#blocksArray].x + (blocksArray[#blocksArray].width)

				if (  lastBlockX < deviceW  ) then --Draw the next block in the zone
					if ( previousPositionX < vars.zoneTableW ) then -- Have we reach the end of the level?
						previousPositionX = previousPositionX + 1
						buildZone()
					end
				end
								
				
			end
			--if (box.x < 100) then
			--	--print("Block: "..i.." | X = "..box.x)
			--	transition.to( box, { time=100, alpha=0.0 } )
			--end
			
		end

		
		if (table.maxn(blocksArray) > 0) then
		
				for i=1,#blocksArray do
					local v = blocksArray[i]
					if ( v and v.destroy ) then
						--v:removeSelf( )
						display.remove(v)
						v=nil
						table.remove( blocksArray,i )
						break
					end
					v = nil
				end
				
		end

	
	
	else
	
		--print("END-------------------")
		
		
		--Stop Game Events
		--endGameEvents("screenResetLevel")


		--[[
		-- GAME OVER !
		--> Cancel the timer
		if(scoreTimertimer) then
			timer.cancel(scoreTimertimer)
			scoreTimertimer = nil
		end
	
		player.alpha = 0.0
	
		--save the HighScore
		saveDataTable.highScore 			= myGlobalData.highScore
		loadsave.saveTable(saveDataTable, "dba_vc_template_data.json")

		--reposition score fields
		scoreDisplay.anchorX = 0.5
		scoreDisplay.x = sizeGetW*0.5
		scoreDisplay.y = (sizeGetH*0.5)-30
		highScoreDisplay.alpha = 0.7
	
		highScoreDisplay.anchorX = 0.5
		highScoreDisplay.x = sizeGetW*0.5
		highScoreDisplay.y = (sizeGetH*0.5)
		highScoreDisplay.alpha = 0.8

		restartButton.anchorX = 0.5
		restartButton.x = (sizeGetW*0.5)-25
		restartButton.y = (sizeGetH*0.5)+50
		restartButton.alpha = 0.8

		homeButton.anchorX = 0.5
		homeButton.x = (sizeGetW*0.5)+25
		homeButton.y = (sizeGetH*0.5)+50
		homeButton.alpha = 0.8


		--Stop events
		Runtime:removeEventListener( "enterFrame", updateTick )
		Runtime:removeEventListener ( "collision", onGlobalCollision )
		--]]

		--remove the rings/walls
		--[[
		if (enableRings==true) then
			for i=1, 3 do
				physics.removeBody(wall[i])
				wall[i]:removeSelf()
				wall[i]=nil
			end
		end
		--]]


	end

end


---------------------------------------------------------------
-- Gone through a Portal Routine
---------------------------------------------------------------
function enterPortalRoutine()
	
	if (vars.gameOver==false) then
		collectFlyingPlayersY = playerFlying.y
		collectGroundPlayersY = player.y
	end
		
	local function changePlayer_to_Flying()
		if (vars.gameOver==false) then

			playerFlying.y = collectGroundPlayersY

			local function applyPhysics()
				--Collect the flying players physics data
				local playerSpriteRef = SpriteData.spriteSetup[140]
				playerFlyingPhysics = playerSpriteRef.spritePhysics
				physics.addBody( playerFlying, playerFlyingPhysics )
				playerFlying.isSensor 				= playerSpriteRef.se
				playerFlying.myName 				= playerSpriteRef.cn
				playerFlying.rotation 				= 0
				--print("Player now flying...")
				playerCanFly = true
				--playerFlying.y = collectGroundPlayersY
			end

			--Morph Running Player into the Flying Player.
			local makeVisibleFlyingPlayer 	= transition.to( playerFlying,	{ time=200, xScale = 1.0, yScale=1.0, alpha=1.0, onComplete=applyPhysics} )
			local makeInvisibleNormalPlayer = transition.to( player, 		{ time=200, xScale = 0.1, yScale=0.1, alpha=0.0, } )

			--Remove the STANDARD players physics body
			local function removePhysicsBody()
            	if not player.bodyWasRemoved then
					physics.removeBody(player)
					player.bodyWasRemoved = true
				end
			end
			timer.performWithDelay( 200, removePhysicsBody )
		end
	end
	
	local function changePlayer_to_Ground()
		if (vars.gameOver==false) then
			--cameraGroup.y = 0
			cameraMoveTimer[1] = transition.moveTo( cameraGroup, { y=0, time=200 } )
			--print("Player now on the Ground...")
			player.y 						= playerFlying.y
			playerCanFly = false

			--Collect the ground running players physics data
			local playerSpriteRef = SpriteData.spriteSetup[myGlobalData.defaultPlayer]

			physics.addBody( player, playerPhysics )
			player.isFixedRotation 			= true
			player.isSensor 				= playerSpriteRef.se
			player.myName 					= playerSpriteRef.cn
			player.rotation 				= 0
			player.x 						= playerFixedXPosition
		
			--Morph Running Player into the Flying Player.
			local makeVisibleNormalPlayer 	= transition.to( player,			{ time=200, xScale = 1.0, yScale=1.0, alpha=1.0} )
			local makeInvisibleFlyingPlayer = transition.to( playerFlying, 		{ time=200, xScale = 0.1, yScale=0.1, alpha=0.0} )

			--Remove the FLYING players physics body
			local function removePhysicsBody()
            	if not playerFlying.bodyWasRemoved then
					physics.removeBody(playerFlying)
					playerFlying.bodyWasRemoved = true
				end
			end
			timer.performWithDelay( 200, removePhysicsBody )
		end
	end
	
	if (playerCanFly == false) then
		timer.performWithDelay( 300, changePlayer_to_Flying )
	else
		timer.performWithDelay( 300, changePlayer_to_Ground )
	end

end



---------------------------------------------------------------
-- Goal reached (ie the end of the level routine)...
---------------------------------------------------------------
function goalReachedRoutine()
	
	print("Level Completed....")

	--Set the Player Reached Boolean to true
	playerReachedGoal	= true
	
	--Stop any more level data being loaded..
	vars.stopObjectSpawns 	= true
	vars.gameOver 			= true
	
	--Stop the Level objects Scrolling
	vars.scrollSpeed 		= 0

	--Stop the Background and Floor Scrolling
	--Runtime:removeEventListener( "enterFrame", platform1Group)
    --Runtime:removeEventListener( "enterFrame", platform2Group)
    --Runtime:removeEventListener( "enterFrame", backgroundScoll1Group)
    --Runtime:removeEventListener( "enterFrame", backgroundScoll2Group)
	
	--Draw the Level Completed Text
	--local completedText = display.newText( "Level Completed", 100, 200, native.systemFont, 40 )
	local completedText = bmf:newString( myGlobalData.fontAvengeanceWhtBlkSh, "Level Completed " )
	completedText.align = "center"
	completedText.xScale = 0.4
	completedText.yScale = 0.4
	completedText.alpha = 0.0
	completedText.x = deviceW + 500
	completedText.y = centerY
	hudGroup:insert(completedText)	

	local showCompletedText = transition.to(completedText, {time=300, x=centerX, alpha=1.0, transition=easing.outBack} )

	
	--Collect Players X and Y Position | then remove player from stage
	--We also collect the flying players x/y depending which player type was in use at the end.
	local playerX = player.x
	local playerY = player.y
	if (playerCanFly == true ) then
		playerX = playerFlying.x
		playerY = playerFlying.y
	end


	local function proceedToComplete()
		display.remove(completedText)
		completedText=nil

		--Remove the players and emitters
		--display.remove(vars.emitter); 		vars.emitter = nil
		--display.remove(player); 		player=nil
		--display.remove(playerFlying); 	player=nil
		
		--[[
		--Remove everything from the Obstacles Group
		for i=#blocksArray,1,-1 do
		  local child = table.remove(blocksArray, i)
		  if child ~= nil then
			child:removeSelf()
			display.remove(child)
			child = nil
		  end
		end
		cleanGroups(obsticlesGroup)
		--]]

		--endGameEvents("screenMenu")
		gameOverStartRoutine("quit")

	end


	--Hide the reset and quit buttons
	restartButton.alpha = 0.0
	--homeButton.alpha = 0.0


	local effectLines = 50
	local effectsCounter = 0
	math.randomseed( os.time() )
	
	local function winEffect()
		local positionRandomX = math.random(playerX-200)
		local positionRandomY = math.random(playerY+400)
		local drawLine = display.newLine( playerX+32, playerY, positionRandomX-100, positionRandomY-200  )
		drawLine:setStrokeColor( 1, 1, 1, (math.random( 6,10 )/100) )
		drawLine.strokeWidth = math.random( 20 )
		obsticlesGroup:insert(drawLine)	
		drawLine:toBack()
		effectsCounter = effectsCounter + 1
		if (effectsCounter == effectLines) then
			timer.performWithDelay( 400, proceedToComplete ) --Draw the Winn effect 50 times, 500th of a second
		end
	end
	
	
	timer.performWithDelay( 5, winEffect, effectLines ) --Draw the Winn effect 50 times, 500th of a second

	






end




---------------------------------------------------------------
-- PLAY button function
---------------------------------------------------------------
local function buttonPlay()
	vars.crashSFX = audio.play(myGlobalData.sfx_Select)
	
	changeTheScene = true
	dataReset.VariableReset()

	composer.gotoScene( "screenWorldSelect", "crossFade", 200  )
	return true
end

---------------------------------------------------------------
-- OPTIONS button function
---------------------------------------------------------------
local function buttonOptions()
	local audioPlay = audio.play(myGlobalData.sfx_Select)
	
	changeTheScene = true
	composer.gotoScene( "screenOptions", "crossFade", 200  )
	return true
end


local mDeg  = math.deg
local mRad  = math.rad
local mCos  = math.cos
local mSin  = math.sin
local mAcos = math.acos
local mAsin = math.asin
local mSqrt = math.sqrt
local mCeil = math.ceil
local mFloor = math.floor
local mAtan2 = math.atan2
local mPi = math.pi


function angle2Vector( angle, tableRet )
	local screenAngle = mRad(-(angle+90))
	local x = mCos(screenAngle) 
	local y = mSin(screenAngle) 
	if(tableRet == true) then	
		return { x=-x, y=y }
	else	
		return -x,y
	end
end


function scale( ... ) 	
	if( type(arg[1]) == "number" ) then		
		local x,y = arg[1] * arg[3], arg[2] * arg[3]		
		if(arg[4]) then			
			return { x=x, y=y }		
		else			
			return x,y		
		end	
		
	else		
		local x,y = arg[1].x * arg[2], arg[1].y * arg[2]		
		if(arg[3]) then			
			return x,y		
		else			
			return { x=x, y=y }		
		end	
	end
end


function tapJumpEvent(event)

	if ( vars.gameOver == false ) then
		
		if(event.phase == "began" or event.phase == "down" or event == "force" ) then

			if (playerCanFly == true ) then
				playerFlyingAngle = playerFlying.rotation
				playerFlying:applyLinearImpulse( 0, -200, playerFlying.x, playerFlying.y )
				playerFlying.x = playerFixedXPosition
				--if (playerFlying.angularVelocity < 10) then
					--playerFlying:applyAngularImpulse( -100 )
					--playerFlying.angularVelocity = 100
				--	playerFlying.angularDamping = 1
				--end
			
			elseif (playerCanFly == false ) then

			if (playerIsJumping==false and playOnPlatform==true ) then


				playerIsJumping = true
				playOnPlatform = false
			
				local oldY = player.y
				local calculateJumpHeight = ( (standardJumpHeight + bonusHeight) / ( vars.scrollSpeed / 4 ) )
	
				local currentAngle = math.round(player.rotation)
				--local newAngle = (currentAngle %360) + 180

				local newAngle = 0
				if (vars.playerJumpStyle) == 0 then
					newAngle= currentAngle + 0
				elseif vars.playerJumpStyle == 1 then
					newAngle= currentAngle + 90
				elseif vars.playerJumpStyle == 2 then
					newAngle= currentAngle + 180
				elseif vars.playerJumpStyle == 3 then
					newAngle= currentAngle + 360
				end
	
				vars.emitter.alpha = 0.0

				--transition.to( player, { time=150, alpha=1.0, y=oldY, delay=200 } )

				local function finishedJumping()
					if (vars.gameOver==false) then
						playerIsJumping	= false
						vars.emitter.alpha	= 1.0
						if (bonusHeight > 0) then
							bonusHeight = 0 --We'll reset the bonus jump height here.
						end
					end
				end

				local function moveBackDown( event )
					if ( vars.gameOver == false ) then
						player:applyLinearImpulse( 0, 450, player.x, player.y )
						--transition.to( player, { time=160, y=player.y+calculateJumpHeight, onComplete=finishedJumping } )
					end
				end
	
				player:applyLinearImpulse( 0, -450, player.x-40, player.y )
				--transition.to( player, { time=400, rotation=(math.round(player.rotation)+180) } )
	
				--transition.to( player, { time=(calculateJumpHeight*2), y=player.y-calculateJumpHeight } )
				--transition.to( player, { time=(calculateJumpHeight*6), rotation=newAngle, onComplete=finishedJumping } )
				transition.to( player, { time=(calculateJumpHeight*2), rotation=newAngle, onComplete=finishedJumping } )
	
				timer.performWithDelay( calculateJumpHeight, moveBackDown )
	
				--transition.to( cameraGroup, { time=160, y=cameraGroup.y-player.y } )
	

		  end
  
  
			elseif(event.phase == "ended" or event.phase == "up" ) then
			--playerIsJumping = false

	  
	  		end
	  
		end
		
		
	end
	
end 

-----------------------------------------------------------------
-- Restart  - Button event
-----------------------------------------------------------------
function restartTouched( event )
	if event.phase == "began" then

	elseif event.phase == "ended" then
		--endGameEvents("screenResetLevel")
		gameOverStartRoutine("restart")
	end

	return true
end

-----------------------------------------------------------------
-- Home  - Button event
-----------------------------------------------------------------
function homeTouched( event )
	if event.phase == "began" then

	elseif event.phase == "ended" then
	
		--endGameEvents("screenMenu")		
		gameOverStartRoutine("quit")
		
	end

	return true
end

--function buildZone()
--end

function buildZone()

	local matDensity = 10000
	local matFriction = 12
	local matBounce = 0.1
	local fileName
	local getAngle
	--local vars.theSprite

	local arraySpriteRef
	local arraySpriteRef_Path
	local arraySpriteRef_Name
	local arraySpriteRef_CollisionName
	local arraySpriteRef_Width
	local arraySpriteRef_Height
	local arraySpriteRef_Physics
	local arraySpriteRef_Sensor

	
	if (vars.stopObjectSpawns==false) then
	
		--Track the table X position
		local xx = previousPositionX
		
		--Update the BG Colour if data in level table.		
		local getNewBGColour = zoneColour[xx]
		if ( xx > 1 and #getNewBGColour==3 ) then
			local function updateLastColour()
				vars.lastBGColour = getNewBGColour
			end
			backTransition = cTrans:colorTransition(bgTopColourRect, vars.lastBGColour, getNewBGColour, fadeColourSpeed, { delay=fadeColourDelay} )
			baseTransition = cTrans:colorTransition(vars.basePhysicsBox, vars.lastBGColour, getNewBGColour, fadeColourSpeed, { delay=fadeColourDelay, onComplete=updateLastColour} )
		end

	
		for yy = 1, vars.zoneTableH do
			--local xx = previousPositionX
			local createObject = false
				
				
				--Get the type of hazard loaded from the Level Array
				vars.getType = zones[yy][xx]
					
					if (vars.getType > 0) then
						arrayIndex = #blocksArray+1
						
						--Collect Sprite from the array, based on the currently requested level grid element(vars.getType)
						arraySpriteRef 					= SpriteData.spriteSetup[vars.getType]
						arraySpriteRef_Path 			= arraySpriteRef.path
						arraySpriteRef_Name 			= arraySpriteRef.name
						arraySpriteRef_CollisionName	= arraySpriteRef.cn
						arraySpriteRef_Width 			= arraySpriteRef.sx
						arraySpriteRef_Height 			= arraySpriteRef.sy
						arraySpriteRef_Physics 			= arraySpriteRef.spritePhysics
						arraySpriteRef_Sensor 			= arraySpriteRef.se
						arraySpriteRef_Physical 		= arraySpriteRef.isPhysical
						
						vars.theSprite = arraySpriteRef_Path..arraySpriteRef_Name..".png"
						vars.gameObject = display.newImageRect( vars.theSprite, arraySpriteRef_Width, arraySpriteRef_Height )
						
						vars.gameObject.isPhysical = arraySpriteRef_Physical
						createObject = true
					else
						--Create a BLANK object (along the BASE only).
						if ( yy==vars.zoneTableH ) then
							arrayIndex = #blocksArray+1
							vars.gameObject = display.newRect(0,0, 32,2)
							vars.gameObject:setFillColor( 0,0,0,0.0 )
							vars.gameObject.isPhysical = false
							createObject = true
						else
							-- It's not a Blank - and its not the BASE - so ignore from here.
							createObject = false
						end
					end
					
					if (createObject==true) then --only create physical elements (and the ground layer)...

						local startY = vars.basePhysicsBox.y-(vars.basePhysicsBox.height/2)
						local getY =  (bottom + ((yy*vars.gridSz)-416)) - (vars.gridSz/2) - (vars.gridSz*2)
					
						vars.gameObject.positionRegistered = false
					
						--[[
						function vars.gameObject:update()
							if (vars.gameOver == false) then
								self.x = self.x - vars.scrollSpeed
								if (self.x < left+(self.width*2)) then
									--self.destroy=true
									--Fade blocks out as they leave the scene.
									self.AnimationTransition = transition.scaleTo( self, { time=5, alpha=0.0, onComplete=function() self.destroy=true end} )
								end
								
								-- update the distance meter
								if (self.x <= centerX and self.positionRegistered == false) then
									self.positionRegistered = true
									vars.distanceMeter.width = ((vars.meterMaxWidth / vars.zoneTableW) * xx) - (100/vars.zoneTableW)-- + 1--.3
								end
								
								
							end
						end 
						--]]
						if (vars.sceneEffectIn == true ) then
							if ( (yy*vars.gridSz) < centerX ) then
								vars.gameObject.y = 0
							else
								vars.gameObject.y = deviceH
							end
						else
							vars.gameObject.y = getY+0
						end
						--vars.gameObject.myName = "block"
						vars.gameObject.myName = arraySpriteRef_CollisionName
						
						if (vars.gameObject.isPhysical == true) then
							physics.addBody( vars.gameObject, arraySpriteRef_Physics )
							vars.gameObject.isSensor = arraySpriteRef_Sensor
						else
						
						end
						-- Add some extra parameters and setup to the loaded sprite
						if (vars.sceneEffectIn == true ) then
							vars.gameObject.alpha = 0.0
						else
							vars.gameObject.alpha = 1.0
						end						
						vars.gameObject.destroy 			= false
						vars.gameObject.isObject 		= true
						vars.gameObject.trackable 		= true
						vars.gameObject.x 				= lastBlockX
						vars.gameObject.rotation 		= 0
						vars.gameObject.isFixedRotation 	= true
						vars.gameObject.gravityScale 	= 0
						vars.gameObject.isSleepingAllowed = true

						
						--Put the compiled sprite data into an array to track
						blocksArray[arrayIndex] = vars.gameObject
						
						obsticlesGroup:insert(blocksArray[arrayIndex])
						if (vars.sceneEffectIn == true ) then
							transition.to( blocksArray[arrayIndex], { time=200, alpha=1.0, y=getY+0 } )
						end
						
					end
					
				
		end
	end
	
end





-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )

   local sceneGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.

	local levelsPath = myGlobalData.levelPathR	
	local cleanMyLevel = "level"..level
	package.loaded[levelsPath..cleanMyLevel] = nil
	local cleanMyLevel = "level"..(level-1)
	package.loaded[levelsPath..cleanMyLevel] = nil
	local cleanMyLevel = "level"..(level+1)
	package.loaded[levelsPath..cleanMyLevel] = nil
	package.loaded["colorTransition"] = nil

   --[[
	if (enableExtraHuds==true) then
		display.remove(playerLineTrack1)
		playerLineTrack1 = nil

		display.remove(playerLineTrack2)
		playerLineTrack2 = nil
		
		display.remove(playerInfoDisplay)
		playerInfoDisplay = nil
	end
	
	display.remove(scoreDisplay)
	scoreDisplay = nil

	display.remove(highScoreDisplay)
	highScoreDisplay = nil


	if(explodeTransition) then
		transition.cancel(explodeTransition)
		explodeTransition = nil
	end
	
	--]]

	--Stop Game Events
	--endGameEvents()
	
end


-- Called when a key event has been received
function onKeyEvent( event )
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    --print( message )
    
    if (event.keyName=="space") then
    	tapJumpEvent(event)
    end

    -- If the "back" key was pressed on Android or Windows Phone, prevent it from backing out of the app
    if ( event.keyName == "back" ) then
        local platformName = system.getInfo( "platformName" )
        if ( platformName == "Android" ) or ( platformName == "WinPhone" ) then
            return true
        end
    end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
end



function endGameEvents(resetToScreen)

	vars.gameOver 		= true
	vars.invincibleMode 	= false

	--cleanUpSceneRoutine()
	
	local function restartLevel()
		composer.gotoScene(resetToScreen)
		return true
	end
	timer.performWithDelay(10, restartLevel )

end



function gameOverStartRoutine(overType)

	local function goReset()
	
		cleanUpSceneRoutine()
		
		if (overType == "restart") then
			endGameEvents("screenResetLevel")
		elseif (overType == "quit") then
			endGameEvents("screenMenu")	
		end
	end

	local function gameEnd()
		vars.gameOver = true
		if (overType == "restart") then
			vars.crashSFX = audio.play(myGlobalData.Sfx_Hit)
			
			restartButton:removeEventListener( "touch", restartTouched )
			
			local dieX = player.x
			local dieY = player.y

			if (playerCanFly == true) then
				dieX = playerFlying.x
				dieY = playerFlying.y
			end

			display.remove(vars.emitter)
			vars.emitter = nil
			display.remove(player)
			player=nil
			display.remove(playerFlying)
			player=nil
		
			--Call the Explode Player functions
			explodePlayer(dieX, dieY)
			
			timer.performWithDelay(600, goReset )
			
		elseif (overType == "quit") then
		
			display.remove(vars.emitter)
			vars.emitter = nil
			display.remove(player)
			player=nil
			display.remove(playerFlying)
			player=nil

			timer.performWithDelay(200, goReset )
		end
		
		
	end
	timer.performWithDelay(60, gameEnd )

end



function cleanUpSceneRoutine()

	if (vars.addBaseLayer == true ) then
		Runtime:removeEventListener( "enterFrame", platform1Group)
		Runtime:removeEventListener( "enterFrame", platform2Group)
    end
	if (vars.addBGLayer == true ) then
		Runtime:removeEventListener( "enterFrame", backgroundScoll1Group)
		Runtime:removeEventListener( "enterFrame", backgroundScoll2Group)
    end
	if (vars.addFGLayer == true ) then
		Runtime:removeEventListener( "enterFrame", foregroundScoll1Group)
		Runtime:removeEventListener( "enterFrame", foregroundScoll2Group)
    end

	Runtime:removeEventListener( "enterFrame", updateTick )
	Runtime:removeEventListener( "collision", onGlobalCollision )
	Runtime:removeEventListener( "key", onKeyEvent )

	audio.stop()
	audio.dispose( vars.gameMusic )
	audio.dispose( vars.crashSFX )	
	audio.dispose()	
	vars.gameMusic = nil
	vars.crashSFX = nil

	display.remove(particleData)
	particleData = nil

	display.remove(explodeParticle)
	explodeParticle = nil
	
	vars.collectScene = nil

	for i=#blocksArray,1,-1 do
	  local child = table.remove(blocksArray, i)    -- Remove from table
	  if (child ~= nil and child.destroy==false) then
	  	--print("Block["..i.."] x = "..child.x.." | y = "..child.y)
		child:removeSelf()
		display.remove(child)
		child = nil
	  end
	end

	for i=#startRings,1,-1 do
	  local child = table.remove(startRings, i)    -- Remove from table
	  if child ~= nil then
		child:removeSelf()
		display.remove(child)
		child = nil
	  end
	end
	
	for i=#scrollZones,1,-1 do
	  local child = table.remove(scrollZones, i)    -- Remove from table
	  if child ~= nil then
		--child:removeSelf()
		display.remove(child)
		child = nil
	  end
	end

	for i=#zones,1,-1 do
	  local child = table.remove(zones, i)    -- Remove from table
	  if child ~= nil then
		--child:removeSelf()
		display.remove(child)
		child = nil
	  end
	end


	for i=#bgArray,1,-1 do
	  local child = table.remove(bgArray, i)    -- Remove from table
	  if child ~= nil then
		child:removeSelf()
		display.remove(child)
		child = nil
	  end
	end

	for i=#groundArray,1,-1 do
	  local child = table.remove(groundArray, i)    -- Remove from table
	  if child ~= nil then
		child:removeSelf()
		display.remove(child)
		child = nil
	  end
	end	
	
	cleanGroups(backgroundGroup)
	cleanGroups(backgroundScoll1Group)
	cleanGroups(backgroundScoll2Group)
	cleanGroups(foregroundScoll1Group)
	cleanGroups(foregroundScoll2Group)
	
	cleanGroups(platform1Group)
	cleanGroups(platform2Group)
	cleanGroups(platform3Group)
	cleanGroups(obsticlesGroup)
	cleanGroups(playerGroup)
	cleanGroups(playerStartEndGroup)
	cleanGroups(cameraGroup)
	cleanGroups(cameraRotateGroup)
	cleanGroups(hudGroup)

	local cleanLevel = myGlobalData.levelPath..vars.myLevel
	--local cleanLevel = myGlobalData.levelPathR..vars.myLevel

	vars.collectScene = nil
	pex = nil
	cTrans = nil
	
	package.loaded[cleanLevel] = nil
	package.loaded["pex"] = nil
	package.loaded["colorTransition"] = nil

	updateLevelAttemps()

	
end


function updateLevelAttemps()
	levelTrys.attemps = levelTrys.attemps + 1
	--levelTrys.lastDistance	= 0
end





function unrequire( m )
 
  package.loaded[m] = nil
  _G[m] = nil
 
  -- Search for the shared library handle in the registry and erase it
  local registry = debug.getregistry()
  local nMatches, mKey, mt = 0, nil, registry['_LOADLIB']
 
  for key, ud in pairs(registry) do
    if type(key) == 'string' and type(ud) == 'userdata' and getmetatable(ud) == mt and string.find(key, "LOADLIB: .*" .. m) then
      nMatches = nMatches + 1
      if nMatches > 1 then
        return false, "More than one possible key for module '" .. m .. "'. Can't decide which one to erase."
      end
      mKey = key
    end
  end
 
  if mKey then
    registry[mKey] = nil
  end
 
  return true
end



---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

---------------------------------------------------------------
-- Add game Listener Events
---------------------------------------------------------------
Runtime:addEventListener( "enterFrame", updateTick )
Runtime:addEventListener ( "collision", onGlobalCollision )

return scene