AnimEntityFx = {}
AnimEntityFx.__index = AnimEntityFx
function AnimEntityFx:Create(x, y, def, frames, spf)

    spf = spf or 0.015

    local this =
    {
        mEntity = Entity:Create(def),
        mAnim = Animation:Create(frames, false, spf),
        mPriority = 2,
    }
    this.mEntity.mX = x
    this.mEntity.mY = y
    this.mEntity.mSprite:SetPosition(x, y)
    setmetatable(this, self)
    return this
end

function AnimEntityFx:Update(dt)
    self.mAnim:Update(dt)
    self.mEntity:SetFrame(self.mAnim:Frame())
end

function AnimEntityFx:Render(renderer)
    self.mEntity:Render(renderer)
end

function AnimEntityFx:IsFinished()
    return self.mAnim:IsFinished()
end