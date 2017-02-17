--
-- The important functions here are
-- Blob:Encode([some table])			Returns a string blob of the serialized data.
-- Blob:Decode([some encoded string])	Returns a lua table from a string blob.
--


Blob = {}

function Blob:Error(value)
	print('Cannot encode value')
	assert(false, 'Cannot encode value')
end

function Blob:PrintType(value, stack, output, dataType)
	local ReduceTypeMap =
	{
		["number"] = "n",
		-- user type data may go here. (vectors)
	}
	local _type = ReduceTypeMap[type(value)]
	assert(_type, "Printing type problem.")
	table.insert(output, string.format("%s%s", _type, value))
end

Blob.number			= Blob.PrintType
Blob['function'] 	= Blob.Error
Blob.thread			= Blob.Error


function Blob:EscapeString(str)
	-- Escape escape character
	local _escapedStr = str:gsub("@", "@@")
	 -- Find any non-ascii strings
	 -- %w alphanumeric, %p punctuation ^ inverse and the space character
	 local function expandForbiddenChars(str)
	 	local chars = {}
	 	for i = 1, #str do
	 		table.insert(chars, string.format("@%03d", str:byte(i)))
	 	end
	 	return table.concat(chars)
	 end
	 return _escapedStr:gsub("([^%w%p ]+)", expandForbiddenChars)
end

function Blob:string(str,  stack, output, dataType)
	local _escapedStr = self:EscapeString(str)
	table.insert(output, string.format('s%d %s', _escapedStr:len(), _escapedStr))
end


function Blob:boolean(value, stack, output, dataType)
	if value == true then
		table.insert(output, 't')
	else
		table.insert(output, 'f')
	end
end

function Blob:userdata(value, stack, output, dataType)
	-- An extra look up will be needed here using Type instead of type
	self:_printType(value, stack, output, dataType)
end

function Blob:OpenTable(t, stack, output, dataType)
	table.insert(output, string.format("["))
end

function Blob:CloseTable(t, stack, output, dataType)
	table.insert(output, string.format("]"))
end

function Blob:KeyPairAssign(output)
	table.insert(output, ";")
end

function Blob:HitLoop(t, stack, output, dataType)
	print('Cannot print tables with loops.')
	assert(false, 'Cannot print tables with loops.')
end

function Blob:Encode(t)

	local tType = type(t)
	if tType ~= 'table' then
		out = {}
	 	self[tType](self, t, nil, out, tType)
	 	return out[1]
	end

	return IterTable(t, nil, nil, nil, self)
end

function Blob:DecodeTable(s, pos)
	local _tableValue = {}
	pos = pos + 1 -- skip the opening '['
	local nextChar = s:sub(pos, pos) -- get whatever is next

	while nextChar ~= "]" do
		local key = nil
		local value, finish = self:Decode(s, pos)

		pos = finish
		nextChar = s:sub(pos, pos)
		if nextChar == ';' then
			key = value
			value, finish = self:Decode(s, pos + 1)
			pos = finish
			nextChar = s:sub(pos, pos)
		end

		if key ~= nil then
			_tableValue[key] = value
		elseif value ~= nil then
			table.insert(_tableValue, value)
		end
	end

	return _tableValue, pos + 1
end

function Blob:DecodeNumber(s, pos)
	-- pos + 1 to skip 'n'
	local start, finish = s:find("-?%d+%.?%d*", pos)
	if start == nil then
		pos = s:len()
		print("Error failed to parse number")
		return
	end
	local number = tonumber(string.sub(s, start, finish))
	return number, finish + 1
end

function Blob:DecodeBoolean(s, pos)
	--pos = pos + 1 -- 1 - 'b',
	local _value = s:sub(pos, pos) == 't'
	return _value, pos + 1
end

function Blob:ExpandString(str)
	local expandedStr = str:gsub("@@", "@")
 	local function unescapeStr(str)
	 	return string.char(tonumber(str))
	end
	return expandedStr:gsub("@(%d%d%d)", unescapeStr)
