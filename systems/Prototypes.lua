local Prototypes = {}

-- This system provides a wrapper for all existing prototypes by sorting
-- them according to their size (larger Prototypes come before smaller
-- ones).
Prototypes.sharedPrototypes = tiny.sortedSystem({isUpdateSystem = true})
function Prototypes.sharedPrototypes:onAddToWorld (world)
    -- Get the list of ranking according to `_config.lua'. This means
    -- that Prototypes that are to the beginning of this ranking are
    -- also placed at the beginning of `self.entities' (and then after
    -- their image size).
    self.prototype_ranking = config.prototype_ranking
    self._inverse_prototype_ranking = invert_table(self.prototype_ranking)

    self.clusters = {}
    self._clusters_images = {}
end

function Prototypes.sharedPrototypes:update (dt)
    -- local prototype_images = {}
    -- for i=1, #self.entities do
    --     prototype_images[#prototype_images + 1] = self.entities[i].image_bw
    -- end

    -- self.prototype_images = prototype_images
end

function Prototypes.sharedPrototypes:onAdd (entity)
    -- Create a new cluster if the Prototype's string is new
    if self.clusters[entity.string] == nil then
        self.clusters[entity.string] = {}
    end

    -- Add to existing cluster
    table.insert(self.clusters[entity.string], entity)

    -- (Re-)Generate the average cluster image
    if config.DEBUG then
        print("Updating cluster image for", entity.string)
    end
    local cluster_image = generate_prototype_image(self.clusters[entity.string])
    self._clusters_images[entity.string] = threshold_image(cluster_image)
end


function Prototypes.sharedPrototypes:uniquePrototypes ()
    local used_prototypes = {}

    return function ()
        local prototype
        for i=1, #self.entities do
            prototype = self.entities[i]
            if used_prototypes[prototype.string] == nil then
                used_prototypes[prototype.string] = true
                return prototype
            end
        end
        return nil
    end
end

-- function Prototypes.sharedPrototypes:onModify (dt)
--         local prototype_strings = {}
--     local prototype_order = {}
--     print("___________")

--     for i=1, #self.entities do
--         local prototype = self.entities[i]
--         print(prototype.string)
--         if prototype_strings[prototype.strings] == nil then
--             prototype_strings[prototype.string] = true
--             prototype_order[#prototype_order + 1] = prototype.string
--         end
--     end

--     -- print(inspect(prototype_strings))
--     -- print(inspect(prototype_order))

--     self.prototype_order = prototype_order
-- end
function Prototypes.sharedPrototypes:compare (e1, e2)
    local area_1 = e1.image:getWidth() * e1.image:getHeight()
    local area_2 = e2.image:getWidth() * e2.image:getHeight()

    if  self._inverse_prototype_ranking[e1.string] == nil
    and self._inverse_prototype_ranking[e2.string] == nil then
        return area_1 > area_2
    elseif not (self._inverse_prototype_ranking[e1.string] and self._inverse_prototype_ranking[e2.string]) then

        return (self._inverse_prototype_ranking[e1.string] or 2) < (self._inverse_prototype_ranking[e2.string] or 1)
    else
        return self._inverse_prototype_ranking[e1.string] < self._inverse_prototype_ranking[e2.string]
    end
end

function Prototypes.sharedPrototypes:filter (entity)
    return entity.isPrototype ~= nil
end


Prototypes.OverlayPrototypes = tiny.system({isDrawSystem = true, active = false})
function Prototypes.OverlayPrototypes:update (dt)
    local width, height = love.graphics.getDimensions()
    local padding = 4
    local next_x = padding
    local next_y = padding

    love.graphics.setColor(0, 0, 0, 191)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setColor(255, 255, 255)

    local image

    -- Display all Prototypes
    for i=1, #PROTOTYPES.entities do
        image = PROTOTYPES.entities[i].image

        love.graphics.draw(image, next_x, next_y)
        next_x = next_x + image:getWidth() + padding

        if  i ~= #PROTOTYPES.entities
        and next_x + padding + PROTOTYPES.entities[i+1].image:getWidth() > width then
            next_x = padding
            next_y = next_y + padding + 100
        end
    end

    -- Display all cluster images
    next_x = padding
    next_y = next_y + 100

    for prototype in PROTOTYPES:uniquePrototypes() do
        image = PROTOTYPES._clusters_images[prototype.string]

        love.graphics.draw(image, next_x, next_y)
        next_x = next_x + image:getWidth() + padding

        if  next_x + padding + 100 > width then
            next_x = padding
            next_y = next_y + padding + 100
        end
    end
end

function Prototypes.OverlayPrototypes:filter (entity)
end


return Prototypes