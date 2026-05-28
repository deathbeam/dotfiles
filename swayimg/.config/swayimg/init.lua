-- swayimg config: cursor pixel/tile coordinates on click
-- Place at ~/.config/swayimg/init.lua
-- Change TILE_W/TILE_H to match your tileset

local TILE_W = 16
local TILE_H = 16

-- Show pixel/tile coords under cursor on MouseLeft click
swayimg.viewer.on_mouse("MouseLeft", function()
    local mouse = swayimg.get_mouse_pos()
    local pos   = swayimg.viewer.get_position()
    local scale = swayimg.viewer.get_scale()
    local img   = swayimg.viewer.get_image()

    -- Window mouse coords -> image pixel coords
    local px = math.floor((mouse.x - pos.x) / scale)
    local py = math.floor((mouse.y - pos.y) / scale)

    if px < 0 or py < 0 or px >= img.width or py >= img.height then
        swayimg.text.set_status("Cursor: outside image")
        swayimg.text.show()
        return true
    end

    local tx = math.floor(px / TILE_W)
    local ty = math.floor(py / TILE_H)

    local status = string.format("Pixel: (%d, %d)  Tile: (%d, %d)  Size: %dx%d  Scale: %d%%",
        px, py, tx, ty, img.width, img.height, math.floor(scale * 100))
    swayimg.text.set_status(status)
    swayimg.text.show()

    return true -- pass through to default drag behavior
end)

-- Default text overlay (press 't' to toggle)
swayimg.viewer.set_text("topleft", {
    "{name}",
    "{frame.width}x{frame.height}",
    "Scale: {scale}%",
})
