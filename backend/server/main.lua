---@class onGiveaway
---@field functions table
---@return table

local function onGiveaway()
    local self = {}
    self.token = nil
    self.active = false
    self.giveaway = {}
    self.entries = {}
    self.timeout = nil

    self.functions = {
        isActive = function()
            return self.active
        end,
        generateToken = function()
            return tostring(math.random(1000000000, 9999999999))
        end,
        hasPerms = function(group)
            return GIVEAWAY.Command["permission"][group] or false
        end,
        createGiveaway = function(source, data)
            if not data.item then
                return Notify(source, "error", "Du hast keine Item angegeben")
            end

            if data.type == "item" and not ESX.DoesItemExist(data.item) then
                return Notify(source, "error", "Das Item existiert nicht")
            end

            if not data.amount or data.amount <= 0 then
                return Notify(source, "error", "Du hast keine Item Anzahl angegeben")
            end

            if not data.entries or data.entries <= 0 then
                return Notify(source, "error", "Du hast keine max. Anzahl an Teilnehmern angegeben")
            end

            if not data.duration or data.duration <= 0 then
                return Notify(source, "error", "Du hast keine Dauer angegeben")
            end

            self.active = true
            
            self.token = self.functions.generateToken()

            self.giveaway[self.token] = {
                ["type"] = data.type,
                ["item"] = data.item,
                ["label"] = data.label,
                ["amount"] = data.amount,
                ["entries"] = data.entries,
                ["duration"] = data.duration,
            }

            TriggerClientEvent("midnight_giveaway/startGiveaway", -1, self.giveaway[self.token])

            self.timeout = Citizen.SetTimeout(data.duration * 60 * 1000, function()
                self.timeout = nil

                if self.active and self.token and self.giveaway[self.token] then
                    self.functions.addReward()
                end
            end)

            Notify(source, "info", "Du hast ein Giveaway gestartet")
        end,
        deleteGiveaway = function()
            if not self.giveaway[self.token] then
                return
            end

            if self.timeout then
                Citizen.ClearTimeout(self.timeout)
                self.timeout = nil
            end

            self.giveaway[self.token] = nil
            self.active = false
            self.token = nil
            self.entries = {}
        end,
        getEntries = function()
            local count = 0

            for _ in pairs(self.entries) do
                count = count + 1
            end

            return count
        end,
        addReward = function()
            local winner = self.functions.getWinner()

            if winner and self.giveaway[self.token] then
                local xTarget = ESX.GetPlayerFromId(winner)

                if xTarget then
                    local data = self.giveaway[self.token]

                    if data.type == "item" then
                        xTarget.addInventoryItem(data.item, data.amount)
                    elseif data.type == "money" then
                        xTarget.addMoney(data.amount)
                    elseif data.type == "weapon" then
                        xTarget.addWeapon(data.item:upper(), 1)
                    end

                    Notify(xTarget.source, "success", ("Du hast %dx %s beim Giveaway gewonnen"):format(data.amount, data.label))
                else
                    print("Der Spieler mit der ID " .. winner .. " wurde nicht gefunden")
                end
            end

            return self.functions.deleteGiveaway()
        end,
        getWinner = function()
            local players = {}

            for src in pairs(self.entries) do
                players[#players + 1] = src
            end

            if #players == 0 then
                return nil
            end

            return players[math.random(1, #players)]
        end,
    }

    function self.RegisterCommands()
        RegisterCommand(GIVEAWAY.Command["name"], function(source, args, raw)
            local action, type, item, label, amount, entries, duration = table.unpack(args)

            local function commandFunc(src)
                if action == "start" then
                    if self.functions.isActive() then
                        return Notify(src, "error", "Es ist bereits ein Giveaway aktiv")
                    end

                    self.functions.createGiveaway(src, {
                        ["type"] = tostring(type),
                        ["item"] = tostring(item),
                        ["label"] = tostring(label),
                        ["amount"] = tonumber(amount),
                        ["entries"] = tonumber(entries),
                        ["duration"] = tonumber(duration),
                    })
                elseif action == "stop" then
                    if not self.functions.isActive() then
                        return Notify(src, "error", "Es ist kein Giveaway aktiv")
                    end

                    self.functions.deleteGiveaway()
                    Notify(src, "success", "Du hast das aktuelle Giveaway gestoppt")
                end
            end

            if source == 0 then
                return print("This command can only be used in-game")
            end

            local xPlayer = ESX.GetPlayerFromId(source)

            if xPlayer then
                if self.functions.hasPerms(xPlayer.group) then
                    commandFunc(source)
                else
                    return Notify(source, "error", "Du hast keine Berechtigung diesen Befehl auszuführen")
                end
            end
        end, false)
    end

    function self.EventHandler()
        RegisterNetEvent("midnight_giveaway/onJoin", function()
            local source = source
            local xPlayer = ESX.GetPlayerFromId(source)

            if xPlayer and self.functions.isActive() then
                TriggerClientEvent("midnight_giveaway/startGiveaway", source, self.giveaway[self.token])
            end
        end)

        RegisterNetEvent("midnight_giveaway/joinGiveaway", function()
            local source = source
            local xPlayer = ESX.GetPlayerFromId(source)

            if xPlayer then
                if self.functions.isActive() then
                    if not self.entries[source] then
                        self.entries[source] = true
                        TriggerClientEvent("midnight_giveaway/updateEntries", -1, self.functions.getEntries())
                        Notify(source, "success", "Du hast am Giveaway teilgenommen")
                    else
                        Notify(source, "error", "Du hast bereits teilgenommen")
                    end
                else
                    Notify(source, "error", "Es ist kein Giveaway aktiv")
                end
            end
        end)

        AddEventHandler("playerDropped", function()
            local source = source

            if self.entries[source] then
                self.entries[source] = nil
                TriggerClientEvent("midnight_giveaway/updateEntries", -1, self.functions.getEntries())
            end
        end)
    end

    function self.Init()
        self.RegisterCommands()
        self.EventHandler()
    end

    return self
end

Citizen.CreateThread(function()
    local instance = onGiveaway()
    instance.Init()
end)