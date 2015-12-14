--[[
/**********************************************************************************************
 * Copyright (c) 2015, Michael Nowotny
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation and/or other
 * materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used
 * to endorse or promote products derived from this software without specific
 * prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
***********************************************************************************************/
]]

-- Standard library imports --
local exp = math.exp
local sqrt = math.sqrt

-- Modules --
local lib = require("lib.af_lib")

local function simulateHestonModel (T, N, R, mu, kappa, vBar, sigmaV, rho, x0, v0)
    local deltaT = T / (N - 1)
    local x = {lib.constant(x0, R), lib.constant(0, R)}
    local v = {lib.constant(v0, R), lib.constant(0, R)}
    local sqrtDeltaT = sqrt(deltaT)
    local sqrtOneMinusRhoSquare = sqrt(1 - rho*rho)
    local mArray = {rho, sqrtOneMinusRhoSquare}
 -- af::array m(2, 1, mArray);
    local tPrevious, tCurrent = 0, 0
    local zeroConstant = lib.constant(0, R)
    for t = 1, N - 1 do -- LoopN
        tPrevious = (t+1) % 2
        tCurrent = t % 2
        local dBt = lib.randn(R, 2) * sqrtDeltaT
        local sqrtVLag = lib.sqrt(v[tPrevious])
    --  x[tCurrent + 1] = x[tPrevious + 1] + (mu - 0.5 * v[tPrevious + 1]) * deltaT + (sqrtVLag * dBt(span, 0))
        local vTmp = v[tPrevious + 1] + kappa * (vBar - v[tPrevious + 1]) * deltaT + sigmaV * (sqrtVLag * lib.matmul(dBt, m))
        v[tCurrent + 1] = af::max(vTmp, zeroConstant)
    end
	return x[tCurrent + 1], v[tCurrent + 1]
end

lib.main(function()
    local T = 1
    local nT = 10 * T
    local R_first_run = 1000
    local R = 20000000
    local x0 = 0 -- initial log stock price
    local v0 = math.pow(0.087, 2) -- initial volatility
    local r = math.log(1.0319) -- risk-free rate
    local rho = -0.82 -- instantaneous correlation between Brownian motions
    local sigmaV = 0.14 -- variance of volatility
    local kappa = 3.46 -- mean reversion speed
    local vBar = 0.008 -- mean variance
    local k = math.log(0.95) -- strike price
    -- Price European call option
	-- first run
	simulateHestonModel(T, nT, R_first_run, r, kappa, vBar, sigmaV, rho, x0, v0) -- CallInEnv
	lib.sync() -- Ensure the first run is finished
	lib.timer_start()
	local x, _ = simulateHestonModel(T, nT, R, r, kappa, vBar, sigmaV, rho, x0, v0)
	lib.sync()
	print("Time in simulation: " .. lib.timer_stop())
	local K = lib.exp(lib.constant(k, x:dims()))
	local zeroConstant = lib.constant(0, x:dims())
	local C_CPU = exp(-r * T) * lib.mean(lib.max(lib.exp(x) - K, zeroConstant))
	lib.print("C_CPU", C_CPU)
end)