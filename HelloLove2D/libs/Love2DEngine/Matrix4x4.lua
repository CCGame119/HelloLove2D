--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/8 15:24
--

local Class = require('libs.Class')

local Vector4 = Love2DEngine.Vector4
local Vector3 = Love2DEngine.Vector3
local setmetatable = setmetatable

---@class Love2DEngine.Matrix4x4:ClassType
---@field identity Love2DEngine.Matrix4x4
---@field public e11 number
---@field public e12 number
---@field public e13 number
---@field public e14 number
---@field public e21 number
---@field public e22 number
---@field public e23 number
---@field public e24 number
---@field public e31 number
---@field public e32 number
---@field public e33 number
---@field public e34 number
---@field public e41 number
---@field public e42 number
---@field public e43 number
---@field public e44 number
local Matrix4x4 = Class.inheritsFrom('Matrix4x4')

---@param col1 Love2DEngine.Vector4
---@param col2 Love2DEngine.Vector4
---@param col3 Love2DEngine.Vector4
---@param col4 Love2DEngine.Vector4
function Matrix4x4:__ctor(col1, col2, col3, col4)
    self.e11, self.e12, self.e13, self.e14 = col1.x, col2.x, col3.x, col4.x
    self.e21, self.e22, self.e23, self.e24 = col1.y, col2.y, col3.y, col4.y
    self.e31, self.e32, self.e33, self.e34 = col1.z, col2.z, col3.z, col4.z
    self.e41, self.e42, self.e43, self.e44 = col1.w, col2.w, col3.w, col4.w
end

--[[
https://www.mathsisfun.com/algebra/matrix-determinant.html
    |a b c d|
A = |e f g h|
    |i j k l|
    |m n o p|

        |f g h|     |e g h|     |e f h|     |e f g|
|A| = a.|j k l| - b.|i k l| + c.|i j l| - d.|i j k|
        |n o p|     |m o p|     |m n p|     |m n o|

|A| = a.|A1| - b.|A2| + c.|A3| - d.|A4|

a.|A1| = a*(f*(k*p - l*o) - g*(j*p - l*n) + h*(j*o - k*n)) = af*(kp - lo) - ag*(jp - ln) + ah*(jo - kn)
b.|A2| = b*(e*(k*p - l*o) - g*(i*p - l*m) + h*(i*o - k*m)) = be*(kp - lo) - bg*(ip - lm) + bh*(io - km)
c.|A3| = c*(e*(j*p - l*n) - f*(i*p - l*m) + h*(i*n - j*m)) = ce*(jp - ln) - cf*(ip - lm) + ch*(in - jm)
d.|A4| = d*(e*(j*o - k*n) - f*(i*o - k*m) + g*(i*n - j*m)) = de*(jo - kn) - df*(io - km) + dg*(in - jm)

 a.|A1| =  af*(kp - lo) - ag*(jp - ln) + ah*(jo - kn)
-b.|A2| = -be*(kp - lo) + bg*(ip - lm) - bh*(io - km)
 c.|A3| =  ce*(jp - ln) - cf*(ip - lm) + ch*(in - jm)
-d.|A4| = -de*(jo - kn) + df*(io - km) - dg*(in - jm)

|A| = (af - be)*(kp - lo) - (ag - ce)*(jp - ln) + (ah - de)*(jo - kn)
     +(bg - cf)*(ip - lm) - (bh - df)*(io - km) + (ch - dg)*(in - jm)
]]
---@param m Love2DEngine.Matrix4x4
function Matrix4x4.Determinant(m)
    local a, b, c, d = m.e11, m.e12, m.e13, m.e14
    local e, f, g, h = m.e21, m.e22, m.e23, m.e24
    local i, j, k, l = m.e31, m.e32, m.e33, m.e34
    local m, n, o, p = m.e41, m.e42, m.e43, m.e44

    local afbe = a*f - b*e
    local kplo = k*p - l*o
    local agce = a*g - c*e
    local jpln = j*p - l*n
    local ahde = a*h - d*e
    local jokn = j*o - k*n
    local bgcf = b*g - c*f
    local iplm = i*p - l*m
    local bhdf = b*h - d*f
    local iokm = i*o - k*m
    local chdg = c*h - d*g
    local injm = i*n - j*m

    local det =  afbe*kplo - agce*jpln + ahde*jokn
               + bgcf*iplm - bhdf*iokm + chdg*injm
    return det
end

