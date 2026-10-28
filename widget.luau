--!nonstrict
-- PokeBar bar widget: cycles the frames the `pokebar` CLI extracts into data_dir.
--
--   left click    pokebar interact   (cry notification)
--   right click   pokebar next
--   middle click  pokebar random
--
-- Drive it from the shell (name or Pokedex number):
--   noctalia msg plugin pokebar/pokebar:pokemon focused set charizard

local frameDir = noctalia.getConfig("data_dir")
local size = noctalia.getConfig("size")

local total = 0
local idx = 0
local ticks = 0
local metaMtime = nil

local function loadMeta()
  local meta = noctalia.readFile(frameDir .. "/meta.txt")
  total = tonumber(meta and meta:match("%d+")) or 0
  if idx >= total then
    idx = 0
  end

  local info = noctalia.readFile(frameDir .. "/info.txt")
  local name = info and info:match("[^\n]+")
  if name then
    barWidget.setTooltip(name)
  end
end

-- The CLI rewrites meta.txt whenever the Pokemon changes (including from a terminal).
local function reloadIfChanged()
  local stat = noctalia.fileInfo(frameDir .. "/meta.txt")
  local mtime = stat and stat.mtime
  if mtime ~= metaMtime then
    metaMtime = mtime
    loadMeta()
  end
end

local function run(args)
  noctalia.runAsync('PATH="$HOME/.local/bin:$PATH" pokebar ' .. args, function(result)
    if result.exitCode ~= 0 then
      local err = if result.stderr ~= "" then result.stderr else result.stdout
      noctalia.notifyError("PokeBar", err)
    end
    reloadIfChanged()
  end, 30000)
end

noctalia.setUpdateInterval(noctalia.getConfig("interval_ms"))
reloadIfChanged()

function update()
  ticks += 1
  if ticks % 20 == 0 then
    reloadIfChanged()
  end
  if total == 0 then
    return
  end
  barWidget.setImage(`{frameDir}/frame_{idx}.png`, false, size, size)
  idx = (idx + 1) % total
end

function onClick()
  run("interact")
end

function onRightClick()
  run("next")
end

function onMiddleClick()
  run("random")
end

function onIpc(event, payload)
  -- payload goes into a shell string, so only allow name / number characters
  if event == "set" and type(payload) == "string" and payload:match("^[%w%-_]+$") then
    run("set " .. payload)
  end
end
