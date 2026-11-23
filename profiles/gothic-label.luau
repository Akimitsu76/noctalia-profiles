--!nonstrict
-- gothic-label — label com moldura gótica NATIVA (desenhada pelo plugin).
-- Borda única (sem linha interna duplicada), cantos quadrados.

local BORDER_COLOR = "#6b0f2a"  -- vinho escuro gótico
local BORDER_W = 2

local function render()
    local title = noctalia.getConfig("title") or ""
    local fontSize = tonumber(noctalia.getConfig("font_size")) or 26
    local fontWeight = noctalia.getConfig("font_weight") or "bold"

    local content = title ~= "" and ui.label({
        text = title,
        fontSize = fontSize,
        fontWeight = fontWeight,
        color = "on_surface",
        textAlign = "center",
    }) or ui.glyph({ name = "tag", size = 24, color = "on_surface_variant" })

    desktopWidget.render(ui.column({
        fill = "#0c0c10",
        border = BORDER_COLOR,
        borderWidth = BORDER_W,
        radius = 0,
        padding = 6,
        align = "center",
        justify = "center",
    }, { content }))
end

function update()
    render()
end

update()
