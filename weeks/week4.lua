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

local sunset

local bgLimo, limoDancer, limo

return {
	enter = function(self, previous, songNum, songAppend)
		bpm = 100

		enemyFrameTimer = 0
		boyfriendFrameTimer = 0

		sounds = {
			["miss"] = {
				love.audio.newSource("sounds/miss1.ogg", "static"),
				love.audio.newSource("sounds/miss2.ogg", "static"),
				love.audio.newSource("sounds/miss3.ogg", "static")
			},
			["death"] = love.audio.newSource("sounds/death.ogg", "static")
		}

		images = {
			["notes"] = love.graphics.newImage(graphics.imagePath("notes")),
			["numbers"] = love.graphics.newImage(graphics.imagePath("numbers"))
		}

		sprites = {
			["numbers"] = love.filesystem.load("sprites/numbers.lua")
		}

		song = songNum
		difficulty = songAppend

		rating = love.filesystem.load("sprites/rating.lua")()

		rating.sizeX, rating.sizeY = 0.75, 0.75
		numbers = {}
		for i = 1, 3 do
			numbers[i] = sprites["numbers"]()

			numbers[i].sizeX, numbers[i].sizeY = 0.5, 0.5
		end

		self:load()
	end,

	load = function(self)
		weeksPixel:load()

		if song == 3 then
			inst = love.audio.newSource("music/week4/milf-inst.ogg", "stream")
			voices = love.audio.newSource("music/week4/milf-voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("music/week4/high-inst.ogg", "stream")
			voices = love.audio.newSource("music/week4/high-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/week4/satin-panties-inst.ogg", "stream")
			voices = love.audio.newSource("music/week4/satin-panties-voices.ogg", "stream")
		end

		self:initUI()

		inst:play()
		weeksPixel:voicesPlay()
	end,

	initUI = function(self)
		weeksPixel:initUI()

		if song == 3 then
			weeksPixel:generateNotes(love.filesystem.load("charts/week4/milf" .. difficulty .. ".lua")())
		elseif song == 2 then
			weeksPixel:generateNotes(love.filesystem.load("charts/week4/high" .. difficulty .. ".lua")())
		else
			weeksPixel:generateNotes(love.filesystem.load("charts/week4/satin-panties" .. difficulty .. ".lua")())
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

		weeksPixel:update(dt)

		-- Hardcoded M.I.L.F camera scaling
		if song == 3 and musicTime > 56000 and musicTime < 67000 and musicThres ~= oldMusicThres and math.fmod(musicTime, 60000 / bpm) < 100 then
			if camScaleTimer then Timer.cancel(camScaleTimer) end

			camScaleTimer = Timer.tween((60 / bpm) / 16, cam, {sizeX = camScale.x * 1.05, sizeY = camScale.y * 1.05}, "out-quad", function() camScaleTimer = Timer.tween((60 / bpm), cam, {sizeX = camScale.x, sizeY = camScale.y}, "out-quad") end)
		end

		if not graphics.isFading() and not inst:isPlaying() and not voices:isPlaying() then
			if storyMode and song < 3 then
				song = song + 1

				self:load()
			else
				graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
			end
		end

		weeksPixel:updateUI(dt)
	end,

	draw = function(self)
		weeksPixel:draw()

		if gameOver then return end

		love.graphics.push()
			love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
			love.graphics.scale(cam.sizeX, cam.sizeY)

			love.graphics.push()
				love.graphics.translate(cam.x * 0.5, cam.y * 0.5)

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

			love.graphics.pop()
			weeksPixel:drawRating(1)
		love.graphics.pop()

		weeksPixel:drawUI()
	end,

	leave = function()
		sunset = nil

		bgLimo = nil
		limoDancer = nil
		limo = nil

		weeksPixel:leave()
	end
}
