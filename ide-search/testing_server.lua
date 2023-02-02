--[[
	Resource: ide-search
	
	File: testing_server.lua

--]]

local function pairsByKeys(t)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

local SPECIAL_IDS = {
    [0] = {dff="cj", txd="NONE"}, -- CJ clothes are special, it doesn't use one txd

    -- Special MTA skins, these dff and txd names are special (bcoz they are not in peds.ide) AFAIK
    [1] = {dff="truth"},
    [2] = {dff="maccer"},
    [265] = {dff="tenpen"},
    [266] = {dff="pulaski"},
    [267] = {dff="hern"},
    [268] = {dff="dwayne"},
    [269] = {dff="smoke"},
    [270] = {dff="sweet"},
    [271] = {dff="ryder"},
    [272] = {dff="forelli"},
    [290] = {dff="rose"},
    [291] = {dff="paul"},
    [292] = {dff="cesar"},
    [293] = {dff="ogloc"},
    [294] = {dff="wuzimu"},
    [295] = {dff="torino"},
    [296] = {dff="jizzy"},
    [297] = {dff="maddogg"},
    [298] = {dff="cat"},
    [299] = {dff="claude"},
    [300] = {dff="ryder2"},
    [301] = {dff="ryder3"},
    [302] = {dff="emmet"},
    [303] = {dff="andre"},
    [304] = {dff="kendl"},
    [305] = {dff="jethro"},
    [306] = {dff="zero"},
    [307] = {dff="tbone"},
    [308] = {dff="sindaco"},
    [309] = {dff="janitor"},
    [310] = {dff="bbthin"},
    [311] = {dff="smokev"},
    [312] = {dff="psycho"},
}

local function saveModels(theType)
    local ideList = getIdeList()

    local targetIds = {}

    if theType == "objects" then
        for id = 321, 18630 do
            -- exclude unused/reserved for other purposes IDs
            if not ((id >= 374 and id <= 614) or (id >= 18631 and id <= 19999) or (id >= 11682 and id <= 12799) or (id >= 15065 and id <= 15999)) then
                targetIds[id] = true
            end
        end
    elseif theType == "vehicles" then
        for id = 400, 611 do
            targetIds[id] = true
        end
    elseif theType == "skins" then
        for id = 0, 312 do
            -- exclude unused
            if not (id == 3 or id == 4 or id == 5 or id == 6 or id == 8 or id == 42 or id == 65 or id == 74
            or id == 86 or id == 149 or id == 199 or id == 208 or id == 273 or id == 289) then
                targetIds[id] = true
            end
        end
    end

    local found = {}

    for name, list in pairs(ideList) do
        for _, v in ipairs(list) do
            if targetIds[v.model] then
                found[v.model] = {dff=v.dff, txd=v.txd}
            end
        end
    end

    local theTypeS = string.sub(theType, 1, -2)
    local fn = theTypeS.."_model_names.lua"
    local f = fileCreate(fn)
    if not f then
        return false
    end
    local str = theTypeS.."ModelNames={\n"
    for id, data in pairsByKeys(found) do
        local special = SPECIAL_IDS[id]
        if special then
            if special.txd == "NONE" then
                str = str.."["..id.."]={dff=\""..(string.lower(special.dff)).."\"},--Special (no TXD)\n"
            else
                str = str.."["..id.."]={dff=\""..(string.lower(special.dff)).."\",txd=\""..(string.lower(special.dff)).."\"},--Special\n"
            end
        else
            str = str.."["..id.."]={dff=\""..(string.lower(data.dff)).."\",txd=\""..(string.lower(data.txd)).."\"},\n"
        end
    end
    str = str.."}"
    fileWrite(f, str)
    fileClose(f)
    print("Saved: "..fn)
    return true
end

addCommandHandler("savemodels", function(thePlayer, cmd, theType)
    if not theType or not (theType == "all" or theType == "objects" or theType == "vehicles" or theType == "skins") then
        return outputChatBox("SYNTAX: /"..cmd.." [all|objects|vehicles|skins]", thePlayer, 255, 255, 255)
    end

    if theType == "all" then
        if saveModels("skins") then
            if saveModels("vehicles") then
                if saveModels("objects") then
                    return outputChatBox("All models saved successfully.", thePlayer, 0, 255, 0)
                end
            end
        end
    else
        if saveModels(theType) then
            return outputChatBox("All "..theType.." saved successfully.", thePlayer, 0, 255, 0)
        end
    end
end)

addCommandHandler("saveskinids", function()

    local str = "skinIds = {"
    for i=0,312 do
        if not (i==3 or i==4 or i==5 or i==6
        or i==8 or i==42 or i==65 or i==74 or i==86 or i==199 or i==149 or i==208 or i==273 or i==289) then
            str = str..i..","
        end
    end
    str = str.."}"
    local f = fileCreate("skin_ids.lua")
    fileWrite(f, str)
    fileClose(f)
    print("written 1")
    
    str = "unusedSkinIds = {"
    for i=0,312 do
        if (i==3 or i==4 or i==5 or i==6
        or i==8 or i==42 or i==65 or i==74 or i==86 or i==199 or i==149 or i==208 or i==273 or i==289) then
            str = str..i..","
        end
    end
    str = str.."}"
    local f = fileCreate("unused_skin_ids.lua")
    fileWrite(f, str)
    fileClose(f)
    print("written 2")

    str = "specialSkinIDs = {"
    for i=0,312 do
        if (i==1 or i==2 or (i>=265 and i<=272) or (i>=290 and i<=312)) then
            str = str..i..","
        end
    end
    str = str.."}"
    local f = fileCreate("special_skin_ids.lua")
    fileWrite(f, str)
    fileClose(f)
    print("written 3")

end, false, false)

addCommandHandler("savevehnicenames", function()
    local str = "vehNiceNames = {\n"
    for i=400,611 do
        str = str.."["..i.."]=\""..string.lower(getVehicleNameFromModel(i)).."\",\n"
    end
    str = str.."}"
    local f = fileCreate("veh_nice_names.lua")
    fileWrite(f, str)
    fileClose(f)
    print("written")
end, false, false)
