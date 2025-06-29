local TweenService = game:GetService("TweenService")

local TWEEN_DEFAULT = TweenInfo.new()
local TWEEN_BEGIN = Enum.PlaybackState.Begin
local TWEEN_PAUSED = Enum.PlaybackState.Paused
local TWEEN_COMPLETED = Enum.PlaybackState.Completed

local Tween = {}
Tween.ClassName = "Tween"
Tween.__index = Tween

export type TweenProperties = {
	_TweenObject: NumberValue?,
	_Tween: Tween?,

	_TargetValue: number,
	_InitialValue: number | boolean,
}

function Tween.new(targetValue: number, tweenInfo: TweenInfo?)
	assert(targetValue, "Missing argument #1: targetValue")

	local tweenObject = Instance.new("NumberValue")

	local tweenProperties: TweenProperties = {
		_TweenObject = tweenObject;
		_Tween = TweenService:Create(tweenObject, tweenInfo or TWEEN_DEFAULT, {Value = targetValue});

		_TargetValue = targetValue;
		_InitialValue = false;
	}

	return setmetatable(tweenProperties, Tween)
end

function Tween:step(state, delta)
	local tween = self._Tween
	local tweenObject = self._TweenObject
	local playbackState = tween.PlaybackState

	if (not self._InitialValue) then
		self._InitialValue = state.value
		tweenObject.Value = self._InitialValue
	end

	if (playbackState == TWEEN_BEGIN or playbackState == TWEEN_PAUSED) then
		tweenObject.Value = state.value
		tween:Play()
	elseif (playbackState == TWEEN_COMPLETED) then
		tweenObject:Destroy()
		tween:Destroy()

		self._TweenObject:Destroy()
		self._Tween:Destroy()

		self._TweenObject = nil
		self._Tween = nil
		self._TargetValue = nil
		self._InitialValue = nil
	end

	while (self._InitialValue and tweenObject.Value == state.value) do task.wait() end

	tween:Pause()

	return {
		complete = playbackState == TWEEN_COMPLETED;
		value = tweenObject.Value;
	}
end

return Tween
