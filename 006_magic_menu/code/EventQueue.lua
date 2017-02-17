
EventQueue = {}
EventQueue.__index = EventQueue
function EventQueue:Create()
    local this =
    {
        mQueue = {},
    }

    setmetatable(this, self)
    return this
end


function EventQueue:Add(event, timePoints)
    local queue = self.mQueue

    -- Instant event
    if timePoints == -1 then
        event.mCountDown = -1
        table.insert(queue, 1, event)
    else
        event.mCountDown = timePoints

        -- loop through events
        for i = 1, #queue do
            local count = queue[i].mCountDown

            if count > event.mCountDown then
                table.insert(queue, i, event)
                return
            end

        end

        table.insert(queue, event)
    end
end

function EventQueue:SpeedToTimePoints(speed)
    local maxSpeed = 255
    speed = math.min(speed, 255)
    local points = maxSpeed - speed
    return math.floor(points)
end

    function EventQueue:SpeedToTimePoints(speed)
        local maxSpeed = 255
        speed = Clamp(speed, 0, maxSpeed)
        local points = maxSpeed - speed
        return math.floor(points)
    end

function EventQueue:Update()

    for _, v in ipairs(self.mQueue) do
        v.mCountDown = math.max(0, v.mCountDown - 1)
    end

    if self.mCurrentEvent ~= nil then

        self.mCurrentEvent:Update()

        if self.mCurrentEvent:IsFinished() then
            self.mCurrentEvent = nil
        else
            return
        end


    elseif self:IsEmpty() then

        return

    else

        -- Need to chose an event
        local front =  table.remove(self.mQueue, 1)
        print("removing from front", front.mName, front.mCountDown)
        front:Execute(self)
        self.mCurrentEvent = front

    end

end

function EventQueue:Clear()
    self.mQueue = {}
    self.mCurrentEvent = nil
end


function EventQueue:IsEmpty()
    return self.mQueue == nil or next(self.mQueue) == nil
end

function EventQueue:ActorHasEvent(actor)

    local current = self.mCurrentEvent or {}

    if current.mOwner == actor then
        return true
    end

    for k, v in ipairs(self.mQueue) do
        if v.mOwner == actor then
            return true
        end
    end

    return false
end


function EventQueue:RemoveEventsOwnedBy(actor)

    for i = #self.mQueue, 1, -1 do
        local v = self.mQueue[i]
        if v.mOwner == actor then
            table.remove(self.mQueue, i)
        end
    end

end

function EventQueue:Print()

    local queue = self.mQueue

    if self:IsEmpty() then
       print("Event Queue is empty.")
       return
    end

    print("Event Queue:")

    local current = self.mCurrentEvent or {}

    print("Current Event: ", current.mName)

    for k, v in ipairs(queue) do
        local out = string.format("[%d] Event: [%d][%s]",
                                  k, v.mCountDown, v.mName)
        print(out)
    end
end

function EventQueue:Render(x, y, renderer)

    local yInc = 15

    renderer:ScaleText(1, 1)
    renderer:AlignText("left", "top")
    renderer:DrawText2d(x, y, "EVENT QUEUE")
    local current = self.mCurrentEvent or {}
    y = y - yInc
    renderer:DrawText2d(x, y, string.format("CURRENT: %s", tostring(current.mName or "None")))

    y = y - yInc * 1.5

    if not next(self.mQueue) then
        renderer:DrawText2d(x, y, "EMPTY!")
    end

    for k, v in ipairs(self.mQueue) do
        local out = string.format("[%d] Event: [%d][%s]",
                                  k, v.mCountDown, v.mName)
        renderer:DrawText2d(x, y, out)
        y = y - yInc
    end
end