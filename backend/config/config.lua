GIVEAWAY = {}

GIVEAWAY.LoadDelay = 3000
GIVEAWAY.Key = 191 -- Enter Key

GIVEAWAY.Command = { -- /giveaway start <type> <item> <label> <amount> <entries> <duration>
    ["name"] = "giveaway",
    ["desc"] = "Start a giveaway",
    ["permission"] = {
        ["pl"] = true,
        ["admin"] = true,
        ["dev"] = true,
    }
}

if IsDuplicityVersion() then
    ---@param source number {source}
    ---@param type string {"success", "error", "warning", "info"}
    ---@param msg string {message}
    Notify = function(source, type, msg)
        TriggerClientEvent("midnight_core:hud:notify", source, type, "NOTIFY", msg)
    end
else
    ---@param type string {"success", "error", "warning", "info"}
    ---@param msg string {message}
    Notify = function(type, msg)
        TriggerEvent("midnight_core:hud:notify", type, "NOTIFY", msg)
    end
end