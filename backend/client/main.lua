---@class onGiveaway
---@field active boolean
---@field entered boolean
---@field pauseMenu boolean
---@field onTick function
---@field EventHandler function
---@field Init function
---@return table

local function onGiveaway()
    local self = {}
    self.active = false
    self.entered = false
    self.pauseMenu = false

    self.functions = {
        emitNui = function(action, data)
            SendNUIMessage({
                action = action,
                data = data,
            })
        end,
        toggleUI = function(state)
            self.functions.emitNui("ToggleUI", {
                state = state,
            })
        end,
        formatTime = function(time)
            local minutes = math.floor(time / 60)
            local seconds = time % 60
            return string.format("%02d:%02d", minutes, seconds)
        end,
    }

    function self.EventHandler()
        RegisterNetEvent("midnight_giveaway/startGiveaway", function(data)
            if not data or not next(data) or self.active then
                return
            end

            self.functions.emitNui("UpdateData", data)

            self.onTick(data)
        end)

        RegisterNetEvent("midnight_giveaway/updateEntries", function(count)
            if not count or count <= 0 then
                return
            end

            self.functions.emitNui("UpdateEntries", {
                count = count,
            })
        end)

        AddEventHandler('esx:pauseMenuActive', function(state)
            if not self.active then
                return
            end

            if state ~= self.pauseMenu then
                self.pauseMenu = state
                self.functions.toggleUI(not state)
            end
        end)
    end

    function self.onTick(data)
        self.active = true
        self.functions.toggleUI(true)

        Citizen.CreateThread(function()
            local time = data.duration * 60

            while time > 0 do
                Citizen.Wait(1000)
                time = time - 1
                self.functions.emitNui("UpdateTimer", {
                    time = self.functions.formatTime(time),
                })
            end

            self.active = false
            self.entered = false
            self.functions.toggleUI(false)
        end)

        Citizen.CreateThread(function()
            local letsleep = 500

            while not self.entered do
                Citizen.Wait(letsleep)

                if not self.pauseMenu and not IsNuiFocused() then
                    letsleep = 0

                    if IsControlJustReleased(0, GIVEAWAY.Key) then
                        self.entered = true
                        TriggerServerEvent("midnight_giveaway/joinGiveaway")
                    end
                else
                    letsleep = 500
                end
            end
        end)
    end

    function self.Init()
        self.EventHandler()
        Citizen.Wait(GIVEAWAY.LoadDelay)
        TriggerServerEvent("midnight_giveaway/onJoin")
    end

    return self
end

Citizen.CreateThread(function()
    local instance = onGiveaway()
    instance.Init()
end)