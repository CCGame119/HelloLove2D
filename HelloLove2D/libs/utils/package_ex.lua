--
-- Created by IntelliJ IDEA.
-- AUTHOR: ChenCY
-- Date: 2018/9/29 11:53
--

function package.addSearchPath(path)
    local fullPath = string.format(";%s%s", love.filesystem.getSourceBaseDirectory(), path)
    package.path = package.path .. fullPath
end