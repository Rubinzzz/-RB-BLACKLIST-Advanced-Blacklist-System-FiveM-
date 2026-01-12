----------------------------------------
-- ADVANCED BLACKLIST SYSTEM (FiveM)
-- Blocks players based on identifiers + reason
-- Discord | Steam | FiveM | License | License2 | IP
----------------------------------------

-- ================================
-- CONFIG
-- ================================

local REAPER_BAN_COMMAND = "reaper ban id"

-- !!! DONT TOUCH THIS !!!
local KICK_TITLE = "RB BLACKLIST"

-- Modifiable
local KICK_MESSAGE_TEMPLATE = "You have been banned from this server. Reason: %reason%"

-- ================================
-- BLACKLIST DATA
-- ================================
local blacklist = {
    {
        discord  = "discord:948628265130672168",
        steam    = "steam:110000112345678",
        fivem    = "fivem:1234567",
        license  = "license:abcdef1234567890",
        license2 = "license2:abcdef1234567890",
        ip       = "127.0.0.1",
        reason   = "Cheating" -- Modifiable
    },
    {
        discord  = "discord:123456789012345678",
        steam    = "steam:110000112345679",
        fivem    = "fivem:7654321",
        license  = "license:zyxwv9876543210",
        license2 = "license2:zyxwv9876543210",
        ip       = "192.168.0.1",
        reason   = "Exploiting" -- Modifiable
    },
    -- Add more BASTARDS to RB BLACKLIST!
}

-- ================================
-- HELPER FUNCTIONS
-- ================================

local function GetPlayerIdentifiersTable(src)
    local identifiers = {
        discord  = nil,
        steam    = nil,
        fivem    = nil,
        license  = nil,
        license2 = nil,
        ip       = nil
    }

    for _, id in pairs(GetPlayerIdentifiers(src)) do
        if id:find("discord:") then identifiers.discord = id end
        if id:find("steam:") then identifiers.steam = id end
        if id:find("fivem:") then identifiers.fivem = id end
        if id:find("license:") then identifiers.license = id end
        if id:find("license2:") then identifiers.license2 = id end
    end

    identifiers.ip = GetPlayerEndpoint(src)
    return identifiers
end

local function IsBlacklisted(playerIds)
    for _, banned in pairs(blacklist) do
        for k, v in pairs(banned) do
            if k ~= "reason" and v ~= nil and playerIds[k] ~= nil and v == playerIds[k] then
                return true, banned
            end
        end
    end
    return false
end

-- ================================
-- PLAYER CONNECT CHECK
-- ================================

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local src = source
    deferrals.defer()
    Wait(0)

    -- Modifiable
    deferrals.update("Checking blacklist...")

    local identifiers = GetPlayerIdentifiersTable(src)
    local blacklisted, bannedEntry = IsBlacklisted(identifiers)

    if blacklisted then
        print(("[BLACKLIST] Blocked %s | Reason: %s"):format(name, bannedEntry.reason or "No reason"))

        ExecuteCommand(REAPER_BAN_COMMAND .. " " .. src)

        local kickMessage = KICK_MESSAGE_TEMPLATE:gsub("%%reason%%", bannedEntry.reason or "No reason")
        deferrals.done(KICK_TITLE .. "\n" .. kickMessage)
        CancelEvent()
        return
    end

    deferrals.done()
end)

-- ================================
-- DEBUG (OPTIONAL)
-- ================================
RegisterCommand("bl_debug", function(source)
    local ids = GetPlayerIdentifiersTable(source)
    print(json.encode(ids, { indent = true }))

end, false)

