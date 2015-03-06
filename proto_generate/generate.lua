--[[
ini 文件读取成 lua 的 table
]]
function loadIni(filename)
	filename = filename or "proto.ini"
	assert(type(filename) == "string", 'filename is not string')
	local file = assert(io.open(filename, 'r'), "can't open that file")
	local data = {}
	local section
	for line in file:lines() do
		--print(line)
		local tempSection = line:match('^%[([^%[%]]+)%]$')
		tempSection = tonumber(tempSection)
		if tempSection then
			section = tempSection
			data[section] = data[section] or {}
		end

		local param, value = line:match('^([%w]+)%s-=%s-(.+)$')
		if param and value and section then
			data[section][param] = {}
			if param == "types" then
				for i = 1, string.len(value) do
					data[section][param][i] = string.sub(value, i, i)
				end
			elseif param == "keys" then
				for w in string.gmatch(value, '[%w]+,-') do
					table.insert(data[section][param], w)
				end
			end
		end
	end
	file:close()
	return data
end

function writeLuaTableToFile(file, lua_table, language)
	local prefix = '\n    '
	local key, sep, valueBKL, valueBKR
	local bracketL = ""
	local bracketR = ""
	if language == 'lua' then
		bracketL = '['
		bracketR = ']'
		sep = ' = '
		valueBKL = '{ \"'
		valueBKR = '\" },'
	else
		sep = ' : '
		valueBKL = '[ \"'
		valueBKR = '\" ],'
	end

	for k, v in pairs(lua_table) do
		if type(k) == 'string' then
			k = '\"' .. k .. '\"'
		end
		file:write(prefix .. bracketL .. k .. bracketR .. sep .. '{')

		for name, tbstr in pairs(v) do
			name = '\"' .. name .. '\"'
			file:write(prefix .. "    " .. bracketL .. name ..bracketR .. sep .. valueBKL)
			file:write(table.concat(tbstr, "\", \"") .. valueBKR)
		end

		file:write(prefix .. '},')
	end
end

--[[
根据 ini 文件生成指定语言版本协议文件
js or lua
]]
function generatefile(tbProto, language)
	local file, prefix, suffix
	if language == 'lua' then
		file = "proto.lua"
		prefix = "--[[\n" .. "Don\'t modify this file manually!\n" .. "]]\n" .. "local _p = {"
		suffix = "\n}\n" .. "return _p\n\n"
	else
		file = "proto.js"
		prefix = "/*\n" .. "Don\'t modify this file manually!\n" .. "*/\n" .. "var _p = {"
		suffix = "\n};\n" .. "module.exports = _p;\n"
	end

	local luaFile = io.open(file, 'w')
	luaFile:write(prefix)
	writeLuaTableToFile(luaFile, tbProto, language)
	luaFile:write(suffix)
	luaFile:close()
end

local tbProto = loadIni("proto.ini")
generatefile(tbProto, "lua")
generatefile(tbProto, "js")
