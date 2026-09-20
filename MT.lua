--// HAYU Store - AUTO TELEPORT CP + SUMMIT + RESET PORTAL
--// LocalScript (versi HP/Delta: aman streaming, baca leaderstats lebih kuat)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--==================================================
-- WHITELIST (GANTI USERNAME DI BAWAH INI)
-- Tulis username Roblox persis seperti aslinya
-- (huruf besar/kecil tidak berpengaruh)
--==================================================

local whitelist = {
    "harpromax",
    "SintaDewi88",
    "BudiGaming_ID",
    "NaufalX_Pro",
    "AyuRblx99",
}

local function isWhitelisted(name)

    name = string.lower(name)

    for _, allowed in ipairs(whitelist) do
        if string.lower(allowed) == name then
            return true
        end
    end

    return false
end

if not isWhitelisted(player.Name) then

    local denied = Instance.new("ScreenGui")
    denied.Name = "HAYUDenied"
    denied.ResetOnSpawn = false
    denied.Parent = player:WaitForChild("PlayerGui")

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0, 300, 0, 55)
    msg.Position = UDim2.new(0.5, -150, 0, 20)
    msg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    msg.BorderSizePixel = 0
    msg.Text = "HAYU Store\nUsername tidak ada di whitelist"
    msg.TextColor3 = Color3.fromRGB(255, 80, 80)
    msg.TextSize = 14
    msg.Font = Enum.Font.GothamBold
    msg.TextWrapped = true
    msg.Parent = denied

    local msgCorner = Instance.new("UICorner")
    msgCorner.CornerRadius = UDim.new(0, 8)
    msgCorner.Parent = msg

    task.delay(5, function()
        denied:Destroy()
    end)

    return
end

--==================================================
-- CHECKPOINT DATA
--==================================================

local checkpoints = {
    {"CP1", 50.60, 36.86, 292.66},
    {"CP2", 194.39, 37.95, 587.01},
    {"CP3", 846.68, 46.40, 687.93},
    {"CP4", 794.21, 44.61, 1592.30},
    {"CP5", 631.57, 44.59, 2143.61},
    {"CP6", 625.72, 244.95, 2494.21},
    {"CP7", 623.66, 244.95, 2941.34},
    {"CP8", 623.71, 244.95, 3341.01},
    {"CP9", 771.28, 272.57, 3730.54},
    {"CP10", 1080.59, 274.74, 3733.61},
    {"CP11", 1809.93, 274.74, 3944.77},
    {"CP12", 2711.15, 273.73, 4664.22},
    {"CP13", 2713.90, 242.74, 5354.90},
    {"CP14", 2851.76, 323.74, 6789.15},
    {"CP15", 2853.30, 323.73, 7526.02},
    {"CP16", 2854.94, 323.73, 8371.66},
    {"CP17", 2850.54, 323.74, 8988.91},
    {"CP18", 3732.08, 323.74, 9405.24},
    {"CP19", 4868.64, 323.74, 9445.85},
    {"CP20", 6352.87, 323.74, 9474.17},
    {"CP21", 7310.49, 416.79, 9504.44},
    {"CP22", 8042.88, 416.79, 9768.75},
    {"CP23", 8074.45, 429.42, 10632.34},
    {"CP24", 8074.60, 429.42, 12804.20},
    {"CP25", 8078.19, 539.42, 14544.73},
    {"CP26", 8049.10, 1091.42, 15305.67},
    {"SUMMIT", 7993.84, 1273.42, 16528.24},
}

local SUMMIT_INDEX = #checkpoints

--==================================================
-- SETTINGS
--==================================================

local enabled = false
local delayTime = 2
local runId = 0               -- mencegah 2 loop jalan bersamaan
local forcedCP = 0            -- hitungan sendiri kalau leaderstats tidak update
local cpUnreliable = false    -- true = leaderstats tidak dipercaya lagi
local failStreak = 0

local cpRetry = 3             -- percobaan ulang kalau CP tidak tercatat
local cpWaitTimeout = 4       -- detik tambahan menunggu leaderstats (HP bisa lambat)
local portalRetry = 3         -- percobaan masuk portal
local portalWait = 10         -- maks detik menunggu reset per percobaan
local portalSearchTime = 12   -- detik mencari portal setelah sampai summit
local streamTimeout = 4       -- detik menunggu area dimuat sebelum teleport
local AVATAR_RADIUS = 200     -- avatar dianggap "di CP" kalau jaraknya <= ini
local SUMMIT_HEIGHT = 1230    -- avatar dengan tinggi (Y) >= ini dianggap di SUMMIT

