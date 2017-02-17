--
-- Dan Schuller: Tween Class based on Flash
--

Tween = {}
Tween.__index = Tween

function Tween:IsFinished()
	return self.isFinished
end

function Tween:Value()
	return self.current
end

function Tween.EaseInQuad(t, b, c, d)
	t = t / d
	return c * t * t + b
end

function Tween.EaseOutQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

function Tween.EaseInCirc(t, b, c, d)
	t = t / d
	return -c * (math.sqrt(1 - t*t) - 1) + b;
end

function Tween.EaseOutCirc(t, b, c, d)
	t = t / d - 1
	return c * math.sqrt(1 - t*t) + b;
end

function Tween.EaseOutInCirc(t, b, c, d)
	if (t < d/2) then
		return Tween.EaseOutCirc(t*2, b, c/2, d)
	end
	return Tween.EaseInCirc((t*2)-d, b+c/2, c/2, d)
end

function Tween.EaseInOutElastic(t, b, c, d, a, p)
	if (t==0) then
		return b
	end
	t = t / (d / 2)
	if (t==2) then
		return b+c
	end
	if (not p) then
		p=d*(.3*1.5)
	end
	if ((not a) or a < Math.abs(c)) then
		a=c
		s=p/4
	else
		s = p/(2*math.pi) * math.asin(c/a)
	end
	if (t < 1) then
		t = t - 1
		return -.5*(a*math.pow(2,10*t) * math.sin( (t*d-s)*(2*math.pi)/p )) + b
	end
	t = t - 1
	return a*math.pow(2,-10*t) * math.sin( (t*d-s)*(2*math.pi)/p )*.5 + c + b
end

function Tween.EaseOutElastic(t, b, c, d, a, p)

	local s = 1.70158
    local a = c

    if 0 == t then
    	return b;
    end

    t = t / d
    if t == 1 then
		return b + c
	end

    if not p then
    	p = d *.3
    end

    if a < math.abs(c) then
        a = c
        s = p / 4
    else
        s = p / (2 * math.pi) * math.asin(c / a);
    end

    return a * math.pow(2, -10 * t) * math.sin( (t * d - s) * (2 * math.pi) / p) + c + b;
end

function Tween.EaseInElastic(t, b, c, d, a, p)

	local a = c
	local s = 1.70158

	if 0 == t then
		return b
	end

	t = t / d
	if t == 1 then
		return b + c
	end

	if not p then
		p = d * .3
	end

	if a < math.abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * math.pi) * math.asin(c / a)
	end

	t = t - 1
	return -(a* math.pow(2, 10 * t) * math.sin( (t * d - s) * (2 * math.pi) /p )) + b;
end

function Tween.EaseInExpo(t, b, c, d)
	return c * math.pow( 2, 10 * (t/d - 1) ) + b
end


function Tween.EaseInBounce(t, b, c, d)
	return c - Tween.EaseOutBounce(d-t, 0, c, d) + b
end

-- Easing equation function for a bounce (exponentially decaying parabolic bounce) easing out: decelerating from zero velocity.
--
-- @param t		Current time (in frames or seconds).
-- @param b		Starting value.
-- @param c		Change needed in value.
-- @param d		Expected easing duration (in frames or seconds).
-- @return		The correct value.
--
function Tween.EaseOutBounce(t, b, c, d)
	t = t / d
	if (t < (1/2.75)) then
		return c*(7.5625*t*t) + b
	end
	if (t < (2/2.75)) then
		t = t - (1.5/2.75)
		return c*(7.5625*t*t + .75) + b
	end
	if (t < (2.5/2.75)) then
		t = t - (2.25/2.75)
		return c*(7.5625*t*t + .9375) + b
	end

	t = t - (2.625/2.75)
	return c*(7.5625*t*t + .984375) + b
end

-- Easing equation function for a bounce (exponentially decaying parabolic bounce) easing in/out: acceleration until halfway, then deceleration.
--
-- @param t		Current time (in frames or seconds).
-- @param b		Starting value.
-- @param c		Change needed in value.
-- @param d		Expected easing duration (in frames or seconds).
-- @return		The correct value.
--
function Tween.EaseInOutBounce(t, b, c, d)
	if (t < d/2) then
		return Tween.EaseInBounce (t*2, 0, c, d) * .5 + b
	else
		return Tween.EaseOutBounce (t*2-d, 0, c, d) * .5 + c*.5 + b
	end
end

function Tween.Linear(timePassed, start, distance, duration)
	return distance * timePassed / duration + start
end

function Tween:FinishValue()
	return self.startValue + self.distance
end

function Tween:Update(elapsedTime)
	 self.timePassed = self.timePassed + (elapsedTime or GetDeltaTime())
	 self.current = self.tweenF(self.timePassed, self.startValue, self.distance, self.totalDuration)

   if self.timePassed > self.totalDuration then
    	self.current = self.startValue + self.distance
    	self.isFinished = true
    end
end

--
--@start				start value
--@finish				end value
--@totalDuration  		time in which to perform tween.
--@tweenF				tween function defaults to linear
function Tween:Create(start, finish, totalDuration, tweenF)
	local this =
	{
		tweenF = tweenF or Tween.Linear,
		distance = finish - start,
		startValue = start,
		current = start,
		totalDuration = totalDuration,
		timePassed = 0,
		isFinished = false
	}
	setmetatable(this, self)
	return this
end