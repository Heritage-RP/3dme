-- @desc Server-side /me handling
-- @author Elio
-- @version 3.0

-- Pre-load the language
local lang = Languages[Config.language]

-- source -> GetGameTimer() of their last /me (PRODUCTION-SERVER#318: one /me per Config.cooldown ms)
local lastMe = {}

-- @desc First `max` characters of `text` (UTF-8 aware, bytes if the text isn't valid UTF-8)
local function truncate(text, max)
    local length = utf8.len(text)
    if not length then return text:sub(1, max) end
    if length <= max then return text end
    return text:sub(1, utf8.offset(text, max + 1) - 1)
end

-- @desc Players close enough to see the /me of `source` (same routing bucket, within Config.dist): the text is only
-- sent to them, never to the whole map (PRODUCTION-SERVER#318). The author always gets it.
local function recipientsOf(source)
    local ped = GetPlayerPed(source)
    if ped == 0 then return { source } end
    local origin = GetEntityCoords(ped)
    local bucket = GetPlayerRoutingBucket(source)
    local recipients = {}
    for _, id in ipairs(GetPlayers()) do
        local player = tonumber(id)
        if player == source then
            recipients[#recipients + 1] = player
        elseif GetPlayerRoutingBucket(id) == bucket then
            local otherPed = GetPlayerPed(id)
            if otherPed ~= 0 and #(GetEntityCoords(otherPed) - origin) <= Config.dist then
                recipients[#recipients + 1] = player
            end
        end
    end
    return recipients
end

-- @desc Handle /me command
local function onMeCommand(source, args)
    if source == 0 then return end -- console: no head to show it over

    local body = truncate(table.concat(args, " "):match("^%s*(.-)%s*$"), Config.maxLength)
    if body == "" then return end

    local now = GetGameTimer()
    if lastMe[source] and now - lastMe[source] < Config.cooldown then return end
    lastMe[source] = now

    local text = "* " .. lang.prefix .. body .. " *"
    local recipients = recipientsOf(source)
    for _, player in ipairs(recipients) do
        TriggerClientEvent('3dme:shareDisplay', player, text, source)
    end
    -- the length only: what players write stays between them
    HrpLog.business.info('me shown', { source = source, length = #text, recipients = #recipients })
end

AddEventHandler('playerDropped', function()
    lastMe[source] = nil
end)

-- Register the command
RegisterCommand(lang.commandName, onMeCommand)
