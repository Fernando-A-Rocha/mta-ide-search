--[[
	Resource: ide-search
	
	File: testing_server.lua
	
	Author: https://github.com/Fernando-A-Rocha
	
	Some testing code for idea-search features
]]

local function isDefaultObjectID(id)
	if id < 321 or id > 18630 then
		return false
	end
	-- exclude unused
	if id >= 18631 and id <= 19999 then
		return false
	end
	if id >= 11682 and id <= 12799 then
		return false
	end
	if id >= 15065 and id <= 15999 then
		return false
	end
	return true
end

addCommandHandler("savemodels", function(thePlayer, cmd, theType)
    if not (theType) or not (theType=="vehicle" or theType=="object" or theType=="skin") then
        return outputChatBox("SYNTAX: /" .. cmd .. " [vehicle|object|skin]", thePlayer, 255, 255, 255)
    end

    local ideList = getIdeList()

    local targetIds = {}
    if (theType=="vehicle") then
        for id=400,611 do
            targetIds[id] = true
        end
    elseif (theType=="object") then
        for id=321,18630 do
            -- exclude unused
            if not ((id >= 18631 and id <= 19999) or (id >= 11682 and id <= 12799) or (id >= 15065 and id <= 15999)) then
                targetIds[id] = true
            end
        end
    elseif (theType=="skin") then
        for id=0,312 do
            targetIds[id] = true
        end
    end

    local found = {}
    for name,list  in pairs(ideList) do
        if name ~= "SAMP" then
            for k,v in pairs(list) do
                if targetIds[v.model] and v.dff then
                    found[#found+1] = {v.model, v.dff, name}
                end
            end
        end
    end

    local str = (string.upper(theType)).."_MODELS = {\n"
    for _, v in ipairs(found) do
        local model = v[1]
        local dff = v[2]
        local ide = v[3]
        str = str .. '\t['..model..'] = "'..dff..'", -- '..ide..'\n'
    end
    str = str .. "}"
    local f = fileCreate(theType.."_models.lua")
    fileWrite(f, str)
    fileClose(f)

    outputChatBox("Saved "..theType.." models to "..theType.."_models.lua", thePlayer, 22, 255, 22)

end, false, false)
