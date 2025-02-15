prrepeat task.wait() until game:IsLoaded()
if _G.vape then _G.vape:Uninject() end

if identifyexecutor then
  if table.find({'Argon', 'Wave', 'Swift'}, (identifyexecutor())) then
    getgenv().setthreadidentity = nil
  end
end

local vape
local loadstring = function(script, name)
  print('running '.. (name and name..'.lua') or 'some file')
  local res, err = loadstring(script, name)
  if err and vape then
    vape:CreateNotification('Lunar Vape', 'Failed to load : ' .. err, 30, 'alert')
  end
  return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
  local suc, res = pcall(function()
    return readfile(file)
  end)
  return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
  return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
  if not isfile(path) then
    local suc, res = pcall(function()
      return game:HttpGet(
      'https://raw.githubusercontent.com/renderintent/render/' ..
      readfile('newvape/profiles/commit.txt') .. '/' .. select(1, path:gsub('newvape/', '')), true)
    end)
    if not suc or res == '404: Not Found' then
      error(res)
    end
    if path:find('.lua') then
      res =
      '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' ..
      res
    end
    writefile(path, res)
  end
  return (func or readfile)(path)
end

local function finishLoading()
  vape.Init = nil
  vape:Load()
  task.spawn(function()
    repeat
      vape:Save()
      task.wait(10)
    until not vape.Loaded
  end)

  local teleportedServers
  vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
    if (not teleportedServers) and (not _G.VapeIndependent) then
      teleportedServers = true
      local teleportScript = [[
				_G.vapereload = true
				if _G.VapeDeveloper then
					loadstring(readfile('newvape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/renderintent/render/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
      if _G.VapeDeveloper then
        teleportScript = '_G.VapeDeveloper = true\n' .. teleportScript
      end
      if _G.VapeCustomProfile then
        teleportScript = '_G.VapeCustomProfile = "' .. _G.VapeCustomProfile .. '"\n' .. teleportScript
      end
      vape:Save()
      queue_on_teleport(teleportScript)
    end
  end))

  if not _G.vapereload then
    if not vape.Categories then return end
    if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
      vape:CreateNotification('Render Vape', ' Render has finished loading enjoy!', 6)
    end
  end
end

if not isfile('newvape/profiles/gui.txt') then
  writefile('newvape/profiles/gui.txt', 'new')
end
local gui = readfile('newvape/profiles/gui.txt')

if not isfolder('newvape/assets/' .. gui) then
  makefolder('newvape/assets/' .. gui)
end
vape = loadstring(downloadFile('newvape/guis/' .. gui .. '.lua'), 'gui')()
_G.vape = vape

if not _G.VapeIndependent then
  loadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
  if isfile('newvape/games/' .. game.PlaceId .. '.lua') then
    loadstring(readfile('newvape/games/' .. game.PlaceId .. '.lua'), tostring(game.PlaceId))(...)
  else
    if not _G.VapeDeveloper then
      local suc, res = pcall(function()
        return game:HttpGet(
        'https://raw.githubusercontent.com/renderintent/render/' ..
        readfile('newvape/profiles/commit.txt') .. '/games/' .. game.PlaceId .. '.lua', true)
      end)
      if suc and res ~= '404: Not Found' then
        loadstring(downloadFile('newvape/games/' .. game.PlaceId .. '.lua'), tostring(game.PlaceId))(...)
      end
    end
  end
  finishLoading()
else
  vape.Init = finishLoading
  return vape
end
