local DamageText = require "src.game.DamageText"

local DamageTextManager = {}
DamageTextManager.texts = {}

function DamageTextManager.spawn(x, y, text)
    table.insert(DamageTextManager.texts, DamageText(x, y, text))
end

function DamageTextManager.update(dt)
    for i = #DamageTextManager.texts, 1, -1 do
        local t = DamageTextManager.texts[i]
        t:update(dt)
        if not t:isActive() then
            table.remove(DamageTextManager.texts, i)
        end
    end
end

function DamageTextManager.draw()
    for _, t in ipairs(DamageTextManager.texts) do
        t:draw()
    end
end

return DamageTextManager