-- Koordinat portal (opsional, sangat membantu di HP).
-- Cara isi: jalankan script di PC sampai masuk portal. Script akan mencetak
-- ke console dan menyalin ke clipboard: Vector3.new(x, y, z)
-- Tempel hasilnya di bawah, contoh:
-- local portalManual = Vector3.new(123.45, 56.78, 9012.34)
local portalManual = nil
local portalPrinted = false

-- fungsi bawaan executor (opsional)
local fti = (typeof(firetouchinterest) == "function") and firetouchinterest or nil
local fpp = (typeof(fireproximityprompt) == "function") and fireproximityprompt or nil
local fcd = (typeof(fireclickdetector) == "function") and fireclickdetector or nil
local gcon = (typeof(getconnections) == "function") and getconnections or nil
local fsig = (typeof(firesignal) == "function") and firesignal or nil

-- coba tombol "Reset" di UI game dulu sebelum portal
-- (game menampilkan: "Klik Reset, kembali ke base!")
local useResetButton = true

local gui = nil               -- diisi di bagian GUI

-- titik BASE (tempat spawn) untuk deteksi posisi avatar
local baseData = {"BASE", 17.21, 27.57, 28.22}

local function alive(id)
    return enabled and id == runId and gui ~= nil and gui.Parent ~= nil
end

--==================================================
-- HELPER: ROOT, LEADERSTATS, CP AVATAR, TELEPORT
--==================================================

local function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function charAlive()
    local character = player.Character
    local hum = character and character:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0
end

-- tunggu karakter siap (setelah respawn / jatuh)
local function waitForRoot(timeout)

    local t = 0
    local root = getRoot()

    while (not root or not charAlive()) and t < timeout do
        task.wait(0.25)
        t = t + 0.25
        root = getRoot()
    end

    if root and charAlive() then
        return root
    end

    return nil
end

local function findLeaderstats()

    local ls = player:FindFirstChild("leaderstats")

    if ls then
        return ls
    end

    for _, child in ipairs(player:GetChildren()) do
        if string.lower(child.Name) == "leaderstats" then
            return child
        end
    end

    return nil
end

local function findCPObject()

    local ls = findLeaderstats()

    if not ls then
        return nil
    end

    local obj = ls:FindFirstChild("CP")

    if obj then
        return obj
    end

    for _, child in ipairs(ls:GetChildren()) do

        local n = string.lower(child.Name)

        if n == "cp" or n == "checkpoint" or n == "checkpoints" then
            return child
        end
    end

    return nil
end

-- Players > leaderstats > CP
-- angka / teks berisi angka ("CP5", "5/26"), atau teks "Summit" / "Base"
local function getCP()

    local obj = findCPObject()

    if not obj then
        return nil
    end

    local ok, value = pcall(function()
        return obj.Value
    end)

    if not ok then
        return nil
    end

    local text = string.lower(tostring(value))
    local digits = string.match(text, "%d+")

    if digits then
        return tonumber(digits)
    end

    if string.find(text, "summit", 1, true) then
        return SUMMIT_INDEX
    end

    if string.find(text, "base", 1, true) then
        return 0
    end

    return nil
end

-- isi mentah CP (ditampilkan di GUI untuk debug)
local function getCPRaw()

    local obj = findCPObject()

    if not obj then

        if findLeaderstats() then
            return "leaderstats ada, CP tidak ada"
        end

        return "leaderstats tidak ada"
    end

    local ok, value = pcall(function()
        return obj.Value
    end)

    if not ok then
        return obj.ClassName
    end

    return obj.ClassName .. "=" .. tostring(value)
end

-- cetak isi leaderstats ke console (untuk cek di Delta)
local function debugLeaderstats()

    local ls = findLeaderstats()

    if not ls then
        print("[HAYU] leaderstats TIDAK ditemukan. Isi Player:")

        for _, c in ipairs(player:GetChildren()) do
            print("  -", c.Name, c.ClassName)
        end

        return
    end

    print("[HAYU] isi leaderstats:")

    for _, c in ipairs(ls:GetChildren()) do

        local v = ""

        pcall(function()
            v = tostring(c.Value)
        end)

        print("  -", c.Name, c.ClassName, v)
    end
end

-- CP terdekat dari posisi avatar
-- 0 = di BASE, 1..27 = CP / SUMMIT, nil = jauh dari semuanya
local function getAvatarCP()

    local root = getRoot()

    if not root then
        return nil
    end

    -- di puncak (tinggi Y besar) = SUMMIT, tidak perlu pas di titik koordinatnya
    if root.Position.Y >= SUMMIT_HEIGHT then
        return SUMMIT_INDEX
    end

    local bestIndex = 0
    local bestDist = (root.Position - Vector3.new(baseData[2], baseData[3], baseData[4])).Magnitude

    for i, data in ipairs(checkpoints) do

        local d = (root.Position - Vector3.new(data[2], data[3], data[4])).Magnitude

        if d < bestDist then
            bestIndex = i
            bestDist = d
        end
    end

    if bestDist <= AVATAR_RADIUS then
        return bestIndex
    end

    return nil
