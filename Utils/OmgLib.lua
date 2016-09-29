-------------------------------------------------------------------------------
-- The Object-Manipulation Grouping Lib utilities file
-------------------------------------------------------------------------------
local backdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
};

function add_debug_border(frame)
	frame:SetBackdrop(backdrop);
	frame:SetBackdropColor(0.25, 0.05, 0.25, 0.75);
	frame:SetBackdropBorderColor(.5, .5, 0, 1);
end

function create_timer(duration, callback)
	C_Timer.After(duration, callback);
end

function str_pad(str, size, pad_str, pad_dir)
	if (strlen(str) >= size or size < 1) then
		return str;
	end
	if (not pad_str) then
		pad_str = " ";
	end
	if (not pad_dir) then
		pad_dir = "right";
	end
	
	local count = size - strlen(str);
	local pad_left = 0;
	local pad_right = 0;
	if (pad_dir == "both") then
		pad_left = round(count / 2, 0);
		pad_right = count - pad_left;
	elseif (pad_dir == "left") then
		pad_left = count;
	else
		pad_right = count;
	end

	if (pad_left > 0) then
		str = str .. string.rep(pad_str, pad_left);
	end
	if (pad_right > 0) then
		str = string.rep(pad_str, pad_right) .. str;
	end

	return str;
end

local OMG_MONEY = {		--Thanks WowHead Looter!
	["1"] = string.gsub(COPPER_AMOUNT, "%%d ", ""),
	["100"] = string.gsub(SILVER_AMOUNT, "%%d ", ""),
	["10000"] = string.gsub(GOLD_AMOUNT, "%%d ", ""),
 };

function omg_parse_money(amount)
	local copper = 0;
	for base, parser in pairs(OMG_MONEY) do
		local found, _, found_amount = string.find(amount, "(%d+) " .. parser);
		if (found) then
			copper = copper + found_amount * tonumber(base);
		end
	end

	return copper;
end

function build_time_string(timestamp)
	local t = math.floor(timestamp);
	local seconds = math.fmod(t, 60);
	t = math.floor(t / 60);
	local minutes = math.fmod(t, 60);
	local hours = math.floor(t / 60);

	local hours_str = "";
	if (hours > 0) then
		hours_str = "asdqwe" .. str_pad(hours, 2, "0") .. ":";
	end

	return hours_str .. str_pad(minutes, 2, "0") .. ":" .. str_pad(seconds, 2, "0");
end

function end_string(cut_string, length)
	local end_dots = "";
	if (string.len(cut_string) > length + 1) then
		end_dots = "...";
	end
	cut_string = string.sub(cut_string, 1, length);

	return cut_string .. end_dots;
end

function trim(trim_string)
	return (string.gsub(trim_string, "^%s*(.-)%s*$", "%1"))
end

function sortedpairs(t, comparator)
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

function tcount(t)
	local n = 0;
	for _ in pairs(t) do
		n = n + 1;
	end

	return n;
end

function round(num, precision)
	return tonumber(string.format("%." .. (precision or 0) .. "f", num));
	--local mult = 10^(precision or 0);
	--return math.floor(num * mult + 0.5) / mult;
end

function explode(div, str)
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

function push_table(base_table, data)
	for key, value in sortedpairs(data) do
		base_table[key] = value;
	end

	return base_table;
end

function print_r(t)
 	local print_r_cache = {};
	local function sub_print_r(t, indent)
		if (print_r_cache[tostring(t)]) then
			echo(indent .. "*" .. tostring(t));
		else
			print_r_cache[tostring(t)] = true;
			if (type(t) == "table") then
				for pos, val in pairs(t) do
					if (type(val) == "table") then
						echo(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {");
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8));
						echo(indent .. string.rep(" ", string.len(pos)+6) .. "}");
					else
						echo(indent .. "[" .. pos .. "] => " .. tostring(val));
					end
				end
			else
				echo(indent .. tostring(t));
			end
		end
	end
	sub_print_r(t, "  ");
end

function echo(text)
	DEFAULT_CHAT_FRAME:AddMessage(text);
end