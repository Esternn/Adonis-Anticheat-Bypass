--remade again bruh

function searchGC(fn: (any) -> boolean, timeout: number): any?
    timeout = timeout or 5;
    local time: number = os.clock();
    while ((os.clock() - time) < timeout and task.wait()) do
        for _: number,v: any? in next, getgc(true) do
            if (fn(v)) then
                return v;
            end
        end
    end
    return nil;
end

task.spawn(function()
    local adonismeta: {} = searchGC(function(v: any?): boolean
        if (type(v) ~= "userdata") then
            return false;
        end
        if (select(2, getmetatable, v) ~= "This metatable is locked") then
            return false;
        end

        getrawmetatable(v).__metatable = nil;
        for i: string, v: () -> any in pairs(v) do
            if (type(v) ~= "function" or type(i) ~= "string") then
                return false;
            end
            if (not type(debug.getupvalue(v, 1)) == "function") then
                return false;
            end
            if ((not debug.getinfo(debug.getupvalue(v, 1)).name or ""):find("Detected")) then
                return false;
            end
            if (not i:find("^__")) then
                return false;
            end
            local env: {[string]: any} = getfenv(v);
            if (not env or env == {}) then
                return false;
            end
            local res: boolean = false;
            env["task"] = {wait = function(s: number | any) res = rawequal(s, 2e2) end}
            debug.setupvalue(v, function(m: string | any, k: string | any) res = rawequal(m, "Kick") and type(k) == "string" and k:lower():match("^proxy metamethod 0x%w+$") end)
            local suc, no: boolean | string = pcall(v)
            if (not suc or not res) then
                return false;
            end
        end
        return true;
    end);
    if (adonismeta) then
        for k in pairs(getrawmetatable(adonismeta)) do
            getrawmetatable(adonismeta)[k] = function() end
        end
    end
end)

task.spawn(function()
    local meta: {[string]: (DataModel, any...) -> any} = getrawmetatable(game);
    setreadonly(meta, false);
    local oldi: (DataModel | Instance, string) -> any = meta.__index;
    meta.__index = newcclosure(function(self, k): any?
        if (k == nil) then
            return error("missing argument #2 (string expected)");
        end
        if (typeof(self) ~= "Instance") then
            return error(`invalid argument #1 (Instance expected, got {typeof(self)})`);
        end
        if (type(k) ~= "string") then
            return error(`invalid argument #2 (string expected, got {typeof(k)})`);
        end
        return oldi(self, k)
    end);
    local oldn: (DataModel | Instance, string, any) -> any = meta.__newindex;
    meta.__newindex = newcclosure(function(self: Instance, k: string, v: any): any?
        if (typeof(self) ~= "Instance") then
            return error(`invalid argument #1 (Instance expected, got {typeof(self)})`);
        end
        if (k == nil) then
            return error(`invalid argument #2 (string expected, got nil)`);
        end
        return oldn(self, k, v)
    end);
    local oldc: (DataModel, string | Instance, any) -> any = meta.__namecall;
    meta.__namecall = newcclosure(function(self: Instance, ...): any?
        if (typeof(self) ~= "Instance") then
            return error(`invalid argument #1 (Instance expected, got {typeof(self)})`);
        end
        if (getnamecallmethod() == nil) then
            return error(`invalid argument #2 (string expected, got nil)`);
        end
        if (not pcall(function() return self[getnamecallmethod()] end)) then
            return error(`{getnamecallmethod()} is not a valid member of {self.ClassName} {self:GetFullName()}`);
        end
        return oldc(self, ...)
    end);
    setreadonly(meta, true);
    local stack: {[string]: any} = searchGC(function(v: {[string]: {any}}) return type(v) == "table" and table.isfrozen(v) and type(v.indexInstance) == "table" and type(v.namecallInstance) == "table" and type(v.newindexInstance) == "table" and type(v.eqEnum) == "table" and type(v.namecallEnum) == "table" and type(v.indexEnum) == "table" end);
    if (stack) then
        for _,v in pairs(stack) do
            setmetatable(v, {__newindex = function() end, __len = function() return 0 end});
        end
    end
end);


