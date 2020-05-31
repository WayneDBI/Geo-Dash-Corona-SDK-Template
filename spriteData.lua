---------------------------------------------------------------------------------------
-- G-Dash
-- Module to collect Sprite, Name, Size and Physics data
---------------------------------------------------------------------------------------
local myGlobalData			= require("globalData")
local unpack 				= unpack
local _pairs 				= pairs

local M = {}

---------------------------------------------------------------------------------------
-- Define The path to each of the asset types
---------------------------------------------------------------------------------------
M.rootImagePath			= myGlobalData.imagePath
---------------------------------------------------------------------------------------
M.Player_Path 			= M.rootImagePath.."Player/"
M.Platform_Path 		= M.rootImagePath.."Platform/"
M.Decoration_Path 		= M.rootImagePath.."Decoration/"
M.Portal_Path 			= M.rootImagePath.."Portal/"
M.Pit_Path 				= M.rootImagePath.."Pit/"
M.Hazard_Path 			= M.rootImagePath.."Hazard/"
M.Ground_Path 			= M.rootImagePath.."Ground/"
M.BounceFloor_Path 		= M.rootImagePath.."BounceFloor/"
M.BounceAir_Path 		= M.rootImagePath.."BounceAir/"
M.Coin1_Path 			= M.rootImagePath.."Coin1/"
M.Coin2_Path 			= M.rootImagePath.."Coin2/"
M.Goal_Path 			= M.rootImagePath.."Goal/"
M.GUI_Path	 			= M.rootImagePath.."GUI/"
M.GameArt_Path 			= M.rootImagePath.."GameArt/"
M.Particles_Path 		= M.rootImagePath.."Particles/"
M.NilSprite_Path 		= M.rootImagePath.."NilSprite/"

---------------------------------------------------------------------------------------
-- Define sprites collision name: Used in game to detect which sprites have collided.
---------------------------------------------------------------------------------------
M.Player_CN			= "player"
M.Platform_CN		= "platform"
M.Decoration_CN		= "decoration"
M.Portal_CN			= "portal"
M.Pit_CN			= "pit"
M.Hazard_CN			= "hazard"
M.Ground_CN			= "ground"
M.BounceFloor_CN	= "bounceFloor"
M.BounceAir_CN		= "bounceAir"
M.Coin1_CN			= "coin1"
M.Coin2_CN			= "coin2"
M.Goal_CN			= "goal"
M.GUI_CN			= "na"
M.GameArt_CN		= "na"
M.Particles_CN		= "na"
M.NilSprite_CN		= "na"

---------------------------------------------------------------------------------------
-- Define Physics Collision Filter for each asset type.
-- (Note some assets do not require a filter).
---------------------------------------------------------------------------------------
M.Player_FD			= { categoryBits = 1, maskBits = 2046 }
M.Platform_FD		= { categoryBits = 2, maskBits = 1 }
M.Portal_FD			= { categoryBits = 4, maskBits = 1 }
M.Pit_FD			= { categoryBits = 8, maskBits = 1 }
M.Hazard_FD			= { categoryBits = 16, maskBits = 1 }
M.Ground_FD			= { categoryBits = 32, maskBits = 1 }
M.Bounce_FloorFD	= { categoryBits = 64, maskBits = 1 }
M.BounceAir_FD		= { categoryBits = 128, maskBits = 1 }
M.Coin1_FD			= { categoryBits = 256, maskBits = 1 }
M.Coin2_FD			= { categoryBits = 512, maskBits = 1 }
M.Goal_FD			= { categoryBits = 1024, maskBits = 1 }

---------------------------------------------------------------------------------------
-- Define Physics Material (Bounce, Density etc)
---------------------------------------------------------------------------------------
local matDensity = 20000
local matFriction = 12
local matBounce = 0.1

--Note: The temp material will be updated for each sprite later.
local tempMaterial	= { "static",	density=matDensity,	friction=matFriction,	bounce=matBounce,	filter=Platform_FD }

---------------------------------------------------------------------------------------
-- Create arrays to hold information for each asset type
-- Note: Each array can hold up to 99 of each type
-- Note: If you add MORE assets to each of the folders, you will need to update the
-- code below to reflect your new images/assets.
-----------------------------------------------------------------------------------------------------------------
-- Structure = [ id ] | Filename | Path | Collision Name | Collision Filter | Physics Shape  |  Physics Material
--             [ id ] |   [1]    | [2]  |     [3]        |       [4]        |    [5]         |       [6]
-----------------------------------------------------------------------------------------------------------------
-- The [ id ] is what we use to build the scene map
-----------------------------------------------------------------------------------------------------------------
local CShape -- This is a place holder. The data is updated after the initial array is created.

