





RegisterNetEvent("firstSpawn")
AddEventHandler("firstSpawn", function(coords, args)
  local _source = source
  MySQL.Async.fetchAll("SELECT * FROM owned_vehicles",{},
       function(result)
          local arr = result
          for i, columns in ipairs(arr) do
              local vehicleInfo = {
                  x = columns.X;
                  y = columns.Y;
                  z = columns.Z;
                  mods = columns.vehicle;
                  heading = columns.heading;
                  }
                TriggerClientEvent("spawncar", _source, vehicleInfo)
              end
    end)
end)






--@param coords is the vehicle information
RegisterNetEvent("saveveh")
AddEventHandler("saveveh", function(coords, args)
    MySQL.Async.fetchAll("INSERT INTO vehicles1 (steamId, model, x, y, z, heading, vehicleFuel, primaryColor, secondaryColor, doorsLocked, engineHealth, bodyHealth, tint) VALUES(@source, @model, @x, @y, @z, @heading, @vehicleFuel, @primaryColor, @secondaryColor, @doorsLocked, @engineHealth, @bodyHealth, @tint)",
          {["@source"] = GetPlayerIdentifiers(source)[1], ["@model"] = args,
          ["@x"] = coords.xCoord, ["@y"] = coords.yCoord, ["@z"] = coords.zCoord,
          ["@heading"]=coords.heading, ["@vehicleFuel"]=coords.fuelLevel,
          ["@primaryColor"]=coords.primaryColor, ["@secondaryColor"]=coords.secondaryColor,
          ["@doorsLocked"]=coords.doorsLocked, ["@engineHealth"]=coords.engineHealth,
          ["@bodyHealth"]=coords.bodyHealth, ["@tint"]=coords.tint},
        function (result)
    end)
end)


--Updates the position of a vehicle with a certain license plate
RegisterNetEvent("parkcar")
AddEventHandler("parkcar", function(carInfo)
    MySQL.Async.fetchAll("UPDATE owned_vehicles SET X=@x,Y=@y,Z=@z,heading=@heading WHERE plate = @plate",
    {["@x"] = carInfo.xCoord, ["@y"] = carInfo.yCoord, ["@z"] = carInfo.zCoord, ["@heading"]=carInfo.heading, ["@plate"]=carInfo.plate},
        function (result)
    end)
end)


--Gets the Owner of a Vehicle
RegisterNetEvent("getowner")
AddEventHandler("getowner", function(carInfo)
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate",
    {["@plate"]=carInfo.plate},
        function (result)
          print(result[1].owner)
    end)
end)

--Deletes all the vehicles on the server from all clients.
RegisterCommand("delallveh", function(source, args, rawCommand)
   TriggerClientEvent("delallveh", -1, "")
 end, false)


--Spawn All the Vehicles In the Database
TriggerEvent('es:addCommand', 'spawncars', function(source, args)
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles",{},
         function(result)
            local arr = result
            for i, columns in ipairs(arr) do
                local vehicleInfo = {
                    x = columns.X;
                    y = columns.Y;
                    z = columns.Z;
                    mods = columns.vehicle;
                    heading = columns.heading;
                    }

                  TriggerClientEvent("spawncar", source, vehicleInfo)
                end
      end)
  end, {help = "Respawns server vehicles"})

  --Update the position of all the vehicles server to their database positions
TriggerEvent('es:addCommand', 'vrefresh', function(source, args)
  MySQL.Async.fetchAll("SELECT * FROM owned_vehicles",{},
      function(result)
         local arr = result
         for i, columns in ipairs(arr) do
           local vehicleInfo = {
               x = columns.X;
               y = columns.Y;
               z = columns.Z;
               mods = columns.vehicle;
               heading = columns.heading;
               }
                 TriggerClientEvent("updatePos",source, vehicleInfo)
           end
         end)
      end, {help = "Respawns server vehicles"})