task.spawn(function()
    local meta: {[string]: (DataModel, any...) -> any} = getrawmetatable(Enum.HumanoidStateType.Running);
    setreadonly(meta, false);
    local oldi: (DataModel | Instance, string) -> any = meta.__index;
    meta.__index = newcclosure(function(self, k): any?
        if (typeof(self) ~= "EnumItem") then
            return error(`invalid argument #1 (EnumItem expected, got {typeof(self)})`);
        end
        if (type(k) ~= "string") then
            return error(`invalid argument #2 (string expected, got {typeof(k)})`);
        end
        return oldi(self, k)
    end);
    meta.__eq = newcclosure(function(self: EnumItem, cmp: EnumItem)
        return rawequal(self.Name, cmp.Name) and rawequal(self.Value, cmp.Value);
    end);
    local oldc: (DataModel, string | Instance, any) -> any = meta.__namecall;
    meta.__namecall = newcclosure(function(self: EnumItem, ...): any?
        if (typeof(self) ~= "EnumItem") then
            return error(`invalid argument #1 (EnumItem expected, got {typeof(self)})`);
        end
        if (getnamecallmethod() == nil) then
            return error(`invalid argument #2 (string expected, got nil)`);
        end
        if (not pcall(function() return self[getnamecallmethod()] end)) then
            return error(`{getnamecallmethod()} is not a valid member of EnumItem Enum.{self.EnumType}.{self.Name}`);
        end
        return oldc(self, ...);
    end);
    setreadonly(meta, true);
end)

do
    local old: (Player, string) -> any?;
    old = hookfunction(game:GetService("Players").LocalPlayer.Kick, newcclosure(function(self: Player | Instance, msg: string): any?
        if (self ~= game:GetService("Players").LocalPlayer) then
            return error("Expected ':' not '.' calling member function Kick");
        end
        return old(self, msg);
    end));
end

do
    local meta: {[string]: (Instance, any...) -> any...} = getrawmetatable(game); 
    setreadonly(meta, false);
    local old: (Instance | Player, any...) -> any... = game.__namecall;
    meta.__namecall = newcclosure(function(self: Instance, ...): any?
        if (self ~= game:GetService("Players").LocalPlayer and getnamecallmethod() == "Kick" and self:IsA("Player")) then
            return error("Cannot kick a non-local player from a LocalScript");
        end
        if (self == game:GetService("Players").LocalPlayer and getnamecallmethod():lower() == "kick" and getnamecallmethod() ~= "Kick") then
            return error(`{getnamecallmethod()} is not a valid member of Player "{game:GetService("Players").LocalPlayer:GetFullName()}"`);
        end
        if (not self:IsA("Player") and getnamecallmethod() == "Kick") then
            return error(`{getnamecallmethod()} is not a valid member of {self.ClassName} "{self:GetFullName()}`);
        end
        if (self:IsA("LogService") and getnamecallmethod():lower() == "getloghistory" and getnamecallmethod() ~= "GetLogHistory") then
            return error(`{getnamecallmethod()} is not a valid member of {self.ClassName} "{self:GetFullName()}`);
        end
        if (not self:IsA("LogService") and getnamecallmethod() == "GetLogHistory") then
            return error(`{getnamecallmethod()} is not a valid member of {self.ClassName} "{self:GetFullName()}`);
        end
        if (self:IsA("RemoteEvent") and getnamecallmethod():lower() == "fireserver" and getnamecallmethod() ~= "fireserver") then
            return error(`{getnamecallmethod()} is not a valid member of {self.ClassName} "{self:GetFullName()}`);
        end
        if (not self:IsA("RemoteEvent") and getnamecallmethod() == "FireServer") then
            return error(`{getnamecallmethod()} is not a valid member of {self.ClassName} "{self:GetFullName()}`);
        end
        if (self:IsA("RemoteFunction") and getnamecallmethod():lower() == "invokeserver" and getnamecallmethod() ~= "invokeserver") then
            return error(`{getnamecallmethod()} is not a valid member of {self.ClassName} "{self:GetFullName()}`);
        end
        if (not self:IsA("RemoteFunction") and getnamecallmethod() == "InvokeServer") then
            return error(`{getnamecallmethod()} is not a valid member of {self.ClassName} "{self:GetFullName()}`);
        end
        return old(self, ...);
    end);
    setreadonly(meta, true);
end

