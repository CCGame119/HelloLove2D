--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/26 19:42
--

local Class = require('libs.Class')

---@class Utils.ZipReader.ZipEntry:ClassType
---@field public name string
---@field public compress number
---@field public crc number
---@field public size number
---@field public sourceSize number
---@field public offset number
---@field public isDirectory boolean
local ZipEntry = Class.inheritsFrom('ZipEntry')

---@class Utils.ZipReader:ClassType
---@field private _stream Utils.ByteBuffer
---@field private _entryCount number
---@field private _pos number
---@field private _index number
local ZipReader = Class.inheritsFrom('ZipReader')

---@param data byte[]
function ZipReader.__ctor(data)
    self._stream = ByteBuffer.new(data)
    self._stream.littleEndian = true

    local pos = self._stream.length - 22
    self._stream.position = pos + 10
    self._entryCount = self._stream:ReadShort()
    self._stream.position = pos + 16
    self._pos = self._stream:ReadInt()
end

---@param entry Utils.ZipReader.ZipEntry
---@return boolean
function ZipReader:GetNextEntry(entry)
    if self._index >= self._entryCount then
        return false
    end

    self._stream.position = self._pos + 28
    local len = self._stream:ReadUshort()
    local len2 = self._stream:ReadUshort() + self._stream:ReadUshort()

    self._stream.position = self._pos + 46
    local name = self._stream:ReadString(len)
    name = string.gsub(name, '\\', '/')

    entry.name = name
    if name[#name] == '/'then --directory
        entry.isDirectory = true
        entry.compress = 0
        entry.crc = 0
        entry.size, entry.sourceSize = 0, 0
        entry.offset = 0
    else
        entry.isDirectory = false
        self._stream.position = self._pos + 10
        entry.compress = self._stream:ReadUshort()
        self._stream.position = self._pos + 16
        entry.crc = self._stream:ReadUint()
        entry.size = self._stream:ReadInt()
        entry.sourceSize = self._stream:ReadInt()
        self._stream.position = self._pos + 42
        entry.offset = self._stream:ReadInt() + 30 + len
    end

    self._pos = self._pos + 46 + len + len2
    self._index = self._index + 1

    return true
end

---@param entry Utils.ZipReader.ZipEntry
function ZipReader:GetEntryData(entry)
    local data = {}
    if entry.size > 0 then
        self._stream.position = entry.offset
        self._stream.ReadBytes(data, 0, entry.size)
    end
    return data
end

local __get = Class.init_get(ZipReader, true)

__get.entryCount = function(self) return self._entryCount end

ZipReader.ZipEntry = ZipEntry
Utils.ZipReader = ZipReader
return ZipReader