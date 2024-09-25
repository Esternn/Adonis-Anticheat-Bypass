local function getMod(val: (ModuleScript) -> boolean): ModuleScript?
    for _,v in getloadedmodules() do
        if (val(v)) then
            return v;
        end
    end
end

local function getGC(fn: (any) -> boolean)
    for _,v: any in getgc(true) do
        if (fn(v)) then
            return v
        end
    end
end;

local function waitForMod(val: (ModuleScript) -> boolean, timeout: number)
    local old: number = time();
    local mod = getMod(val);
    while ((time() - old) < (timeout and timeout * 1000 or math.huge) and task.wait() and not mod) do
        if ((time() - old) == 5000) then
            warn("Infinite yield possible on module script");
        end
        mod = getMod(val);
    end
    return mod;
end

local adonismod: ModuleScript? = waitForMod(newcclosure(function(v: ModuleScript): boolean
    local suc, ret: boolean & any = pcall(require, v);
    if (not suc) then
        return false;
    end
    if (type(ret) ~= "function") then
        return false;
    end

    local protonames: {[string]: number} = {
        Init = 4,
        RunAfterLoaded = 1,
        RunLast = 1,
        Detected = 6,
        compareTables = 1
    };
    local protos: {[number]: (any...) -> any} = debug.getprotos(ret) or {};
    for _,v in pairs(protos) do
        if (protonames[debug.getinfo(v).name] ~= #debug.getupvalues(protos)) then
            return false;
        end
    end

    return true;
end, 5));

if (not adonismod) then
    do return end;
end

-- antiproxy detection
do
    local proxy: {}? = getGC(function(v: any): boolean
        if (type(v) ~= "userdata") then
            return false;
        end
        if (pcall(setmetatable, v, getmetatable(v)) or select(2, pcall(setmetatable, v, getmetatable(v))) ~= "This metatable is locked") then
            return false;
        end
        local meta: {[string]: () -> any}? = getrawmetatable(v);
        if (not meta) then
            return false;
        end
        meta.__metatable = nil;
        for k: string,v: () -> any in pairs(meta) do
            if (not k:match("^__")) then
                return false;
            end
            if (type(debug.getupvalue(v, 1)) ~= "function") then
                return false;
            end
        end
        return true;
    end);
    if (proxy) then
        for k in getrawmetatable(proxy) do
            getrawmetatable(proxy)[k] = function() end
        end
    end
end

--anti anti hooks p1: instances
do
    local stack: {[string]: {any}}? = getGC(function(v: {[string]: {any}} | any): boolean
        if (type(v) ~= "table") then
            return false;
        end

        if (not (select(2, pcall(function() v['\0'] = nil end)) or ""):find("attempt to modify a readonly table")) then
            return false;
        end

        for k in pairs(v) do
            if (not k:lower():find("enum") and not k:lower():find("instance")) then
                return false;
            end
        end
        return true;
    end);
    if (stack) then
        for k,v in pairs(stack) do
            setmetatable(stack[k], {__newindex = function() end});
        end
    end
    local oldindex;
    oldindex = hookmetamethod(game, "__index", newcclosure(function(self, k)
        if (not k or not self) then
            return error(oldindex(nil, nil));
        end
        return oldindex(self, k)
    end));
    local oldnindex;
    oldnindex = hookmetamethod(game, "__newindex", newcclosure(function(self, k, v)
        if (not k or not self or not v) then
            return error(oldnindex(nil, nil));
        end
        return oldnindex(self, k, v)
    end));
    local oldnmcall;
    oldnmcall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if (not self or not getnamecallmethod() or getnamecallmethod() == '') then
            return error(oldnindex(nil, nil));
        end
        return oldnindex(self, ...);
    end));
end

--part 2: enums
do
    local oldindex;
    oldindex = hookmetamethod(Enum.HumanoidStateType, "__index", newcclosure(function(self, k)
        if (not k or not self) then
            return error(oldindex(nil, nil));
        end
        return oldindex(self, k)
    end));
    local oldnindex;
    oldnindex = hookmetamethod(Enum.HumanoidStateType, "__newindex", newcclosure(function(self, k, v)
        if (not k or not self or not v) then
            return error(oldnindex(nil, nil));
        end
        return oldnindex(self, k, v)
    end));
    local oldnmcall;
    oldnmcall = hookmetamethod(Enum.HumanoidStateType, "__namecall", newcclosure(function(self, ...)
        if (not self or not getnamecallmethod() or getnamecallmethod() == '') then
            return error(oldnindex(nil, nil));
        end
        return oldnindex(self, ...);
    end));
end

-- anti anti anti kick

