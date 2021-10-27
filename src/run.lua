--[[
    Runner
    HawDevelopment
    25/10/2021
--]]

function Run(settings, file, osname)
    if settings.Directory and not file:match("%.lua$") then
        local indir = {}
        file = file:gsub("/", "\\")
        
        if osname == "windows" then
            local pfile = io.popen("dir " .. file .. " /b")
            for dir in pfile:lines() do
                table.insert(indir, dir)
            end
            pfile:close()
        elseif osname == "linux" then
            local pfile = io.popen('ls -l "'.. file ..'"')
            for filename in pfile:lines() do
                table.insert(indir, filename)
            end
            pfile:close()
        end
        
        -- Run directory
        local results = {}
        for _, value in pairs(indir) do
            table.insert(results, Run(settings, value))
        end
        return results
    end
    
    local tests = require(file)
    
    local function Log(...)
        if settings.Verbose and not file.Quiet then
            print(...)
        end
    end
    
    -- Pass through
    local result, pass, fail, skip = {Skipped = {}, Passed = {}, Failed = {}}, 0, 0, 0
    for key, value in pairs(tests) do
        
        Log("Running test: " .. key)
        local skipped = false
        local succes, msg = pcall(value, function (msg)
            -- Skip function
            skipped = true
            error(msg, 2)
        end)
        
        if skipped then
            Log("Skipped: " .. msg)
            skip = skip + 1
            result.Skipped[key] = msg
        elseif succes then
            Log("Passed")
            pass = pass + 1
            result.Passed[key] = true
        else
            Log("Failed: " .. msg)
            fail = fail + 1
            result.Failed[key] = msg or ""
        end
    end
    
    result.PassedCount = pass
    result.FailedCount = fail
    result.SkippedCount = skip
    
    return result
end

return Run