end

-- CP yang dianggap sedang dicapai:
-- 1) leaderstats kalau terbaca
-- 2) hitungan sendiri (forcedCP) kalau leaderstats tidak update
-- 3) posisi avatar (BASE = 0, atau CP terdekat) kalau leaderstats tidak terbaca
local function getEffectiveCP()

    local realCP = getCP()
    local avatarCP = getAvatarCP()
    local forced = enabled and forcedCP or 0

    if realCP ~= nil then

        if forced > realCP then
            return forced, "hitung", avatarCP
        end

        return realCP, "leaderstats", avatarCP
    end

    if forced > 0 then
        return forced, "hitung", avatarCP
    end

    if avatarCP ~= nil then
        return avatarCP, "avatar", avatarCP
    end

    return 0, "unknown", avatarCP
end

-- minta game memuat area tujuan dulu (penting di HP), baru teleport
local function requestStream(pos)

    pcall(function()
        player:RequestStreamAroundAsync(pos, streamTimeout)
    end)
end

local function teleportTo(x, y, z)

    local root = waitForRoot(8)

    if not root then
        return false
    end

    local pos = Vector3.new(x, y, z)

    requestStream(pos)

    root = getRoot()

    if not root then
        return false
    end

    root.CFrame = CFrame.new(pos)

    return true
end

-- pancing sentuhan ke part checkpoint di sekitar (butuh firetouchinterest)
local function pokeTouch(pos)

    if not fti then
        return
    end

    local root = getRoot()

    if not root then
        return
    end

    local char = player.Character

    for _, p in ipairs(workspace:GetPartBoundsInRadius(pos, 12)) do

        if p:FindFirstChildOfClass("TouchTransmitter")
            and not (char and p:IsDescendantOf(char)) then

            pcall(function()
                fti(root, p, 0)
                task.wait()
                fti(root, p, 1)
            end)
        end
    end
end

--==================================================
-- GUI
--==================================================

-- hapus GUI lama kalau script dijalankan lebih dari sekali
-- (loop instance lama ikut berhenti karena gui.Parent = nil)
do
    local old = player:WaitForChild("PlayerGui"):FindFirstChild("AutoTeleportGUI")

    if old then
        old:Destroy()
    end
end

gui = Instance.new("ScreenGui")
gui.Name = "AutoTeleportGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 270, 0, 240)
main.Position = UDim2.new(0.5, -135, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 38)
title.Position = UDim2.new(0, 12, 0, 3)
title.BackgroundTransparency = 1
title.Text = "HAYU Store"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Active = true
title.Parent = main

-- CLOSE
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -38, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.TextSize = 14
close.Font = Enum.Font.GothamBold
close.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = close

close.MouseButton1Click:Connect(function()
    enabled = false
    gui:Destroy()
end)

-- ROW 1: STATUS (kiri) + CP LEADERSTATS (kanan)
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.5, -10, 0, 25)
status.Position = UDim2.new(0, 10, 0, 42)
status.BackgroundTransparency = 1
status.Text = "Status: OFF"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.TextSize = 14
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local cpLabel = Instance.new("TextLabel")
cpLabel.Size = UDim2.new(0.5, -10, 0, 25)
cpLabel.Position = UDim2.new(0.5, 0, 0, 42)
cpLabel.BackgroundTransparency = 1
cpLabel.Text = "CP: ?"
cpLabel.TextColor3 = Color3.fromRGB(255, 210, 80)
cpLabel.TextSize = 14
cpLabel.Font = Enum.Font.GothamBold
cpLabel.TextXAlignment = Enum.TextXAlignment.Right
cpLabel.Parent = main

-- ROW 2: POSISI AVATAR (kiri) + NEXT (kanan)
local avatarLabel = Instance.new("TextLabel")
avatarLabel.Size = UDim2.new(0.5, -10, 0, 22)
avatarLabel.Position = UDim2.new(0, 10, 0, 68)
avatarLabel.BackgroundTransparency = 1
avatarLabel.Text = "Avatar: -"
avatarLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
avatarLabel.TextSize = 13
avatarLabel.Font = Enum.Font.Gotham
avatarLabel.TextXAlignment = Enum.TextXAlignment.Left
avatarLabel.Parent = main

