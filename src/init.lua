local Flipper = {
	SingleMotor = require(script.SingleMotor),
	GroupMotor = require(script.GroupMotor),

	Instant = require(script.Instant),
	Linear = require(script.Linear),
	Spring = require(script.Spring),
	Tween = require(script.Tween),
	Wobbler = require(script.Wobbler),

	isMotor = require(script.isMotor),
}

export type SingleMotor = typeof(Flipper.SingleMotor.new(0, false))
export type GroupMotor = typeof(Flipper.GroupMotor.new(0, false))

export type Instant = typeof(Flipper.Instant.new(0))
export type Linear = typeof(Flipper.Linear.new(0))
export type Spring = typeof(Flipper.Spring.new(0))
export type Tween = typeof(Flipper.Tween.new(0))
export type Wobbler = typeof(Flipper.Wobbler.new(0))


return Flipper :: {
	SingleMotor: SingleMotor,
	GroupMotor: GroupMotor,
	Instant: Instant,
	Linear: Linear,
	Spring: Spring,
	Tween: Tween,
	Wobbler: Wobbler,
}