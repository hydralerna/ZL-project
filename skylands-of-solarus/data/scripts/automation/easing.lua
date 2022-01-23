-- Robert Penner's easing equations.
--
-- Usage:
-- local easing = require("automation/easing")
-- local value = easing.quad_in(elapsed_time, begin, delta, animation_duration)

-------------------------------------------------------------------------------
-- Copyright (c) 2001 Robert Penner
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--  * Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright
--    notice, this list of conditions and the following disclaimer in the
--    documentation and/or other materials provided with the distribution.
--  * Neither the name of the author nor the names of contributors may be used
--    to endorse or promote products derived from this software without
--    specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

-- Easing equation function for a simple linear tweening, with no easing.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function linear(t, b, c, d)
  return c * t / d + b
end

-------------------------------------------------------------------------------

-- Easing equation function for a quadratic (t^2) easing in:
-- accelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quad_in(t, b, c, d)
  t = t / d
  return c * math.pow(t, 2) + b
end

-- Easing equation function for a quadratic (t^2) easing out:
-- decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quad_out(t, b, c, d)
  t = t / d
  return -c * t * (t - 2) + b
end

-- Easing equation function for a quadratic (t^2) easing in/out:
-- acceleration until halfway, then deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quad_in_out(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * math.pow(t, 2) + b
  else
    return -c / 2 * ((t - 1) * (t - 3) - 1) + b
  end
end

-- Easing equation function for a quadratic (t^2) easing out/in:
-- deceleration until halfway, then acceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quad_out_in(t, b, c, d)
  if t < d / 2 then
    return quad_out (t * 2, b, c / 2, d)
  else
    return quad_in((t * 2) - d, b + c / 2, c / 2, d)
  end
end

-------------------------------------------------------------------------------

-- Easing equation function for a cubic (t^3) easing in:
-- accelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function cubic_in(t, b, c, d)
  t = t / d
  return c * math.pow(t, 3) + b
end

-- Easing equation function for a cubic (t^3) easing out:
-- decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function cubic_out(t, b, c, d)
  t = t / d - 1
  return c * (math.pow(t, 3) + 1) + b
end

-- Easing equation function for a cubic (t^3) easing in/out:
-- acceleration until halfway, then deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function cubic_in_out(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * t * t * t + b
  else
    t = t - 2
    return c / 2 * (t * t * t + 2) + b
  end
end

-- Easing equation function for a cubic (t^3) easing out/in:
-- deceleration until halfway, then acceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function cubic_out_in(t, b, c, d)
  if t < d / 2 then
    return cubic_out(t * 2, b, c / 2, d)
  else
    return cubic_in((t * 2) - d, b + c / 2, c / 2, d)
  end
end

-------------------------------------------------------------------------------

-- Easing equation function for a quartic (t^4) easing in:
-- accelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quart_in(t, b, c, d)
  t = t / d
  return c * math.pow(t, 4) + b
end

-- Easing equation function for a quartic (t^4) easing out:
-- decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quart_out(t, b, c, d)
  t = t / d - 1
  return -c * (math.pow(t, 4) - 1) + b
end


-- Easing equation function for a quartic (t^4) easing in/out:
-- acceleration until halfway, then deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quart_in_out(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * math.pow(t, 4) + b
  else
    t = t - 2
    return -c / 2 * (math.pow(t, 4) - 2) + b
  end
end

-- Easing equation function for a quartic (t^4) easing out/in:
-- deceleration until halfway, then acceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quart_out_in(t, b, c, d)
  if t < d / 2 then
    return quart_out(t * 2, b, c / 2, d)
  else
    return quart_in((t * 2) - d, b + c / 2, c / 2, d)
  end
end

-------------------------------------------------------------------------------

-- Easing equation function for a quintic (t^5) easing in:
-- accelerating from zero velocity
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quint_in(t, b, c, d)
  t = t / d
  return c * math.pow(t, 5) + b
end

-- Easing equation function for a quintic (t^5) easing out:
-- decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quint_out(t, b, c, d)
  t = t / d - 1
  return c * (math.pow(t, 5) + 1) + b
end

-- Easing equation function for a quintic (t^5) easing in/out:
-- acceleration until halfway, then deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quint_in_out(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return c / 2 * math.pow(t, 5) + b
  else
    t = t - 2
    return c / 2 * (math.pow(t, 5) + 2) + b
  end
end

-- Easing equation function for a quintic (t^5) easing in/out:
-- acceleration until halfway, then deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function quint_out_in(t, b, c, d)
  if t < d / 2 then
    return quint_out(t * 2, b, c / 2, d)
  else
    return quint_in((t * 2) - d, b + c / 2, c / 2, d)
  end
end

-------------------------------------------------------------------------------

-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function sine_in(t, b, c, d)
  return -c * math.cos(t / d * (math.pi / 2)) + c + b
end

-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function sine_out(t, b, c, d)
  return c * math.sin(t / d * (math.pi / 2)) + b
end

-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function sine_in_out(t, b, c, d)
  return -c / 2 * (math.cos(math.pi * t / d) - 1) + b
end

-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function sine_out_in(t, b, c, d)
  if t < d / 2 then
    return sine_out(t * 2, b, c / 2, d)
  else
    return sine_in((t * 2) -d, b + c / 2, c / 2, d)
  end
end

-------------------------------------------------------------------------------

-- Easing equation function for an exponential (2^t) easing in:
-- accelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function expo_in(t, b, c, d)
  if t == 0 then
    return b
  else
    return c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001
  end
end

-- Easing equation function for an exponential (2^t) easing out:
-- decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function expo_out(t, b, c, d)
  if t == d then
    return b + c
  else
    return c * 1.001 * (-math.pow(2, -10 * t / d) + 1) + b
  end
end

-- Easing equation function for an exponential (2^t) easing out:
-- decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function expo_in_out(t, b, c, d)
  if t == 0 then
    return b
  end
  if t == d then
    return b + c
  end
  t = t / d * 2
  if t < 1 then
    return c / 2 * math.pow(2, 10 * (t - 1)) + b - c * 0.0005
  else
    t = t - 1
    return c / 2 * 1.0005 * (-math.pow(2, -10 * t) + 2) + b
  end
end

-- Easing equation function for an exponential (2^t) easing out/in:
-- deceleration until halfway, then acceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function expo_out_in(t, b, c, d)
  if t < d / 2 then
    return expo_out(t * 2, b, c / 2, d)
  else
    return expo_in((t * 2) - d, b + c / 2, c / 2, d)
  end
end

-------------------------------------------------------------------------------

-- Easing equation function for a circular (sqrt(1-t^2)) easing in:
-- accelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function circ_in(t, b, c, d)
  t = t / d
  return(-c * (math.sqrt(1 - math.pow(t, 2)) - 1) + b)
end

-- Easing equation function for a circular (sqrt(1-t^2)) easing out:
-- decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function circ_out(t, b, c, d)
  t = t / d - 1
  return(c * math.sqrt(1 - math.pow(t, 2)) + b)
end

-- Easing equation function for a circular (sqrt(1-t^2)) easing in/out:
-- acceleration until halfway, then deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function circ_in_out(t, b, c, d)
  t = t / d * 2
  if t < 1 then
    return -c / 2 * (math.sqrt(1 - t * t) - 1) + b
  else
    t = t - 2
    return c / 2 * (math.sqrt(1 - t * t) + 1) + b
  end
end

-- Easing equation function for a circular (sqrt(1-t^2)) easing in/out:
-- acceleration until halfway, then deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function circ_out_in(t, b, c, d)
  if t < d / 2 then
    return circ_out(t * 2, b, c / 2, d)
  else
    return circ_in((t * 2) - d, b + c / 2, c / 2, d)
  end
end

-------------------------------------------------------------------------------

-- Easing equation function for an elastic (exponentially decaying sine wave)
-- easing in: accelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function elastic_in(t, b, c, d, a, p)
  if t == 0 then
    return b
  end
  t = t / d
  if t == 1 then
    return b + c
  end
  if not p then
    p = d * 0.3
  end
  local s
  if not a or a < math.abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * math.pi) * math.asin(c/a)
  end
  t = t - 1
  return -(a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
end

-- Easing equation function for an elastic (exponentially decaying sine wave)
-- easing out: decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
-- a = amplitud
-- p = period
local function elastic_out(t, b, c, d, a, p)
  if t == 0 then
    return b
  end
  t = t / d
  if t == 1 then
    return b + c
  end
  if not p then
    p = d * 0.3
  end
  local s
  if not a or a < math.abs(c) then
    a = c * 0.5
    s = p / 4
  else
    s = p / (2 * math.pi) * math.asin(c/a)
  end
  return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p) + c + b
end

-- Easing equation function for an elastic (exponentially decaying sine wave)
-- easing in/out: acceleration until halfway, then deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
-- a = amplitud
-- p = period
local function elastic_in_out(t, b, c, d, a, p)
  if t == 0 then
    return b
  end
  t = t / d * 2
  if t == 2 then
    return b + c
  end
  if not p then
    p = d * (0.3 * 1.5)
  end
  if not a then
    a = 0
  end
  local s
  if not a or a < math.abs(c) then
    a = c
    s = p / 4
  else
    s = p / (2 * math.pi) * math.asin(c / a)
  end
  if t < 1 then
    t = t - 1
    return -0.5 * (a * math.pow(2, 10 * t) * math.sin((t * d - s) * (2 * math.pi) / p)) + b
  else
    t = t - 1
    return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * math.pi) / p ) * 0.5 + c + b
  end
end

-- Easing equation function for an elastic (exponentially decaying sine wave)
-- easing out/in: deceleration until halfway, then acceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
-- a = amplitud
-- p = period
local function elastic_out_in(t, b, c, d, a, p)
  if t < d / 2 then
    return elastic_out(t * 2, b, c / 2, d, a, p)
  else
    return elastic_in((t * 2) - d, b + c / 2, c / 2, d, a, p)
  end
end

-------------------------------------------------------------------------------

-- Easing equation function for a back (overshooting cubic easing
-- (s+1)*t^3 - s*t^2) easing in: accelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
-- s = 
local function back_in(t, b, c, d, s)
  if not s then
    s = 1.70158
  end
  t = t / d
  return c * t * t * ((s + 1) * t - s) + b
end

-- Easing equation function for a back (overshooting cubic easing
-- (s+1)*t^3 - s*t^2) easing out: decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
-- s = 
local function back_out(t, b, c, d, s)
  if not s then
    s = 1.70158
  end
  t = t / d - 1
  return c * (t * t * ((s + 1) * t + s) + 1) + b
end

-- Easing equation function for a back (overshooting cubic easing
-- (s+1)*t^3 - s*t^2) easing in/out: acceleration until halfway, then 
-- deceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
-- s =
local function back_in_out(t, b, c, d, s)
  if not s then
    s = 1.70158
  end
  s = s * 1.525
  t = t / d * 2
  if t < 1 then
    return c / 2 * (t * t * ((s + 1) * t - s)) + b
  else
    t = t - 2
    return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
  end
end

-- Easing equation function for a back (overshooting cubic easing
-- (s+1)*t^3 - s*t^2) easing out/in: deceleration until halfway, then
-- acceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
-- s =
local function back_out_in(t, b, c, d, s)
  if t < d / 2 then
    return back_out(t * 2, b, c / 2, d, s)
  else
    return back_in((t * 2) - d, b + c / 2, c / 2, d, s)
  end
end

-------------------------------------------------------------------------------

--Easing equation function for a bounce (exponentially decaying parabolic 
-- bounce) easing out: decelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function bounce_out(t, b, c, d)
  t = t / d
  if t < 1 / 2.75 then
    return c * (7.5625 * t * t) + b
  elseif t < 2 / 2.75 then
    t = t - (1.5 / 2.75)
    return c * (7.5625 * t * t + 0.75) + b
  elseif t < 2.5 / 2.75 then
    t = t - (2.25 / 2.75)
    return c * (7.5625 * t * t + 0.9375) + b
  else
    t = t - (2.625 / 2.75)
    return c * (7.5625 * t * t + 0.984375) + b
  end

-- Easing equation function for a bounce (exponentially decaying parabolic
-- bounce) easing in: accelerating from zero velocity.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function bounce_in(t, b, c, d)
  return c - bounce_out(d - t, 0, c, d) + b
end
end

-- Easing equation function for a bounce (exponentially decaying parabolic
-- bounce) easing in/out: acceleration until halfway, then deceleration
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function bounce_in_out(t, b, c, d)
  if t < d / 2 then
    return bounce_in(t * 2, 0, c, d) * 0.5 + b
  else
    return bounce_out(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
  end
end

-- Easing equation function for a bounce (exponentially decaying parabolic
-- bounce) easing out/in: deceleration until halfway, then acceleration.
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration
local function bounce_out_in(t, b, c, d)
  if t < d / 2 then
    return bounce_out(t * 2, b, c / 2, d)
  else
    return bounce_in((t * 2) - d, b + c / 2, c / 2, d)
  end
end


-------------------------------------------------------------------------------

-- A table for easy access to the library of functions.
return {
  linear = linear,
  quad_in = quad_in,
  quad_out = quad_out,
  quad_in_out = quad_in_out,
  quad_out_in = quad_out_in,
  cubic_in  = cubic_in,
  cubic_out = cubic_out,
  cubic_in_out = cubic_in_out,
  cubic_out_in = cubic_out_in,
  quart_in = quart_in,
  quart_out = quart_out,
  quart_in_out = quart_in_out,
  quart_out_in = quart_out_in,
  quint_in = quint_in,
  quint_out = quint_out,
  quint_in_out = quint_in_out,
  quint_out_in = quint_out_in,
  sine_in = sine_in,
  sine_out = sine_out,
  sine_in_out = sine_in_out,
  sine_out_in = sine_out_in,
  expo_in = expo_in,
  expo_out = expo_out,
  expo_in_out = expo_in_out,
  expo_out_in = expo_out_in,
  circ_in = circ_in,
  circ_out = circ_out,
  circ_in_out = circ_in_out,
  circ_out_in = circ_out_in,
  elastic_in = elastic_in,
  elastic_out = elastic_out,
  elastic_in_out = elastic_in_out,
  elastic_out_in = elastic_out_in,
  back_in = back_in,
  back_out = back_out,
  back_in_out = back_in_out,
  back_out_in = back_out_in,
  bounce_in = bounce_in,
  bounce_out = bounce_out,
  bounce_in_out = bounce_in_out,
  bounce_out_in = bounce_out_in,
}
