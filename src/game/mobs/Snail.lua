local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"
local Timer = require "libs.hump.timer"
local Enemy = require "src.game.mobs.Enemy"
local Hbox = require "src.game.Hbox"
local Sounds = require "src.game.Sounds"

-- Idle Animation Resources
local idleSprite = love.graphics.newImage("graphics/mobs/snail/Hide-Sheet.png")
local idleGrid = Anim8.newGrid(48, 32, idleSprite:getWidth(), idleSprite:getHeight())
local idleAnim = Anim8.newAnimation(idleGrid('1-8',1),0.2)
-- Walk Animation Resources
local walkSprite = love.graphics.newImage("graphics/mobs/snail/Walk-Sheet.png")
local walkGrid = Anim8.newGrid(48, 32, walkSprite:getWidth(), walkSprite:getHeight())
local walkAnim = Anim8.newAnimation(walkGrid('1-8',1),0.2)
-- Hit Animation Resources
local hitSprite = love.graphics.newImage("graphics/mobs/snail/Dead-Sheet.png")
local hitGrid = Anim8.newGrid(48, 32, hitSprite:getWidth(), hitSprite:getHeight())
local hitAnim = Anim8.newAnimation(hitGrid('5-8',1),0.2)

local Snail = Class{__includes = Enemy}
function Snail:init() Enemy:init() -- superclass const.
    self.name = "snail"
    self.type = type

    self.dir = "l" -- Direction r = right, l = left
    self.state = "idle" -- idle state
    self.animations = {} -- dict of animations (each mob will have its own)
    self.sprites = {} -- dict of sprites (for animations)
    self.hitboxes = {}
    self.hurtboxes = {}

    self.hp = 40
    self.score = 400
    self.damage = 50

    self:setAnimation("idle",idleSprite, idleAnim)
    self:setAnimation("walk",walkSprite, walkAnim)
    self:setAnimation("hit", hitSprite, hitAnim)

    self:setHurtbox("idle",10,10,34,22)
    self:setHurtbox("walk",10,10,34,22)
    self:setHurtbox("hit",6,2,34,30)

    self:setHitbox("idle",10,10,34,22)
    self:setHitbox("walk",10,10,34,22)
    
    Timer.every(5,function() self:changeState() end)
end

function Snail:changeState()
    if self.state == "idle" then
            self.state = "walk"
    elseif self.state == "walk" then
        self.state = "idle"
    end
end
    

function Snail:update(dt, stage)
    if self.state == "walk" then
        if not stage:bottomCollision(self,1,0) then -- not on solid ground
            self.y = self.y + 32*dt -- fall 
        elseif self.dir == "l" then -- on ground and walking left
            if stage:leftCollision(self,0) then -- collision, change dir
                self:changeDirection()
            else -- no collision, keep walking left
                self.x = self.x-16*dt
            end
        else -- on ground and walking right
            if stage:rightCollision(self,0) then -- collision, change dir
                self:changeDirection()
            else -- no collision, keep walking right
                self.x = self.x+16*dt
            end 
        end -- end if bottom collision & dir 
    end -- end if walking state
    Timer.update(dt) -- attention, Timer.update uses dot, and not :
    self.animations[self.state]:update(dt)
end -- end function
    
function Snail:hit(damage, direction)
    if self.invincible then return end

    self.invincible = true
    self.hp = self.hp - damage
    self.state = "hit"
    Sounds["mob_hurt"]:play()

    if self.hp <= 0 then
        self.died = true
    end

    Timer.after(1, function() self:endHit(direction) end)
    Timer.after(0.9, function() self.invincible = false end)

end

function Snail:endHit(direction)
    if self.dir == direction then
        self:changeDirection()
    end
    self.state = "walk"
end

return Snail