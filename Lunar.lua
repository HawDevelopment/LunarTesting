--[[
    Lunar
    HawDevelopment
    25/10/2021
--]]
local path = arg[0]
if path:sub(-1, -1) == "\\" or path:sub(-1, -1) == "/" then
    path = path:sub(1, -2)
end
package.path = path:sub(1, -10) .. "?.lua" .. ";" .. package.path

-- TODO: Add suport for mac
local format, osname = package.cpath:match("%p[\\|/]?%p(%a+)"), ""
if format == "dll" then
    osname = "windows"
elseif format == "so" then
    osname = "linux"
else
    error("Your os is not supported for auto directory")
end

-- Maybe add support for another method?
local canPwsh
local er, code = os.execute("powershell write-host -NoNewline ''")
if er == 0 or code == 0 then
    canPwsh = true
end

local Lunar = require("src.lunar")
local unpack = unpack or table.unpack

local RUN_TEST_DEFUALT = true
local AUTO_DIR = true

local USAGE = [[
    USAGE: Luna.lua [SUBCOMMANDS] [FILES]
    
    SUBCOMMANDS:
        test    Run tests
        add     Adds a test
]]

local function ValueInTable(tab, value)
    for i, val in pairs(tab) do
        if val == value then
            return true, i
        end
    end
    return false
end

local function IsDir(tofind)
    local ercode, code = os.execute("cd " .. tofind)
    if ercode == 0 or code == 0 then
        return true
    else
        return false
    end
end

function RunCommand(args)
    if #arg == 0 then
        if RUN_TEST_DEFUALT then
            arg[1] = "test"
            RunCommand(arg)
        else
            print(USAGE)
        end
    end
    
    
    local os_option, os_index = ValueInTable(args, "--os")
    local Settings = {
        Verbose = ValueInTable(args, "-v") or ValueInTable(args, "--verbose"),
        Quiet = ValueInTable(args, "-q") or ValueInTable(args, "--quiet"),
        Directory = ValueInTable(args, "-d") or ValueInTable(args, "--directory"),
        Os = os_option and args[os_index + 1] or osname,
    }
    
    if args[#args - 1] == "test" or args[#args] == "test" then
        -- Run
        local filename = args[#args - 1] == "test" and args[#args] or "test.lua"
        if osname == "windows" then
            filename = filename:gsub("/", "\\")
        end
        
        local file = io.open(filename, "r")
        
        -- Validate
        if not file and (AUTO_DIR and not IsDir(filename)) then
            print(filename .. " not found")
            return
        end
        
        if not filename:match("%.lua$") then
            if (filename:match("/$") or filename:match("\\$")) and AUTO_DIR then
                -- It must be a directory
                Settings.Directory = true
            else
                print("File must be a lua file")
                return
            end
        else
            filename = filename:gsub("%.lua$", "")
        end
        
        print()
        local setting = { Indentation = "    ", Os = osname, CanPwsh = canPwsh }
        if Settings.Directory then
            setting.Indentation = ""
            
            function RunOut(name, result)
                if not result.Failed then
                    -- Its a directory
                    print(setting.Indentation .. "Running dir: " .. name)
                    setting.Indentation = setting.Indentation .. "    "
                    for key, value in pairs(result) do
                        RunOut(key, value)
                    end
                    setting.Indentation = setting.Indentation:sub(1, -5)
                else
                    print(setting.Indentation .. "Running file: " .. name)
                    Lunar.out(result, setting)
                end
            end
            
            local results = Lunar.run(Settings, filename, osname)
            RunOut(filename, results)
        else
            print("Running file: " .. filename)
            local result = Lunar.run(Settings, filename, osname)
            Lunar.out(result, setting)
        end
        print()
    end
end

if arg then
    RunCommand(arg)
end

return RunCommand
