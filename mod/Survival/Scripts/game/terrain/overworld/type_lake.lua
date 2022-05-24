--This file is generated! Don't edit here.

----------------------------------------------------------------------------------------------------
-- Data
----------------------------------------------------------------------------------------------------

local g_lake = {} --Flags lookup table

-------------------------------
-- Bits                      --
-- dir | SE | SW | NW | NE | --
-- bit |  3 |  2 |  1 |  0 | --
-------------------------------

local function toLakeIndex( se, sw, nw, ne )
	return bit.bor( bit.lshift( se, 3 ), bit.lshift( sw, 2 ), bit.lshift( nw, 1 ), bit.tobit( ne ) )
end

function initLakeTiles()
	for i=0, 15 do
		g_lake[i] = { tiles = {}, rotation = 0 }
	end
	g_lake[toLakeIndex( 0, 0, 0, 1 )] = { tiles = { addTile( 8000101, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_01.tile" ), addTile( 8000102, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_02.tile" ), addTile( 8000103, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_03.tile" ), addTile( 8000104, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_04.tile" ), addTile( 8000105, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_05.tile" ), addTile( 8000106, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_06.tile" ), addTile( 8000107, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_07.tile" ), addTile( 8000108, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_08.tile" ), addTile( 8000109, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_09.tile" ), addTile( 8000110, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_10.tile" ), addTile( 8000111, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_11.tile" ) }, rotation = 0 }
	g_lake[toLakeIndex( 0, 0, 1, 0 )] = { tiles = { addTile( 8000101, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_01.tile" ), addTile( 8000102, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_02.tile" ), addTile( 8000103, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_03.tile" ), addTile( 8000104, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_04.tile" ), addTile( 8000105, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_05.tile" ), addTile( 8000106, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_06.tile" ), addTile( 8000107, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_07.tile" ), addTile( 8000108, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_08.tile" ), addTile( 8000109, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_09.tile" ), addTile( 8000110, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_10.tile" ), addTile( 8000111, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_11.tile" ) }, rotation = 1 }
	g_lake[toLakeIndex( 0, 0, 1, 1 )] = { tiles = { addTile( 8000301, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_01.tile" ), addTile( 8000302, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_02.tile" ), addTile( 8000303, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_03.tile" ), addTile( 8000304, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_04.tile" ), addTile( 8000305, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_05.tile" ), addTile( 8000306, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_06.tile" ), addTile( 8000307, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_07.tile" ), addTile( 8000308, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_08.tile" ), addTile( 8000309, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_09.tile" ), addTile( 8000310, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_10.tile" ), addTile( 8000311, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_11.tile" ), addTile( 8000312, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_12.tile" ), addTile( 8000313, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_13.tile" ), addTile( 8000314, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_14.tile" ) }, rotation = 0 }
	g_lake[toLakeIndex( 0, 1, 0, 0 )] = { tiles = { addTile( 8000101, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_01.tile" ), addTile( 8000102, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_02.tile" ), addTile( 8000103, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_03.tile" ), addTile( 8000104, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_04.tile" ), addTile( 8000105, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_05.tile" ), addTile( 8000106, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_06.tile" ), addTile( 8000107, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_07.tile" ), addTile( 8000108, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_08.tile" ), addTile( 8000109, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_09.tile" ), addTile( 8000110, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_10.tile" ), addTile( 8000111, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_11.tile" ) }, rotation = 2 }
	g_lake[toLakeIndex( 0, 1, 0, 1 )] = { tiles = { addTile( 8000501, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0101)_01.tile" ) }, rotation = 0 }
	g_lake[toLakeIndex( 0, 1, 1, 0 )] = { tiles = { addTile( 8000301, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_01.tile" ), addTile( 8000302, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_02.tile" ), addTile( 8000303, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_03.tile" ), addTile( 8000304, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_04.tile" ), addTile( 8000305, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_05.tile" ), addTile( 8000306, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_06.tile" ), addTile( 8000307, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_07.tile" ), addTile( 8000308, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_08.tile" ), addTile( 8000309, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_09.tile" ), addTile( 8000310, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_10.tile" ), addTile( 8000311, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_11.tile" ), addTile( 8000312, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_12.tile" ), addTile( 8000313, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_13.tile" ), addTile( 8000314, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_14.tile" ) }, rotation = 1 }
	g_lake[toLakeIndex( 0, 1, 1, 1 )] = { tiles = { addTile( 8000701, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_01.tile" ), addTile( 8000702, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_02.tile" ), addTile( 8000703, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_03.tile" ), addTile( 8000704, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_04.tile" ), addTile( 8000705, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_05.tile" ), addTile( 8000706, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_06.tile" ) }, rotation = 0 }
	g_lake[toLakeIndex( 1, 0, 0, 0 )] = { tiles = { addTile( 8000101, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_01.tile" ), addTile( 8000102, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_02.tile" ), addTile( 8000103, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_03.tile" ), addTile( 8000104, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_04.tile" ), addTile( 8000105, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_05.tile" ), addTile( 8000106, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_06.tile" ), addTile( 8000107, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_07.tile" ), addTile( 8000108, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_08.tile" ), addTile( 8000109, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_09.tile" ), addTile( 8000110, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_10.tile" ), addTile( 8000111, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0001)_11.tile" ) }, rotation = 3 }
	g_lake[toLakeIndex( 1, 0, 0, 1 )] = { tiles = { addTile( 8000301, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_01.tile" ), addTile( 8000302, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_02.tile" ), addTile( 8000303, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_03.tile" ), addTile( 8000304, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_04.tile" ), addTile( 8000305, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_05.tile" ), addTile( 8000306, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_06.tile" ), addTile( 8000307, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_07.tile" ), addTile( 8000308, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_08.tile" ), addTile( 8000309, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_09.tile" ), addTile( 8000310, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_10.tile" ), addTile( 8000311, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_11.tile" ), addTile( 8000312, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_12.tile" ), addTile( 8000313, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_13.tile" ), addTile( 8000314, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_14.tile" ) }, rotation = 3 }
	g_lake[toLakeIndex( 1, 0, 1, 0 )] = { tiles = { addTile( 8000501, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0101)_01.tile" ) }, rotation = 3 }
	g_lake[toLakeIndex( 1, 0, 1, 1 )] = { tiles = { addTile( 8000701, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_01.tile" ), addTile( 8000702, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_02.tile" ), addTile( 8000703, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_03.tile" ), addTile( 8000704, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_04.tile" ), addTile( 8000705, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_05.tile" ), addTile( 8000706, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_06.tile" ) }, rotation = 3 }
	g_lake[toLakeIndex( 1, 1, 0, 0 )] = { tiles = { addTile( 8000301, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_01.tile" ), addTile( 8000302, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_02.tile" ), addTile( 8000303, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_03.tile" ), addTile( 8000304, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_04.tile" ), addTile( 8000305, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_05.tile" ), addTile( 8000306, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_06.tile" ), addTile( 8000307, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_07.tile" ), addTile( 8000308, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_08.tile" ), addTile( 8000309, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_09.tile" ), addTile( 8000310, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_10.tile" ), addTile( 8000311, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_11.tile" ), addTile( 8000312, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_12.tile" ), addTile( 8000313, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_13.tile" ), addTile( 8000314, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0011)_14.tile" ) }, rotation = 2 }
	g_lake[toLakeIndex( 1, 1, 0, 1 )] = { tiles = { addTile( 8000701, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_01.tile" ), addTile( 8000702, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_02.tile" ), addTile( 8000703, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_03.tile" ), addTile( 8000704, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_04.tile" ), addTile( 8000705, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_05.tile" ), addTile( 8000706, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_06.tile" ) }, rotation = 2 }
	g_lake[toLakeIndex( 1, 1, 1, 0 )] = { tiles = { addTile( 8000701, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_01.tile" ), addTile( 8000702, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_02.tile" ), addTile( 8000703, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_03.tile" ), addTile( 8000704, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_04.tile" ), addTile( 8000705, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_05.tile" ), addTile( 8000706, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(0111)_06.tile" ) }, rotation = 1 }
	g_lake[toLakeIndex( 1, 1, 1, 1 )] = { tiles = { addTile( 8001501, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_01.tile" ), addTile( 8001502, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_02.tile" ), addTile( 8001503, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_03.tile" ), addTile( 8001504, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_04.tile" ), addTile( 8001505, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_05.tile" ), addTile( 8001506, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_06.tile" ), addTile( 8001507, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_07.tile" ), addTile( 8001508, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_08.tile" ), addTile( 8001509, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_09.tile" ), addTile( 8001510, "$SURVIVAL_DATA/Terrain/Tiles/lake/Lake(1111)_10.tile" ) }, rotation = 0 }
end

----------------------------------------------------------------------------------------------------
-- Getters
----------------------------------------------------------------------------------------------------

function getLakeTileIdAndRotation( cornerFlags, variationNoise, rotationNoise )
	if cornerFlags > 0 then
		local item = g_lake[cornerFlags]
		local tileCount = table.getn( item.tiles )

		if tileCount == 0 then
			return -1, 0 --error tile
		end

		local rotation = cornerFlags == 15 and ( rotationNoise % 4 ) or item.rotation

		return item.tiles[variationNoise % tileCount + 1], rotation
	end

	return 0, 0
end
