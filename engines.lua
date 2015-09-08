--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    engines.lua

]]

GreedyEngine = class("GreedyEngine", Engine)
function GreedyEngine:__init ()
    self._prototypes = {}
    self._segments = {}

    self:addInitializer("isPrototype", function (entity)
        if config.DEBUG then
            print("Prototype `" .. entity:get("String").string .. "' was created.")
        end

        table.insert(self._prototypes, entity)
    end)

    self:addInitializer("isSegment", function (entity)
        if config.DEBUG then
            --print("Segment `" .. entity:get("String").string .. "' was created.")
            print "Segment created"
        end

        table.insert(self._segments, entity)
    end)
end

function GreedyEngine:allPrototypes ()
    return self._prototypes
end

function GreedyEngine:checkIfPrototypeExists (literal)
    for _, p in pairs(self._prototypes) do
        if p:get("String").string == literal then
            print "you already exist"
            return true
        end
    end

    return false
end