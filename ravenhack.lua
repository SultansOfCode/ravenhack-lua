-- References
local rhWindow = nil
local autoMinigameCheckBox = nil


function hackVisibleDimension(amount)
  local gameMapPanel = modules.game_interface.getMapPanel()

  if gameMapPanel == nil then
    return
  end

  local dimension = gameMapPanel:getVisibleDimension()

  dimension.width = dimension.width + amount
  dimension.height = dimension.height + amount

  gameMapPanel:setVisibleDimension(dimension)

  g_logger.info("ZoomHack visible dimension triggered")
end

function showRavenHackWindow()
  if rhWindow == nil then
    return
  end

  rhWindow:show()
  rhWindow:raise()
  rhWindow:focus()
end

function hideRavenHackWindow()
  if rhWindow == nil then
    return
  end

  rhWindow:hide()
end

function toggleRavenHackWindow()
  if rhWindow == nil then
    return
  end

  if rhWindow:isVisible() then
    hideRavenHackWindow()
  else
    showRavenHackWindow()
  end
end

function onLogin()
  showRavenHackWindow()
end

function onLogout()
  hideRavenHackWindow()
end

-- Module initialization on load
function init()
  connect(g_game, {
		onLogin = onLogin,
		onLogout = onLogout
	})

  g_keyboard.bindKeyDown("Ctrl+Alt+;", function()
    toggleRavenHackWindow()
  end)

  -- Create the window, get its reference and hide it
  rhWindow = g_ui.displayUI("ravenhack", modules.game_interface.getRootPanel())

  rhWindow:hide()

  autoMinigameCheckBox = rhWindow:getChildById("autoMinigameCheckBox")
end

-- Module termination on unload
function terminate()
  disconnect(g_game, {
		onLogin = onLogin,
		onLogout = onLogout
	})

  -- If window is found, destroy it
  if rhWindow ~= nil then
    rhWindow:destroy()

    rhWindow = nil
  end
end

function zoomMinusButtonClick()
  hackVisibleDimension(2)
end

function zoomPlusButtonClick()
  hackVisibleDimension(-2)
end

function zoomResetButtonClick()
  modules.game_interface.refreshViewMode()
end

function noShadersButtonClick()
  local gameMapPanel = modules.game_interface.getMapPanel()

  if gameMapPanel == nil then
    return
  end

  gameMapPanel:setShader(nil)
end

function worldLightButtonClick()
  g_map.setLightData(255, 215)
end

function hitMinigameButtonClick()
  local minigameWindow = modules.game_channeling_minigame.minigameWindow

  if minigameWindow == nil then
    return
  end

  if not minigameWindow:isVisible() then
    return
  end

  local barContainer = modules.game_channeling_minigame.barContainer
  local rangeIndicator = modules.game_channeling_minigame.rangeIndicator
  local movingLine = modules.game_channeling_minigame.movingLine

  local left = rangeIndicator:getMarginLeft()
  local right = left + rangeIndicator:getWidth()
  local rangeStart = math.ceil((rangeIndicator:getMarginLeft() / barContainer:getWidth()) * 100)
  local rangeEnd = math.floor(((rangeIndicator:getMarginLeft() + rangeIndicator:getWidth()) / barContainer:getWidth()) * 100)

  local rnd = math.random(left + 1, right - 1)

  movingLine:setMarginLeft(rnd)

  movingLine.value = math.floor((rnd / barContainer:getWidth()) * 100)

  modules.game_channeling_minigame.sendInput()
end

function autoMinigameCheckBoxCheckChange()
  if autoMinigameEvent ~= nil then
    removeEvent(autoMinigameEvent)

    autoMinigameEvent = nil
  end

  if autoMinigameCheckBox == nil then
    return
  end

  if not autoMinigameCheckBox:isChecked() then
    return
  end

  autoMinigameEvent = cycleEvent(hitMinigameButtonClick, 500)
end

function getAddressButtonClick()
  local label = rhWindow:getChildById("autoMinigameLabel")
  local gameMapPanel = modules.game_interface.getMapPanel()
  local f = gameMapPanel.setVisibleDimension

  label:setText(string.format("%p", f))
end
