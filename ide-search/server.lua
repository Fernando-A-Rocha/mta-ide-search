--[[
	Resource: ide-search
	
	File: server.lua
	
	Author: https://github.com/Fernando-A-Rocha
	
	Description: This resource lets you search for model IDs, DFF and TXD names in all of GTA's ide files (as well as SAMP.ide)
	You can use it for finding which DFF models use a certain TXD file, etc

	Useful link(s):
		https://dev.prineside.com/en/gtasa_samp_model_id/ - You can use this platform to search for objects via Model ID/Name
		and view its properties including DFF & TXD files it uses
		
	Example:
		lae2_ground04 [17513] - https://dev.prineside.com/en/gtasa_samp_model_id/model/17513-lae2_ground04/
		DFF: lae2_ground04.dff
		TXD: landlae2e.txd

		With this script you can search 'landlae2e.txd' and see that it's also used by:
		grass_bank [17866] - https://dev.prineside.com/en/gtasa_samp_model_id/model/17866-grass_bank/


	Commands: /searchide & /listide
]]

local ideList = {}

addEventHandler( "onResourceStart", resourceRoot, 
function (startedResource)
	local meta = xmlLoadFile("meta.xml")
	if not meta then return outputDebugString("Failed to load meta.xml", 1) end

	local found = {}

    local nodes = xmlNodeGetChildren(meta)
    for i, node in pairs(nodes) do
		if xmlNodeGetName(node) == "file" then
            local src = xmlNodeGetAttribute(node, "src")
            local download = xmlNodeGetAttribute(node, "download")
            if src and download == "false" then
                table.insert(found, src)
            end
		end
	end

	xmlUnloadFile(meta)

	-- Parse all
	for k,src in pairs(found) do
		local f = fileOpen(src)
		if not f then return outputDebugString("Aborting: failed to load "..src, 1) end

		local str = fileRead(f, fileGetSize(f))
		fileClose(f)

		local idename = split(split(src, "/")[2], ".")[1]
		ideList[idename] = {}

		local lines = split(str, "\n")
		for j, line in pairs(lines) do
			line = line:gsub("%\r", "")
			local s = split(line,",")
			if s and s[1] and s[2] and s[3] then
				local model = tonumber(s[1])
                local dff = string.gsub(s[2], '%s+', '')
                local txd = string.gsub(s[3], '%s+', '')
                if model and (not tonumber(dff)) and (not tonumber(txd)) then
		            table.insert(ideList[idename], {model=model, dff=dff, txd=txd})
	            else
	            	-- iprint(s)
	            end
			end
		end
	end
end)

function listIdeFiles(thePlayer, cmd)
	outputChatBox("Total IDE files parsed: "..table.size(ideList), thePlayer, 255, 194, 14)
	outputChatBox("Loading GUI...", thePlayer, 187,187,187)
	triggerClientEvent(thePlayer, "ide-search:viewList", resourceRoot, ideList)
end
addCommandHandler("listide", listIdeFiles, false, false)

function searchInIde(thePlayer, cmd, idename, stype, svalue)
	if not idename or not stype or not svalue then
		outputChatBox("SYNTAX: /"..cmd.." [IDE File Name] [Search Type] [...]", thePlayer, 255,194,14)
		outputChatBox("You can enter 'all' to search all IDE files", thePlayer, 255,255,255)
		outputChatBox("Search Types: model, dff, txd", thePlayer, 255,255,255)
		outputChatBox("TIP: You can also use /listide to search via GUI", thePlayer, 187,187,187)
		return
	end
	idename = string.lower(idename)
	local search = idename
	if idename ~= "all" then

		local f = split(idename, ".")
		if f and f[2] == "ide" then
			search = f[1]
		end

		local found = false
		for name,_  in pairs(ideList) do
			if name == search then
				found = true
				break
			end
		end

		if not found then
			return outputChatBox("There's no .ide file in 'files' with the name: "..search, thePlayer, 255, 25, 25)
		end
	end

	stype = string.lower(stype)
	if not (stype == "model" or stype == "dff" or stype == "txd") then
		return searchInIde(thePlayer, cmd)
	end

	if stype == "model" and not tonumber(svalue) then
		return outputChatBox(stype.." is to search for Model ID in .ide", thePlayer, 255, 25, 25)
	end

	if stype == "dff" then
		local f = split(svalue, ".")
		if f and f[2] == "dff" then
			svalue = f[1]
		end
	end
	if stype == "txd" then
		local f = split(svalue, ".")
		if f and f[2] == "txd" then
			svalue = f[1]
		end
	end

	outputChatBox("Searching..", thePlayer, 187, 187, 187)

	local count = 0
	for name,list  in pairs(ideList) do
		if (search=="all" or search==name) then
			for k,v in pairs(list) do
				if stype == "model" and (tonumber(v.model) == tonumber(svalue))
				or stype == "dff" and (string.find(string.lower(v.dff), string.lower(svalue)))
				or stype == "txd" and (string.find(string.lower(v.txd), string.lower(svalue))) then
					outputChatBox("#ffe600 "..v.model.." |#2ef5ff "..v.dff..".dff |#ff96fd "..v.txd..".txd  #b3b3b3("..name..".ide)", thePlayer, 255, 255, 255, true)
					count = count + 1
				end
			end
		end
	end
	if count > 0 then
		outputChatBox("Found "..count.." results for: "..stype.." '"..svalue.."' in "..search.." IDE", thePlayer, 25, 255, 25)
	else
		outputChatBox("No results found for: "..stype.." '"..svalue.."' in "..search.." IDE", thePlayer, 255, 50, 50)
	end
end
addCommandHandler("searchide", searchInIde, false, false)

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end