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

local font

local song, difficulty

local sky, school, street, treesBack

local petals, trees, freaks

return {
	enter = function(self, previous, songNum, songAppend)
		love.graphics.setDefaultFilter("nearest")

		lovesize.set(256, 144)

		font = love.graphics.newFont("fonts/pixel.ttf", 10)

		weeksPixel:enter()

		song = songNum
		difficulty = songAppend

		cam.sizeX, cam.sizeY = 1, 1
		camScale.x, camScale.y = 1, 1

		enemy = love.filesystem.load("sprites/pixel/boyfriend.lua")()

		if song ~= 3 then
			sky = graphics.newImage(love.graphics.newImage(graphics.imagePath("week6/sky")))
			school = graphics.newImage(love.graphics.newImage(graphics.imagePath("week6/school")))
			street = graphics.newImage(love.graphics.newImage(graphics.imagePath("week6/street")))
			treesBack = graphics.newImage(love.graphics.newImage(graphics.imagePath("week6/trees-back")))

			freaks = love.filesystem.load("sprites/week6/freaks.lua")()

			sky.y = 1
			school.y = 1
		end

		boyfriend.x, boyfriend.y = 50, 30
		fakeBoyfriend.x, fakeBoyfriend.y = 50, 30
		enemy.x, enemy.y = -50, 0

		enemyIcon:animate("senpai", false)

		self:load()
	end,

	load = function(self)
		if song == 2 then
			freaks:animate("dissuaded", true)
		end

		weeksPixel:load()

		if song == 3 then
			inst = love.audio.newSource("music/week6/thorns-inst.ogg", "stream")
			voices = love.audio.newSource("music/week6/thorns-voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("music/week6/roses-inst.ogg", "stream")
			voices = love.audio.newSource("music/week6/roses-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/week6/senpai-inst.ogg", "stream")
			voices = love.audio.newSource("music/week6/senpai-voices.ogg", "stream")
		end
		

		self:initUI()

		inst:play()
		weeksPixel:voicesPlay()
	end,

	initUI = function(self)
		weeksPixel:initUI()

		if song == 3 then
			weeksPixel:generateNotes(love.filesystem.load("charts/week6/thorns-hard.lua")())
		elseif song == 2 then
			weeksPixel:generateNotes(love.filesystem.load("charts/week6/roses-hard.lua")())
		else
			weeksPixel:generateNotes(love.filesystem.load("charts/week6/senpai-hard.lua")())
		end
	end,

	update = function(self, dt)
		if gameOver then
			if not graphics.isFading() then
				if input:pressed("confirm") then
					inst:stop()
					inst = love.audio.newSource("music/pixel/game-over-end.ogg", "stream")
					inst:play()

					Timer.clear()

					cam.x, cam.y = -fakeBoyfriend.x, -fakeBoyfriend.y

					fakeBoyfriend:animate("dead confirm", false)

					graphics.fadeOut(3, function() self:load() end)
				elseif input:pressed("gameBack") then
					graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
				end
			end

			fakeBoyfriend:update(dt)

			return
		end

		weeksPixel:update(dt)

		
		freaks:update(dt)

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
		love.graphics.setFont(font)

		weeksPixel:draw()

		if gameOver then return end

		love.graphics.push()
			love.graphics.translate(128, 72)
			love.graphics.scale(cam.sizeX, cam.sizeY)
			love.graphics.push()
				love.graphics.translate(math.floor(cam.x * 0.9), math.floor(cam.y * 0.9))
				sky:draw()
				school:draw()
			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(math.floor(cam.x), math.floor(cam.y))
				street:draw()
				treesBack:draw()
				freaks:draw()
				girlfriend:draw()
				enemy:draw()
				boyfriend:draw()
			love.graphics.pop()
			weeksPixel:drawRating()
		love.graphics.pop()

		weeksPixel:drawUI()
	end,

	leave = function(self)
		font = nil

		sky = nil
		school = nil
		street = nil

		weeksPixel:leave()

		lovesize.set(800, 240)

		love.graphics.setDefaultFilter("linear")
	end
}
