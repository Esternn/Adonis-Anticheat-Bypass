-- local GuiService = game:GetService("GuiService")
--remade
local function getnil(name: string, classname: string): Instance? for _,v in pairs(getnilinstances()) do if (v.Name == name) and v:IsA(classname) then return v end end end
local function waitfornil(name: string, classname: string, timeout: number) local oldtime: number = time(); while (((time() - oldtime) <= timeout) and task.wait()) do local v: Instance? = getnil(name, classname); if (v) then return v end end end
local adonis: ModuleScript? = waitfornil("\n\n\n\n\nModuleScript", "ModuleScript", 5);
if (not adonis) then
    print("No adonis detected, aborting...");
    do return end;
end

-- local exit: boolean = false;
local function genload(): {{string}}
    local buf: {{string}} = {};
    for j = 1, 30 do
        for i = 1, 125 do
            if (i % 2) == 0 then
                buf[j] = (buf[j] or '') .. '\0';
                continue;
            end
            buf[j] = (buf[j] or '') .. math.random(0, 255);
        end
    end
    return buf;
end

if (not hookfunction) then
    warn("Anticheat is enabled but no hookfunction is provided with your exploit, balling out now: you're on your own(get a better exploit please)");
    do return end;
end
if (newcclosure and not pcall(hookfunction, newcclosure(function() return end), function() end)) then
    warn("Your exploit blocks c closures from being hooked, balling out now: you're on your own now(maybe move to CoreScript thread?)")
    do return end;
end

local getmeta: ({any}) -> ({any})? = getrawmetatable or debug.getmetatable
if (not getmeta) then
    warn("Anticheat is enabled but no metatable-hook-functions are included by your executor, balling out now: you're on your own...");
    do return end;
end

local function searchGC(map: (any) -> boolean) for _,v in getgc(true) do if (map(v)) then return v end end end

local adonis: {} = searchGC(function(v: {any} | any)
    if (type(v) ~= "table") then
        return false;
    end
    if (select(2, pcall(getmetatable, v)) ~= "This metatable is locked") then
        return false;
    end
    local meta: {[string]: () -> nil} = getmeta(v);
    for i,v in pairs(meta) do
        if (type(v) ~= "function") then continue end;
        if (type(debug.getupvalue(v, 1)) ~= "function") then
            return false;
        end
        local env: {any} = getfenv(v) or {};
        local check = false;
        env["task"] = {{wait = function(t) check = t == 2e2; end}};
        local fn = debug.getupvalue(v, 1); 
        if (not debug.getinfo(fn).name == "Detected") then
            return;
        end
        hookfunction(fn, function() check = t == "Kick" end)
        pcall(v);
        if (not check) then
            return false;
        end
    end
    return true;
end);

for k in getmeta(adonis) do
    getmeta(adonis)[k] = function() end;
end

local function hookmeta(tabl: any, name: string, func: (any...) -> any...)
    if (hookmetamethod) then
        return hookmetamethod(tabl, name, newcclosure and newcclosure(func) or func);
    end
    if (isreadonly and isreadonly(tabl)) then
        setreadonly(tabl, false);
    end
    func = newcclosure and newcclosure(func) or func;
    local meta: {any}? = getmeta(tabl);
    if (not meta) then
        return;
    end
    local method: any = meta[name];
    if (not method) then
        error(`No metamethod {name} found in table!`);
    end
    meta[name] = func;
    if (setreadonly) then
        setreadonly(tabl, true);
    end
    return method;
end

do
    local old: (any...) -> any...;
    old = hookmeta(game, "__namecall", function(self, ...)
        if (self == game:GetService("Workspace") and getnamecallmethod() == "GetRealPhysicsFPS") then
            return math.huge;
        end
        return old(self, ...);
    end)
end

do
    local old: (any...) -> any...;
    old = hookmeta(game, "__namecall", function(self, ...)
        if (self == game and getnamecallmethod() == "IsLoaded") then
            local proto: (any...) -> any... = debug.getproto(1, 1)
            if (not proto) then
                return old(self, ...)
            end
            if (debug.getinfo(proto).name == "idleTamper" and debug.getupvalue(proto, 1) == false) then
                return task.wait(9e9)
            end
        end
    end)
end
do
    local old;
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        local humanoid: Humanoid = char.Humanoid;
        if (not humanoid) then return; end
        old = hookmeta(humanoid.StateChanged, "__namecall", function(self, f, ...)
            if (self == humanoid.StateChanged and getnamecallmethod():lower() == "connect") then
                return old(function(s)
                    if (s == Enum.HumanoidStateType.StrafingNoPhysics) then
                        return;
                    end
                    f(s);
                end)
            end
            return old(self, f, ...);
        end)
    end)
end

do
    local old;
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        local humanoid: Humanoid = char.Humanoid;
        if (not humanoid) then return; end
        old = hookmeta(game "__namecall", function(self, ...)
            if (self == humanoid and getnamecallmethod():lower() == "getstate" and old(self, ...) == Enum.HumanoidStateType.StrafingNoPhysics) then
                return Enum.HumanoidStateType.Running;
            end
            return old(self, ...);
        end)
    end)
end

do
    local old;
    old = hookmeta(game, "__index", function(self, k)
        if (self == game:GetService("GuiService") and k == "MenuIsOpen") then
            local proto: (any...) -> any... = debug.getproto(1, 1);
            if (not proto) then
                return old(self, k)
            end
            if (debug.getinfo(proto).name == "getCoreUrls" and debug.getupvalues(proto) == {}) then
                return task.wait(9e9);
            end
        end
    end)
end

do
    local old;
    old = hookmeta(game, "__index", function(self, k)
        if (self == game:GetService("PolicyService") and k == "") then
            local check, checkServ: (any...) -> any... = debug.getproto(1, 1), debug.getproto(1, 1)
            if (not check or not checkServ) then
                return old(self, k);
            end
            if (debug.getinfo(check).name == "check" and debug.getinfo(checkServ) == "checkServ" and debug.getupvalue(check, 1) and type(debug.getupvalue(check, 1)) == "table" and debug.getupvalue(check, 1)[1] == "current identity is [0789]") then
                return task.wait(9e9)
            end
        end
    end)
end
