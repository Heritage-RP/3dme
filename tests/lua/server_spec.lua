-- server.lua with FiveM stubs (PRODUCTION-SERVER#318): /me only reaches players in range, one per second, 120
-- characters at most, empty ignored. Run from the resource folder:
-- docker run --rm -v "$PWD":/w -w /w nickblah/lua:5.4 lua tests/lua/server_spec.lua

local failures = 0
local function check(name, cond)
    if cond then io.write('ok   ', name, '\n') else failures = failures + 1; io.write('FAIL ', name, '\n') end
end

local vec = {}
vec.__index = vec
local function vector3(x, y, z) return setmetatable({ x = x, y = y, z = z }, vec) end
vec.__sub = function(a, b) return vector3(a.x - b.x, a.y - b.y, a.z - b.z) end
vec.__len = function(a) return math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z) end

-- players: id -> { coords, bucket } ; ped handle = id * 10
local function load(players)
    local env = { sent = {}, records = {}, now = 10000 }
    _G.GetPlayers = function()
        local ids = {}
        for id in pairs(players) do ids[#ids + 1] = tostring(id) end
        table.sort(ids)
        return ids
    end
    _G.GetPlayerPed = function(id)
        local player = players[tonumber(id)]
        return player and player.coords and tonumber(id) * 10 or 0
    end
    _G.GetEntityCoords = function(ped) return players[ped // 10].coords end
    _G.GetPlayerRoutingBucket = function(id) return players[tonumber(id)].bucket or 0 end
    _G.GetGameTimer = function() return env.now end
    _G.TriggerClientEvent = function(name, target, ...) env.sent[#env.sent + 1] = { name = name, target = target, args = { ... } } end
    _G.HrpLog = { business = { info = function(msg, attrs) env.records[#env.records + 1] = { msg = msg, attrs = attrs } end } }
    _G.AddEventHandler = function(name, fn) env[name] = fn end
    _G.RegisterCommand = function(name, fn) env.command, env.commandName = fn, name end
    dofile('config.lua')
    dofile('server.lua')
    env.me = function(source, text)
        local args = {}
        for word in text:gmatch('%S+') do args[#args + 1] = word end
        env.command(source, args)
    end
    env.targets = function()
        local targets = {}
        for _, event in ipairs(env.sent) do targets[#targets + 1] = event.target end
        table.sort(targets)
        return table.concat(targets, ',')
    end
    return env
end

do
    local env = load({
        [1] = { coords = vector3(0, 0, 0) },
        [2] = { coords = vector3(100, 0, 0) },
        [3] = { coords = vector3(251, 0, 0) },        -- out of range
        [4] = { coords = vector3(10, 0, 0), bucket = 5 }, -- other routing bucket
        [5] = {},                                      -- no ped yet (loading)
    })
    env.me(1, 'se gratte le nez')
    check('sent to the author and players in range only', env.targets() == '1,2')
    check('event and text', env.sent[1].name == '3dme:shareDisplay'
        and env.sent[1].args[1] == "* l'individu se gratte le nez *" and env.sent[1].args[2] == 1)
    check('never broadcast to everyone', env.targets():find('-1') == nil)
    check('record has the length, not the text', env.records[1].attrs.length == #"* l'individu se gratte le nez *"
        and env.records[1].attrs.recipients == 2)
    for _, record in ipairs(env.records) do
        for _, value in pairs(record.attrs) do check('text not logged', value ~= 'se gratte le nez') end
    end
end

do
    local env = load({ [1] = { coords = vector3(0, 0, 0) } })
    env.me(1, 'un')
    env.me(1, 'deux')
    check('cooldown: second /me within a second ignored', #env.sent == 1)
    env.now = env.now + 1000
    env.me(1, 'trois')
    check('cooldown over: sent again', #env.sent == 2)
end

do
    local env = load({ [1] = { coords = vector3(0, 0, 0) }, [2] = { coords = vector3(0, 0, 0) } })
    env.me(1, 'un')
    _G.source = 1
    env.playerDropped()
    _G.source = nil
    env.me(1, 'deux')
    check('dropped player forgotten (no stale cooldown)', #env.sent == 4)
end

do
    local env = load({ [1] = { coords = vector3(0, 0, 0) } })
    env.me(1, '   ')
    check('empty /me ignored', #env.sent == 0)
    env.me(0, 'console')
    check('console ignored', #env.sent == 0)
end

do
    local env = load({ [1] = { coords = vector3(0, 0, 0) } })
    env.me(1, string.rep('é', 300))
    local text = env.sent[1].args[1]
    local body = text:match("^%* l'individu (.*) %*$")
    check('cut at 120 characters (UTF-8 aware)', body ~= nil and utf8.len(body) == Config.maxLength)
end

if failures > 0 then
    io.write(failures, ' failure(s)\n')
    os.exit(1)
end
io.write('all passed\n')
