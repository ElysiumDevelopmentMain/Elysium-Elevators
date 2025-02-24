Config = {}

Config.Elevators = {
    {
        id = 1, -- Unique ID for this elevator system
        name = "Department Of Homeland Security Elevator 1",
        main = vector3(2504.28, -433.22, 99.11), -- Set this the same as your ground floor/first floor
        floors = {
            { label = "Second Floor", coords = vector3(2504.28, -433.22, 99.11) },
            { label = "Office Floor", coords = vector3(2504.46, -433.08, 106.91) }
        },
        controlPanel =  vector3(2501.82, -422.20, 99.11) , -- Control panel for both elevators, Set this the exact same as your linked elevator if another system is linked
        linkedElevators = { 1 }, -- Place the number of the elevator you want linked to this elevator 0 if nothing
        locked = false -- Elevator state (locked or unlocked on script start)
    },
    {
        id = 2,
        name = "Department Of Homeland Security Elevator 2",
        main = vector3(2504.16, -342.42, 94.09),  -- Set this the same as your ground floor/first floor
        floors = {
            { label = "Ground Floor", coords = vector3(2504.16, -342.42, 94.09) },
            { label = "Third Floor", coords = vector3(2504.30, -342.48, 101.89) },
            { label = "Fourth Floor", coords = vector3(2497.55, -349.01, 105.69)  }
        },
        controlPanel = vector3(2510.68, -334.68, 101.89), -- Control panel for both elevators, Set this the exact same as your linked elevator if another system is linked
        linkedElevators = { 2 }, -- Place the number of the elevator you want linked to this elevator 0 if nothing
        locked = false -- Elevator state (locked or unlocked on script start)
    }
}
