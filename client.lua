local function contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

local function teleportPlayer(coords)
    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
    Wait(500)
    DoScreenFadeIn(500)
end

local function getCurrentFloor(elevator)
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _, floor in pairs(elevator.floors) do
        local dist = #(playerCoords - floor.coords)
        if dist < 2.0 then
            return floor.label
        end
    end

    return nil
end

local function openElevatorMenu(elevator)
    if not elevator or not elevator.floors then
        print("^1[Elevator] ERROR: Elevator data is missing or incorrect.^0")
        return
    end


    local currentFloor = getCurrentFloor(elevator)
    local options = {}

    for _, floor in pairs(elevator.floors) do
        local label = floor.label
        if currentFloor == floor.label then
            label = label .. " (Current)"
        end

        table.insert(options, {
            title = label,
            icon = "fa-solid fa-building",
            onSelect = function()
                if elevator.locked then
                    local alert = lib.alertDialog({
                        header = 'Elevator System',
                        content = 'This elevator shaft is currently locked, Please try another elevator or wait until this elevator shaft has been unlocked',
                        centered = true,
                        cancel = true
                    })
                    return 
                end

                if currentFloor ~= floor.label then
                    teleportPlayer(floor.coords)
                    lib.notify({
                        title = 'Elevator System',
                        description = 'You are now on the chosen floor',
                        type = 'success'
                    })
                else
                    lib.notify({
                        title = 'Elevator System',
                        description = 'You are already on this floor, Please try another floor!',
                        type = 'error'
                    })
                end
            end
        })
    end

    lib.registerContext({
        id = "elevator_menu",
        title = elevator.name,
        options = options
    })

    lib.showContext("elevator_menu")
end

local function openControlPanelMenu(elevator)
    if not elevator.controlPanel then
        print("^1[Control Panel] ERROR: Control panel coordinates not defined for elevator: " .. elevator.name .. "^0")
        return
    end

    local options = {}

    table.insert(options, {
        title = "Lock all elevator shafts",
        icon = "fa-solid fa-lock",
        onSelect = function()
            local lockedElevators = {}
            for _, elev in pairs(Config.Elevators) do
                if elev.id == elevator.id or contains(elev.linkedElevators, elevator.id) then
                    elev.locked = true
                    table.insert(lockedElevators, elev.name)
                end
            end
            lib.notify({
                title = 'Elevator System',
                description = 'All Elevator systems successfully Locked',
                type = 'success'
            })
        end
    })

    table.insert(options, {
        title = "Unlock all elevator shafts",
        icon = "fa-solid fa-unlock",
        onSelect = function()
            local unlockedElevators = {}
            for _, elev in pairs(Config.Elevators) do
                if elev.id == elevator.id or contains(elev.linkedElevators, elevator.id) then
                    elev.locked = false
                    table.insert(unlockedElevators, elev.name)
                end
            end
            lib.notify({
                title = 'Elevator System',
                description = 'All Elevator systems successfully Unlocked',
                type = 'success'
            })
        end
    })

    for _, linkedId in pairs(elevator.linkedElevators) do
        for _, elev in pairs(Config.Elevators) do
            if elev.id == linkedId or elev.id == elevator.id then
                table.insert(options, {
                    title = elev.name .. (elev.locked and " (Locked)" or " (Unlocked)"),
                    icon = elev.locked and "fa-solid fa-lock" or "fa-solid fa-unlock",
                    onSelect = function()
                        if elev.locked then
                            elev.locked = false
                            lib.notify({
                                title = 'Elevator System',
                                description = 'Elevator system successfully Unlocked',
                                type = 'success'
                            })
                        else
                            elev.locked = true
                            lib.notify({
                                title = 'Elevator System',
                                description = 'Elevator system successfully Locked',
                                type = 'success'
                            })
                        end
                    end
                })
            end
        end
    end

    lib.registerContext({
        id = "control_panel_menu",
        title = "Control Panel",
        options = options
    })

    lib.showContext("control_panel_menu")
end

RegisterNetEvent("elevator:openMenu", function(elevator)
    if not elevator then
        print("^1[Elevator] ERROR: Elevator data is nil or invalid.^0")
        return
    end

    local foundElevator = nil
    for _, configElevator in pairs(Config.Elevators) do
        if configElevator.main == elevator.args.main then
            foundElevator = configElevator
            break
        end
    end

    if foundElevator then
        openElevatorMenu(foundElevator)
    else
        print("^1[Elevator] ERROR: No elevator found with these coordinates.^0")
    end
end)

RegisterNetEvent("elevator:openControlPanel", function(elevator)
    if not elevator then
        print("^1[Elevator] ERROR: Elevator data is nil or invalid.^0")
        return
    end

    local foundElevator = nil
    for _, configElevator in pairs(Config.Elevators) do
        if configElevator.controlPanel == elevator.args.controlPanel then
            foundElevator = configElevator
            break
        end
    end

    if foundElevator then
        openControlPanelMenu(foundElevator)
    else
        print("^1[Elevator] ERROR: No elevator found with these control panel coordinates.^0")
    end
end)

CreateThread(function()
    print("^2[Elevator] Config data loaded: " .. json.encode(Config.Elevators)) 

    local registeredControlPanels = {}

    for _, elevator in pairs(Config.Elevators) do
        if elevator and elevator.main and elevator.floors then
            local isMainElevatorRegistered = false  

            exports.ox_target:addBoxZone({
                coords = elevator.main,
                size = vec3(1.5, 1.5, 2.0),
                rotation = 0,
                debug = false,
                options = {
                    {
                        name = "use_elevator",
                        event = "elevator:openMenu",  
                        icon = "fa-solid fa-elevator",
                        label = "Use Elevator",
                        args = elevator  
                    }
                }
            })
            isMainElevatorRegistered = true  

            for _, floor in pairs(elevator.floors) do
                if not isMainElevatorRegistered or floor.coords ~= elevator.main then
                    exports.ox_target:addBoxZone({
                        coords = floor.coords,
                        size = vec3(1.5, 1.5, 2.0),
                        rotation = 0,
                        debug = false,
                        options = {
                            {
                                name = "use_elevator_floor",
                                event = "elevator:openMenu",  
                                icon = "fa-solid fa-elevator",
                                label = "Use Elevator",
                                args = elevator  
                            }
                        }
                    })
                end
            end

            if not registeredControlPanels[elevator.controlPanel] then
                exports.ox_target:addBoxZone({
                    coords = elevator.controlPanel,
                    size = vec3(1.5, 1.5, 2.0),
                    rotation = 0,
                    debug = false,
                    options = {
                        {
                            name = "use_control_panel",
                            event = "elevator:openControlPanel", 
                            icon = "fa-solid fa-cogs",
                            label = "Use Control Panel",
                            args = elevator 
                        }
                    }
                })

                registeredControlPanels[elevator.controlPanel] = true
            end
        else
            print("^1[Elevator] ERROR: Missing data for elevator: " .. (elevator.name or "Unknown") .. "^0")
        end
    end
end)
