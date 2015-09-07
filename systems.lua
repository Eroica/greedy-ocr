LineDrawSystem = class("LineDrawSystem", System)
function LineDrawSystem:draw()
    for i, v in pairs(self.targets) do
        love.graphics.draw(v:get("Image").image, v:get("Position").l, v:get("Position").t)
    end
end

function LineDrawSystem:requires()
    return {"isLine"}
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