M.spriteSetup = { 

		[100] = { name="1_player", path=M.Player_Path, cn=M.Player_CN, cf=M.Player_FD, cs=CShape, ptype="dynamic", de=50, se=false, fr=0.2, bc=0.0, rad=14, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[101] = { name="2_player", path=M.Player_Path, cn=M.Player_CN, cf=M.Player_FD, cs=CShape, ptype="dynamic", de=50, se=false, fr=0.2, bc=0.0, rad=14, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[102] = { name="3_player", path=M.Player_Path, cn=M.Player_CN, cf=M.Player_FD, cs=CShape, ptype="dynamic", de=50, se=false, fr=0.2, bc=0.0, rad=14, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[140] = { name="1_spaceship", path=M.Player_Path, cn=M.Player_CN, cf=M.Player_FD, cs=CShape, ptype="dynamic", de=50, se=false, fr=0.2, bc=0.0, spritePhysics=tempMaterial, sx=32, sy=26, isPhysical=true  },
		--Add more player sprites as required - up to id [149]

		[150] = { name="1_block", path=M.Platform_Path, cn=M.Platform_CN, cf=M.Platform_FD, cs=CShape, ptype="static", de=matDensity, se=false, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[151] = { name="2_block", path=M.Platform_Path, cn=M.Platform_CN, cf=M.Platform_FD, cs=CShape, ptype="static", de=matDensity, se=false, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[152] = { name="3_block", path=M.Platform_Path, cn=M.Platform_CN, cf=M.Platform_FD, cs=CShape, ptype="static", de=matDensity, se=false, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[153] = { name="4_block", path=M.Platform_Path, cn=M.Platform_CN, cf=M.Platform_FD, cs=CShape, ptype="static", de=matDensity, se=false, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[154] = { name="5_block", path=M.Platform_Path, cn=M.Platform_CN, cf=M.Platform_FD, cs=CShape, ptype="static", de=matDensity, se=false, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[155] = { name="6_block", path=M.Platform_Path, cn=M.Platform_CN, cf=M.Platform_FD, cs=CShape, ptype="static", de=matDensity, se=false, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[156] = { name="7_block", path=M.Platform_Path, cn=M.Platform_CN, cf=M.Platform_FD, cs=CShape, ptype="static", de=matDensity, se=false, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		--Add more platforms as required - up to id [199]
		
		[200] = { name="1_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[201] = { name="2_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[202] = { name="3_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[203] = { name="4_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[204] = { name="5_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[205] = { name="6_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[206] = { name="7_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[207] = { name="8_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		--[208] = { name="9_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[209] = { name="10_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[210] = { name="11_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[211] = { name="12_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[212] = { name="13_hazard", path=M.Hazard_Path, cn=M.Hazard_CN, cf=M.Hazard_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		--Add more Hazards as required - up to id [249]

		[250] = { name="1_bounceAir", path=M.BounceAir_Path, cn=M.BounceAir_CN, cf=M.BounceAir_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		--Add more Bounce Air as required - up to id [299]

		[300] = { name="1_bounceFloor", path=M.BounceFloor_Path, cn=M.BounceFloor_CN, cf=M.Bounce_FloorFD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		--Add more Bounce Floor as required - up to id [349]

		[350] = { name="1_coinSmall", path=M.Coin1_Path, cn=M.Coin1_CN, cf=M.Coin1_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		--Add more Coins Type 1 as required - up to id [399]

		[400] = { name="1_coinBig", path=M.Coin2_Path, cn=M.Coin2_CN, cf=M.Coin2_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		--Add more Coins Type 2 as required - up to id [449]

		[450] = { name="1_goal", path=M.Goal_Path, cn=M.Goal_CN, cf=M.Platform_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		--Add more Goals as required - up to id [499]

		[500] = { name="1_portal", path=M.Portal_Path, cn=M.Portal_CN, cf=M.Portal_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=96, isPhysical=true  },
		--Add more Portals as required - up to id [549]

--[[
  //add some tabs
  me.appendTab("Platform")
  me.appendTab("Hazard")
  me.appendTab("Decoration")
  me.appendTab("Collect 1")
  me.appendTab("Collect2")
  me.appendTab("Bounce")
  me.appendTab("Portal")
  me.appendTab("Goal")
  //me.appendTab("Marker")
  //me.appendTab("Ground")
  //me.appendTab("Pit")
  //me.appendTab("Player")
  
  menuTextArray(0) = "Project Setup"
  menuTextArray(1) = "Game Details"
  menuTextArray(2) = "Asset Manager"
  menuTextArray(3) = "Game Icons"
  menuTextArray(4) = "Default Screen"
  menuTextArray(5) = "Home Screen"
  menuTextArray(6) = "About Screen"
  menuTextArray(7) = "Level Select Screen"
  menuTextArray(8) = "Game Over Screen"
  menuTextArray(9) = "Levels Setup"
  menuTextArray(10) = "Level Editor"
  menuTextArray(11) = "Player Setup"
  menuTextArray(12) = "Collectables Setup"
  menuTextArray(13) = "Lua Code"
  menuTextArray(14) = "Export Project"  
  
  
  --]]
  
		[550] = { name="1_decor", path=M.Decoration_Path, cn=M.Decoration_CN, cf="", cs="", ptype="", de=matDensity, se=true, fr="", bc="", spritePhysics="", sx=32, sy=32, isPhysical=false  },
		[551] = { name="2_decor", path=M.Decoration_Path, cn=M.Decoration_CN, cf="", cs="", ptype="", de=matDensity, se=true, fr="", bc="", spritePhysics="", sx=32, sy=32, isPhysical=false  },
		[552] = { name="3_decor", path=M.Decoration_Path, cn=M.Decoration_CN, cf="", cs="", ptype="", de=matDensity, se=true, fr="", bc="", spritePhysics="", sx=32, sy=32, isPhysical=false  },
		[553] = { name="4_decorBlock", path=M.Decoration_Path, cn=M.Decoration_CN, cf="", cs="", ptype="", de=matDensity, se=true, fr="", bc="", spritePhysics="", sx=32, sy=32, isPhysical=false  },
		--Add more Decorations as required - up to id [599]
		
		--[[-----------------------------------------------------------------------------------
		-- We have setup these extra items - but not implemented in this template.
		-- Use, if you want more scene sprites and extra collisions etc.
		---------------------------------------------------------------------------------------
		[600] = { name="1_ground", path=M.Ground_Path, cn=M.Ground_CN, cf=M.Ground_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		[650] = { name="1_pit", path=M.Pit_Path, cn=M.Pit_CN, cf=M.Pit_FD, cs=CShape, ptype="static", de=matDensity, se=true, fr=matFriction, bc=matBounce, spritePhysics=tempMaterial, sx=32, sy=32, isPhysical=true  },
		----------------------------------------------------------------------------------------]]
		
}

-----------------------------------------------------------------------------------------------------------------
-- Structure = [ id ] | Filename | Path | Collision Name | Collision Filter | Physics Shape  |  Physics Material
--             [ id ] |   [1]    | [2]  |     [3]        |       [4]        |    [5]         |       [6]
-----------------------------------------------------------------------------------------------------------------
--print(    "Sprite [ID] : "				..M.spriteSetup.data[100].name    )
--print(    "Sprite [Name] : "				..M.spriteSetup.data[100].name    )
--print(    "Sprite [Path] : "				..M.spriteSetup.data[100].path    )
--print(    "Sprite [Collision Name] : "	..M.spriteSetup[1].cn    )
--print(    "Sprite [Collision Filter] : "	..table.concat( M.spriteSetup[1].cf, ", " ) )
--print(    "Sprite [Physics Shape] : "		..table.concat( M.spriteSetup[1].cs, ", " ) )
--print(    "Sprite [Physics Material] : "	..table.concat( M.spriteSetup[1].cm, ", " ) )

---------------------------------------------------------------------------------------
-- Count how many sprites the game will have.
---------------------------------------------------------------------------------------
local spritesInArrayCounter = 0
for k,v in pairs(M.spriteSetup) do
     spritesInArrayCounter = spritesInArrayCounter + 1
end
--print("Array Size: "..spritesInArrayCounter)


---------------------------------------------------------------------------------------
-- Create the collision shape data for the sprites
-- The following routine calculates the sprites HIT AREA based on the transparency.
---------------------------------------------------------------------------------------
local outlineQuality = 10 -- Higher numbers result in more polygons/accuracy - but slower on CPU

for keyRef, value in pairs(M.spriteSetup) do
	
	local spriteRef = M.spriteSetup[keyRef]
	--print(keyRef)
	
	if (spriteRef ~= nil) then
		
		--Get PNG file
		local theSprite = spriteRef.path..spriteRef.name..".png"
		
		--Extract Mask and to get the collision boundary
		local theSprite_Outline = graphics.newOutline( outlineQuality, theSprite )
		
		--Re-Build the Physics material for this sprite
		local new_PhysicsMaterial = { spriteRef.ptype, density=spriteRef.de, friction=spriteRef.fr, bounce=spriteRef.bc, filter=spriteRef.cf, outline=theSprite_Outline}
		
		--Update the sprites details in the table
		M.spriteSetup[keyRef].spritePhysics = new_PhysicsMaterial
		
		--Clear the references to the sprite.
		theSprite 			= nil
		theSprite_Outline 	= nil
		new_PhysicsMaterial = nil

	end
	
end


return M