do
    local old;
    local oldk = game:GetService("Players").LocalPlayer.Kick;
    hookfunction(game:GetService("Players").LocalPlayer.Kick, newcclosure(function(self, msg)
        if (self ~= game:GetService("Players").LocalPlayer) then
            return error("Expected ':' not '.' calling member function Kick");
        end
        return oldk(self, msg);
    end));
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if (getnamecallmethod() == "Kick" and not self:IsA("Player")) then
            return error(`Kick is not a valid member of {self.ClassName} "{self:GetFullName()}"`);
        end
        if (getnamecallmethod() == "Kick" and self:IsA("Player") and self.Parent == game:GetService("Players") and self ~= game:GetService("Players").LocalPlayer) then
            return error("Cannot kick a non-local Player from a LocalScript");
        end
        if (getnamecallmethod() ~= "Kick" and getnamecallmethod:lower() == "kick" and self == game:GetService("Players").LocalPlayer) then
            return error(`{getnamecallmethod()} is not a valid member of Player {game:GetService("Players").LocalPlayer:GetFullName()}`);
        end
        return old(self, ...);
    end))
end

-- anti anti fps spoof
do
    local old = workspace.GetRealPhysicsFPS;
    hookfunction(workspace.GetRealPhysicsFPS, newcclosure(function(self)
        if (self ~= workspace) then
            return error("Expected ':' not '.' calling member function GetRealPhysicsFPS");
        end
    end))
end

-- anti anti anti log service
do
    local oldlog = game:GetService("LogService").GetLogHistory;
    hookfunction(game:GetService("LogService").GetLogHistory, function(self)
        if (self ~= game:GetService("LogService")) then
            return error("Expected ':' not '.' calling member function GetLogHistory");
        end
    end)
    local old;
    hookmetamethod(game, "__namecall", function(self, ...)
        if (getnamecallmethod() ~= "GetLogHistory" and getnamecallmethod():lower() == "getloghistory" and self == game:GetService("LogService")) then
            return error(`{getnamecallmethod()} is not a valid member of LogService "{game:GetService("LogService"):GetFullName()}"`)
        end
        if (getnamecallmethod() == "GetLogHistory" and self ~= game:GetService("LogService")) then
            return error(`GetLogHistory is not a valid member of LogService "{self:GetFullName()}"`)
        end
        
    end)
end

do
    for _,v: RemoteEvent | any in pairs(getregistry()) do
        if (not typeof(v) == "Instance" or not v:IsA("RemoteEvent")) then
            continue
        end
        local oldf = v.FireServer
        hookfunction(v.FireServer, function(self, ...)
            if (self ~= v) then
                return error("Expected ':' not '.' calling member function FireServer");
            end
        end)
    end
    game.DescendantAdded:Connect(function(v)
        if (not typeof(v) == "Instance" or not v:IsA("RemoteEvent")) then
            return;
        end
        local oldf = v.FireServer
        hookfunction(v.FIreServer, function(self, ...)
            if (self ~= v) then
                return error("Expected ':' not '.' calling member function FireServer");
            end
        end)
    end)
    local old;
    hookmetamethod(game, "__namecall", function(self, ...)
        if (getnamecallmethod() ~= "FireServer" and getnamecallmethod():lower() == "fireserver" and self:IsA("RemoteEvent")) then
            return error(`{getnamecallmethod()} is not a valid member of RemoteEvent "{self:GetFullName()}"`)
        end
        if (getnamecallmethod() == "FireServer" and not self:IsA("RemoteEvent")) then
            return error(`FireServer is not a valid member of {self.ClassName} "{self:GetFullName()}"`)
        end
    end)
end

do
    for _,v: RemoteFunction | any in pairs(getregistry()) do
        if (not typeof(v) == "Instance" or not v:IsA("RemoteFunction")) then
            continue
        end
        local oldf = v.InvokeServer
        hookfunction(v.InvokeServer, function(self, ...)
            if (self ~= v) then
                return error("Expected ':' not '.' calling member function InvokeServer");
            end
        end)
    end
    game.DescendantAdded:Connect(function(v)
        if (not typeof(v) == "Instance" or not v:IsA("RemoteFunction")) then
            return;
        end
        local oldf = v.InvokeServer
        hookfunction(v.InvokeServer, function(self, ...)
            if (self ~= v) then
                return error("Expected ':' not '.' calling member function InvokeServer");
            end
        end)
    end)
    local old;
    hookmetamethod(game, "__namecall", function(self, ...)
        if (getnamecallmethod() ~= "InvokeServer" and getnamecallmethod():lower() == "invokeserver" and self:IsA("RemoteFunction")) then
            return error(`{getnamecallmethod()} is not a valid member of RemoteEvent "{self:GetFullName()}"`)
        end
        if (getnamecallmethod() == "InvokeServer" and not self:IsA("RemoteFunction")) then
            return error(`InvokeServer is not a valid member of {self.ClassName} "{self:GetFullName()}"`)
        end
    end)
end