local nextLabel = Instance.new("TextLabel")
nextLabel.Size = UDim2.new(0.5, -10, 0, 22)
nextLabel.Position = UDim2.new(0.5, 0, 0, 68)
nextLabel.BackgroundTransparency = 1
nextLabel.Text = "Next: CP1"
nextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
nextLabel.TextSize = 13
nextLabel.Font = Enum.Font.Gotham
nextLabel.TextXAlignment = Enum.TextXAlignment.Right
nextLabel.Parent = main

-- baris debug kecil di bawah GUI: isi asli leaderstats.CP
local dbgLabel = Instance.new("TextLabel")
dbgLabel.Size = UDim2.new(1, -20, 0, 16)
dbgLabel.Position = UDim2.new(0, 10, 0, 218)
dbgLabel.BackgroundTransparency = 1
dbgLabel.Text = ""
dbgLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
dbgLabel.TextSize = 10
dbgLabel.Font = Enum.Font.Gotham
dbgLabel.TextXAlignment = Enum.TextXAlignment.Left
dbgLabel.TextTruncate = Enum.TextTruncate.AtEnd
dbgLabel.Parent = main

-- update label CP / avatar / next terus-menerus (tidak mati walau ada error)
task.spawn(function()
    while gui.Parent do

        local ok, err = pcall(function()

            local cp, source, a = getEffectiveCP()

            if source == "unknown" then
                cpLabel.Text = "CP: ?"
            elseif source == "avatar" then
                cpLabel.Text = "CP: " .. cp .. "~"     -- dari posisi avatar
            elseif source == "hitung" or cpUnreliable then
                cpLabel.Text = "CP: " .. cp .. "*"     -- hitungan sendiri
            else
                cpLabel.Text = "CP: " .. cp
            end

            if a == nil then
                avatarLabel.Text = "Avatar: -"
            elseif a == 0 then
                avatarLabel.Text = "Avatar: BASE"
            elseif a == SUMMIT_INDEX then
                avatarLabel.Text = "Avatar: SUMMIT"
            else
                avatarLabel.Text = "Avatar: CP" .. a
            end

            local expected = cp + 1

            if expected < SUMMIT_INDEX then
                nextLabel.Text = "Next: CP" .. expected
            elseif expected == SUMMIT_INDEX then
                nextLabel.Text = "Next: SUMMIT"
            else
                nextLabel.Text = "Next: PORTAL"
            end

            dbgLabel.Text = "CP raw: " .. getCPRaw()
        end)

        if not ok then
            dbgLabel.Text = "label err: " .. tostring(err)
        end

        task.wait(0.25)
    end
end)

-- DELAY
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0, 110, 0, 30)
delayLabel.Position = UDim2.new(0, 10, 0, 96)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay (sec):"
delayLabel.TextColor3 = Color3.fromRGB(220,220,220)
delayLabel.TextSize = 13
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = main

local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(0, 125, 0, 30)
delayBox.Position = UDim2.new(1, -135, 0, 96)
delayBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
delayBox.Text = "2"
delayBox.PlaceholderText = "Seconds"
delayBox.TextColor3 = Color3.fromRGB(255,255,255)
delayBox.TextSize = 14
delayBox.Font = Enum.Font.Gotham
delayBox.ClearTextOnFocus = false
delayBox.Parent = main

local delayCorner = Instance.new("UICorner")
delayCorner.CornerRadius = UDim.new(0, 6)
delayCorner.Parent = delayBox

-- INFO
local currentLabel = Instance.new("TextLabel")
currentLabel.Size = UDim2.new(1, -20, 0, 32)
currentLabel.Position = UDim2.new(0, 10, 0, 132)
currentLabel.BackgroundTransparency = 1
currentLabel.Text = "Siap. CP diambil dari leaderstats"
currentLabel.TextColor3 = Color3.fromRGB(160,160,160)
currentLabel.TextSize = 12
currentLabel.Font = Enum.Font.Gotham
currentLabel.TextXAlignment = Enum.TextXAlignment.Left
currentLabel.TextYAlignment = Enum.TextYAlignment.Top
currentLabel.TextWrapped = true
currentLabel.Parent = main

local function setInfo(text)
    currentLabel.Text = text
end

-- ON / OFF
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 172)
toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(255,255,255)
toggle.TextSize = 16
toggle.Font = Enum.Font.GothamBold
toggle.Parent = main

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 7)
toggleCorner.Parent = toggle

--==================================================
-- CARI PORTAL "KEMBALI KE BASE"
--==================================================

local cachedPortalPart = nil