--[[
A-1 = (1/|A|)A*
     | A11 A12 A13 A14 |T
A* = | A21 A22 A23 A24 |
     | A31 A32 A33 A34 |
     | A41 A42 A43 A44 |
]]
---@param m Love2DEngine.Matrix4x4
function Matrix4x4.Inverse(m)
    local a, b, c, d = m.e11, m.e12, m.e13, m.e14
    local e, f, g, h = m.e21, m.e22, m.e23, m.e24
    local i, j, k, l = m.e31, m.e32, m.e33, m.e34
    local m, n, o, p = m.e41, m.e42, m.e43, m.e44

    local afbe = a*f - b*e
    local kplo = k*p - l*o
    local agce = a*g - c*e
    local jpln = j*p - l*n
    local ahde = a*h - d*e
    local jokn = j*o - k*n
    local bgcf = b*g - c*f
    local iplm = i*p - l*m
    local bhdf = b*h - d*f
    local iokm = i*o - k*m
    local chdg = c*h - d*g
    local injm = i*n - j*m

    local det =  afbe*kplo - agce*jpln + ahde*jokn
               + bgcf*iplm - bhdf*iokm + chdg*injm

    local mat = Matrix4x4.identity
    mat.e11 =   f*kplo - g*jpln + h*jokn
    mat.e21 = -(e*kplo - g*iplm - h*iokm)
    mat.e31 =   e*jpln - f*iplm - h*injm
    mat.e41 = -(e*jokn - f*iokm + g*injm)

    mat.e12 = -(b*kplo - c*jpln + d*jokn)
    mat.e22 =   a*kplo - c*iplm + d*iokm
    mat.e32 = -(a*jpln - b*iplm + d*injm)
    mat.e42 =   a*jokn - b*iokm + c*injm

    local gpho = g*p-h*o
    local fphn = f*p-h*n
    local fogn = f*o-g*n
    local ephm = e*p-h*m
    local eogm = e*o-g*m
    local enfm = e*n-f*m

    mat.e13 =   b*gpho - c*fphn + d*fogn
    mat.e23 = -(a*gpho - c*ephm + d*eogm)
    mat.e33 =   a*fphn - b*ephm + d*enfm
    mat.e43 = -(a*fogn - b*eogm + c*enfm)

    local glhk = g*l-h*k
    local flhj = f*l-h*j
    local fkgj = f*k-g*j
    local elhi = e*l-h*i
    local ekgi = e*k-g*i
    local ejfi = e*j-f*i

    mat.e14 = -(b*glhk - c*flhj + d*fkgj)
    mat.e24 =   a*glhk - c*elhi + d*ekgi
    mat.e34 = -(a*flhj - b*elhi + d*ejfi)
    mat.e44 =   a*fkgj - b*ekgi + c*ejfi

    return mat:Div(det)
end

---@param pos Love2DEngine.Vector3
---@param q Love2DEngine.Quaternion
---@param s Love2DEngine.Vector3
---@return Love2DEngine.Matrix4x4
function Matrix4x4.TRS(pos, q, s)
    --[[
    transpose matrix
    1,  0,  0, 0
    0,  1,  0, 0
    0,  0,  1, 0
    dx, dy, dz, 1

    rotation matrix
    http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToMatrix/
    ]]
    --- transpose
    local mat = Matrix4x4.identity
    mat.e41, mat.e42, mat.e43 = pos.x, pos.y, pos.z

    --- rotation with quternion
    local x2  = q.x*2;	local y2  = q.y*2;	local z2  = q.z*2;
    local xx2 = x2*q.x;	local yy2 = y2*q.y;	local zz2 = z2*q.z;
    local xy2 = x2*q.y;	local zw2 = z2*q.w;	local xz2 = x2*q.z;
    local yw2 = y2*q.w;	local yz2 = y2*q.z;	local xw2 = x2*q.w;

    mat.e11 = 1-yy2-zz2
    mat.e21 = xy2-zw2
    mat.e31 = xz2+yw2

    mat.e12 = xy2+zw2
    mat.e22 = 1-xx2-zz2
    mat.e32 = yz2-xw2

    mat.e13 = xz2-yw2
    mat.e23 = yz2+xw2
    mat.e33 = 1-xx2-yy2

    -- scale
    mat.e11 = mat.e11 * s.x
    mat.e22 = mat.e22 * s.y
    mat.e33 = mat.e33 * s.z

    return mat
end

