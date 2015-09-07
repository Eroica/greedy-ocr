function table.firstElement(list)
    for index, value in pairs(list) do
        return value
    end
end

Engine = class("Engine")

function Engine:__init() 
    self.entities = {}
    self.rootEntity = Entity()
    self.singleRequirements = {}
    self.allRequirements = {}
    self.entityLists = {}
    self.eventManager = EventManager()
    self.initializer = {}

    self.systems = {}
    self.systemRegistry= {}
    self.systems["all"] = {}
    self.systems["update"] = {}
    self.systems["draw"] = {}

    self.eventManager:addListener("ComponentRemoved", self, self.componentRemoved)
    self.eventManager:addListener("ComponentAdded", self, self.componentAdded)
end

function Engine:addEntity(entity)
    -- Setting engine eventManager as eventManager for entity
    entity.eventManager = self.eventManager
    -- Getting the next free ID or insert into table
    local newId = #self.entities + 1
    entity.id = newId
    self.entities[entity.id] = entity

    -- If a rootEntity entity is defined and the entity doesn't have a parent yet, the rootEntity entity becomes the entity's parent
    if entity.parent == nil then
        entity:setParent(self.rootEntity)
    end
    entity:registerAsChild()

    -- Calling initializer
    for component, func in pairs(self.initializer) do
        if entity:has(component) then
            func(entity)
        end
    end

    for index, component in pairs(entity.components) do
        -- Adding Entity to specific Entitylist
        if not self.entityLists[component.__name] then self.entityLists[component.__name] = {} end
        self.entityLists[component.__name][entity.id] = entity

        -- Adding Entity to System if all requirements are granted
        if self.singleRequirements[component.__name] then
            for index2, system in pairs(self.singleRequirements[component.__name]) do
                self:checkRequirements(entity, system)
            end
        end
    end
end 

function Engine:removeEntity(entity, removeChildren, newParent)
    -- Removing the Entity from all Systems and engine
    for _, component in pairs(entity.components) do
        if self.singleRequirements[component.__name] then
            for _, system in pairs(self.singleRequirements[component.__name]) do
                system:removeEntity(entity)
            end
        end
    end
    -- Deleting the Entity from the specific entity lists
    for index, component in pairs(entity.components) do
        self.entityLists[component.__name][entity.id] = nil
    end
    if self.entities[entity.id] then
        -- If removeChild is defined, all children become deleted recursively
        if removeChildren then
            for _, child in pairs(entity.children) do
                self:removeEntity(child, true)
            end
        else
            -- If a new Parent is defined, this Entity will be set as the new Parent
            for _, child in pairs(entity.children) do
                if newParent then
                    child:setParent(newParent)
                else
                    child:setParent(self.rootEntity)
                end
                -- Registering as child
                entity:registerAsChild()
            end
        end
        -- Removing Reference to entity from parent
        for index, child in pairs(entity.parent.children) do
            entity.parent.children[entity.id] = nil
        end
        -- Setting status of entity to dead. This is for other systems, which still got a hard reference on this
        self.entities[entity.id].alive = false
        -- Removing entity from engine
        self.entities[entity.id] = nil
    else
        print("Trying to remove non existent entity from engine.")
        print("Entity id: " .. entity.id)
        print("Entity's components:")
        for index, component in pairs(entity.components) do
            print(index)
        end
    end
end

function Engine:addSystem(system, typ)
    -- Adding System to engine system reference table
    if not (self.systemRegistry[system.__name]) then 
        self.systemRegistry[system.__name] = system
        table.insert(self.systems["all"], system)
        self:registerSystem(system)
    elseif not system.update and system.draw then
        if self.systemRegistry[system.__name] then
            print("Lovetoys: " .. system.__name .. " already exists. Aborting")
            return
        end
    end

    -- Adding System to draw or update table
    if system.draw and (not typ or typ == "draw") then
        for _, registeredSystem in pairs(self.systems["draw"]) do
            if registeredSystem.__name == system.__name then
                print("Lovetoys: " .. system.__name .. " already exists. Aborting")
                return
            end
        end
        table.insert(self.systems["draw"], system)
    end
    if system.update and (not typ or typ == "update") then
        for _, registeredSystem in pairs(self.systems["update"]) do
            if registeredSystem.__name == system.__name then
                print("Lovetoys: " .. system.__name .. " already exists. Aborting")
                return
            end
        end
        table.insert(self.systems["update"], system)
    end

    -- Checks if some of the already existing entities match the required components.
    for index, entity in pairs(self.entities) do
        self:checkRequirements(entity, system)
    end
    return system
