SaveScheme =
{
    meta = 'marked',
    fields =
    {
        ['gGame'] =
        {
            meta = 'marked',
            fields =
            {
                ['Stack'] =
                {
                    meta = 'function',
                    meta_extract_function = function(data, scheme)
                        -- Get ExploreState
                        local exploreState = nil
                        for k, v in ipairs(data.mStates) do
                            if v.__index == ExploreState then
                                exploreState = v
                                break
                            end
                        end
                        -- Extract the start pos and
                        return
                        {
                            mapId = exploreState.mMapDef.id,
                            x = exploreState.mHero.mEntity.mTileX,
                            y = exploreState.mHero.mEntity.mTileY,
                            layer = exploreState.mHero.mEntity.mLayer
                        }
                    end,
                },
                ['World'] =
                {
                    meta = 'marked',
                    fields =
                    {
                        ['mTime'] = { meta = 'copy' },
                        ['mGold'] = { meta = 'copy' },
                        ['mItems'] = { meta = 'copy' },
                        ['mKeyItems'] = { meta = 'copy' },
                        ['mGameState'] = { meta = 'copy'},
                        ['mParty'] =
                        {
                            meta = 'marked',
                            meta_before_patch = function(data, source, scheme, dataParent, id)
                                dataParent[id] = Party:Create() -- clear the mParty table
                                local members = source.mMembers
                                for k, v in pairs(members) do
                                    local def = gPartyMemberDefs[v.mId]
                                    local actor = Actor:Create(def)
                                    dataParent[id]:Add(actor)
                                end
                                print("created patry from save")
                                PrintTable(gGame.World.mParty)
                            end,
                            fields =
                            {
                                ['mMembers'] =
                                {
                                    meta = 'each',
                                    value =
                                    {
                                        meta = 'marked',
                                        fields =
                                        {
                                            ['mId'] = { meta = 'copy' },
                                            ['mLevel'] = { meta = 'copy'},
                                            ['mXP'] = { meta = 'copy' },
                                            ['mNextLevelXP'] = { meta = 'copy'},
                                            ['mStats'] =
                                            {
                                                meta = 'marked',
                                                fields =
                                                {
                                                    ['mBase'] = { meta = 'copy' },
                                                    ['mModifiers'] = { meta = 'copy' },
                                                }
                                            },
                                            ['mActiveEquipSlots'] = { meta = 'copy' },
                                            ['mActions'] = { meta = 'copy' },
                                            ['mEquipment'] = { meta = 'copy' },
                                            ['mSpecial'] = { meta = 'copy' },
                                            ['mMagic'] = { meta = 'copy' },
                                        }
                                    }
                                }
                            }

                        }
                    }
                },
            }
        }
    },
    meta_after_patch = function(data, save, scheme, dataParent, id)

        -- Clear the stack
        gGame.Stack = StateStack:Create()

        for k, v in pairs(save) do
            print(k,v)
        end

        local stackData = save['gGame']['Stack']
        local map = MapDB[stackData.mapId]
        map = map(gGame.World.mGameState)
        local startPos = Vector.Create(stackData.x,
                                       stackData.y,
                                       stackData.layer)

        local explore = ExploreState:Create(gGame.Stack,
                                            map,
                                            startPos)
        gGame.Stack:Push(explore)

    end
}
