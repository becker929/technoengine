package.path = reaper.GetResourcePath() .. '/Scripts/rtk/1/?.lua'
local rtk = require('rtk')
local log = rtk.log
log.level = log.INFO

function readTemplate()
  local f = "/Users/anthonybecker/Desktop/project-checklist.md"
  local file = io.open(f, "r")
  if not file then return nil end
  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()
  return lines
end


local content = readTemplate()
for _, line in ipairs(content) do
  --window:add(rtk.CheckBox{line})
end


function main()
  local window = rtk.Window{borderless=true}
  local home = {
    init = function(app, screen)
      local box = rtk.VBox{margin=10}
      local button = box:add(rtk.Button{"Add New Track"})
      button.onclick = function()
        log.info("button clicked")
      end
      screen.widget = box
    end,
  }
  local app = window:add(rtk.Application())
  app:add_screen(home, 'home')
  app.statusbar:hide()
  window:open()
end


rtk.call(main)