---@param point Love2DEngine.Vector3
---@return Love2DEngine.Vector3
function Matrix4x4:MultiplyPoint(point)
    local v = Vector3.zero
    v.x = self.e11 * point.x + self.e21 * point.y + self.e31 * point.z + self.e41
    v.y = self.e12 * point.x + self.e22 * point.y + self.e32 * point.z + self.e42
    v.z = self.e13 * point.x + self.e23 * point.y + self.e33 * point.z + self.e43
    local w = self.e14 * point.x + self.e24 * point.y + self.e34 * point.z + self.e44
    v.x = v.x / w
    v.y = v.y / w
    v.z = v.z / w
    return v
end

---@param mat Love2DEngine.Matrix4x4
function Matrix4x4:Multiply(mat)
    local lhs, rhs = self, mat

    local e11 = lhs.e11*rhs.e11 + lhs.e12*rhs.e21 + lhs.e13*rhs.e31 + lhs.e14*rhs.e41
    local e12 = lhs.e11*rhs.e12 + lhs.e12*rhs.e22 + lhs.e13*rhs.e32 + lhs.e14*rhs.e42
    local e13 = lhs.e11*rhs.e13 + lhs.e12*rhs.e23 + lhs.e13*rhs.e33 + lhs.e14*rhs.e43
    local e14 = lhs.e11*rhs.e14 + lhs.e12*rhs.e24 + lhs.e13*rhs.e34 + lhs.e14*rhs.e44
    local e21 = lhs.e21*rhs.e11 + lhs.e22*rhs.e21 + lhs.e23*rhs.e31 + lhs.e24*rhs.e41
    local e22 = lhs.e21*rhs.e12 + lhs.e22*rhs.e22 + lhs.e23*rhs.e32 + lhs.e24*rhs.e42
    local e23 = lhs.e21*rhs.e13 + lhs.e22*rhs.e23 + lhs.e23*rhs.e33 + lhs.e24*rhs.e43
    local e24 = lhs.e21*rhs.e14 + lhs.e22*rhs.e24 + lhs.e23*rhs.e34 + lhs.e24*rhs.e44
    local e31 = lhs.e31*rhs.e11 + lhs.e32*rhs.e21 + lhs.e33*rhs.e31 + lhs.e34*rhs.e41
    local e32 = lhs.e31*rhs.e12 + lhs.e32*rhs.e22 + lhs.e33*rhs.e32 + lhs.e34*rhs.e42
    local e33 = lhs.e31*rhs.e13 + lhs.e32*rhs.e23 + lhs.e33*rhs.e33 + lhs.e34*rhs.e43
    local e34 = lhs.e31*rhs.e14 + lhs.e32*rhs.e24 + lhs.e33*rhs.e34 + lhs.e34*rhs.e44
    local e41 = lhs.e41*rhs.e11 + lhs.e42*rhs.e21 + lhs.e43*rhs.e31 + lhs.e44*rhs.e41
    local e42 = lhs.e41*rhs.e12 + lhs.e42*rhs.e22 + lhs.e43*rhs.e32 + lhs.e44*rhs.e42
    local e43 = lhs.e41*rhs.e13 + lhs.e42*rhs.e23 + lhs.e43*rhs.e33 + lhs.e44*rhs.e43
    local e44 = lhs.e41*rhs.e14 + lhs.e42*rhs.e24 + lhs.e43*rhs.e34 + lhs.e44*rhs.e44

    self.e11 = e11
    self.e12 = e12
    self.e13 = e13
    self.e14 = e14
    self.e21 = e21
    self.e22 = e22
    self.e23 = e23
    self.e24 = e24
    self.e31 = e31
    self.e32 = e32
    self.e33 = e33
    self.e34 = e34
    self.e41 = e41
    self.e42 = e42
    self.e43 = e43
    self.e44 = e44

    return self
end

---@param vec Love2DEngine.Vector3
function Matrix4x4.Translate(vec)
    local mat = Matrix4x4.identity
    mat.e41, mat.e42, mat.e43 = pos.x, pos.y, pos.z
end

---@param val number
---@return Love2DEngine.Matrix4x4
function Matrix4x4:Div(val)
    for i = 1, 4 do
        for j = 1, 4 do
            local key = 'e'.. i .. j
            self[key] = self[key] / val
        end
    end
    return self
end

--TODO: Love2DEngine.Matrix4x4

