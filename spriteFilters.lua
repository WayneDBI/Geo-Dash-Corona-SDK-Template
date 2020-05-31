---------------------------------------------------------------------------------------
-- G-Dash
-- Module to prepare Sprite Collision Filters
---------------------------------------------------------------------------------------
local myGlobalData			= require("globalData")
local unpack 				= unpack
local _pairs 				= pairs

local M = {}

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



return M