end

function Blob:DecodeString(s, pos)
	-- pos + 1 skips 's'
	local start, pos = s:find("%d+", pos + 1)
	if start == nil then
		pos = s:len()
		print('Error parsing string - couldnt find number')
		return
	end
	local _strLen = tonumber(string.sub(s, start, pos))
	pos = pos + 1
	local finish = pos + _strLen
	local _str = string.sub(s, pos + 1, finish)
	return self:ExpandString(_str), finish + 1
end

Blob.DecodeMap =
{
	['['] = Blob.DecodeTable,
	['n'] = Blob.DecodeNumber,
	['t'] = Blob.DecodeBoolean,
	['f'] = Blob.DecodeBoolean,
	['s'] = Blob.DecodeString,
}

function Blob:Decode(s, pos)
	pos = pos or 1
	local char = s:sub(pos, pos)
	assert(Blob.DecodeMap[char], "Decode failure")
	return Blob.DecodeMap[char](self, s, pos)
end

--
-- Testing (if you make changes go through these one by one to make sure they still hold.)
--


-- TblToString = function(t) return IterTable(t) end
-- print( "{} ->",  	TblToString(Blob:Decode(Blob:Encode({}))))
-- print(Blob:Encode({}))
-- print( "{{}} ->",  	TblToString(Blob:Decode(Blob:Encode( {{}}))) )
-- print( "{{}, {}, {}} ->",  	TblToString(Blob:Decode(Blob:Encode( {{}, {}, {}}))) )
-- print( "{{{}}, {{}, {}}, {{}, {}, {}}} ->",  	TblToString(Blob:Decode(Blob:Encode( {{{}}, {{},{}}, {{},{},{}}}))) )
-- print(Blob:Encode( {[{}] = {}}))
-- print( "{[{}] = {}} ->",  	TblToString(Blob:Decode(Blob:Encode( {[{}] = {}}))) )
-- print( "{[{{}, {{}}}] = {}} ->",  	TblToString(Blob:Decode(Blob:Encode( {[{{}, {{}}}] = {}}))) )
-- print( "{true, true, false} ->", TblToString(Blob:Decode(Blob:Encode({true, true, false}))))
-- print( "{[true] = true, true, false} ->", TblToString(Blob:Decode(Blob:Encode({[true] = true, true, false}))))
-- print( "{[true] = {true, true, [{}] = true} ->", TblToString(Blob:Decode(Blob:Encode({[true] = {true, true, [{}] = true}}))))
-- print( "{1, 2, 3} ->", TblToString(Blob:Decode(Blob:Encode({1, 2, 3}))))
-- print( "{-1} ->", TblToString(Blob:Decode(Blob:Encode({-1}))))
-- print(Blob:Encode( {1.1} ))
-- print( "{1.1} ->", TblToString(Blob:Decode(Blob:Encode({1.1}))))
-- print( "{1.0001, 0.333, -0.66745001} ->", TblToString(Blob:Decode(Blob:Encode({1.0001, 0.333, -0.66745001}))))
-- print( "{'test'} ->", TblToString(Blob:Decode(Blob:Encode({'test'}))))
-- print("{['test'] = 9, [8] = 'test2'}", TblToString(Blob:Decode(Blob:Encode({{['test'] = 9, [8] = 'test2'}}))))
-- print(Blob:Encode( {[10] = 9, [-2] = 1} ))
-- print("{[10] = 9, [-2] = 1}", TblToString(Blob:Decode(Blob:Encode({[10] = 9, [-2] = 1}))))


-- -- This is to check it can handle encoding non-ascii characters
-- print(Blob:Encode{["somet@\0hing"] = 5})
-- print("中")
-- for i = 1, #"中" do
-- 	print(string.byte("中", i))
-- end
-- print("\228\184\173")
-- print(Blob:Encode({"中"}))

-- print(TblToString(Blob:Decode(Blob:Encode({"中"}))))
-- print(TblToString(Blob:Decode(Blob:Encode{["some@\0thing"] = 5})))



