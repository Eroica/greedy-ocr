--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    systems.lua

]]

LineDrawSystem = class("LineDrawSystem", System)
function LineDrawSystem:draw()
    for i, v in pairs(self.targets) do
        love.graphics.draw(v:get("Image").image, v:get("Position").l, v:get("Position").t)
    end
end

function LineDrawSystem:requires()
    return {"isLine"}
end


SegmentStringDrawSystem = class("SegmentStringDrawSystem", System)
function SegmentStringDrawSystem:draw()
    for i, v in pairs(self.targets) do
        local position = v:get("Position")
        local size = v:get("Size")

        love.graphics.setColor(0, 0, 0)
        love.graphics.print(v:tostring(), position.l , math.floor(position.t + size.height))
        love.graphics.setColor(255, 255, 255)
    end
end

function SegmentStringDrawSystem:requires()
    return {"isSegment"}
end


SegmentDrawSystem = class("SegmentDrawSystem", System)
function SegmentDrawSystem:draw()
    for i, v in pairs(self.targets) do
        local position = v:get("Position")
        local size = v:get("Size")

        love.graphics.setColor(255, 0, 255)
        love.graphics.rectangle("line", position.l, position.t, size.width, size.height)
        -- love.graphics.line(position.l, 0, position.l + size.width, 0)
        -- love.graphics.line(position.l + size.width, 0, position.l + size.width, size.height)
        -- love.graphics.line(position.l, size.height, position.l + size.width, size.height)
        -- love.graphics.line(position.l, 0, position.l, size.height)
        love.graphics.setColor(255, 255, 255)
    end
end

function SegmentDrawSystem:requires()
    return {"isSegment"}
end


ComponentsDrawSystem = class("ComponentsDrawSystem", System)
function ComponentsDrawSystem:draw()
    love.graphics.setColor(0, 255, 0)
    for i, v in pairs(self.targets) do
        local parent_position = v:getParent():get("Position")
        local parent_size = v:getParent():get("Size")
        local range = v:get("Range")

        love.graphics.push()
            love.graphics.translate(parent_position.l, parent_position.t)
            love.graphics.line(range.s, 0, range.s, parent_size.height)
            love.graphics.line(range.e, 0, range.e, parent_size.height)
        love.graphics.pop()
    end
    love.graphics.setColor(255, 255, 255)
end

function ComponentsDrawSystem:requires()
    return {"isComponent"}
end



SegmentRecognitionSystem = class("SegmentRecognitionSystem", System)
function SegmentRecognitionSystem:update (dt)
    for i, segment in pairs(self.targets) do
        local match = lexicon:lookup(segment:tostring())

        if #match == 1 then
            if config.DEBUG then
                print("Segment `" .. segment:tostring() .. "' succesfully recognized as `" .. match[1] .."'.")
            end

            local match_copy = match[1]

            local recognized_components = {}
            for j, component in pairs(segment._components) do
                local comp_string = component:get("String").string
                if comp_string ~= ".*" then
                    table.insert(recognized_components, comp_string)
                end
            end

            table.sort(recognized_components, function (a, b) return #a > #b end)

            for j=1, #recognized_components do
                match_copy = string.gsub(match_copy, recognized_components[j], "#")
            end

            local match_substring = explode("#", match_copy)
            local match_table = {}
            for j=1, #match_substring do
                if match_substring[j] ~= "" then
                    table.insert(match_table, match_substring[j])
                end
            end

            local match_components = {}
            for j=1, #segment._components do
                if segment._components[j]:get("String").string == ".*" then
                    table.insert(match_components, segment._components[j])
                end
            end

            assert(#match_table == #match_components)

            for j=1, #match_table do
                match_components[j]:get("String").string = match_table[j]
            end

            for j=1, #match_components do
                local comp = match_components[j]
                if engine:checkIfPrototypeExists(comp:get("String").string) == false then
                    local literal = comp:get("String").string
                    local image = comp:get("Image").image
                    local prot = entities.Prototype(literal, image)
                end
            end

            segment:remove("isNotRecognized")
        end
    end
end

function SegmentRecognitionSystem:requires ()
    return {"isSegment", "isNotRecognized"}
end


PrototypeDrawSystem = class("PrototypeDrawSystem", System)
function PrototypeDrawSystem:draw ()

    local width, height = love.graphics.getDimensions()
    local padding = 4
    local next_x = padding
    local next_y = padding

    love.graphics.setColor(0, 0, 0, 191)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(255, 255, 255)

    for i, prototype in pairs(self.targets) do

        local image = prototype:get("Image").image

        if image:getWidth() + padding > width then
            next_x = padding
            next_y = next_y + padding + 100
        end

        love.graphics.draw(image, next_x, next_y)

        next_x = next_x + image:getWidth() + padding
    end
end

function PrototypeDrawSystem:requires ()
    return {"isPrototype"}
end



local HUD_HEIGHT = 44
local HUD_PADDING = 4
local HUD_COLOR = {32, 40, 63}
local HUD_LINE_COLOR = {56, 61, 81}
-- local HUD_COLOR = {73, 93, 127}
-- local HUD_LINE_COLOR = {125, 143, 165}

HUDDrawSystem = class("HUDDrawSystem", System)
function HUDDrawSystem:draw()
    local width, height = love.graphics.getDimensions()
    local x, y = love.mouse.getPosition()

    love.graphics.setColor(unpack(HUD_COLOR))
    love.graphics.rectangle("fill", 0, height - HUD_HEIGHT, width, height)
    love.graphics.setColor(unpack(HUD_LINE_COLOR))
    love.graphics.line(0, height - HUD_HEIGHT - 1, width, height - HUD_HEIGHT - 1)

    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
        love.graphics.translate(HUD_PADDING, height - HUD_HEIGHT + HUD_PADDING)

        for _, seg in pairs(engine:getEntitiesWithComponent("isSegment")) do
            local pos = seg:get("Position")
            local size = seg:get("Size")
            if x >= pos.l and x < pos.l + size.width and y >= pos.t and y < pos.t + size.height then
                love.graphics.print("Segment Coordinates: " .. tostring(x - pos.l) .. "|" .. tostring(y - pos.t), 0, 0)
            end
        end
        love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), width - 55, 0)

        local prots = engine._prototypes
        local prots_strings = {}
        for i=1, #prots do
            table.insert(prots_strings, prots[i]:get("String").string)
        end

        love.graphics.print("Prototypes (" .. #engine._prototypes .. "): "
                            .. table.concat(prots_strings, ", "), 0, 20)
    love.graphics.pop()
end

function HUDDrawSystem:requires()
    return {}
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

ButtonDrawSystem = class("ButtonDrawSystem", System)
function ButtonDrawSystem:draw()
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

function ButtonDrawSystem:requires()
    return {}
end