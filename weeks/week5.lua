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

local walls, escalator, christmasTree, snow

local topBop, bottomBop, santa

local scaryIntro = false

return {
	enter = function(self, previous, songNum, songAppend)
		cam.sizeX, cam.sizeY = 0.7, 0.7
		camScale.x, camScale.y = 0.7, 0.7

		bpm = 100
		useAltAnims = false

		enemyFrameTimer = 0
		boyfriendFrameTimer = 0

		sounds = {
			["miss"] = {
				love.audio.newSource("sounds/miss1.ogg", "static"),
				love.audio.newSource("sounds/miss2.ogg", "static"),
				love.audio.newSource("sounds/miss3.ogg", "static")
			},
			["death"] = love.audio.newSource("sounds/death.ogg", "static"),
			["lights off"] = love.audio.newSource("sounds/week5/lights-off.ogg", "static"),
			["lights on"] = love.audio.newSource("sounds/week5/lights-on.ogg", "static")
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
			camScale.x, camScale.y = 0.9, 0.9

			if scaryIntro then
				cam.x, cam.y = -150, 750
				cam.sizeX, cam.sizeY = 2.5, 2.5

				graphics.cancelTimer()
				graphics.fade[1] = 1
			else
				cam.sizeX, cam.sizeY = 0.9, 0.9
			end

			inst = love.audio.newSource("music/week5/winter-horrorland-inst.ogg", "stream")
			voices = love.audio.newSource("music/week5/winter-horrorland-voices.ogg", "stream")
		elseif song == 2 then
			inst = love.audio.newSource("music/week5/eggnog-inst.ogg", "stream")
			voices = love.audio.newSource("music/week5/eggnog-voices.ogg", "stream")
		else
			inst = love.audio.newSource("music/week5/cocoa-inst.ogg", "stream")
			voices = love.audio.newSource("music/week5/cocoa-voices.ogg", "stream")
		end

		self:initUI()

		if scaryIntro then
			Timer.after(
				5,
				function()
					scaryIntro = false

					camTimer = Timer.tween(2, cam, {x = 100, y = 75, sizeX = 0.9, sizeY = 0.9}, "out-quad")

					inst:play()
					weeksPixel:voicesPlay()
				end
			)

			audio.playSound(sounds["lights on"])
		else
			inst:play()
			weeksPixel:voicesPlay()
		end
	end,

	initUI = function(self)
		weeksPixel:initUI()

		if song == 3 then
			weeksPixel:generateNotes(love.filesystem.load("charts/week5/winter-horrorland" .. difficulty .. ".lua")())
		elseif song == 2 then
			weeksPixel:generateNotes(love.filesystem.load("charts/week5/eggnog" .. difficulty .. ".lua")())
		else
			weeksPixel:generateNotes(love.filesystem.load("charts/week5/cocoa" .. difficulty .. ".lua")())
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

		if not scaryIntro then
			weeksPixel:update(dt)

			if not scaryIntro and not graphics.isFading() and not inst:isPlaying() and not voices:isPlaying() then
				if storyMode and song < 3 then
					song = song + 1

					-- Winter Horrorland setup
					if song == 3 then
						scaryIntro = true

						audio.playSound(sounds["lights off"])

						graphics.cancelTimer()
						graphics.fade[1] = 0

						Timer.after(3, function() self:load() end)
					else
						self:load()
					end
				else
					graphics.fadeOut(0.5, function() Gamestate.switch(menu) end)
				end
			end

			weeksPixel:updateUI(dt)
		end
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
				love.graphics.translate(cam.x * 0.9, cam.y * 0.9)

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x, cam.y)

			love.graphics.pop()
			love.graphics.push()
				love.graphics.translate(cam.x * 1.1, cam.y * 1.1)
			love.graphics.pop()
			weeksPixel:drawRating(0.9)
		love.graphics.pop()

		if not scaryIntro then
			love.graphics.push()
				love.graphics.translate(graphics.getWidth() / 2, graphics.getHeight() / 2)
				love.graphics.scale(0.7, 0.7)

				for i = 1, 4 do
					if enemyArrows[i]:getAnimName() == "off" then
						graphics.setColor(0.6, 0.6, 0.6)
					end
					enemyArrows[i]:draw()
					graphics.setColor(1, 1, 1)
					boyfriendArrows[i]:draw()

					love.graphics.push()
						love.graphics.translate(0, -musicPos)

						for j = #enemyNotes[i], 1, -1 do
							if (not settings.downscroll and enemyNotes[i][j].y - musicPos <= 560) or (settings.downscroll and enemyNotes[i][j].y - musicPos >= -560) then
								local animName = enemyNotes[i][j]:getAnimName()

								if animName == "hold" or animName == "end" then
									graphics.setColor(1, 1, 1, 0.5)
								end
								enemyNotes[i][j]:draw()
								graphics.setColor(1, 1, 1)
							end
						end
						for j = #boyfriendNotes[i], 1, -1 do
							if (not settings.downscroll and boyfriendNotes[i][j].y - musicPos <= 560) or (settings.downscroll and boyfriendNotes[i][j].y - musicPos >= -560) then
								local animName = boyfriendNotes[i][j]:getAnimName()

								if settings.downscroll then
									if animName == "hold" or animName == "end" then
										graphics.setColor(1, 1, 1, math.min(0.5, (500 - (boyfriendNotes[i][j].y - musicPos)) / 150))
									else
										graphics.setColor(1, 1, 1, math.min(1, (500 - (boyfriendNotes[i][j].y - musicPos)) / 75))
									end
								else
									if animName == "hold" or animName == "end" then
										graphics.setColor(1, 1, 1, math.min(0.5, (500 + (boyfriendNotes[i][j].y - musicPos)) / 150))
									else
										graphics.setColor(1, 1, 1, math.min(1, (500 + (boyfriendNotes[i][j].y - musicPos)) / 75))
									end
								end
								boyfriendNotes[i][j]:draw()
							end
						end
						graphics.setColor(1, 1, 1)
					love.graphics.pop()
				end

				if settings.downscroll then
					graphics.setColor(1, 0, 0)
					love.graphics.rectangle("fill", -500, -400, 1000, 25)
					graphics.setColor(0, 1, 0)
					love.graphics.rectangle("fill", 500, -400, -health * 10, 25)
					graphics.setColor(0, 0, 0)
					love.graphics.setLineWidth(10)
					love.graphics.rectangle("line", -500, -400, 1000, 25)
					love.graphics.setLineWidth(1)
					graphics.setColor(1, 1, 1)
				else
					graphics.setColor(1, 0, 0)
					love.graphics.rectangle("fill", -500, 350, 1000, 25)
					graphics.setColor(0, 1, 0)
					love.graphics.rectangle("fill", 500, 350, -health * 10, 25)
					graphics.setColor(0, 0, 0)
					love.graphics.setLineWidth(10)
					love.graphics.rectangle("line", -500, 350, 1000, 25)
					love.graphics.setLineWidth(1)
					graphics.setColor(1, 1, 1)
				end

				if settings.downscroll then
					graphics.setColor(0, 0, 0)
					love.graphics.print("Score: " .. score, 300, -350)
					graphics.setColor(1, 1, 1)
				else
					graphics.setColor(0, 0, 0)
					love.graphics.print("Score: " .. score, 300, 400)
					graphics.setColor(1, 1, 1)
				end
			love.graphics.pop()
		end
	end,

	leave = function()
		walls = nil
		escalator = nil

		santa = nil

		weeksPixel:leave()
	end
}
