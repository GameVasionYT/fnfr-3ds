--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local difficulty

local stageBack, stageFront, curtains

return {
	enter = function(self, previous, songNum, songAppend)
		weeks:enter()

		difficulty = songAppend

		self:load()
	end,

	load = function(self)
		weeks:load()

		inst = nil
		voices = love.audio.newSource("music/tutorial/tutorial.ogg", "stream")

		self:initUI()

		weeks:voicesPlay()
	end,

	initUI = function(self)
		weeks:initUI()

		weeks:generateNotes(love.filesystem.load("charts/tutorial/tutorial" .. difficulty .. ".lua")())
	end,

	update = function(self, dt)
		if gameOver then
			if not graphics:isFading() then
				if input:pressed("confirm") then
					if inst then -- In case "confirm" is pressed before game over music starts
						inst:stop()
					end
					inst = love.audio.newSource("music/game-over-end.ogg", "stream")
					inst:play()

					Timer.clear()

					cam.x, cam.y = 0, 0

					graphics.fadeOut(3, function() self:load() end)
				elseif input:pressed("gameBack") then
					graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
				end
			end

			return
		end

		oldMusicThres = musicThres

		musicTime = musicTime + (love.timer.getTime() * 1000) - previousFrameTime
		previousFrameTime = love.timer.getTime() * 1000

		if voices:tell("seconds") * 1000 ~= lastReportedPlaytime then
			musicTime = (musicTime + (voices:tell("seconds") * 1000)) / 2
			lastReportedPlaytime = voices:tell("seconds") * 1000
		end

		musicThres = math.floor(musicTime / 100) -- Since "musicTime" isn't precise, this is needed

		for i = 1, #events do
			if events[i].eventTime <= musicTime then
				local oldBpm = bpm

				if events[i].bpm then
					bpm = events[i].bpm
					if not bpm then bpm = oldBpm end
				end

				if camTimer then
					Timer.cancel(camTimer)
				end
				if events[i].mustHitSection then
					camTimer = Timer.tween(1.5, cam, {x = 50, y = 50}, "out-quad")
				else
					camTimer = Timer.tween(1.5, cam, {x = 100, y = 75}, "out-quad")
				end

				table.remove(events, i)

				break
			end
		end

		if musicThres ~= oldMusicThres and math.fmod(musicTime, 240000 / bpm) < 100 then
			if camScaleTimer then Timer.cancel(camScaleTimer) end

			camScaleTimer = Timer.tween((60 / bpm) / 16, cam, {sizeX = camScale.x * 1.05, sizeY = camScale.y * 1.05}, "out-quad", function() camScaleTimer = Timer.tween((60 / bpm), cam, {sizeX = camScale.x, sizeY = camScale.y}, "out-quad") end)
		end

		for i = 1, 3 do
			local spriteTimer = spriteTimers[i]

			if spriteTimer > 0 then
				spriteTimers[i] = spriteTimer - 1
			end
		end

		if not graphics.isFading() and not voices:isPlaying() then
			storyMode = false

			graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		weeks:draw()

		if gameOver then return end

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			love.graphics.push()
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 1.1, cam.y * 1.1)

			love.graphics.pop()
			weeks:drawRating(0.9)
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		stageBack = nil
		stageFront = nil
		curtains = nil

		weeks:leave()
	end
}
