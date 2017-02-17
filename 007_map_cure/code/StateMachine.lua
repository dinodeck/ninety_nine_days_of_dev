--
-- StateMachine - a state machine
--
-- Usage:
--
-- -- States are only created as need, to save memory, reduce clean-up bugs and increase speed
-- -- due to garbage collection taking longer with more data in memory.
-- --
-- -- States are added with a string identifier and an intialisation function.
-- -- It is expect the init function, when called, will return a table with
-- -- Render, Update, Enter and Exit methods.
--
-- gStateMachine = StateMachine:Create
-- {
-- 		['MainMenu'] = function()
-- 			return MainMenu:Create()
-- 		end,
-- 		['InnerGame'] = function()
-- 			return InnerGame:Create()
-- 		end,
-- 		['GameOver'] = function()
-- 			return GameOver:Create()
-- 		end,
-- }
-- gStateMachine:Change("MainGame")
--
-- Arguments passed into the Change function after the state name
-- will be forwarded to the Enter function of the state being changed too.
--
-- State identifiers should have the same name as the state table, unless there's a good
-- reason not to. i.e. MainMenu creates a state using the MainMenu table. This keeps things
-- straight forward.
--
-- =Doing Transistions=
--
StateMachine = {}
StateMachine.__index = StateMachine
function StateMachine:Create(states)
	local this =
	{
		mEmpty =
		{
			Render = function() end,
			Update = function() end,
			Enter = function() end,
			Exit = function() end
		},
		mStates = states or {}, -- [name] -> [function that returns state]
		mCurrent = nil,
	}

	this.mCurrent = this.mEmpty
	setmetatable(this, self)
	return this
end

function StateMachine:Change(stateName, enterParams)
	assert(self.mStates[stateName]) -- state must exist!
	self.mCurrent:Exit()
	self.mCurrent = self.mStates[stateName]()
	self.mCurrent:Enter(enterParams)
end

function StateMachine:Update(dt)
	self.mCurrent:Update(dt)
end

function StateMachine:Render(renderer)
	self.mCurrent:Render(renderer)
end

function StateMachine:Current()
	return self.mCurrent
end