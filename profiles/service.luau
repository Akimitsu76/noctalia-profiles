-- victor/profiles service — salva/aplica perfis de personalizacao do Noctalia.
-- Chamar via: noctalia msg plugin victor/profiles:service all <acao> [nome]
-- acoes: save | apply | list | delete

local PROFILE_CMD = "noctalia-profile"

local last_result = ""

function run(cmd, args)
    local full = {PROFILE_CMD, cmd, table.unpack(args or {})}
    local ok, res = pcall(noctalia.runSync, full)
    if not ok then
        return "erro ao executar " .. cmd .. ": " .. tostring(res)
    end
    local out = ""
    if type(res) == "table" then
        out = res.stdout or ""
        if res.stderr and res.stderr ~= "" then out = out .. "\n" .. res.stderr end
    else
        out = tostring(res)
    end
    return out
end

function handle(action, name)
    if action == "save" then
        if not name or name == "" then return "uso: save <nome>" end
        last_result = run("save", {name})
    elseif action == "apply" then
        if not name or name == "" then return "uso: apply <nome>" end
        last_result = run("apply", {name})
    elseif action == "list" then
        last_result = run("list", {})
    elseif action == "delete" then
        if not name or name == "" then return "uso: delete <nome>" end
        -- python script nao tem delete ainda; faz manual
        local pd = noctalia.expandPath("~/.local/state/noctalia/profiles/" .. name)
        local ok, res = pcall(noctalia.removeFile, pd .. "/settings.toml")
        -- simples: remove diretorio vazio via rm -rf assincrono seria ideal
        last_result = run("list", {})
    else
        last_result = "acao desconhecida: " .. tostring(action) .. " (save|apply|list|delete)"
    end
    return last_result
end

function onIpc(event, payload)
    -- payload pode ser string "save meu-perfil" ou json {action="save", name="..."}
    local action, name
    if type(payload) == "string" and payload ~= "" then
        local parts = {}
        for part in payload:gmatch("%S+") do table.insert(parts, part) end
        action = parts[1]
        name = parts[2]
    elseif type(payload) == "table" then
        action = payload.action
        name = payload.name
    else
        action = event
    end
    return handle(action, name)
end

function onConfigChanged()
    -- nada a fazer
end

last_result = "profiles service pronto. use: noctalia msg plugin victor/profiles:service all save <nome>"
