--[[
    Will
    HawDevelopment
    26/10/2021
--]]

local KeyToFunc
KeyToFunc = {
    never = function(self)
        rawset(self, "Never", not rawget(self, "Never"))
    end,
    be = function (self)
        rawset(self, "Be", true)
        KeyToFunc.equal(self)
    end,
    equal = function(self)
        getmetatable(self).__call = function (_, val)
            local val2 = rawget(self, "Value")
            local res = val2 == (val or error("No value given to will!"))
            local never = rawget(self, "Never")
            if never then
                res = not res
            end
            assert(res, ("Expected value %s%s to be %s"):format(tostring(val2), never and " never" or "", tostring(val)))
        end
    end,
    a = function (self, settings)
        if settings.CheckGrammar then
            assert(rawget(self, "Be"), "Expected \"be\" before \"a\" (Grammar Check, Can be disabled!)")
        end
        getmetatable(self).__call = function (_, val)
            local val1 = rawget(self, "Value")
            val = val or error("No value given to will!")
            local res = type(val1) == val
            local never = rawget(self, "Never")
            if never then
                res = not res
            end
            assert(res, ("Expected the type %s%s to be %s"):format(type(val1), never and " never" or "", type(val)))
        end
    end,
    exist = function (self)
        getmetatable(self).__call = function ()
            local res = rawget(self, "Value") ~= nil
            local never = rawget(self, "Never")
            if never then
                res = not res
            end
            assert(res, "Expected the value to exist")
        end
    end,
    have = function (self)
        getmetatable(self).__call = function (_, key)
            local val = rawget(self, "Value")
            local res = type(val) == "table" and val[key] ~= nil
            local never = rawget(self, "Never")
            if never then
                res = not res
            end
            assert(res, ("Expected the key %s%s to be in value"):format(tostring(key), never and " never" or ""))
        end
    end,
    fail = function (self)
        getmetatable(self).__call = function ()
            local suc, err = pcall(rawget(self, "Value"))
            suc = not suc
            
            local never = rawget(self, "Never")
            if never then
                suc = not suc
            end
            assert(suc, ("Expected the value%s to fail"):format(never and " never" or ""))
        end
    end,
}
KeyToFunc.exists = KeyToFunc.exist
KeyToFunc.throw = KeyToFunc.fail
KeyToFunc["error"] = KeyToFunc.fail

function Will(v)
    
    local self = setmetatable({
        Value = v,
        Never = false,
        
        -- Grammar
        Be = false,
    }, {
        __index = function (self, key)
            if KeyToFunc[key] then
                KeyToFunc[key](self, {})
            end
            return self
        end
    })
    return self
end

return Will