end

function Engine:registerSystem(system)
    -- Registering in case system:requires returns a table of strings
    if system:requires()[1] and type(system:requires()[1]) == "string" then
        for index, req in pairs(system:requires()) do
            -- Registering at singleRequirements
            if index == 1 then
                self.singleRequirements[req] = self.singleRequirements[req] or {}
                table.insert(self.singleRequirements[req], system)
            end
            -- Registering at allRequirements
            self.allRequirements[req] = self.allRequirements[req] or {}
            table.insert(self.allRequirements[req], system)
        end
    end

    -- Registering in case its a table of tables which contain strings
    if table.firstElement(system:requires()) and type(table.firstElement(system:requires())) == "table" then
        for index, componentList in pairs(system:requires()) do
            -- Registering at singleRequirements
            local component = componentList[1]
            self.singleRequirements[component] = self.singleRequirements[component] or {}
            table.insert(self.singleRequirements[component], system)

            -- Registering at allRequirements
            for _, req in pairs(componentList) do
                self.allRequirements[req] = self.allRequirements[req] or {}
                -- Check if this List already contains the System
                local contained = false
                for _, registeredSystem in pairs(self.allRequirements[req]) do
                    if registeredSystem == system then
                        contained = true
                        break
                    end
                end
                if not contained then
                    table.insert(self.allRequirements[req], system)
                end
            end
            system.targets[index] = {}
        end
    end
end

function Engine:stopSystem(name)
    for index, system in pairs(self.systems["all"]) do
        if name == system.__name then
            system.active = false
        end
    end
end

function Engine:startSystem(name)
    for index, system in pairs(self.systems["all"]) do
        if name == system.__name then
            system.active = true
        end
    end
end

function Engine:toggleSystem(name)
    for index, system in pairs(self.systems["all"]) do
        if name == system.__name then
            system.active = not system.active
        end
    end
end

function Engine:update(dt)
    for index, system in ipairs(self.systems["update"]) do
        if system.active then
            system:update(dt)
        end
    end
end

function Engine:addInitializer(name, func)
    self.initializer[name] = func
end

function Engine:removeInitializer(name)
    self.initializer[name] = nil
end

function Engine:draw()
    for index, system in ipairs(self.systems["draw"]) do
        if system.active then
            system:draw()
        end
    end
end

function Engine:componentRemoved(event)
    local entity = event.entity
    local component = event.component

    -- Removing Entity from Entitylists
    self.entityLists[component][entity.id] = nil

    -- Removing Entity from old systems
    if self.allRequirements[component] then
        for index, system in pairs(self.allRequirements[component]) do 
            system:removeEntity(entity, component)
        end
    end
end

function Engine:componentAdded(event)
    local entity = event.entity
    local component = event.component

    -- Adding the Entity to Entitylist
    if not self.entityLists[component] then self.entityLists[component] = {} end
    self.entityLists[component][entity.id] = entity

    -- Adding the Entity to the requiring systems
    if self.allRequirements[component] then
        for index, system in pairs(self.allRequirements[component]) do
            self:checkRequirements(entity, system)
        end
    end

    -- Calling Initializer
    if self.initializer[event.component] then
        self.initializer[event.component](event.entity)
    end
end

function Engine:getRootEntity()
    if self.rootEntity ~= nil then
        return self.rootEntity
    end
end

-- Returns an Entitylist for a specific component. If the Entitylist doesn't exist yet it'll be created and returned.
function Engine:getEntitiesWithComponent(component)
    if not self.entityLists[component] then self.entityLists[component] = {} end
    return self.entityLists[component]
end

function Engine:checkRequirements(entity, system)
    local meetsrequirements = true
    local category = nil
    for index, req in pairs(system:requires()) do
        if type(req) == "string" then
            if not entity.components[req] then
                meetsrequirements = false
                break
            end
        elseif type(req) == "table" then
            meetsrequirements = true
            for index2, req2 in pairs(req) do
                if not entity.components[req2] then
                    meetsrequirements = false
                    break
                end
            end
            if meetsrequirements == true then
                category = index 
                system:addEntity(entity, category)
            end
        end
    end
    if meetsrequirements == true and category == nil then
        system:addEntity(entity)
    end
end
