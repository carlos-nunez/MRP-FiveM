--- Client Events ---


    RegisterCommand('makecar', function(source, args, rawCommand)

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
        local vehicle = CreateVehicle(vehiclehash, x, y, z, GetEntityHeading(PlayerPedId())+90, 1, 0)
			local primary, secondary = GetVehicleColours(vehicle)
		        local carInfo = {
            xCoord=x,
            yCoord=y,
            zCoord=z,
			heading = GetEntityHeading(PlayerPedId())+90,
			primaryColor = primary,
			secondaryColor = secondary,
            engineHealth = GetVehicleEngineHealth(vehicle),
            bodyHealth = GetVehicleBodyHealth(vehicle),
            doorsLocked = 1,
            fuelLevel = GetVehicleFuelLevel(vehicle),
            tint = GetVehicleWindowTint(vehicle)

        }

        TriggerServerEvent("createveh", carInfo, args)

        local comparedPlate = GetVehicleNumberPlateText(vehicle)
        local wordStr;

        TriggerEvent("chatMessage",  "[Server]", {255,0,0}, carInfo.primaryColor)

        end)

    end)


    RegisterNetEvent('spawncar')
    AddEventHandler('spawncar', function(vehicleInfo)

        local x,y,z = table.unpack(vector3(vehicleInfo.x, vehicleInfo.y, vehicleInfo.z))
        local veh = vehicleInfo.model

        local vehiclehash = GetHashKey(veh)
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




          local heading = vehicleInfo.heading
      local vehicle = CreateVehicle(vehiclehash, x, y, z, heading, 1, 0)







            local primaryColor = vehicleInfo.primaryColor
            local secondaryColor = vehicleInfo.secondaryColor
            local engineHealth = vehicleInfo.engineHealth - 0.01
            local bodyHealth = vehicleInfo.bodyHealth - 0.01
            local doorsLocked = vehicleInfo.doorsLocked
            local fuelLevel = vehicleInfo.fuel - 0.01
            local tint = vehicleInfo.tint
            local plate = tostring(vehicleInfo.plate)

            SetVehicleColours(vehicle, primaryColor, secondaryColor)
            SetVehicleEngineHealth(vehicle, engineHealth)
            SetVehicleBodyHealth(vehicle, bodyHealth)
            SetVehicleDoorsLocked(vehicle, doorsLocked)
            SetVehicleFuelLevel(vehicle, 100.00)
            SetVehicleWindowTint(vehicle, tint)
            SetEntityAsMissionEntity(vehicle, 1, 1)
            SetVehicleNumberPlateText(vehicle, plate)
            local comparedPlate = GetVehicleNumberPlateText(vehicle)






        TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "x: " ..x.."y: " ..y.."z: " ..z.."Model: " ..veh .."Id: " ..engineHealth)



        end)

    end)




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



    RegisterNetEvent('updatePos')
    AddEventHandler('updatePos', function(vehicleInfo)
      local plate = tonumber(vehicleInfo.plate)

      for vehicle in EnumerateVehicles() do
          local plate2 = tonumber(GetVehicleNumberPlateText(vehicle))
          if plate2 == plate then SetEntityCoords(vehicle, vehicleInfo.x, vehicleInfo.y, vehicleInfo.z) SetEntityHeading(vehicle,vehicleInfo.heading) else TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "No match") end
      end

    end)




    RegisterCommand("refresh", function(source, args, rawCommand)
        for vehicle in EnumerateVehicles() do
            local current = NetworkGetNetworkIdFromEntity(vehicle)

            local current1 = current
           SetEntityCoords(vehicle, -1270.50, 2540.04, 18.62)
        end


   end, false)

    RegisterCommand("delallveh", function(source, args, rawCommand)
       TriggerEvent("delallveh")


   end, false)

    RegisterCommand("printveh", function(source, args, rawCommand)
         for vehicle in EnumerateVehicles() do
             local plate = GetVehicleNumberPlateText(vehicle)

             TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Model: "..plate)
         end


    end, false)
	
	
	    RegisterCommand("tester", function(source, args, rawCommand)
		local veh = args[1];
         for vehicle in EnumerateVehicles() do
             local plate = GetVehicleNumberPlateText(vehicle)

             TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Model: "..plate)
			 TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "ID: "..veh)
			 
			 local vehNum = tonumber(veh)
			 local modelNum = tonumber(plate)
			 
			 if vehNum == modelNum then TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Match") else TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "No Match") end
			 
			 
         end


    end, false)
	

	    RegisterCommand("tester", function(source, args, rawCommand)
		local veh = args[1];
		       local playerCoords = GetEntityCoords(PlayerPedId(-1))
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
			 TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Match") SetEntityCoords(vehicle, x, y, z) else 
			 TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "No Match") 
			 end
			 
			 
         end


    end, false)
	
	
	
	

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


     }


       TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Pushing car with the following plate" ..carInfo.plate)
       TriggerServerEvent('parkcar', carInfo)


   end, false)








    RegisterCommand('customcar', function(source, args, rawCommand)
	TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Use: /customcar [model] [primaryColor] [secondaryColor] [forwardspeed] [maxspeed]")

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
            local maxSpeed = tonumber(args[4])
			local forwardSpeed = tonumber(args[5])

            SetVehicleColours(vehicle, primaryColor, secondaryColor)
            SetVehicleMaxSpeed(vehicle, maxSpeed)
            ModifyVehicleTopSpeed(vehicle, forwardSpeed)
            SetEntityAsMissionEntity(vehicle, 1, 1)



        TriggerEvent("chatMessage",  "[Server]", {255,0,0}, "Model:"..model.." Max Speed: "..maxSpeed.." Acc: "..forwardSpeed.."Colors"..primaryColor)

        end)

    end)