-- ambil part pemilik BillboardGui / SurfaceGui
local function partFromGui(guiObject)

    local a = guiObject.Adornee

    if a then
        if a:IsA("BasePart") then
            return a
        elseif a:IsA("Attachment") and a.Parent and a.Parent:IsA("BasePart") then
            return a.Parent
        elseif a:IsA("Model") then
            return a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart", true)
        end
    end

    local p = guiObject.Parent

    if p then
        if p:IsA("BasePart") then
            return p
        elseif p:IsA("Attachment") and p.Parent and p.Parent:IsA("BasePart") then
            return p.Parent
        elseif p:IsA("Model") then
            return p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart", true)
        end
    end

    return nil
end

-- cari teks "KEMBALI KE BASE" di dalam sebuah Instance
local function scanTextIn(container)

    if not container then
        return nil
    end

    local count = 0

    for _, obj in ipairs(container:GetDescendants()) do

        count = count + 1

        if count % 3000 == 0 then
            task.wait()
        end

        if obj:IsA("TextLabel") or obj:IsA("TextButton") then

            local text = string.upper(obj.Text)

            if string.find(text, "KEMBALI KE BASE", 1, true) then

                local g = obj:FindFirstAncestorWhichIsA("BillboardGui")
                    or obj:FindFirstAncestorWhichIsA("SurfaceGui")

                if g then
                    local part = partFromGui(g)

                    if part then
                        return part
                    end
                end
            end
        end
    end

    return nil
end

-- scan cepat: hanya part di sekitar posisi avatar
local function scanNearby(pos, radius)

    local count = 0

    for _, p in ipairs(workspace:GetPartBoundsInRadius(pos, radius)) do

        count = count + 1

        if count % 500 == 0 then
            task.wait()
        end

        local found = scanTextIn(p)

        if found then
            return found
        end
    end

    return nil
end

-- cadangan: cari lewat nama part / model
local function scanByName()

    local count = 0

    for _, obj in ipairs(workspace:GetDescendants()) do

        count = count + 1

        if count % 3000 == 0 then
            task.wait()
        end

        if obj:IsA("BasePart") or obj:IsA("Model") then

            local n = string.lower(obj.Name)

            if string.find(n, "kembali", 1, true)
                or (string.find(n, "portal", 1, true)
                    and (string.find(n, "base", 1, true)
                        or string.find(n, "reset", 1, true)
                        or string.find(n, "return", 1, true))) then

                if obj:IsA("BasePart") then
                    return obj
                end

                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)

                if part then
                    return part
                end
            end
        end
    end

    return nil
end

-- full = true -> scan seluruh workspace (lebih berat)
local function findPortalPart(full)

    if cachedPortalPart and cachedPortalPart.Parent then
        return cachedPortalPart
    end

    local part = nil
    local root = getRoot()

    if root then
        part = scanNearby(root.Position, 300)
    end

    if not part and full then
        part = scanTextIn(workspace)
            or scanTextIn(player:FindFirstChildOfClass("PlayerGui"))
            or scanByName()
    end

    cachedPortalPart = part

    return part
end

-- tunggu portal termuat (di HP butuh waktu lebih lama)
local function waitForPortal(myId, maxTime)

    local t = 0

    while alive(myId) do

        local part = findPortalPart(t % 6 == 0)

        if part then
            return part
        end

        if t >= maxTime then
            break
        end

        task.wait(1)
        t = t + 1
    end

    return nil
end

-- part di sekitar portal yang punya TouchInterest
local function findTouchPart(pos)

    local best = nil
    local bestDist = nil
    local char = player.Character

    for _, p in ipairs(workspace:GetPartBoundsInRadius(pos, 20)) do

        if p:FindFirstChildOfClass("TouchTransmitter")
            and not (char and p:IsDescendantOf(char)) then

            local d = (p.Position - pos).Magnitude

            if not bestDist or d < bestDist then
                best = p
                bestDist = d
            end
        end
    end

    return best
end

--==================================================
-- MASUK PORTAL
--==================================================

local function triggerPortal(pos)

    local touchPart = findTouchPart(pos)
    local target = touchPart and touchPart.Position or pos

    -- cetak & salin koordinat portal (sekali) untuk dipakai di HP
    if not portalPrinted then

        portalPrinted = true

        local text = string.format("Vector3.new(%.2f, %.2f, %.2f)", target.X, target.Y, target.Z)

        print("[HAYU] PORTAL: " .. text)

        pcall(function()
            if typeof(setclipboard) == "function" then
                setclipboard(text)
            end
        end)
    end

    local offsets = {
        Vector3.new(0, 0, 0),
        Vector3.new(0, -4, 0),
        Vector3.new(0, 3, 0),
        Vector3.new(0, -8, 0),
    }

    for _, off in ipairs(offsets) do

        local root = waitForRoot(5)

        if not root then
            return
        end

        root.CFrame = CFrame.new(target + off)
        task.wait(0.35)

        local parts = workspace:GetPartBoundsInRadius(target, 15)
        local fired = {}

        for _, p in ipairs(parts) do

            -- sentuhan (TouchInterest)
            if fti and p:FindFirstChildOfClass("TouchTransmitter") then
                pcall(function()
                    fti(root, p, 0)
                    task.wait()
                    fti(root, p, 1)
                end)
            end

            -- ProximityPrompt
            local prompt = p:FindFirstChildWhichIsA("ProximityPrompt", true)

            if prompt and fpp and not fired[prompt] then
                fired[prompt] = true
                pcall(fpp, prompt)
            end

            -- ClickDetector
            local click = p:FindFirstChildWhichIsA("ClickDetector", true)

            if click and fcd and not fired[click] then
                fired[click] = true
                pcall(fcd, click)
            end
        end

        task.wait(0.35)

        -- sudah terpental jauh (ke base) = berhasil
        if (root.Position - target).Magnitude > 100 then
            return
        end
    end
