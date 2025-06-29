

export type WobblerOptions = {
	damper: number,
	position: number,
	speed: number,
	velocity: number,
}

local VELOCITY_THRESHOLD = 0.001
local POSITION_THRESHOLD = 0.001

local Spring = {}

function Spring.new(initial, clock)
	local target = initial or 0
	clock = clock or os.clock
	return setmetatable({
		_clock = clock,
		_time0 = clock(),
		_position0 = target,
		_velocity0 = 0 * target,
		_target = target,
		_damper = 1,
		_speed = 1,
	}, Spring)
end

function Spring:Impulse(velocity)
	self.Velocity = self.Velocity + velocity
end

function Spring:__index(index)
	if Spring[index] then
		return Spring[index]
	elseif index == "Value" or index == "Position" or index == "p" then
		local position, _ = self:_positionVelocity(self._clock())
		return position
	elseif index == "Velocity" or index == "v" then
		local _, velocity = self:_positionVelocity(self._clock())
		return velocity
	elseif index == "Target" or index == "t" then
		return self._target
	elseif index == "Damper" or index == "d" then
		return self._damper
	elseif index == "Speed" or index == "s" then
		return self._speed
	elseif index == "Clock" then
		return self._clock
	else
		error(("%q is not a valid member of Spring"):format(tostring(index)), 2)
	end
end

function Spring:__newindex(index, value)
	local now = self._clock()

	if index == "Value" or index == "Position" or index == "p" then
		local _, velocity = self:_positionVelocity(now)
		self._position0 = value
		self._velocity0 = velocity
		self._time0 = now
	elseif index == "Velocity" or index == "v" then
		local position, _ = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = value
		self._time0 = now
	elseif index == "Target" or index == "t" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._target = value
		self._time0 = now
	elseif index == "Damper" or index == "d" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._damper = value
		self._time0 = now
	elseif index == "Speed" or index == "s" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._speed = value < 0 and 0 or value
		self._time0 = now
	elseif index == "Clock" then
		local position, velocity = self:_positionVelocity(now)
		self._position0 = position
		self._velocity0 = velocity
		self._clock = value
		self._time0 = value()
	else
		error(("%q is not a valid member of Spring"):format(tostring(index)), 2)
	end
end

function Spring:_positionVelocity(now)
	local p0 = self._position0
	local v0 = self._velocity0
	local p1 = self._target
	local d = self._damper
	local s = self._speed

	local t = s * (now - self._time0)
	local d2 = d * d

	local h, si, co
	if d2 < 1 then
		h = math.sqrt(1 - d2)
		local ep = math.exp(-d * t) / h
		co, si = ep * math.cos(h * t), ep * math.sin(h * t)
	elseif d2 == 1 then
		h = 1
		local ep = math.exp(-d * t) / h
		co, si = ep, ep * t
	else
		h = math.sqrt(d2 - 1)
		local u = math.exp((-d + h) * t) / (2 * h)
		local v = math.exp((-d - h) * t) / (2 * h)
		co, si = u + v, u - v
	end

	local a0 = h * co + d * si
	local a1 = 1 - (h * co + d * si)
	local a2 = si / s

	local b0 = -s * si
	local b1 = s * si
	local b2 = h * co - d * si

	return a0 * p0 + a1 * p1 + a2 * v0, b0 * p0 + b1 * p1 + b2 * v0
end

local Wobbler = {}
Wobbler.ClassName = "ImpulseSpring"
Wobbler.__index = Wobbler

function Wobbler.new(impulse: number, options: WobblerOptions?)
    options = options or {}
	local spring = Spring.new(0)
	spring.Damper = options.damper or .5
	spring.Speed = options.speed or 3
	spring.Velocity = options.velocity or 1

	return setmetatable({
		_spring = spring,
		_implulse = impulse,
	}, Wobbler)
end

function Wobbler:init(state)
	self._spring.Position = state.initValue
	self._spring.Target = state.initValue
	self._initValue = state.initValue

	self._spring:Impulse(self._implulse)
end

function Wobbler:step(state, _dt)
	local target, v1, p1 = self._spring.Target, self._spring.Velocity, self._spring.Position

	local complete = math.abs(v1) < VELOCITY_THRESHOLD and math.abs(p1 - target) < POSITION_THRESHOLD

	return {
		complete = complete,
		value = complete and target or p1,
		velocity = v1,
		initValue = self._initValue,
	}
end

return Wobbler