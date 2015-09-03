function isLine()
    return {}
end

function isSegment()
    return {}
end

function isComponent()
    return {}
end

function isPrototype()
    return {}
end

function Position(l, t)
    return {
        l = l,
        t = t
    }
end

function Size(width, height)
    return {
        width = width,
        height = height
    }
end

function Image(image)
    local image_bw = love.image.newImageData(image:getWidth(), image:getHeight())
    image_bw:paste(image:getData(), 0, 0, 0, 0, image:getWidth(), image:getHeight())
    image_bw:mapPixel(threshold())

    return {
        image = image,
        image_bw = love.graphics.newImage(image_bw)
    }
end

function Range(s, e)
    return {
        s = s,
        e = e
    }
end

function String(literal)
    return {
        string = literal or ".*"
    }
end