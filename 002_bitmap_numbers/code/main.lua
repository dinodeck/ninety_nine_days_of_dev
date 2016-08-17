LoadLibrary('Asset')
Asset.Run('Dependencies.lua')

gRenderer = Renderer.Create()
gNumberFont = BitmapText:Create(NumberFont)


function SetupNewGame()
    gStack = StateStack:Create()
    gWorld = World:Create()

    local startPos = Vector.Create(5, 9, 1)

    local hero = Actor:Create(gPartyMemberDefs.hero)
    local thief = Actor:Create(gPartyMemberDefs.thief)
    local mage = Actor:Create(gPartyMemberDefs.mage)
    gWorld.mParty:Add(hero)
    gWorld.mParty:Add(thief)
    gWorld.mParty:Add(mage)


    gWorld.mGold = 0
    gWorld:AddItem(11, 3)
    gWorld:AddItem(10, 5)
    gWorld:AddItem(12, 5)

    local sayDef = { textScale = 1.3 }
    local intro =
    {
        SOP.BlackScreen(),
        SOP.RunAction("AddNPC",
            {"handin", { def = "thief", id="thief", x = 4, y = 10}},
            {GetMapRef}),
        SOP.RunAction("AddNPC",
            {"handin", { def = "mage", id="mage", x = 6, y = 11}},
            {GetMapRef}),
        SOP.FadeOutScreen(),
        SOP.MoveNPC("major", "handin",
            {
                "right",
                "right",
                "left",
                "left",
                "down"
            }),
        SOP.Say("handin", "major", "So, in conclusion...", 3.05, sayDef),
        SOP.Say("handin", "major", "Head north to the mine.", 4.3,sayDef),
        SOP.Say("handin", "major", "Find the skull ruby.", 4.3,sayDef),
        SOP.Say("handin", "major", "Bring it back here to me.", 4.25, sayDef),
        SOP.Say("handin", "major", "Then I'll give you the second half of your fee.", 5.25, sayDef),
        SOP.Say("handin", "major", "Do we have an agreement?", 4.0, sayDef),
        SOP.Say("handin", "hero", "Yes.", 1.5, sayDef),
        SOP.Say("handin", "major", "Good.", 1.5, sayDef),
        SOP.Say("handin", "major", "Here's the first half of the fee...", 4.0, sayDef),
        SOP.Say("handin", "major", "Now get going.", 2.5, sayDef),
        -- Party members can walk into the hero and
        -- return control to the player.
        SOP.NoBlock(
            SOP.MoveNPC("thief", "handin",
            {
                "right",
                "up",
            })),
        SOP.FadeOutChar("handin", "thief"),
        SOP.RunAction("RemoveNPC", {"handin", "thief"},
            {GetMapRef}),
        SOP.NoBlock(
            SOP.MoveNPC("mage", "handin",
            {
                "left",
                "up",
                "up",
            })),
        SOP.FadeOutChar("handin", "mage"),
        SOP.RunAction("RemoveNPC", {"handin", "mage"},
            {GetMapRef}),
        SOP.Function(function()
                        gWorld.mGameState.maps.town.quest_given = true
                        -- give the reward amount!
                        gWorld.mGold = gWorld.mGold + 500
                     end),
        SOP.Wait(0.1),
        SOP.HandOff("handin")
    }

    do
        local map = MapDB['town'](gWorld.mGameState)
        gStack:Push(ExploreState:Create(gStack, map, startPos))
    end

    return Storyboard:Create(gStack, intro, true)
end



local storyboard = SetupNewGame()

gStack:Push(TitleScreenState:Create(gStack, storyboard))
math.randomseed( os.time() )

function update()
    local dt = GetDeltaTime()
    gStack:Update(dt)
    gStack:Render(gRenderer)
    gWorld:Update(dt)

    if Keyboard.JustPressed(KEY_H) then
        gWorld.mGameState.maps.cave.completed_puzzle = false
        gWorld.mParty:DebugHurtParty()
    end

    if Keyboard.JustPressed(KEY_T) then
        print("teleport!")
        gWorld:RemoveKey(14)

        local exploreState = gStack:Top()
        Actions.Teleport(exploreState.mMap, 56, 41, 1)(nil, exploreState.mHero.mEntity)
    end

end
