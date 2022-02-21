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

local hauntedHouse

return {
	enter = function(self, previous, songNum, songAppend)
		weeks:enter()

		song = songNum
		difficulty = songAppend

		cam.sizeX, cam.sizeY = 1.1, 1.1
		camScale.x, camScale.y = 1.1, 1.1

		sounds["thunder"] = {
			love.audio.newSource("sounds/week2/thunder1.ogg", "static"),
			love.audio.newSource("sounds/week2/thunder2.ogg", "static")
		}

		self:load()
	end,

	load = function(self)
		weeks:load()

		if song == 2 then
			inst = love.audio.newSource("music/week2/south-inst.ogg", "stream")
			voices = love.audio.newSource("music/week2/south-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/week2/spookeez-inst.ogg", "stream")
			voices = love.audio.newSource("music/week2/spookeez-voices.ogg", "stream")
		end

		self:initUI()

		inst:play()
		weeks:voicesPlay()
	end,

	initUI = function(self)
		weeks:initUI()

		if song == 2 then
			weeks:generateNotes(love.filesystem.load("charts/week2/south" .. difficulty .. ".lua")())
		else
			weeks:generateNotes(love.filesystem.load("charts/week2/spookeez" .. difficulty .. ".lua")())
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

		if not graphics.isFading() and not inst:isPlaying() and not voices:isPlaying() then
			if storyMode and song < 2 then
				song = song + 1

				self:load()
			else
				graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
			end
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
			weeks:drawRating(0.9)
		love.graphics.pop()

		weeks:drawUI()
	end,

	leave = function(self)
		hauntedHouse = nil

		weeks:leave()
	end
}
