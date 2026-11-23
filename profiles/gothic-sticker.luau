--!nonstrict
-- gothic-sticker — sticker com moldura gótica NATIVA (desenhada pelo plugin).
-- Mesmo princípio do fastfetch: borda externa na ui.column, borda interna
-- no ui.image, com um pequeno "matte" entre elas. Sem PNG sobreposto.
-- image_width/image_height acompanham o box do widget (mantidos pelo
-- noctalia-widget-frames), então tudo escala junto.

local OUTER_COLOR = "#6b0f2a"  -- vinho escuro gótico
local INNER_COLOR = "#8a1230"  -- vermelho escuro
local OUTER_W = 3
local INNER_W = 2
local MATTE = 4

local function render()
    local path = noctalia.getConfig("image_path") or ""
    local iw = tonumber(noctalia.getConfig("image_width")) or 320
    local ih = tonumber(noctalia.getConfig("image_height")) or 320

    local image = path ~= "" and ui.image({
        path = path,
        width = iw - 2 * (OUTER_W + MATTE),
        height = ih - 2 * (OUTER_W + MATTE),
        fit = "stretch",
        radius = 0,
        border = INNER_COLOR,
        borderWidth = INNER_W,
    }) or ui.glyph({ name = "photo", size = 32, color = "on_surface_variant" })

    desktopWidget.render(ui.column({
        fill = "#0c0c10",
        border = OUTER_COLOR,
        borderWidth = OUTER_W,
        radius = 0,
        padding = MATTE,
        align = "center",
        justify = "center",
    }, { image }))
end

function update()
    render()
end

update()
