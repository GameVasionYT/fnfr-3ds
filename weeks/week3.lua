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

local song, difficulty

local sky, city, cityWindows, behindTrain, street
local winColors, winColor

return {
	enter = function(self, previous, songNum, songAppend)
		weeks:enter()

		song = songNum
		difficulty = songAppend

		cam.sizeX, cam.sizeY = 1, 1
		camScale.x, camScale.y = 1, 1

		winColors = {
			{49, 162, 253}, -- Blue
			{49, 253, 140}, -- Green
			{251, 51, 245}, -- Magenta
			{253, 69, 49}, -- Orange
			{251, 166, 51}, -- Yellow
		}
		winColor = 1

		self:load()
	end,

	load = function(self)
		weeks:load()

		if song == 3 then
			inst = love.audio.newSource("music/week3/blammed-inst.ogg", "stream")
			voices = love.audio.newSource("music/week3/blammed-voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("music/week3/philly-nice-inst.ogg", "stream")
			voices = love.audio.newSource("music/week3/philly-nice-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/week3/pico-inst.ogg", "stream")
			voices = love.audio.newSource("music/week3/pico-voices.ogg", "stream")
		end

		self:initUI()

		inst:play()
		weeks:voicesPlay()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 3 then
			weeks:generateNotes(love.filesystem.load("charts/week3/blammed" .. difficulty .. ".lua")())
		elseif song == 2 then
			weeks:generateNotes(love.filesystem.load("charts/week3/philly-nice" .. difficulty .. ".lua")())
		else
			weeks:generateNotes(love.filesystem.load("charts/week3/pico" .. difficulty .. ".lua")())
		end
	end,

	update = function(self, dt)
		if gameOver then
			if not graphics.isFading() then
				if input:pressed("confirm") then
					inst:stop()
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

		weeks:update(dt)

		if musicThres ~= oldMusicThres and math.fmod(musicTime, 240000 / bpm) < 100 then
			winColor = winColor + 1

			if winColor > 5 then
				winColor = 1
			end
		end

		if not graphics.isFading() and not inst:isPlaying() and not voices:isPlaying() then
			if storyMode and song < 3 then
				song = song + 1

				self:load()
			else
				graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
			end
		end

		weeks:updateUI(dt)
	end,

	draw = function(self)
		local curWinColor = winColors[winColor]

		weeks:draw()

		if gameOver then return end

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			love.graphics.push()
				love.graphics.translate(cam.x * 0.25, cam.y * 0.25)

				love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 0.5, cam.y * 0.5)

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

			love.graphics.pop()
			weeks:drawRating(0.9)
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		sky = nil
		city = nil
		cityWindows = nil
		behindTrain = nil
		street = nil

		weeks:leave()
	end
}
