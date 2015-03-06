--����һ���࣬��ʱ��֧�ּ̳У��̳з�������quick��class����
--[[
���һ��new����
ʹ����������԰ѳ�ʼ�������Ž� ctor ��������Զ�����
]]
function gf_class()
    local cls = { ctor = function() end }
    cls.__index = cls

    function cls.new(...)
        local instance = setmetatable({}, cls)
        instance:ctor(...)
        return instance
    end

    return cls
end

--[[
�� Lua �����䷽����װΪһ����������
]]
function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end
