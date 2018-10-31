--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/10 19:08
--

local Class = require('libs.Class')
local utf8 = require("utf8")
local bit = require('bit')
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

local Color32 = Love2DEngine.Color32

---@class Utils.ByteBuffer:ClassType
---@field public littleEndian boolean
---@field public stringTable string[]
---@field public version number
---@field public position number
---@field public length number
---@field public bytesAvailable boolean
---@field public buffer byte[]
---@field private _pointer number
---@field private _offset number
---@field private _length number
---@field private _data byte[]
local ByteBuffer = Class.inheritsFrom('ByteBuffer')

---@type byte[] @byte[8]
ByteBuffer.temp = {0, 0, 0, 0, 0, 0, 0, 0}

---@param data byte[]
---@param offset number @default: 0
---@param length number @default: -1
function ByteBuffer:__ctor(data, offset, length)
    self._data = data
    self._pointer = 0
    self._offset = offset
    if length < 0 then
        self._length = #data - offset
    else
        self._length = length
        self.littleEndian = false
    end
end

---@param count number
---@return number
function ByteBuffer:Skip(count)
    self._pointer = self._pointer + count
    return self._pointer
end

---@return byte
function ByteBuffer:ReadByte()
    local b =  self._data[self._offset + self._pointer]
    self._pointer = self._pointer + 1
    return self._pointer
end

---@param output_or_count byte[]|number
---@param destIndex number
---@param count number
---@return byte[]
function ByteBuffer:ReadBytes(output_or_count, destIndex, count)
    if type(output_or_count) == 'number' then
        count = output_or_count
        destIndex = 0
        ---@type byte[]
        output_or_count = {}
    end

    if count > self._length + 1 - self._pointer then
        error('ArgumentOutOfRangeException')
    end
    table.copy_l2(self._data, self._offset + self._pointer, output_or_count, destIndex, count)
    self._pointer = self._pointer + count
    return output_or_count
end

---@return Utils.ByteBuffer
function ByteBuffer:ReadBuffer()
    local count = self:ReadInt()
    local ba = ByteBuffer.new(self._data, self._pointer, count)
    ba.stringTable = self.stringTable
    ba.version = self.version
    self._pointer = self._pointer + count
    return ba
end

---@return char
function ByteBuffer:ReadChar()
    return utf8.char(self:ReadShort())
end

---@return boolean
function ByteBuffer:ReadBool()
    local result = self._data[self._offset + self._pointer] == 1
    self._pointer = self._pointer + 1
    return result
end

---@return number
function ByteBuffer:ReadShort()
    local startIndex = self._offset + self._pointer
    self._pointer = self._pointer + 2
    if self.littleEndian then
        return bor(self._data[startIndex], lshift(self._data[startIndex + 1], 8))
    end
    return bor(lshift(self._data[startIndex], 8), self._data[startIndex + 1])
end

ByteBuffer.ReadUshort = ByteBuffer.ReadShort

---@return number
function ByteBuffer:ReadInt()
    local i = self._offset + self._pointer
    self._pointer = self._pointer + 4

    if self.littleEndian then
        return bor(self._data[i], lshift(self._data[i + 1], 8), lshift(self._data[i + 2], 16), lshift(self._data[i + 3], 24))
    end
    return bor(lshift(self._data[i], 24), lshift(self._data[i + 1], 16), lshift(self._data[i + 2], 8), self._data[i + 3])
end

ByteBuffer.ReadUint = ByteBuffer.ReadInt
ByteBuffer.ReadFloat = ByteBuffer.ReadInt

---@return number
function ByteBuffer:ReadLong()
    local i = self._offset + self._pointer
    self._pointer = self._pointer + 8

    if self.littleEndian then
        return bor(self._data[i], lshift(self._data[i + 1], 8), lshift(self._data[i + 2], 16), lshift(self._data[i + 3], 24),
                lshift(self._data[i + 4], 32), lshift(self._data[i + 5], 40), lshift(self._data[i + 6], 48), lshift(self._data[i + 7], 56))
    end
    return bor(lshift(self._data[i], 56), lshift(self._data[i + 1], 48), lshift(self._data[i + 2], 40), lshift(self._data[i + 3], 32),
            lshift(self._data[i + 4], 24), lshift(self._data[i + 5], 16), lshift(self._data[i + 6], 8), self._data[i + 7])
end

ByteBuffer.ReadDouble = ByteBuffer.ReadLong

---@return string
function ByteBuffer:ReadString(len)
    local bytes = self:ReadBytes(len)
    return string.char(unpack(bytes))
end

---@return string
function ByteBuffer:ReadS()
    local index = self:ReadUshort()
    if index == 65534 then
        return nil
    end
    if index == 65533 then
        return ''
    end
    return self.stringTable[index]
end

---@param val string
function ByteBuffer:WriteS(val)
    local index = self:ReadUshort()
    if index ~= 65534 and index ~= 65533 then
        self.stringTable[index] = val
    end
end

---@return Love2DEngine.Color32
function ByteBuffer:ReadColor()
    local startIndex = self._offset + self._pointer
    local r = self._data[startIndex]
    local g = self._data[startIndex + 1]
    local b = self._data[startIndex + 2]
    local a = self._data[startIndex + 3]
    self._pointer = self._pointer + 4

    return Color32(r, g, b, a)
end

---@param indexTablePos number
---@param blockIndex number
---@return boolean
function ByteBuffer:Seek(indexTablePos, blockIndex)
    local tmp = self._pointer
    self._pointer = indexTablePos
    local segCount = self._data[self._offset + self._pointer]
    self._pointer = self._pointer + 1
    if blockIndex < segCount then
        local useShort = self._data[self._offset + self._pointer] == 1
        self._pointer = self._pointer + 1
        local newPos
        if useShort then
            self._pointer = self._pointer + 2 * blockIndex
            newPos = self:ReadShort()
        else
            self._pointer = self._pointer + 4 * blockIndex
            newPos = self:ReadInt()
        end

        if newPos > 0 then
            self._pointer = indexTablePos + newPos
            return true
        end

        self._pointer = tmp
        return false

    else
        self._pointer = tmp
        return false
    end
end


local __get = Class.init_get(ByteBuffer, true)
local __set = Class.init_set(ByteBuffer, true)

---@param self Utils.ByteBuffer
__get.position = function(self) return self._pointer end

---@param self Utils.ByteBuffer
---@param val number
__set.position = function(self, val) self._pointer = val end

---@param self Utils.ByteBuffer
__get.length = function(self) return self._length end

---@param self Utils.ByteBuffer
__get.bytesAvailable = function(self) return self._pointer <= self._length end

---@param self Utils.ByteBuffer
__get.buffer = function(self) return self._data end


Utils.ByteBuffer = ByteBuffer
return ByteBuffer