Matrix4x4.__tostring = function(mat)
    local fmt = '|%f, %f, %f, %f|'
    local r1 = string.format(fmt, mat.e11, mat.e12, mat.e13, mat.e14)
    local r2 = string.format(fmt, mat.e21, mat.e22, mat.e23, mat.e24)
    local r3 = string.format(fmt, mat.e31, mat.e32, mat.e33, mat.e34)
    local r4 = string.format(fmt, mat.e41, mat.e42, mat.e43, mat.e44)
    local str = string.format('%s\n%s\n%s\n%s\n', r1, r2, r3, r4)
    return str
end

Matrix4x4.__mul = function(lhs, rhs)
    local mat = Matrix4x4.identity

    mat.e11 = lhs.e11*rhs.e11 + lhs.e12*rhs.e21 + lhs.e13*rhs.e31 + lhs.e14*rhs.e41
    mat.e12 = lhs.e11*rhs.e12 + lhs.e12*rhs.e22 + lhs.e13*rhs.e32 + lhs.e14*rhs.e42
    mat.e13 = lhs.e11*rhs.e13 + lhs.e12*rhs.e23 + lhs.e13*rhs.e33 + lhs.e14*rhs.e43
    mat.e14 = lhs.e11*rhs.e14 + lhs.e12*rhs.e24 + lhs.e13*rhs.e34 + lhs.e14*rhs.e44
    mat.e21 = lhs.e21*rhs.e11 + lhs.e22*rhs.e21 + lhs.e23*rhs.e31 + lhs.e24*rhs.e41
    mat.e22 = lhs.e21*rhs.e12 + lhs.e22*rhs.e22 + lhs.e23*rhs.e32 + lhs.e24*rhs.e42
    mat.e23 = lhs.e21*rhs.e13 + lhs.e22*rhs.e23 + lhs.e23*rhs.e33 + lhs.e24*rhs.e43
    mat.e24 = lhs.e21*rhs.e14 + lhs.e22*rhs.e24 + lhs.e23*rhs.e34 + lhs.e24*rhs.e44
    mat.e31 = lhs.e31*rhs.e11 + lhs.e32*rhs.e21 + lhs.e33*rhs.e31 + lhs.e34*rhs.e41
    mat.e32 = lhs.e31*rhs.e12 + lhs.e32*rhs.e22 + lhs.e33*rhs.e32 + lhs.e34*rhs.e42
    mat.e33 = lhs.e31*rhs.e13 + lhs.e32*rhs.e23 + lhs.e33*rhs.e33 + lhs.e34*rhs.e43
    mat.e34 = lhs.e31*rhs.e14 + lhs.e32*rhs.e24 + lhs.e33*rhs.e34 + lhs.e34*rhs.e44
    mat.e41 = lhs.e41*rhs.e11 + lhs.e42*rhs.e21 + lhs.e43*rhs.e31 + lhs.e44*rhs.e41
    mat.e42 = lhs.e41*rhs.e12 + lhs.e42*rhs.e22 + lhs.e43*rhs.e32 + lhs.e44*rhs.e42
    mat.e43 = lhs.e41*rhs.e13 + lhs.e42*rhs.e23 + lhs.e43*rhs.e33 + lhs.e44*rhs.e43
    mat.e44 = lhs.e41*rhs.e14 + lhs.e42*rhs.e24 + lhs.e43*rhs.e34 + lhs.e44*rhs.e44

    return mat
end

local __get = Class.init_get(Matrix4x4, true)
local __set = Class.init_set(Matrix4x4, true)

__get.inverse = Matrix4x4.Inverse
__get.identity = function(self) return Matrix4x4.new(Vector4(1, 0, 0, 0), Vector4(0, 1, 0, 0), Vector4(0, 0, 1, 0), Vector4(0, 0, 0, 1)) end
__get.zero = function(self) return Matrix4x4.new(Vector4(), Vector4(), Vector4(), Vector4()) end
__get.isIdentity = function(self)
    if  self.e11 == 1 and self.e12 == 0 and self.e13 == 0 and self.e14 == 0 and
        self.e21 == 0 and self.e22 == 1 and self.e23 == 0 and self.e24 == 0 and
        self.e31 == 0 and self.e32 == 0 and self.e33 == 1 and self.e34 == 0 and
        self.e41 == 0 and self.e42 == 0 and self.e43 == 0 and self.e44 == 1 then
        return true
    end
end

Love2DEngine.Matrix4x4 = Matrix4x4
setmetatable(Matrix4x4, Matrix4x4)
return Matrix4x4