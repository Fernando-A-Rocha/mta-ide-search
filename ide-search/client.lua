addEvent("ide-search:viewList", true)

local win, spam
local sw,sh = guiGetScreenSize()

function populate(grid, cols, ideList, filterFor, caseSensitive)
	local count = 0
	for name,list in pairs(ideList) do
		table.sort(list, function(a,b) return a.model < b.model end)
		for k,v in pairsByKeys(list) do

			if (not filterFor) or (filterFor and (
				caseSensitive and (
					(string.find(name, filterFor))
					or (string.find(v.model, filterFor))
					or (string.find(v.dff, filterFor))
					or (string.find(v.txd, filterFor))
					)
				or (not caseSensitive) and (
					(string.find(string.lower(name), string.lower(filterFor)))
					or (string.find(string.lower(v.model), string.lower(filterFor)))
					or (string.find(string.lower(v.dff), string.lower(filterFor)))
					or (string.find(string.lower(v.txd), string.lower(filterFor)))
					)
			)) then

				local row = guiGridListAddRow(grid)
				guiGridListSetItemText(grid, row, cols.model, v.model, false, true)
				guiGridListSetItemText(grid, row, cols.dff, v.dff, false, false)
				guiGridListSetItemText(grid, row, cols.txd, v.txd, false, false)
				guiGridListSetItemText(grid, row, cols.ide, name, false, false)

				if name == "SAMP" then
					for col=1,table.size(cols) do
						guiGridListSetItemColor(grid, row, col, 255,194,14)
					end
				end

				count = count + 1
			end
		end
	end
	return count
end

function viewList(ideList)
	if isElement(win) then destroyElement(win) end
	showCursor(true)

	local ww,wh = 750,500
	local title = "Double click a line to copy information"
	win = guiCreateWindow(sw/2-ww/2, sh/2-wh/2, ww,wh, title, false)

	local close = guiCreateButton(0, wh-30, ww, 30, "Close", false, win)
	addEventHandler( "onClientGUIClick", close, function()
		if isTimer(spam) then
			killTimer(spam)
			spam = nil
		end
		destroyElement(win)
		showCursor(false)
	end, false)

	local filter_text = "Model ID / DFF / TXD"
	local filter = guiCreateEdit(0, wh-35-35, ww -70 -120, 35, filter_text, false, win)
	addEventHandler( "onClientGUIClick", filter, function()
		local text = guiGetText(source)
		if text == filter_text then
			guiSetText(source, "")
		end
	end, false)
	local filter_button = guiCreateButton(ww-60, wh-35-35, 60, 35, "Filter", false, win)
	guiSetProperty(filter_button, "NormalTextColour", "FFFFFF00")
	local filter_case = guiCreateCheckBox(ww-60-115, wh-35-35, 115, 35, "Case Sensitive", false, false, win)

	local grid = guiCreateGridList(0, 20, ww, wh-20 -35 -40, false, win)
	local cols = {}
	cols.model = guiGridListAddColumn(grid, "Model ID", 0.2)
	cols.dff = guiGridListAddColumn(grid, "DFF Name", 0.25)
	cols.txd = guiGridListAddColumn(grid, "TXD Name", 0.25)
	cols.ide = guiGridListAddColumn(grid, "IDE File", 0.2)

	local count = populate(grid, cols, ideList)

	addEventHandler( "onClientGUIDoubleClick", grid, 
	function (button)
		if button == "left" then
			local row, col = guiGridListGetSelectedItem(source)
			if row ~= -1 then
				local model, dff, txd, ide = guiGridListGetItemText(grid, row, cols.model), guiGridListGetItemText(grid, row, cols.dff), guiGridListGetItemText(grid, row, cols.txd), guiGridListGetItemText(grid, row, cols.ide)
				local text = model.." | "..dff..".dff | "..txd..".txd  ("..ide..".ide)"
				if setClipboard(text) then
					outputChatBox("Copied to clipboard:#ffffff "..text, 187,187,187, true)
				end
			end
		end
	end, false)

	addEventHandler( "onClientGUIClick", filter_button, 
	function()
		if isTimer(spam) then return end
		guiSetText(win, "Please wait..")
		guiGridListClear(grid)

		local text = guiGetText(filter)
		spam = setTimer(function()
			guiSetText(win, title)
			spam = nil
		end, 1000, 1)

		local caseSensitive = guiCheckBoxGetSelected(filter_case)

		local count = populate(grid, cols, ideList, text, caseSensitive)
		outputChatBox("Found "..count.." entries for '"..text.."' ("..(caseSensitive and "case sensitive" or "case insensitive")..").", 25,255,25)
	end, false)

	outputChatBox("Showing "..count.." IDE entries.", 25,255,25)
end
addEventHandler("ide-search:viewList", resourceRoot, viewList)

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end

function pairsByKeys(t)
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