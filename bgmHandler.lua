local self = {}
local api = {}
local cosmos
local DISABLED = false

ShopHandler = require("shopHandler")
TableHandler = require("tableHandler")

local trackDefs = require("defs/musicTracks")
local trackList = trackDefs.list
local trackData = {}
local loopDuration = trackDefs.trackDuration
local playbackPosition = loopDuration

local bankA = {}
local bankB = {}
local targetVolumes = {}
local actualVolumes = {}
local volumePercentPerSecond = 0.3
local bankAIsCurrent = true

local continuoScore = 3
local ripienoScore = 50
local principalScore = 100

function api.StopCurrentTrack(delay)
	for i=1,#targetVolumes do
    targetVolumes[i] = 0
  end
end

function api.Update(dt)
  -- IMPLEMENT
  continuoScore = ShopHandler.GetCurrentContinuoScore()
  ripienoScore = 300 * TableHandler.GetAverageFullness()
  principalScore = 4 * TableHandler.GetMaxBookValue()
  local sourceScore = nil
  local track = nil
  
  playbackPosition = playbackPosition + dt
  
  -- Perform bank cutover and update the volume target values if required
  if cosmos.MusicEnabled()
  then
    if playbackPosition >= loopDuration
    then playbackPosition = 0
      bankAIsCurrent = not bankAIsCurrent
      for k,v in pairs(bankAIsCurrent and bankA or bankB) do
        v:play()
      end
    end
    
    for i=1,#trackData do
        track = nil
        sourceScore = nil
        track = trackData[i]
        
        if track.group == "continuo"
        then sourceScore = continuoScore
        elseif track.group == "ripieno"
        then sourceScore = ripienoScore
        elseif track.group == "principal"
        then sourceScore = principalScore
        else sourceScore = 0
        end
        
        if sourceScore >= track.maxVal
        then targetVolumes[i] = 1.0 * track.volMult
        elseif sourceScore <= track.minVal
        then targetVolumes[i] = 0.0
        else targetVolumes[i] =  track.volMult * (sourceScore - track.minVal) / (sourceScore - track.maxVal)
        end
    end  
  end
  
  -- Unconditionally step all volumes towards target values
  local dv = dt * volumePercentPerSecond
  
  for i=1,#targetVolumes do
    if actualVolumes[i] == targetVolumes[i]
    then -- noop - this is an aid to debugging to allow setting breakpoints that bypass the do-nothing case
    elseif actualVolumes[i] - dv >= targetVolumes[i] and actualVolumes[i] + dv <= targetVolumes[i] -- if the target volume is between 1dv below and 1dv above the target volume
    then actualVolumes[i] = targetVolumes[i] -- directly set it to the target volume
  elseif actualVolumes[i] >= targetVolumes[i] -- otherwise step towards the target volume at 1dv per frame
  then actualVolumes[i] = actualVolumes[i] - dv
    else actualVolumes[i] = actualVolumes[i] + dv
  end
    bankA[i]:setVolume(actualVolumes[i])
    bankB[i]:setVolume(actualVolumes[i])
  end
  
end

function api.Initialize(newCosmos)
	if DISABLED then
		return
	end
  
  for i=1,#trackList do
      track = trackList[i]
      trackData[i] = require("resources/soundDefs/" .. track)
      targetVolumes[i] = 0
      actualVolumes[i] = 0
      local path = "resources/sounds/" .. trackData[i].file
      bankA[i] = love.audio.newSource("resources/sounds/" .. trackData[i].file,"static")
      bankB[i] = love.audio.newSource("resources/sounds/" .. trackData[i].file,"static")
      bankA[i]:setVolume(0.0)
      bankB[i]:setVolume(0.0)
  end
  
  playbackPosition = loopDuration
  
	self = {}
	cosmos = newCosmos
	initialDelay = 0
end

return api