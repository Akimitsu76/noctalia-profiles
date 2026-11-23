--!nonstrict
-- gothic-label — label com moldura gótica NATIVA (desenhada pelo plugin).
-- Mesmo padrão do fastfetch/gothic-sticker: borda externa na ui.column,
-- borda interna na ui.row que envolve o texto. Sem PNG sobreposto.

local OUTER_COLOR = "#6b0f2a"  -- vinho escuro gótico
local INNER_COLOR = "#8a1230"  -- vermelho escuro
local OUTER_W = 3
local INNER_W = 2
local MATTE = 4

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
        border = OUTER_COLOR,
        borderWidth = OUTER_W,
        radius = 0,
        padding = MATTE,
        align = "center",
        justify = "center",
    }, {
        ui.row({
            fill = "#0c0c10",
            border = INNER_COLOR,
            borderWidth = INNER_W,
            radius = 0,
            padding = 6,
            align = "center",
            justify = "center",
            flexGrow = 1,
        }, { content }),
    }))
end

function update()
    render()
end

update()
