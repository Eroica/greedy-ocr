local Page = {}

local config = require "_config"

Page.DrawPage = tiny.processingSystem({isDrawSystem = true})
function Page.DrawPage:process (entity, dt)
    CAMERA:draw(function(l, t, w, h)
        love.graphics.draw(entity.image, entity.position.l, entity.position.t)
    end)
end

function Page.DrawPage:filter (entity)
    return entity.isPage ~= nil
end


local HUD_HEIGHT     = 44
local HUD_PADDING    = 4
local HUD_COLOR      = {unpack(config.HUD_COLOR)}
local HUD_LINE_COLOR = {unpack(config.HUD_LINE_COLOR)}

Page.DrawHUD = tiny.system({isDrawSystem = true})
function Page.DrawHUD:update (dt)
    local width, height = love.graphics.getDimensions()
    local x, y = CAMERA:toWorld(love.mouse.getPosition())

    love.graphics.setColor(unpack(config.HUD_COLOR))
    love.graphics.rectangle("fill", 0, height - HUD_HEIGHT, width, height)
    love.graphics.setColor(unpack(config.HUD_LINE_COLOR))
    love.graphics.line(0, height - HUD_HEIGHT - 1, width, height - HUD_HEIGHT - 1)

    love.graphics.setColor(255, 255, 255)
    do love.graphics.push()
        love.graphics.translate(HUD_PADDING, height - HUD_HEIGHT + HUD_PADDING)

        for _, e in pairs(self.entities) do
            local pos  = e.position
            local l, t = pos.l, pos.t
            local size = e.size
            if  x >= l and x < l + size.width
            and y >= t and y < t + size.height then
                love.graphics.print(   "Coordinates: " .. tostring(x - l)
                                    .. "|"             .. tostring(y - t)
                                    .. " Segment: "    .. tostring(_)
                                    .. ", String: "    .. tostring(e), 0, 0)
            end
        end

        local prots_strings = {}
        for i=1, #PROTOTYPES.entities do
            table.insert(prots_strings, PROTOTYPES.entities[i].string)
        end

        love.graphics.print(   "Prototypes (" .. #PROTOTYPES.entities .. "): "
                            .. table.concat(prots_strings, ", "), 0, 20)

        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()),
                            width - 55, 20)

        love.graphics.printf(   "World Coordinates: " .. tostring(x) .. "|"
                             .. tostring(y), width - 208, 0, 200, "right")

    end love.graphics.pop()
    love.graphics.setColor(255, 255, 255)
end

function Page.DrawHUD:filter (entity)
    return entity.isSegment ~= nil
end


local BUTTON_HEIGHT = 24
local BUTTON_1 = {
    width  = 72,
    height = BUTTON_HEIGHT,
    text   = "Export (E)"
}

local BUTTON_2 = {
    width  = 160,
    height = BUTTON_HEIGHT,
    text   = "Show all Prototypes (P)"
}

local BUTTON_3 = {
    width  = 176,
    height = BUTTON_HEIGHT,
    text   = "Recognize all Segments (S)"
}

Page.DrawButtons = tiny.system({isDrawSystem = true})
function Page.DrawButtons:update (dt)
    local width, height = love.graphics.getDimensions()

    do love.graphics.push()
        love.graphics.translate(0, height - BUTTON_HEIGHT - HUD_HEIGHT - HUD_PADDING - 2)

        -- Button 1 ("Export")
        love.graphics.setColor(unpack(config.HUD_LINE_COLOR))
        love.graphics.rectangle("line", width - BUTTON_1.width - HUD_PADDING - 1, 0, BUTTON_1.width + 2, BUTTON_HEIGHT + 2)

        love.graphics.setColor(unpack(config.HUD_COLOR))
        love.graphics.rectangle("fill", width - BUTTON_1.width - HUD_PADDING, 1, BUTTON_1.width, BUTTON_HEIGHT)

        love.graphics.setColor(255, 255, 255)
        do love.graphics.push()
            love.graphics.translate(width - BUTTON_1.width - HUD_PADDING, 1 + HUD_PADDING)
            love.graphics.printf(BUTTON_1.text, 0, 0, BUTTON_1.width, "center")
        end love.graphics.pop()


        -- Button 2
        love.graphics.setColor(unpack(config.HUD_LINE_COLOR))
        love.graphics.rectangle("line", width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3 - 1, 0, BUTTON_2.width + 2, BUTTON_HEIGHT + 2)

        love.graphics.setColor(unpack(config.HUD_COLOR))
        love.graphics.rectangle("fill", width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3, 1, BUTTON_2.width, BUTTON_HEIGHT)

        love.graphics.setColor(255, 255, 255)
        do love.graphics.push()
            love.graphics.translate(width - BUTTON_1.width - BUTTON_2.width - HUD_PADDING * 3, 1 + HUD_PADDING)
            love.graphics.printf(BUTTON_2.text, 0, 0, BUTTON_2.width, "center")
        end love.graphics.pop()


        -- Button 3
        love.graphics.setColor(unpack(config.HUD_LINE_COLOR))
        love.graphics.rectangle("line", width - BUTTON_1.width - BUTTON_2.width - BUTTON_3.width - HUD_PADDING * 5 - 1, 0, BUTTON_3.width + 2, BUTTON_HEIGHT + 2)

        love.graphics.setColor(unpack(config.HUD_COLOR))
        love.graphics.rectangle("fill", width - BUTTON_1.width - BUTTON_2.width - BUTTON_3.width - HUD_PADDING * 5, 1, BUTTON_3.width, BUTTON_HEIGHT)

        love.graphics.setColor(255, 255, 255)
        do love.graphics.push()
            love.graphics.translate(width - BUTTON_1.width - BUTTON_2.width - BUTTON_3.width - HUD_PADDING * 5, 1 + HUD_PADDING)
            love.graphics.printf(BUTTON_3.text, 0, 0, BUTTON_3.width, "center")
        end love.graphics.pop()

    end love.graphics.pop()
    love.graphics.setColor(255, 255, 255)
end


Page.CreateRectangles = tiny.system({isDrawSystem = true, l = 0, t = 0})
function Page.CreateRectangles:update (dt)
    if not love.keyboard.isDown(" ") then
        self.dx, self.dy = love.mouse.getPosition()

        love.graphics.setColor(0, 0, 255)
        love.graphics.push()
            love.graphics.translate(self.l, self.t)
            love.graphics.rectangle("line", 0, 0, self. dx - self.l, self.dy - self.t)
        love.graphics.pop()
        love.graphics.setColor(255, 255, 255)
    end
end

function Page.CreateRectangles:onAddToWorld (world)
    self.l, self.t = love.mouse.getPosition()
end

function Page.CreateRectangles:onRemoveFromWorld (world)

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


return Page