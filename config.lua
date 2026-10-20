-- @desc Shared config file
-- @author Elio
-- @version 2.0

-- Global configuration
Config = {
    language = GetConvar and GetConvar('ox:locale', 'en') or 'en', -- ox_lib's replicated locale (`setr ox:locale fr`), 'en' if unknown
    color = { r = 230, g = 230, b = 230, a = 255 }, -- Text color
    font = 0, -- Text font
    time = 5000, -- Duration to display the text (in ms)
    scale = 0.5, -- Text scale
    dist = 250, -- Max. distance to see a /me (the server only sends it to players this close)
    maxLength = 120, -- Longest /me text (characters, longer is cut)
    cooldown = 1000, -- Min. time between two /me of a player (in ms)
}

-- Languages available
Languages = {
    ['en'] = {
        commandName = 'me',
        commandDescription = 'Display an action above your head.',
        commandSuggestion = {{ name = 'action', help = '"scratch his nose" for example.'}},
        prefix = 'the person '
    },
    ['fr'] = {
        commandName = 'me',
        commandDescription = 'Affiche une action au dessus de votre tête.',
        commandSuggestion = {{ name = 'action', help = '"se gratte le nez" par exemple.'}},
        prefix = 'l\'individu '
    },
    ['dk'] = {
        commandName = 'me',
        commandDescription = 'Viser en handling over hovedet.',
        commandSuggestion = {{ name = 'Handling', help = '"Tager en smøg op ad lommen" for eksempel.'}},
        prefix = 'Personen '
    },
}

-- Fork patch (PATCHES.md): a language missing from the list falls back to English
if not Languages[Config.language] then Config.language = 'en' end
