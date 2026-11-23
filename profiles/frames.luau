-- victor/profiles:frames — serviço automático de molduras góticas.
-- Aplica moldura gótico-dark a qualquer widget de desktop automaticamente.
-- Reage a onConfigChanged (widget adicionado/removido/redimensionado).
--
-- IPC: noctalia msg plugin victor/profiles:frames all "refresh"

local CMD = "noctalia-widget-frames"
local running = false
local lastRun = 0

local function log(m)
    if noctalia.log then noctalia.log("[frames] " .. tostring(m)) end
end

local function applyFrames(force)
    if running then return end
    running = true
    local args = {CMD}
    if force then table.insert(args, "--full") end
    noctalia.runAsync(args, function(r)
        running = false
        local out = ""
        if type(r) == "table" then
            out = (r.stdout or "")
            if r.stderr and r.stderr ~= "" then out = out .. " " .. r.stderr end
        elseif type(r) == "string" then
            out = r
        end
        if out:find("config atualizada") then
            log("molduras atualizadas")
            noctalia.runAsync({"noctalia", "msg", "config-reload"}, function() end)
        elseif out:find("nada a mudar") then
            -- silencioso: tudo correto
        else
            log(out)
        end
    end)
end

function onConfigChanged()
    -- debounce: evitar loop infinito (script escreve settings → onConfigChanged)
    local now = os.time()
    if now - lastRun < 3 then return end
    lastRun = now
    applyFrames(false)
end

function onIpc(event, _payload)
    if event == "refresh" or event == "full" then
        applyFrames(event == "full")
    end
end

log("serviço de molduras pronto")
