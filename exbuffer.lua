--[[
使用lpack实现的数据缓冲
]]

require("lpack.core")

require("script/lib/basefunctions.lua")

ENDIAN_BIG = 1
ENDIAN_LITTLE = 2

local Exbuffer = gf_class()

--[[
package bit struct
2 bytes LEN(Big endian) + 2 bytes msgid(Big endian) + json body string
>H + >H + A
]]
Exbuffer.BODY_LEN = 2
Exbuffer.MSGID_LEN = 2
Exbuffer.PACKET_MAX_LEN = 2100000000

--[[
endian 1 长度、msgid、为大端
       2 小端
]]
function Exbuffer:ctor(endian)
	self._endian = endian or ENDIAN_BIG
	self._buf = {}
	self.offset = 0
end

function Exbuffer:parseMsg(__bytes)
	local msgs = {}
	-- copy bytes to buffer
	print("hh = ", string.len(__bytes))
	for i = 1, string.len(__bytes) do
		self._buf[#self._buf + 1] = string.sub(__bytes, i, i)
	end

	while self:getBufferLen() >= self.BODY_LEN do
		local bodylen = self:readUShort(self.offset)
		print("bodylen = ", bodylen)
		if bodylen < self.PACKET_MAX_LEN then
			if (#self._buf - self.offset - self.BODY_LEN - self.MSGID_LEN) >= bodylen then
				local msgid = self:readUShort(self.offset + self.BODY_LEN)
				print("msgid = ", msgid)
				local msg = {}
				msg.id = msgid
				msg.data = self:readString(self.offset + self.BODY_LEN + self.MSGID_LEN, bodylen)
				msgs[#msgs + 1] = msg
				self.offset = self.offset + self.BODY_LEN + self.MSGID_LEN + bodylen
			end
		else
			print("致命错误，服务端消息长度错误", bodylen)
			break
		end
	end

	local leaveLen = self:getBufferLen()
	if leaveLen <= 0 then
		self._buf = {}
	else
		local tmp = {}
		for i = 1, #leaveLen do
			tmp[i] = self._buf[self.offset + i]
		end
		self._buf = tmp
	end
	self.offset = 0
	return msgs
end

function Exbuffer:readUShort(pos)
	pos = pos or 0
	local __, __v = string.unpack(table.concat(self._buf, "", pos + 1, pos + 2), self:getFmt('H'))
	return __v
end

function Exbuffer:readString(pos, len)
	pos = pos or 0
	local __, __v = string.unpack(table.concat(self._buf, "", pos + 1, pos + len), self:getFmt('A')..len)
	print("stirng = ", __, __v, pos, len)
	return __v
end

function Exbuffer:getBufferLen()
	return #self._buf - self.offset
end

function Exbuffer:getFmt(__fmt)
	__fmt = __fmt or ""
	if self._endian == ENDIAN_BIG then
		return ">"..__fmt
	elseif self._endian == ENDIAN_LITTLE then
		return "<"..__fmt
	end
	return "="..__fmt
end

return Exbuffer

