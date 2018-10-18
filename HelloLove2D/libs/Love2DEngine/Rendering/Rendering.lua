--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/10/15 17:02
--

---@class Love2DEngine.Rendering:namespace
local Rendering = {name = 'Love2DEngine.Rendering'}

---@class Love2DEngine.Rendering.BlendMode:enum
local BlendMode = {
    Zero = 0,
    One = 1,
    DstColor = 2,
    SrcColor = 3,
    OneMinusDstColor = 4,
    SrcAlpha = 5,
    OneMinusSrcColor = 6,
    DstAlpha = 7,
    OneMinusDstAlpha = 8,
    SrcAlphaSaturate = 9,
    OneMinusSrcAlpha = 10,
}

---@class Love2DEngine.Rendering.CompareFunction:enum
local CompareFunction = {
    Disabled = 0,
    Never = 1,
    Less = 2,
    Equal = 3,
    LessEqual = 4,
    Greater = 5,
    NotEqual = 6,
    GreaterEqual = 7,
    Always = 8,
}

---@class Love2DEngine.Rendering.StencilOp:enum
local StencilOp = {
    Keep = 0,
    Zero = 1,
    Replace = 2,
    IncrementSaturate = 3,
    DecrementSaturate = 4,
    Invert = 5,
    IncrementWrap = 6,
    DecrementWrap = 7,
}

Rendering.BlendMode = BlendMode
Rendering.CompareFunction = CompareFunction
Rendering.StencilOp = StencilOp
Love2DEngine.Rendering = Rendering
Love2DEngine.Rendering = Rendering
return Rendering