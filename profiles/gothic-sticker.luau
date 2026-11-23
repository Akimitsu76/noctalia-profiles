--!nonstrict
-- gothic-sticker — sticker com moldura gótica NATIVA (desenhada pelo plugin).
-- Mesmo padrão do fastfetch: duas ui.column aninhadas com border/borderWidth.
-- A borda faz parte do widget: escala junto, sem camada PNG extra.

local OUTER_COLOR = "#6b0f2a"  -- vinho escuro gótico
local INNER_COLOR = "#8a1230"  -- vermelho escuro
local OUTER_W = 3
local INNER_W = 2

local function frame(node)
    return ui.column({
        gap = 0,
        padding = 1,
        radius = 0,
        fill = "#0c0c10",
        border = OUTER_COLOR,
        borderWidth = OUTER_W,
        align = "center",
        justify = "center",
        clip = true,
    }, {
        ui.column({
            gap = 0,
            padding = 0,
            radius = 0,
            fill = "#0c0c10",
            border = INNER_COLOR,
            borderWidth = INNER_W,
            align = "center",
            justify = "center",
            flexGrow = 1,
            clip = true,
        }, { node }),
    })
end

local function render()
    local path = noctalia.getConfig("image_path") or ""

    if path == "" then
        desktopWidget.render(frame(
            ui.glyph({ name = "photo", size = 32, color = "on_surface_variant" })
        ))
        return
    end

    desktopWidget.render(frame(
        ui.image({
            path = path,
            fit = "stretch",
            radius = 0,
            flexGrow = 1,
        })
    ))
end

function update()
    render()
end

update()
