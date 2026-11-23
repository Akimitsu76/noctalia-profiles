--!nonstrict
-- victor/profiles — painel gótico de gerenciamento de perfis do Noctalia.
--
-- Salva e aplica perfis completos (config, widgets, layout, frames, fontes,
-- cores, wallpaper e plugins) via `noctalia-profile`.
--
-- Abrir: noctalia msg panel-toggle victor/profiles:profiles

local HOME = noctalia.getenv("HOME") or ""
local configuredDir = noctalia.getConfig("profiles_dir")
local PROFILES_DIR = (type(configuredDir) == "string" and configuredDir ~= "")
    and noctalia.expandPath(configuredDir)
    or noctalia.expandPath("~/.local/state/noctalia/profiles")
local CMD = "noctalia-profile"

local profiles = {}
local selected = nil
local nameInput = ""
local status = "Pronto. Selecione um perfil ou salve a config atual."
local statusKind = "info" -- info | ok | err
local pendingDelete = nil
local busy = false

local function setStatus(msg, kind)
    status = msg or ""
    statusKind = kind or "info"
end

local function metaLine(p)
    local when = p.saved_at or "?"
    when = when:gsub("T", " "):sub(1, 16)
    local host = p.hostname or "?"
    local nwall = 0
    if type(p.wallpapers) == "table" then
        for _ in pairs(p.wallpapers) do nwall = nwall + 1 end
    end
    return when .. "  ·  " .. host .. "  ·  " .. nwall .. " wallpaper(s)"
end

local function refreshProfiles()
    profiles = {}
    local names = noctalia.listDir(PROFILES_DIR)
    if names ~= nil then
        for _, n in ipairs(names) do
            if n:sub(1, 1) ~= "." then
                local meta = { name = n }
                local mf = PROFILES_DIR .. "/" .. n .. "/manifest.json"
                if noctalia.fileExists(mf) then
                    local ok, raw = pcall(noctalia.readFile, mf)
                    if ok and raw then
                        local ok2, decoded = pcall(noctalia.json.decode, raw)
                        if ok2 and type(decoded) == "table" then
                            for k, v in pairs(decoded) do meta[k] = v end
                            meta.name = n
                        end
                    end
                end
                table.insert(profiles, meta)
            end
        end
    end
    table.sort(profiles, function(a, b)
        return tostring(a.saved_at or "") > tostring(b.saved_at or "")
    end)
end

local function runProfile(args, onDone)
    busy = true
    setStatus("Executando…", "info")
    render()
    noctalia.runAsync({ CMD, table.unpack(args) }, function(r)
        busy = false
        local out = ""
        if type(r) == "table" then
            out = (r.stdout or "")
            if r.stderr and r.stderr ~= "" then out = out .. " " .. r.stderr end
        elseif type(r) == "string" then
            out = r
        end
        refreshProfiles()
        if onDone then onDone(out) end
        render()
    end)
end

local function divider()
    return ui.column({ height = 1, fill = "outline_variant", radius = 0 })
end

local function glyphFor(p)
    if selected == p.name then return "check" end
    return "window"
end

local function profileRow(p)
    local isSel = (selected == p.name)
    local children = {
        ui.glyph({ name = glyphFor(p), size = 16, color = isSel and "primary" or "on_surface_variant" }),
        ui.column({ flexGrow = 1, gap = 2, align = "stretch" }, {
            ui.label({
                text = p.name,
                fontSize = 14,
                fontWeight = "bold",
                color = isSel and "primary" or "on_surface",
                maxLines = 1,
            }),
            ui.label({
                text = metaLine(p),
                fontSize = 10,
                color = "on_surface_variant",
                maxLines = 1,
            }),
        }),
    }
    if pendingDelete == p.name then
        table.insert(children, ui.button({
            glyph = "check",
            variant = "primary",
            onClick = function()
                pendingDelete = nil
                runProfile({ "delete", p.name }, function(out)
                    setStatus("Perfil '" .. p.name .. "' removido.", "ok")
                    if selected == p.name then selected = nil end
                end)
            end,
        }))
        table.insert(children, ui.button({
            glyph = "close",
            variant = "ghost",
            onClick = function() pendingDelete = nil; render() end,
        }))
    else
        table.insert(children, ui.button({
            glyph = "trash",
            variant = "ghost",
            onClick = function()
                pendingDelete = p.name
                setStatus("Confirmar exclusão de '" .. p.name .. "'?", "err")
                render()
            end,
        }))
    end
    return ui.row({
        key = "profile-" .. p.name .. (isSel and "-sel" or "-idle") .. (pendingDelete == p.name and "-del" or ""),
        gap = 10,
        align = "center",
        padding = 10,
        paddingH = 12,
        fill = isSel and "primary/0.14" or "surface",
        border = isSel and "primary" or "outline_variant",
        borderWidth = 1,
        radius = 2,
        onClick = function()
            selected = p.name
            pendingDelete = nil
            setStatus("Perfil selecionado: " .. p.name, "info")
            render()
        end,
    }, children)