end

--==================================================
-- TOMBOL "RESET" DI UI GAME
--==================================================

local function isGuiVisible(obj)

    local cur = obj

    while cur and cur ~= game do

        if cur:IsA("GuiObject") and not cur.Visible then
            return false
        end

        if cur:IsA("ScreenGui") and not cur.Enabled then
            return false
        end

        cur = cur.Parent
    end

    return true
end

local function findResetButton()

    local pg = player:FindFirstChildOfClass("PlayerGui")

    if not pg then
        return nil
    end

    local count = 0

    for _, obj in ipairs(pg:GetDescendants()) do

        count = count + 1

        if count % 2000 == 0 then
            task.wait()
        end

        if not obj:IsDescendantOf(gui) then

            local btn = nil

            -- tombol yang namanya "Reset"
            if obj:IsA("GuiButton") and string.lower(obj.Name) == "reset" then
                btn = obj
            end

            -- teks "Reset" (label di bawah ikon)
            if not btn and (obj:IsA("TextLabel") or obj:IsA("TextButton")) then

                local text = string.lower(obj.Text)
                text = string.gsub(text, "%s+", "")

                if text == "reset" then

                    if obj:IsA("GuiButton") then
                        btn = obj
                    else
                        btn = obj:FindFirstAncestorWhichIsA("GuiButton")

                        if not btn and obj.Parent then
                            btn = obj.Parent:FindFirstChildWhichIsA("GuiButton", true)
                        end
                    end
                end
            end

            if btn and isGuiVisible(btn) then
                return btn
            end
        end
    end

    return nil
end

-- tekan tombol lewat executor (getconnections / firesignal)
local function activateButton(btn)

    local fired = false

    local signals = {
        btn.MouseButton1Click,
        btn.Activated,
        btn.MouseButton1Down,
        btn.MouseButton1Up,
    }

    -- 1) jalankan fungsi yang terhubung ke tombol (paling mirip klik asli)
    if gcon then

        for _, sig in ipairs(signals) do

            local list = {}

            pcall(function()
                list = gcon(sig)
            end)

            for _, c in ipairs(list) do

                pcall(function()
                    if c.Fire then
                        c:Fire()
                    elseif c.Function then
                        c.Function()
                    end
                end)

                fired = true
            end

            if fired then
                return true
            end
        end
    end

    -- 2) cadangan: firesignal
    if fsig then

        pcall(function()
            fsig(btn.MouseButton1Click)
            fired = true
        end)

        pcall(function()
            fsig(btn.Activated)
            fired = true
        end)
    end

    return fired
end

--==================================================
-- CEK HASIL RESET
--==================================================

-- tunggu leaderstats ikut turun (maks 4 detik)
local function settleCP(cpBefore, myId)

    if not cpBefore or cpBefore <= 0 then
        return
    end

    local t = 0

    while t < 4 and alive(myId) do

        local cp = getCP()

        if cp == nil or cp < cpBefore then
            return
        end

        task.wait(0.25)
        t = t + 0.25
    end
end

-- berhasil kalau: CP turun, atau avatar sudah di BASE,
-- atau (khusus portal) avatar menjauh dari titik portal
local function waitForResetResult(myId, cpBefore, awayFrom, timeout)

    local baseVec = Vector3.new(baseData[2], baseData[3], baseData[4])
    local checkBase = (awayFrom == nil) or ((awayFrom - baseVec).Magnitude > 300)

    local waited = 0

    while waited < timeout and alive(myId) do

        local cp = getCP()

        if cp ~= nil and cpBefore ~= nil and cpBefore > 0 and cp < cpBefore then
            return true
        end

        local root = getRoot()
        local moved = false

        if checkBase and getAvatarCP() == 0 then
            moved = true
        elseif awayFrom and root and (root.Position - awayFrom).Magnitude > 150 then
            moved = true
        end

        if moved then
            settleCP(cpBefore, myId)
            return true
        end

        task.wait(0.25)
        waited = waited + 0.25
    end

    return false
