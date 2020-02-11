--- Client Events ---
ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

--Enumeration Functions
local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
  }

  local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end

      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)

      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next

      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
  end

  function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
  end

  function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
  end

  function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
  end

  function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
  end

--@Param vehicleInfo = x, y, z, heading, and mods
--@Desc Spawns a car with coords and mods passed in.
    RegisterNetEvent('spawncar')
    AddEventHandler('spawncar', function(vehicleInfo)
      local mods = json.decode(vehicleInfo.mods)
      ESX.Game.SpawnVehicle(mods.model, vector3(vehicleInfo.x, vehicleInfo.y, vehicleInfo.z), vehicleInfo.heading, function(vehicle)
        ESX.Game.SetVehicleProperties(vehicle, json.decode(vehicleInfo.mods))
        SetEntityAsMissionEntity(vehicle, true, true)
        TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "x: " ..vehicleInfo.x.."y: " ..vehicleInfo.y.."z: " ..vehicleInfo.heading.."Model: " ..mods.model)
      end)
    end)

--Delete All Vehicles On the Server
      RegisterNetEvent("delallveh")
      AddEventHandler("delallveh", function ()
          local totalvehc = 0
          local notdelvehc = 0

          for vehicle in EnumerateVehicles() do
              if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then SetVehicleHasBeenOwnedByPlayer(vehicle, false) SetEntityAsMissionEntity(vehicle, false, false) DeleteVehicle(vehicle)
                  if (DoesEntityExist(vehicle)) then DeleteVehicle(vehicle) end
                  if (DoesEntityExist(vehicle)) then notdelvehc = notdelvehc + 1 end
              end
              totalvehc = totalvehc + 1
          end
          local vehfrac = totalvehc - notdelvehc .. " / " .. totalvehc
          Citizen.Trace("You just deleted "..vehfrac.." vehicles in the server!")
      end)


--Event to Update Positions of a vehicle with a plate number. Used to update all car positions on server
    RegisterNetEvent('updatePos')
    AddEventHandler('updatePos', function(vehicleInfo)
      local mods = json.decode(vehicleInfo.mods)
      local plate = tonumber(mods.plate)

      for vehicle in EnumerateVehicles() do
          local plate2 = tonumber(GetVehicleNumberPlateText(vehicle))
          if plate2 == plate then SetEntityCoords(vehicle, vehicleInfo.x, vehicleInfo.y, vehicleInfo.z) SetEntityHeading(vehicle,vehicleInfo.heading) else TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "No match") end
      end

    end)

--Refresh the position of a certain vehicle
    RegisterCommand("refreshVeh", function(source, args, rawCommand)
      local plate = tonumber(args[1])
      for vehicle in EnumerateVehicles() do
          local plate2 = tonumber(GetVehicleNumberPlateText(vehicle))
          if plate2 == plate then SetEntityCoords(vehicle, vehicleInfo.x, vehicleInfo.y, vehicleInfo.z) SetEntityHeading(vehicle,vehicleInfo.heading) else TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "No match") end
      end
    end, false)



-- Print All vehicles
    RegisterCommand("printveh", function(source, args, rawCommand)
         for vehicle in EnumerateVehicles() do
             local plate = GetVehicleNumberPlateText(vehicle)
             local owner = NetworkGetEntityOwner(vehicle)
             TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Model: "..plate)
         end
    end, false)



-- Teleport a Car to you
	    RegisterCommand("tester", function(source, args, rawCommand)
		       local veh = args[1];
		       local playerCoords = GetEntityCoords(PlayerPedId(-1))
           local play = GetPlayerPed(-1)
	         local x = playerCoords.x;
           local y = playerCoords.y;
           local z = playerCoords.z;



         for vehicle in EnumerateVehicles() do
             local plate = GetVehicleNumberPlateText(vehicle)

             TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Model: "..plate)
			       TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "ID: "..veh)

			          local vehNum = tonumber(veh)
			          local modelNum = tonumber(plate)

			             if vehNum == modelNum then
					   NetworkRequestControlOfEntity(vehicle)
	
					local timeout = 2000
					while timeout > 0 and not NetworkHasControlOfEntity(vehicle) do
					Wait(100)
					timeout = timeout - 100
					end
					 
					 
			                  TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Match") SetEntityCoords(vehicle, x, y, z) 		local id = NetworkGetNetworkIdFromEntity(vehicle)
       		             else
			                  TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "No Match")
			                   end
                       end
                     end, false)




-- Save A Vehicles Position
    RegisterCommand("npark", function(source, args, rawCommand)

       local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
       local licensePlate = GetVehicleNumberPlateText(vehicle)
       local playerCoords = GetEntityCoords(PlayerPedId(-1))
       local x = playerCoords.x;
       local y = playerCoords.y;
       local z = playerCoords.z;

     local carInfo = {
       xCoord = x,
       yCoord = y,
       zCoord = z,
       heading = GetEntityHeading(PlayerPedId(-1)),
       plate = licensePlate,
       steam = steam
     }
       TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Pushing car with the following plate" ..carInfo.plate)
       TriggerServerEvent('parkcar', carInfo)
	   TriggerServerEvent('getowner', carInfo)

   end, false)







--Spawn Cars with Colors and Speed and Acceleration
  RegisterCommand('customcar', function(source, args, rawCommand)
	TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Use: /customcar [model] [primaryColor] [secondaryColor] [maxspeed] [forwardspeed]")
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 8.0, 0.5))
        local veh = args[1]
        if veh == nil then veh = "adder" end
        vehiclehash = GetHashKey(veh)
        RequestModel(vehiclehash)

        Citizen.CreateThread(function()
            local waiting = 0
            while not HasModelLoaded(vehiclehash) do
                waiting = waiting + 100
                Citizen.Wait(100)
                if waiting > 5000 then
                    ShowNotification("~r~Could not load the vehicle model in time, a crash was prevented.")
                    break
                end
            end

            local vehicle = CreateVehicle(vehiclehash, x, y, z,GetEntityHeading(PlayerPedId())+90,1, 0)
		        local model = args[1]
            local primaryColor = tonumber(args[2])
            local secondaryColor = tonumber(args[3])
            local maxSpeed = tonumber(args[4]) +.01
			      local forwardSpeed = tonumber(args[5]) + .01
            SetVehicleColours(vehicle, primaryColor, secondaryColor)
            SetVehicleMaxSpeed(vehicle, maxSpeed)
            ModifyVehicleTopSpeed(vehicle, forwardSpeed)
            SetEntityAsMissionEntity(vehicle, 1, 1)
        TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Model:"..model.." Max Speed: "..maxSpeed.." Acc: "..forwardSpeed.."Colors"..primaryColor)
        end)
    end)

--Spawn the cars in when the first player joins
    AddEventHandler("playerSpawned", function(spawnInfo)
      if GetNumberOfPlayers() == 1 then
        TriggerServerEvent("firstSpawn")
        TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "This works")
        end
      end)
