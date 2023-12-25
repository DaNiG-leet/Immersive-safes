local old_fn = ISDestroyCursor.canDestroy

local wallSafes = {
    WallN = {
        safes_01_27 = true,
        safes_01_25 = true,
        safes_01_19 = true,
        safes_01_17 = true
    },
    WallW = {
        safes_01_18 = true,
        safes_01_16 = true,
        safes_01_24 = true,
        safes_01_26 = true
    }
}

local wallSafesInvert = {
    WallN = {
        safes_01_22 = true,
        safes_01_20 = true,
        safes_01_29 = true,
        safes_01_31 = true
    },
    WallW = {
        safes_01_21 = true,
        safes_01_23 = true,
        safes_01_28 = true,
        safes_01_30 = true
    }
}

local floorSafes = {
    safes_01_32 = true,
    safes_01_33 = true,
    safes_01_34 = true,
    safes_01_35 = true
}

local function isWall(obj)
    local props = obj:getProperties()
    return props and (props:Is("WallN") or props:Is("WallW") or props:Is("WallNW"))
end

local function isWallSafeInIsoGridSquare(sq, wStr)
    if not sq then return false end
    local sqObjects = sq:getObjects()
    for i = 0, sqObjects:size() - 1 do if wStr[sqObjects:get(i):getTextureName()] then return true end end
    return false
end

local function isWallSafeBehindTheWall(obj)
    local props = obj:getProperties()
    local sq = obj:getSquare()
    if props:Is("WallN") then
        return isWallSafeInIsoGridSquare(getCell():getGridSquare(sq:getX(), sq:getY() - 1, sq:getZ()), wallSafesInvert.WallN)
    elseif props:Is("WallW") then
        return isWallSafeInIsoGridSquare(getCell():getGridSquare(sq:getX() - 1, sq:getY(), sq:getZ()), wallSafesInvert.WallW)
    elseif props:Is("WallNW") then
        return isWallSafeInIsoGridSquare(getCell():getGridSquare(sq:getX() - 1, sq:getY(), sq:getZ()), wallSafesInvert.WallW) or isWallSafeInIsoGridSquare(getCell():getGridSquare(sq:getX(), sq:getY() - 1, sq:getZ()), wallSafesInvert.WallN)
    end
end

local function isWallSafeOnWall(obj)
    local props = obj:getProperties()
    local sq = obj:getSquare()
    if props:Is("WallN") then
        return isWallSafeInIsoGridSquare(sq, wallSafes.WallN)
    elseif props:Is("WallW") then
        return isWallSafeInIsoGridSquare(sq, wallSafes.WallW)
    elseif props:Is("WallNW") then
        return isWallSafeInIsoGridSquare(sq, wallSafes.WallW) or isWallSafeInIsoGridSquare(sq, wallSafes.WallN)
    end
    return false
end

local function isFloorSafeOnFloor(obj)
    local sq = obj:getSquare()
    if not sq then return false end
    local sqObjects = sq:getObjects()
    for i = 0, sqObjects:size() - 1 do 
        if floorSafes[sqObjects:get(i):getTextureName()] then
            return true 
        end 
    end
    return false
end

function ISDestroyCursor:canDestroy(object)
    if isAdmin() then return old_fn(self, object) end
    if (instanceof(object, 'IsoObject') or instanceof(object, 'IsoThumpable')) and type(object:getTextureName()) == 'string' and luautils.stringStarts(object:getTextureName(), "safes_01") then return false end
    if isWall(object) and (isWallSafeOnWall(object) or isWallSafeBehindTheWall(object)) then return false end
    if object:isFloor() and isFloorSafeOnFloor(object) then return false end
    return old_fn(self, object)
end
