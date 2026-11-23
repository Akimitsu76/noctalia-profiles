-- victor/profiles service — salva/aplica perfis completos do Noctalia.
-- IPC:
--   noctalia msg plugin victor/profiles:service all "save <nome>"
--   noctalia msg plugin victor/profiles:service all "apply <nome>"
--   noctalia msg plugin victor/profiles:service all "list"
--   noctalia msg plugin victor/profiles:service all "delete <nome>"

local CMD = "noctalia-profile"

local function notify(t, b)
    if noctalia.notify then noctalia.notify(t, b or "") end
end

local function log(m)
    if noctalia.log then noctalia.log("[profiles] " .. tostring(m)) end
end

local function run(args, done)
    noctalia.runAsync({CMD, table.unpack(args)}, function(r)
        local out = ""
        if type(r) == "table" then
            out = (r.stdout or "")
            if r.stderr and r.stderr ~= "" then out = out .. "\n" .. r.stderr end
        elseif type(r) == "string" then
            out = r
        end
        if done then done(out) end
    end)
end

local function split(s)
    local parts = {}
    for p in tostring(s):gmatch("%S+") do table.insert(parts, p) end
    return parts
end

local function handle(action, name)
    log("acao=" .. tostring(action) .. " nome=" .. tostring(name))
    if action == "save" then
        if not name or name == "" then notify("Profiles", "uso: save <nome>"); return end
        run({"save", name}, function(out)
            notify("Perfil salvo", name .. (out ~= "" and ("\n" .. out) or ""))
        end)
    elseif action == "apply" then
        if not name or name == "" then notify("Profiles", "uso: apply <nome>"); return end
        run({"apply", name}, function(out)
            notify("Perfil aplicado", name .. (out ~= "" and ("\n" .. out) or ""))
        end)
    elseif action == "list" then
        run({"list"}, function(out)
            notify("Perfis", out ~= "" and out or "nenhum perfil salvo")
        end)
    elseif action == "delete" then
        if not name or name == "" then notify("Profiles", "uso: delete <nome>"); return end
        run({"delete", name}, function(out)
            notify("Perfil removido", name)
        end)
    else
        notify("Profiles", "acao desconhecida: " .. tostring(action) .. "\nuse save|apply|list|delete")
    end
end

function onIpc(event, payload)
    local action, name
    if type(payload) == "table" then
        action = payload.action or event
        name = payload.name
    else
        local parts = split(event)
        action = parts[1]
        name = parts[2]
        if type(payload) == "string" and payload ~= "" then
            name = name or payload
        end
    end
    handle(action, name)
end

function onConfigChanged() end

log("service pronto")
