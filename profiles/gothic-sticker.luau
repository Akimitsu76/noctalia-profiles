--!nonstrict
-- gothic-sticker — sticker com moldura gótica NATIVA (desenhada pelo plugin).
-- Substitui o antigo sticker + PNG sobreposto.
-- A borda faz parte do widget: escala junto, sem camada extra.

local OUTER_COLOR = "#6b0f2a"  -- vinho escuro gótico
local INNER_COLOR = "#8a1230"  -- vermelho escuro
local OUTER_W = 3
local INNER_W = 2
local PAD = 1

local function render()
    local path = noctalia.getConfig("image_path") or ""

    if path == "" then
        desktopWidget.render(ui.column({
            fill = "#0c0c10",
            border = OUTER_COLOR,
            borderWidth = OUTER_W,
            radius = 0,
            align = "center", justify = "center",
            padding = PAD,
            flexGrow = 1,
        }, {
            ui.glyph({ name = "photo", size = 32, color = "on_surface_variant" }),
        }))
        return
    end

    desktopWidget.render(
        ui.column({
            fill = "#0c0c10",
            border = OUTER_COLOR,
            borderWidth = OUTER_W,
            radius = 0,
            padding = PAD,
            flexGrow = 1,
            clip = true,
        }, {
            ui.image({
                path = path,
                fit = "stretch",
                border = INNER_COLOR,
                borderWidth = INNER_W,
                radius = 0,
                flexGrow = 1,
            }),
        })
    )
end

function update()
    render()
end

update()
