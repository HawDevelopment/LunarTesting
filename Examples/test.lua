--[[
    Tests
    HawDevelopment
    26/10/2021
--]]

local Will = require("src.will")

return {
	["undefined variable should never exist"] = function(skip)
		error("undefined variable should never exist")
	end,

	["1+1 should equal 2"] = function(skip)
		Will(1 + 1).equal(2)
	end,

	["tests can write full sentences"] = function(skip)
		Will(true).you.can.write.anything.as.long.as.it.ends.with.a.valid.assertion.like.exist()
	end,

	["this test will skip"] = function(skip)
		skip("because we are demonstrating the skip feature")

		warn("This line won't run because it is skipped")
	end,

	["no-op will never throw"] = function(skip)
		Will(function() end).never.fail()
	end,

	["this test will fail"] = function(skip)
		error("this test will fail") -- this("sample string").matches("a pattern that isn't in the value")
	end,

	["Random:NextNumber() should be a number value"] = function(skip)
		Will(math.random(1, 3)).be.a("number")
	end,
}