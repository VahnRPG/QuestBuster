-------------------------------------------------------------------------------
-- The Object-Manipulation Grouping Lib utilities file
-------------------------------------------------------------------------------
local mod_name, mod = ...;
mod.omg = {};

local OMG_MONEY = {		--Thanks WowHead Looter!
	["1"] = string.gsub(COPPER_AMOUNT, "%%d ", ""),
	["100"] = string.gsub(SILVER_AMOUNT, "%%d ", ""),
	["10000"] = string.gsub(GOLD_AMOUNT, "%%d ", ""),
 };

function mod.omg:parse_money(money)
	local copper = 0;
	for base, parser in pairs(OMG_MONEY) do
		local found, _, found_amount = string.find(money, "(%d+) " .. parser);
		if (found) then
			copper = copper + found_amount * tonumber(base);
		end
	end

	return copper;
end

local backdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
};

function mod.omg:add_debug_border(frame)
	frame:SetBackdrop(backdrop);
	frame:SetBackdropColor(0.25, 0.05, 0.25, 0.75);
	frame:SetBackdropBorderColor(.5, .5, 0, 1);
end

function mod.omg:create_timer(duration, callback)
	C_Timer.After(duration, callback);
end

function mod.omg:str_pad(text, size, pad_str, pad_dir)
	if (strlen(text) >= size or size < 1) then
		return text;
	end
	if (not pad_str) then
		pad_str = " ";
	end
	if (not pad_dir) then
		pad_dir = "right";
	end
	
	local count = size - strlen(text);
	local pad_left = 0;
	local pad_right = 0;
	if (pad_dir == "both") then
		pad_left = mod.omg:round(count / 2, 0);
		pad_right = count - pad_left;
	elseif (pad_dir == "left") then
		pad_left = count;
	else
		pad_right = count;
	end

	if (pad_left > 0) then
		text = text .. string.rep(pad_str, pad_left);
	end
	if (pad_right > 0) then
		text = string.rep(pad_str, pad_right) .. text;
	end

	return text;
end

function mod.omg:build_time_string(timestamp)
	local t = math.floor(timestamp);
	local seconds = math.fmod(t, 60);
	t = math.floor(t / 60);
	local minutes = math.fmod(t, 60);
	local hours = math.floor(t / 60);

	local hours_str = "";
	if (hours > 0) then
		hours_str = mod.omg:str_pad(hours, 2, "0") .. ":";
	end

	return hours_str .. mod.omg:str_pad(minutes, 2, "0") .. ":" .. mod.omg:str_pad(seconds, 2, "0");
end

function mod.omg:end_string(text, length)
	local end_dots = "";
	if (string.len(text) > length + 1) then
		end_dots = "...";
	end
	text = string.sub(text, 1, length);

	return text .. end_dots;
end

function mod.omg:trim(text)
	return string.gsub(text, "^%s*(.-)%s*$", "%1");
end

function mod.omg:ucwords(text)
	local function ucwords_helper(first, rest)
		return first:upper() .. rest:lower();
	end

	return text:gsub("(%a)([%w_']*)", ucwords_helper);
end

function mod.omg:sortedpairs(t, comparator)
	local sortedKeys = {};
	table.foreach(t, function(k, v) table.insert(sortedKeys, k) end);
	table.sort(sortedKeys, comparator);
	local i = 0;
	local function _f(_s, _v)
		i = i + 1;
		local k = sortedKeys[i];
		if (k) then
			return k, t[k];
		end
	end

	return _f, nil, nil;
end

function mod.omg:tcount(t)
	local n = 0;
	for _ in pairs(t) do
		n = n + 1;
	end

	return n;
end

function mod.omg:round(num, precision)
	return tonumber(string.format("%." .. (precision or 0) .. "f", num));
end

function mod.omg:explode(div, str)
	if (div == "") then
		return nil;
	end

	local pos = 0;
	local arr = {};
	for st, sp in function() return string.find(str, div, pos, true) end do
		table.insert(arr, string.sub(str, pos, st-1));
		pos = sp + 1;
	end

	table.insert(arr, string.sub(str, pos));

	return arr;
end

function mod.omg:push_table(base_table, data)
	for key, value in mod.omg:sortedpairs(data) do
		base_table[key] = value;
	end

	return base_table;
end

function mod.omg:in_array(needle, haystack)
	for key, value in pairs(haystack) do
		if (value == needle) then
			return true;
		end
	end
	return false;
end

function mod.omg:clone_table(t)
    if (type(t) ~= "table") then
		return t;
	end

	local copy = {};
	for k, v in next, t, nil do
		copy[mod.omg:clone_table(k)] = mod.omg:clone_table(v);
	end
	setmetatable(copy, mod.omg:clone_table(getmetatable(t)));

    return copy;
end

function mod.omg:print_r(t)
	local print_r_cache = {};
	local function sub_print_r(t, indent)
		if (print_r_cache[tostring(t)]) then
			mod.omg:echo(indent .. "*" .. tostring(t));
		else
			print_r_cache[tostring(t)] = true;
			if (type(t) == "table") then
				for pos, val in pairs(t) do
					if (type(val) == "table") then
						mod.omg:echo(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {");
						sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8));
						mod.omg:echo(indent .. string.rep(" ", string.len(pos) + 6) .. "}");
					elseif (type(val) == "string") then
						mod.omg:echo(indent .. "[" .. pos .. "] => \"" .. val .. "\"");
					else
						mod.omg:echo(indent .. "[" .. pos .. "] => " .. tostring(val));
					end
				end
			else
				mod.omg:echo(indent .. tostring(t));
			end
		end
	end
	if (type(t) == "table") then
		mod.omg:echo(tostring(t).." {");
		sub_print_r(t, "  ");
		mod.omg:echo("}");
	else
		sub_print_r(t, "  ");
	end

	mod.omg:echo(" ");
end

function mod.omg:echo(text)
	DEFAULT_CHAT_FRAME:AddMessage(text);
end