end

local function tryResetButton(myId, cpBefore)

    setInfo("Cari tombol Reset...")

    local btn = findResetButton()

    if not btn then
        return false, "tombol Reset tidak ketemu"
    end

    if not (gcon or fsig) then
        return false, "executor tanpa getconnections/firesignal"
    end

    setInfo("Menekan tombol Reset...")

    if not activateButton(btn) then
        return false, "tombol Reset tidak bisa ditekan"
    end

    if waitForResetResult(myId, cpBefore, nil, 8) then
        return true
    end

    return false, "Reset ditekan, CP tidak turun"
end

--==================================================
-- RESET: TOMBOL RESET -> PORTAL
--==================================================

local function doPortalReset(myId)

    local cpBefore = getCP()
    local foundAny = false
    local reasons = {}

    -- 1) tombol Reset di UI game
    if useResetButton then

        local ok, why = tryResetButton(myId, cpBefore)

        if ok then
            return true
        end

        if not alive(myId) then
            return false
        end

        reasons[#reasons + 1] = why
    end

    -- 2) portal "KEMBALI KE BASE"
    for attempt = 1, portalRetry do

        if not alive(myId) then
            return false
        end

        setInfo("Cari portal (" .. attempt .. "/" .. portalRetry .. ")")

        local part = waitForPortal(myId, attempt == 1 and portalSearchTime or 3)

        if not alive(myId) then
            return false
        end

        local pos = nil

        if part then

            pos = part.Position
            foundAny = true
            requestStream(pos)
            setInfo("Portal ketemu, masuk (" .. attempt .. "/" .. portalRetry .. ")")

        elseif portalManual then

            setInfo("Portal belum termuat, ke koordinat manual")

            requestStream(portalManual)
            teleportTo(portalManual.X, portalManual.Y, portalManual.Z)
            task.wait(1.5)

            cachedPortalPart = nil

            local again = findPortalPart(false)

            pos = again and again.Position or portalManual

        else
            setInfo("Portal tidak ketemu")
        end

        if pos then

            triggerPortal(pos)

            if waitForResetResult(myId, cpBefore, pos, portalWait) then
                return true
            end
        end
    end

    if not foundAny and not portalManual then
        reasons[#reasons + 1] = "portal tidak ketemu"
    elseif not foundAny then
        reasons[#reasons + 1] = "portal manual tidak termuat"
    else
        reasons[#reasons + 1] = "portal tersentuh, CP tidak turun"
    end

    return false, table.concat(reasons, "; ")
end

--==================================================
-- STOP FUNCTION
--==================================================

local function stopTeleport()

    enabled = false

    toggle.Text = "OFF"
    toggle.BackgroundColor3 = Color3.fromRGB(170, 45, 45)

    status.Text = "Status: OFF"
    status.TextColor3 = Color3.fromRGB(255, 80, 80)
end

--==================================================
-- TUNGGU CP TERCATAT DI LEADERSTATS
--==================================================

local function waitForCP(target, timeout, myId)

    -- leaderstats tidak terbaca / tidak dipercaya: tidak bisa diverifikasi
    if cpUnreliable or getCP() == nil then
        return true
    end

    local t = 0

    while alive(myId) do

        local cp = getCP()

        if cp and cp >= target then
            return true
        end

        if t >= timeout then
            break
        end

        task.wait(0.1)
        t = t + 0.1
    end

    return false
end

--==================================================
-- LOOP UTAMA (BERULANG SAMPAI OFF)
--==================================================

local function startTeleport()

    runId = runId + 1
    local myId = runId

    forcedCP = 0
    cpUnreliable = false
    failStreak = 0

    local retries = 0
    local stage = "-"

    -- satu putaran logika (dijalankan lewat xpcall, error tampil di GUI + nama tahap)
    local function step()

        stage = "baca CP"

        local currentCP, source, avatarCP = getEffectiveCP()
        local expected = currentCP + 1

        --==========================================
        -- AVATAR TERLEWAT DARI CP LEADERSTATS
        -- -> BALIK KE POSISI CP LEADERSTATS
        --==========================================

        if avatarCP and avatarCP > expected then

            stage = "terlewat"

            local backIndex = currentCP

            if backIndex < 1 then
                backIndex = 1
            end

            if backIndex > SUMMIT_INDEX then
                backIndex = SUMMIT_INDEX
            end

            local back = checkpoints[backIndex]

            setInfo("Terlewat! Balik ke " .. back[1])

            teleportTo(back[2], back[3], back[4])
            task.wait(delayTime)

            if not alive(myId) then
                return
            end
        end

        if expected >= SUMMIT_INDEX then

            --======================================
            -- SUMMIT -> RESET (TOMBOL RESET / PORTAL)
            --======================================

            stage = "teleport SUMMIT"

            local s = checkpoints[SUMMIT_INDEX]

            setInfo("Teleport: SUMMIT")

            teleportTo(s[2], s[3], s[4])
            task.wait(delayTime + 1)

            if not alive(myId) then
                return
            end

            stage = "reset"

            local ok, reason = doPortalReset(myId)

            if not alive(myId) then
                return
            end

            if not ok then
                setInfo("Gagal reset: " .. tostring(reason))
                warn("[HAYU] gagal reset: " .. tostring(reason))
                stopTeleport()
                return
            end

            forcedCP = 0
            retries = 0

            setInfo("Reset OK, mulai lagi dari awal")
            task.wait(1.5)

        else

            --======================================
            -- TELEPORT KE CP BERIKUTNYA
            --======================================

            local data = checkpoints[expected]

            stage = "teleport " .. data[1]

            setInfo("Teleport: " .. data[1])

            teleportTo(data[2], data[3], data[4])

            -- CP pertama (dari base) atau percobaan ulang:
            -- pancing sentuhan ke part checkpoint di sekitar
            if expected == 1 or retries > 0 then
                stage = "pokeTouch " .. data[1]
                task.wait(0.3)
                pokeTouch(Vector3.new(data[2], data[3], data[4]))
            end

            task.wait(delayTime)

            if not alive(myId) then
                return
            end

            stage = "cek CP " .. data[1]

            local registered = waitForCP(expected, cpWaitTimeout, myId)

            if registered then

                retries = 0
                failStreak = 0

                -- leaderstats tidak terbaca / tidak dipercaya: pakai hitungan sendiri
                if cpUnreliable or getCP() == nil then
                    forcedCP = expected
                end

            else

                retries = retries + 1

                if retries >= cpRetry then

                    forcedCP = expected
                    retries = 0
                    failStreak = failStreak + 1

                    if failStreak >= 2 then
                        cpUnreliable = true
                        setInfo("leaderstats tidak update, mode hitung sendiri")
                    else
                        setInfo(data[1] .. " tidak tercatat, lanjut")
                    end

                else
                    setInfo(data[1] .. " belum tercatat, ulang (" .. retries .. "/" .. cpRetry .. ")")
                end
            end
        end
    end

    task.spawn(function()

        while alive(myId) do

            local ok, err = xpcall(step, function(e)
                return tostring(e) .. " [" .. stage .. "]"
            end)

            if not ok then
                setInfo("Error: " .. tostring(err))
                warn("[HAYU] error: " .. tostring(err))
                task.wait(2)
            end
        end
    end)
end

--==================================================
-- ON / OFF BUTTON
--==================================================

toggle.MouseButton1Click:Connect(function()

    if not enabled then

        local selectedDelay = tonumber(delayBox.Text)

        if selectedDelay and selectedDelay >= 0.1 then
            delayTime = selectedDelay
        else
            delayTime = 2
            delayBox.Text = "2"
        end

        enabled = true

        toggle.Text = "ON"
        toggle.BackgroundColor3 = Color3.fromRGB(45, 170, 80)

        status.Text = "Status: ON"
        status.TextColor3 = Color3.fromRGB(80, 255, 100)

        setInfo("Memulai...")

        -- jalankan loop DULU, diagnostik belakangan (aman kalau error)
        startTeleport()

        pcall(function()

            local cp, source = getEffectiveCP()

            print("[HAYU] mulai dari CP " .. cp .. " (sumber: " .. source .. ")")

            debugLeaderstats()

            print("[HAYU] executor: firetouchinterest=" .. tostring(fti ~= nil)
                .. " fireproximityprompt=" .. tostring(fpp ~= nil)
                .. " fireclickdetector=" .. tostring(fcd ~= nil)
                .. " setclipboard=" .. tostring(typeof(setclipboard) == "function"))
        end)

    else

        stopTeleport()

        setInfo("Stopped")
    end
end)

--==================================================
-- UPDATE DELAY
--==================================================

delayBox.FocusLost:Connect(function()

    local value = tonumber(delayBox.Text)

    if value and value >= 0.1 then
        delayTime = value
    else
        delayTime = 2
        delayBox.Text = "2"
    end
end)

--==================================================
-- DRAG GUI
--==================================================

local dragging = false
local dragStart = nil
local startPosition = nil

local function updateDrag(input)

    local delta = input.Position - dragStart

    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

title.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if dragging then

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            updateDrag(input)
        end
    end
end)
