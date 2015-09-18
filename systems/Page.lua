local Page = {}


Page.DrawPage = tiny.processingSystem({isDrawSystem = true})
function Page.DrawPage:process (entity, dt)
    CAMERA:draw(function(l, t, w, h)
        love.graphics.draw(entity.image, entity.position.l, entity.position.t)
    end)
end

function Page.DrawPage:filter (entity)
    return entity.isPage ~= nil
end



local HUD_HEIGHT = 44
local HUD_PADDING = 4
local HUD_COLOR = {32, 40, 63}
local HUD_LINE_COLOR = {56, 61, 81}
-- local HUD_COLOR = {73, 93, 127}
-- local HUD_LINE_COLOR = {125, 143, 165}


Page.DrawHUD = tiny.system({isDrawSystem = true})
function Page.DrawHUD:update (dt)
    local width, height = love.graphics.getDimensions()
    --local l, t, width, height = CAMERA:getVisible()
    local x, y = CAMERA:toWorld(love.mouse.getPosition())

    love.graphics.setColor(unpack(HUD_COLOR))
    love.graphics.rectangle("fill", 0, height - HUD_HEIGHT, width, height)
    love.graphics.setColor(unpack(HUD_LINE_COLOR))
    love.graphics.line(0, height - HUD_HEIGHT - 1, width, height - HUD_HEIGHT - 1)

    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
        love.graphics.translate(HUD_PADDING, height - HUD_HEIGHT + HUD_PADDING)

        for _, e in pairs(self.entities) do
            local pos = e.position
            local l, t = pos.l, pos.t
            local size = e.size
            if  x >= l and x < l + size.width
            and y >= t and y < t + size.height then
                love.graphics.print("Segment " .. tostring(_) .. " Coordinates: " .. tostring(x - l) .. "|" .. tostring(y - t), 0, 0)
            end
        end
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), width - 55, 0)


        love.graphics.print("World Coordinates: " .. tostring(x) .. "|" .. tostring(y), width - 200, 20)

        -- local prots = engine._prototypes
        -- local prots_strings = {}
        -- for i=1, #prots do
        --     table.insert(prots_strings, prots[i]:get("String").string)
        -- end

        -- love.graphics.print("Prototypes (" .. #engine._prototypes .. "): "
        --                     .. table.concat(prots_strings, ", "), 0, 20)
    love.graphics.pop()
end

function Page.DrawHUD:filter (entity)
    return entity.isSegment ~= nil
end


local BUTTON_HEIGHT = 24
local BUTTON_1 = {
    width = 48,
    height = BUTTON_HEIGHT,
    text = "Export"
}

local BUTTON_2 = {
    width = 148,
    height = BUTTON_HEIGHT,
    text = "Show all Prototypes"
}

Page.DrawButtons = tiny.system({isDrawSystem = true})
function Page.DrawButtons:update (dt)
    local width, height = love.graphics.getDimensions()

    love.graphics.push()
        love.graphics.translate(0, height - BUTTON_HEIGHT - HUD_HEIGHT - HUD_PADDING - 2)

        -- Button 1 ("Export")
        love.graphics.setColor(unpack(HUD_LINE_COLOR))
        love.graphics.rectangle("line", width - BUTTON_1.width - HUD_PADDING - 1, 0, BUTTON_1.width + 2, BUTTON_HEIGHT + 2)

        love.graphics.setColor(unpack(HUD_COLOR))
        love.graphics.rectangle("fill", width - BUTTON_1.width - HUD_PADDING, 1, BUTTON_1.width, BUTTON_HEIGHT)

        love.graphics.setColor(255, 255, 255)
        love.graphics.push()
            love.graphics.translate(width - BUTTON_1.width - HUD_PADDING, 1 + HUD_PADDING)
            love.graphics.printf(BUTTON_1.text, 0, 0, BUTTON_1.width, "center")
        love.graphics.pop()


        -- Button 2
        love.graphics.setColor(unpack(HUD_LINE_COLOR))
        love.graphics.rectangle("line", width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3 - 1, 0, BUTTON_2.width + 2, BUTTON_HEIGHT + 2)

        love.graphics.setColor(unpack(HUD_COLOR))
        love.graphics.rectangle("fill", width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3, 1, BUTTON_2.width, BUTTON_HEIGHT)

        love.graphics.setColor(255, 255, 255)
        love.graphics.push()
            love.graphics.translate(width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3, 1 + HUD_PADDING)
            love.graphics.printf(BUTTON_2.text, 0, 0, BUTTON_2.width, "center")
        love.graphics.pop()

    love.graphics.pop()
end

-- function DrawButtons:requires()
--     return {}
-- end




Page.CreateRectangles = tiny.system({isDrawSystem = true, l = 0, t = 0})
function Page.CreateRectangles:update (dt)
    local x, y = love.mouse.getPosition()


    love.graphics.setColor(0, 0, 255)
    love.graphics.push()
        love.graphics.translate(self.l, self.t)
        love.graphics.rectangle("line", 0, 0, x-self.l, y-self.t)
    love.graphics.pop()
    love.graphics.setColor(255, 255, 255)
end








Page.CameraPosition = tiny.system({isUpdateSystem = true})
function Page.CameraPosition:onAddToWorld (world)
    self.x, self.y = love.mouse.getPosition()
    self.l, self.t = CAMERA.x, CAMERA.y
end

function Page.CameraPosition:update (dt)
    if love.keyboard.isDown(" ") then
        local current_x, current_y = love.mouse.getPosition()
        local dx, dy = current_x - self.x, current_y - self.y

        CAMERA:setPosition(self.l - dx, self.t - dy)
    end
end

-- function Page.CameraPosition:onRemoveFromWorld (world)
--     CAMERA:setCamera(self.new_x, self.new_y)
-- end

function Page.CameraPosition:filter (entity)
    -- return entity.isCamera ~=nil
end


return Page