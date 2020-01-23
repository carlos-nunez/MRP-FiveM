
RegisterNetEvent("createveh")
AddEventHandler("createveh", function(coords, args)

    MySQL.Async.fetchAll("INSERT INTO vehicles1 (steamId, model, x, y, z, heading, vehicleFuel, primaryColor, secondaryColor, doorsLocked, engineHealth, bodyHealth, tint) VALUES(@source, @model, @x, @y, @z, @heading, @vehicleFuel, @primaryColor, @secondaryColor, @doorsLocked, @engineHealth, @bodyHealth, @tint)",

    {["@source"] = GetPlayerIdentifiers(source)[1], ["@model"] = args, ["@x"] = coords.xCoord, ["@y"] = coords.yCoord, ["@z"] = coords.zCoord, ["@heading"]=coords.heading, ["@vehicleFuel"]=coords.fuelLevel, ["@primaryColor"]=coords.primaryColor, ["@secondaryColor"]=coords.secondaryColor, ["@doorsLocked"]=coords.doorsLocked, ["@engineHealth"]=coords.engineHealth, ["@bodyHealth"]=coords.bodyHealth, ["@tint"]=coords.tint},

        function (result)
    end)
end)


RegisterNetEvent("parkcar")
AddEventHandler("parkcar", function(carInfo)

    MySQL.Async.fetchAll("UPDATE vehicles1 SET X=@x,Y=@y,Z=@z,heading=@heading WHERE vehicleId = @plate",

    {["@x"] = carInfo.xCoord, ["@y"] = carInfo.yCoord, ["@z"] = carInfo.zCoord, ["@heading"]=carInfo.heading, ["@plate"]=carInfo.plate},

        function (result)
    end)
end)








        TriggerEvent('es:addCommand', 'spawncars1', function(source, args)


          MySQL.Async.fetchAll("SELECT * FROM vehicles1",{},
       function(result)
          local arr = result


          for i, columns in ipairs(arr) do
              local vehicleInfo = {
                  x = columns.X;
                  y = columns.Y;
                  z = columns.Z;
                  model = columns.model;
                  upgrades = columns.upgrades;
                  heading = columns.heading;
                  wheelHealth = columns.wheelHealth;
                  fuel = columns.vehicleFuel;
                  primaryColor = columns.primaryColor;
                  secondaryColor = columns.secondaryColor;
                  doorsLocked = columns.doorsLocked;
                  engineHealth = columns.engineHealth;
                  bodyHealth = columns.bodyHealth;
                  tint = columns.tint;
                  plate = columns.vehicleId;
                  }
                  TriggerClientEvent("spawncar",source, vehicleInfo)

            end
end)


       end, {help = "Respawns server vehicles"})




       TriggerEvent('es:addCommand', 'nrefresh', function(source, args)


         MySQL.Async.fetchAll("SELECT * FROM vehicles1",{},
      function(result)
         local arr = result


         for i, columns in ipairs(arr) do
             local vehicleInfo = {
                 x = columns.X;
                 y = columns.Y;
                 z = columns.Z;
                 model = columns.model;
                 upgrades = columns.upgrades;
                 heading = columns.heading;
                 wheelHealth = columns.wheelHealth;
                 fuel = columns.vehicleFuel;
                 primaryColor = columns.primaryColor;
                 secondaryColor = columns.secondaryColor;
                 doorsLocked = columns.doorsLocked;
                 engineHealth = columns.engineHealth;
                 bodyHealth = columns.bodyHealth;
                 tint = columns.tint;
                 plate = columns.vehicleId;
                 }
                 TriggerClientEvent("updatePos",source, vehicleInfo)

           end
end)


      end, {help = "Respawns server vehicles"})
