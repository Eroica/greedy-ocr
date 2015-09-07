--[[
    greedy-ocr
    Original Work Copyright (c) 2015 Sebastian Spaar
------------------------------------------------------------------------
    engines.lua

]]

GreedyEngine = class("GreedyEngine", Engine)
function GreedyEngine:__init()
    self.testi = 123

    self:addInitializer("isPrototype", function (entity)
        print("Prototype `" .. entity:get("String").string .. "' was created.")
    end)
end