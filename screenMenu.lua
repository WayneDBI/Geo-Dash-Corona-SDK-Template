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
-- screenMenu.lua
------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------
-- Require all of the external modules for this level
---------------------------------------------------------------
local composer 			= require( "composer" )
local scene 			= composer.newScene()
local myGlobalData 		= require( "globalData" )
local levelTrys 		= require("levelAttemtsData") -- Require our external Load/Save module
levelTrys.attemps 		= 1	--Reset the LEVEL Attempts counter (but not on the level reset / trys)
levelTrys.lastDistance	= 0
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
	--Background Image
	local bg = display.newImageRect(SpriteData.GUI_Path.."homeScreen.png",568,384)
	bg.x = display.contentWidth * 0.5
	bg.y = display.contentHeight * 0.5
	bg.alpha=1
	sceneGroup:insert( bg )

	--Start Button
	local startButton = display.newImageRect(SpriteData.GUI_Path.."buttonStart.png",45,45)
	startButton.x = centerX
	startButton.y = centerY+60
	startButton.alpha=1
	startButton:addEventListener( "touch", touchStart)
	sceneGroup:insert( startButton )

end



---------------------------------------------------------------
-- start game button
---------------------------------------------------------------
function startGame()
	composer.gotoScene( "screenResetLevel")
end
function touchStart(event)
	if(event.phase == "began") then
	elseif(event.phase == "ended") then
		startGame()
  end
end


-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
      
      
	local levelsPath = myGlobalData.levelPathR	
	local cleanMyLevel = "level"..level
	package.loaded[levelsPath..cleanMyLevel] = nil
	local cleanMyLevel = "level"..(level-1)
	package.loaded[levelsPath..cleanMyLevel] = nil
	local cleanMyLevel = "level"..(level+1)
	package.loaded[levelsPath..cleanMyLevel] = nil
	package.loaded["colorTransition"] = nil
	composer.removeScene( "screenStart" )
	composer.removeScene( "screenResetLevel" )
      
      
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.
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
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
