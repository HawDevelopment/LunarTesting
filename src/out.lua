--[[
    Out
    HawDevelopment
    26/10/2021
--]]

return function(result, settings)
    settings.Indentation = settings.Indentation or ""
    
    local Print, File
    if settings.CanPwsh then
        File = "\n"
        Print = function(toprint, color)
            local toadd = "Write-Host " .. (color and "-ForegroundColor " .. color or "") .. " \"" .. (settings.Indentation:gsub("    ", "`t") .. toprint) .. "\""
            File = File .. toadd .. "\n"
        end
    else
        Print = function(toprint)
            print(settings.Indentation .. toprint)
        end
    end
    
    -- Run errors first
    for key, value in pairs(result.Failed) do
        Print("Fail: " .. key .. ": " .. value, "Red")
    end
    for key, _ in pairs(result.Passed) do
        Print("Pass: " .. key, "Green")
    end
    for key, value in pairs(result.Skipped) do
        Print("Skip: " .. key .. ": " .. value, "Yellow")
    end
    
    if settings.CanPwsh then
        local pipe = io.popen("powershell -ExecutionPolicy bypass -command -", "w")
        pipe:write(File)
        pipe:close()
    end
end