do
    local old: () -> number?;
    old = hookfunction(workspace.GetRealPhysicsFPS, newcclosure(function(self: Workspace | any): number
        if (self ~= game:GetService("Players").LocalPlayer) then
            return error("Expected ':' not '.' calling member function GetRealPhysicsFPS");
        end
        return math.huge;
    end));
end

do
    local old: () -> {string}?;
    old = hookfunction(game:GetService("LogService").GetLogHistory, newcclosure(function(self: LogService | any): {string}
        if (self ~= game:GetService("LogService")) then
            return error("Expected ':' not '.' calling member function GetLogHistory");
        end
        return old(self);
    end));
end

do
    for _: number,v: RemoteEvent | Instance in getinstances() do
        if (not v:IsA("RemoteEvent")) then
            continue;
        end
        local old: (any...) -> any?;
        old = hookfunction(v.FireServer, newcclosure(function(self: RemoteEvent | any, ...): {string}
            if (self ~= v) then
                return error("Expected ':' not '.' calling member function FireServer");
            end
            return old(self, ...);
        end));
    end
end

do
    for _: number,v: RemoteFunction | Instance in getinstances() do
        if (not v:IsA("RemoteFunction")) then
            continue;
        end
        local old: (any...) -> any?;
        old = hookfunction(v.InvokeServer, newcclosure(function(self: RemoteFunction | any, ...): {string}
            if (self ~= v) then
                return error("Expected ':' not '.' calling member function InvokeServer");
            end
            return old(self, ...)
        end));
    end
end

do
    local old: (RBXScriptSignal, (number) -> any) -> any?;
    old = hookfunction(game:GetService("Players").LocalPlayer.Idled.Connect, newcclosure(function(self: RBXScriptSignal, fn: (number) -> any): any?
        return old(self, function() fn(10) end);
    end));
end

do
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        task.spawn(function()
            local hum: Humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 2);
            if (not hum) then
                return;
            end
            local olde: (RBXScriptSignal, (number) -> any) -> any?;
            olde = hookfunction(hum.StateChanged.Connect, newcclosure(function(self: RBXScriptSignal, fn: (number) -> any): any?
                return olde(self, function(state: EnumItem) fn( if state == Enum.HumanoidStateType.StrafingNoPhysics then Enum.HumanoidStateType.Running else state) end);
            end));
            local olds: (RBXScriptSignal, (number) -> any) -> any?;
            olds = hookfunction(hum.GetState, newcclosure(function(self: Humanoid): any?
                return if olds(self) == Enum.HumanoidStateType.StrafingNoPhysics then Enum.HumanoidStateType.Running else olds(self);
            end));
        end)
    end)
end

do
    local old: ((any...) -> any..., (any...) -> any...) -> any;
    old = hookfunction(xpcall, newcclosure(function(f, k)
        if (debug.getproto(f, 1) and (debug.getinfo(f, debug.getproto(f, 1)).name or ""):find("getCoreUrls") and type(debug.getupvalue(k, 1)) == "function" and (debug.getinfo(f, debug.getupvalue(k, 1)).name or ""):find("Detected")) then
            return;
        end
    end))
end

do
    local old: (RBXScriptSignal, (string) -> any) -> any?;
    old = hookfunction(game:GetService("PolicyService").ChildAdded.Connect, newcclosure(function(self: RBXScriptSignal, fn: (Instance) -> any): any?
        local protonames: {string} = {check = function(env: {[number]: any}) return type(env[1]) == "table" and env[1][1] == "current identity is [0789]" and env[1][2] == "gui made by kujo" end, checkServ = function(env: {[number]: any}) return env and pcall(function() return env[1].GuiService end) and env[1] ~= game end, soundIdCheck = function(env: {[number]: any}) return type(env[1]) == "table" and type(env[1][1]) == "number" end, checkTools = function(env: {[number]: any}) return type(env[1]) == "table" and env[1]["CodeName"] and env[2] and pcall(function() return env[2].Workspace end) and type(env[3]) == "function" and (debug.getinfo(env[3]).name or ""):find("Detected") end};
        for _,v in debug.getprotos(2) do
            if (protonames[debug.getinfo(v).name] and not protonames[debug.getinfo(v).name](debug.getupvalues(v))) then
                return old(self, fn);
            end
            return old(self, fn), task.wait(9e5);
        end
    end));
end
