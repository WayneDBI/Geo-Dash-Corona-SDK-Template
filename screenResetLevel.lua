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
-- screenResetLevel.lua
------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------
-- Require all of the external modules for this level
---------------------------------------------------------------
local composer = require( "composer" )
local scene = composer.newScene()

local myGlobalData 		= require( "globalData" )

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
	--print("---RESTART---")
	---------------------------------------------------------------
	-- simply create a Black square.
	---------------------------------------------------------------
	--local myRectangle = display.newRect(0, 0, myGlobalData._w, myGlobalData._h)
	--myRectangle:setFillColor(0,0,0)
	--myRectangle.x = myGlobalData._w *0.5
	--myRectangle.y = myGlobalData._h *0.5
	--sceneGroup:insert(myRectangle)

end


---------------------------------------------------------------
-- level select button function
---------------------------------------------------------------
function restartLevel()
	composer.gotoScene( "screenStart" )
	--return true
end


-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.

--[[
	local levelsPath = myGlobalData.levelPathR	
	local cleanMyLevel = "level"..level
	package.loaded[levelsPath..cleanMyLevel] = nil
	local cleanMyLevel = "level"..(level-1)
	package.loaded[levelsPath..cleanMyLevel] = nil
	local cleanMyLevel = "level"..(level+1)
	package.loaded[levelsPath..cleanMyLevel] = nil
--]]

	composer.removeScene( "screenStart" )
	composer.removeScene( "screenMenu" )
	
	--Short delay before we go back to the scene
	timer.performWithDelay(60, restartLevel )
      
      
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