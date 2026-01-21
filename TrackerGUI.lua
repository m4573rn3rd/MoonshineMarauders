local addonName, addonTable = ...
addonTable.TrackerGUI = {}

function addonTable.TrackerGUI:Create()
    if self.frame then return end

    -- Get the main frame defined in MoonshineMarauders.xml
    local f = MoonshineMaraudersFrame
    if not f then 
        -- This should not happen if XML is loaded correctly
        error("MoonshineMaraudersFrame not found! Is MoonshineMarauders.xml loaded?") 
    end

    -- Clear any existing dynamic children if Create is called multiple times (e.g. for re-init)
    -- This is crucial to prevent duplicate UI elements if the frame persists but children are re-added.
    for _, child in ipairs({f:GetChildren()}) do
        -- Exclude static children defined in XML or children of specific types (e.g., CloseButton)
        if child:GetName() and not string.match(child:GetName(), "CloseButton") then
            child:Hide()
            child:ClearAllPoints()
            child:SetParent(UIParent) -- Discard to UIParent
        end
    end
    -- Reset default attributes that might have been changed dynamically
    f:SetSize(400, 300) -- Default size from XML
    f:SetPoint("CENTER") -- Default position from XML
    f:SetMovable(true) -- Default from template
    f:EnableMouse(true) -- Default from template
    f:SetUserPlaced(true) -- Ensure it saves its position

    self.tabs = {} -- Table to hold tab buttons and content frames
    self.activeTab = nil -- Currently active tab name

    -- Call function to create tabs, parenting to the XML frame
    self:CreateTabs(f)
    
    self.frame = f
end

-- Function to create and manage tabs
function addonTable.TrackerGUI:CreateTabs(parentFrame)
    local tabNames = {"Quest Tracker"} -- Only Quest Tracker tab
    local lastTabButton = nil
    local tabOffsetFromTop = 32 -- Position tabs slightly below the XML frame's title bar
    local tabContentOffset = 26 -- Position content below the tab buttons

    for i, name in ipairs(tabNames) do
        local tabButton = CreateFrame("Button", nil, parentFrame) -- Generic button
        tabButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
        tabButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
        tabButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight", "ADD")
        tabButton:SetText(name)
        tabButton:GetFontString():SetFontObject("GameFontNormalSmall") -- Apply font object to the button's text
        tabButton:SetWidth(100)
        tabButton:SetHeight(24)
        
        if not lastTabButton then
            tabButton:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -tabOffsetFromTop)
        else
            tabButton:SetPoint("LEFT", lastTabButton, "RIGHT", 2, 0)
        end
        lastTabButton = tabButton

        -- Create content frame for each tab
        local contentFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
        contentFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -(tabContentOffset + 5))
        contentFrame:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -5, 5)
        contentFrame:SetBackdrop({
            bgFile = "Interface\ChatFrame\ChatFrameBackground",
            edgeFile = "Interface\Tooltips\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        contentFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
        contentFrame:Hide() -- Hide by default

        self.tabs[name] = {
            button = tabButton,
            content = contentFrame
        }

        tabButton:SetScript("OnClick", function()
            self:SwitchTab(name)
        end)
    end

    -- Create content for Quest tab (only one tab now)
    addonTable.QuestLog:CreateHUD(self.tabs["Quest Tracker"].content)
    -- Add an Update method to the parentFrame for the Quest tab
    self.tabs["Quest Tracker"].content.Update = function(self)
        addonTable.QuestLog:UpdateHUD()
    end

    -- Switch to the first (and only) tab by default
    self:SwitchTab(tabNames[1])
end



-- Function to switch active tab
function addonTable.TrackerGUI:SwitchTab(tabName)
    if self.activeTab then
        self.tabs[self.activeTab].content:Hide()
        self.tabs[self.activeTab].button:GetFontString():SetTextColor(1, 1, 1) -- Unselected color
    end

    self.activeTab = tabName
    self.tabs[self.activeTab].content:Show()
    self.tabs[self.activeTab].button:GetFontString():SetTextColor(1, 1, 0) -- Selected color

    -- Call update for the newly active tab if it has one
    if self.tabs[self.activeTab].content.Update then
        self.tabs[self.activeTab].content:Update()
    end
end

-- Modified addonTable.TrackerGUI:Update to be triggered by the main frame's OnUpdate
function addonTable.TrackerGUI:Update()
    if not self.frame or not self.frame:IsShown() or not self.activeTab then return end

    local currentTabContent = self.tabs[self.activeTab].content
    if currentTabContent and currentTabContent.Update then
        currentTabContent:Update()
    end
end