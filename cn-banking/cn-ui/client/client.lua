local table = {}

function DrawNotify(id, text, color, icon)
	if id then
		if table[id] == nil then
			table[id] = text
			print("+")
			SendNUIMessage({display = true, text = text, color = color or "#26242f",icon=icon or 'fas fa-exclamation'})
		end
	end
	return id
end

function Clear(id)
	if table[id] ~= nil then
		table[id] = nil
		print("-")
		SendNUIMessage({display = false})
	end
end