end

local function buildList()
    local rows = {}
    if #profiles == 0 then
        table.insert(rows, ui.column({ gap = 6, align = "center", padding = 18 }, {
            ui.glyph({ name = "moon", size = 26, color = "on_surface_variant" }),
            ui.label({ text = "Nenhum perfil ainda", color = "on_surface_variant", fontSize = 13 }),
            ui.label({ text = "Salve a config atual abaixo.", color = "on_surface_variant", fontSize = 11 }),
        }))
    else
        for _, p in ipairs(profiles) do
            table.insert(rows, profileRow(p))
        end
    end
    return ui.scroll({ flexGrow = 1, gap = 8, align = "stretch" }, rows)
end

local function statusColor()
    if statusKind == "ok" then return "primary" end
    if statusKind == "err" then return "error" end
    return "on_surface_variant"
end

function render()
    local header = ui.row({ align = "center", gap = 10, justify = "space_between" }, {
        ui.glyph({ name = "moon", size = 22, color = "primary" }),
        ui.column({ flexGrow = 1, gap = 0, align = "stretch" }, {
            ui.label({ text = "PROFILES", fontSize = 19, fontWeight = "bold", color = "primary" }),
            ui.label({ text = "GRIMÓRIO DO NOCTALIA", fontSize = 9, color = "on_surface_variant" }),
        }),
        ui.button({ glyph = "refresh", variant = "ghost", onClick = function()
            refreshProfiles(); setStatus("Lista atualizada.", "ok"); render()
        end }),
        ui.button({ glyph = "close", variant = "ghost", onClick = function() panel.close() end }),
    })

    local actions = ui.row({ gap = 8, align = "stretch" }, {
        ui.button({
            text = busy and "…" or "SALVAR ATUAL",
            glyph = "save",
            variant = "primary",
            onClick = function()
                if busy then return end
                local n = nameInput:gsub("^%s+", ""):gsub("%s+$", "")
                if n == "" then
                    setStatus("Digite um nome para o perfil.", "err"); render(); return
                end
                runProfile({ "save", n }, function(out)
                    setStatus("Perfil '" .. n .. "' salvo.", "ok")
                    selected = n
                end)
            end,
        }),
        ui.button({
            text = busy and "…" or "APLICAR",
            glyph = "restore",
            variant = "primary",
            onClick = function()
                if busy then return end
                if not selected then
                    setStatus("Selecione um perfil na lista.", "err"); render(); return
                end
                local target = selected
                runProfile({ "apply", target }, function(out)
                    setStatus("Perfil '" .. target .. "' aplicado.", "ok")
                end)
            end,
        }),
    })

    local nameField = ui.input({
        key = "profile-name",
        placeholder = "nome do novo perfil…",
        onChange = function(v) nameInput = v or "" end,
        onSubmit = function(v)
            nameInput = v or nameInput
            if nameInput ~= "" and not busy then
                runProfile({ "save", nameInput }, function()
                    setStatus("Perfil '" .. nameInput .. "' salvo.", "ok")
                    selected = nameInput
                end)
            end
        end,
    })

    panel.render(ui.column({ flexGrow = 1, gap = 12, align = "stretch" }, {
        header,
        divider(),
        ui.label({ text = "PERFIS SALVOS", fontSize = 10, fontWeight = "medium", color = "on_surface_variant" }),
        buildList(),
        divider(),
        ui.label({ text = "SALVAR CONFIGURAÇÃO ATUAL", fontSize = 10, fontWeight = "medium", color = "on_surface_variant" }),
        nameField,
        actions,
        ui.label({ text = status, fontSize = 11, color = statusColor(), maxLines = 2 }),
    }))
end

function onOpen(_context)
    pendingDelete = nil
    refreshProfiles()
    if selected == nil and #profiles > 0 then
        selected = profiles[1].name
    end
    setStatus("Pronto.", "info")
    render()
end
