Save =
{
    mSaveGame = SaveGame.Create("save.dat")
}

function Save:Copy(source)
    if type(source) == "table" then
        return DeepClone(source)
    else
        return source
    end
end

function Save:ExtractEach(t, scheme)
    local data = {}
    for k, v in pairs(t) do
        data[k] = Save:Extract(v, scheme)
    end
    return data
end

function Save:ExtractMarked(t, scheme)
    local data = {}

    for id, v in pairs(scheme) do
        local source = t[id]
        data[id] = Save:Extract(source, v)
    end

    return data
end

function Save:Extract(source, scheme)
    if scheme.meta == 'marked' then
        return Save:ExtractMarked(source, scheme.fields)
    elseif scheme.meta == 'copy' then
        return Save:Copy(source)
    elseif scheme.meta == 'each' then
        return Save:ExtractEach(source, scheme.value)
    elseif scheme.meta == 'function' then
        return scheme.meta_extract_function(source, scheme)
    end
end



function Save:PatchEach(data, save, scheme)
    for id, v in pairs(save) do
        Save:Patch(data[id], save[id], scheme, data, id)
    end
end

function Save:Patch(data, save, scheme, dataParent, id)
    local meta = scheme.meta

    if scheme.meta_before_patch then
        scheme.meta_before_patch(dataParent, save,
                                 scheme, dataParent, id)
    end

    if meta == 'marked' then
        Save:PatchMarked(data, save, scheme.fields)
        if dataParent then
            dataParent[id] = data
        end
    elseif meta == 'copy' then
        dataParent[id] = Save:Copy(save)
    elseif meta == 'each' then
        -- Create entry if it's missing
        --print('each', id, dataParent == gWorld)
        dataParent[id] = dataParent[id] or {}
        Save:PatchEach(data, save, scheme.value)
    end

    if scheme.meta_after_patch then
        scheme.meta_after_patch(dataParent, save,
                                scheme, dataParent, id)
    end
end

function Save:PatchMarked(data, save, scheme)

    for id, v in pairs(scheme) do
        Save:Patch(data[id], save[id], v, data, id)
    end

end

function Save:DoesExist()
    return not (self.mSaveGame:Read() == "")
end

function Save:Save()
    local tmpSave = self:Extract(_G, SaveScheme)
    self.mSaveGame:Write(Blob:Encode(tmpSave))
end

function Save:Load()
    local tmpSave = self.mSaveGame:Read()
    if tmpSave == "" then
        return
    end
    tmpSave = Blob:Decode(tmpSave)
    self:Patch(_G, tmpSave, SaveScheme)
end