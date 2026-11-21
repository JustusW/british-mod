-- Pot of gold at the throw release (throw sheet frame index 7; the pot is still drawn in his hand on that frame), per direction 0 = north, clockwise.
-- Tiles relative to the entity position. ground = {x, y} under the pot (game axes, y south), height = metres above ground,
-- screen = sprite-space offset {x, y} (what the 45 deg camera shows; y negative = up on screen).
return
{
  {ground = {0.199, -0.685}, height = 0.649, screen = {0.199, -0.944}}, -- 0
  {ground = {0.444, -0.554}, height = 0.649, screen = {0.444, -0.851}}, -- 1
  {ground = {0.622, -0.339}, height = 0.649, screen = {0.622, -0.698}}, -- 2
  {ground = {0.709, -0.076}, height = 0.649, screen = {0.709, -0.513}}, -- 3
  {ground = {0.685, 0.199}, height = 0.649, screen = {0.685, -0.318}}, -- 4
  {ground = {0.554, 0.444}, height = 0.649, screen = {0.554, -0.145}}, -- 5
  {ground = {0.339, 0.622}, height = 0.649, screen = {0.339, -0.019}}, -- 6
  {ground = {0.076, 0.709}, height = 0.649, screen = {0.076, 0.042}}, -- 7
  {ground = {-0.199, 0.685}, height = 0.649, screen = {-0.199, 0.026}}, -- 8
  {ground = {-0.444, 0.554}, height = 0.649, screen = {-0.444, -0.067}}, -- 9
  {ground = {-0.622, 0.339}, height = 0.649, screen = {-0.622, -0.219}}, -- 10
  {ground = {-0.709, 0.076}, height = 0.649, screen = {-0.709, -0.405}}, -- 11
  {ground = {-0.685, -0.199}, height = 0.649, screen = {-0.685, -0.6}}, -- 12
  {ground = {-0.554, -0.444}, height = 0.649, screen = {-0.554, -0.773}}, -- 13
  {ground = {-0.339, -0.622}, height = 0.649, screen = {-0.339, -0.898}}, -- 14
  {ground = {-0.076, -0.709}, height = 0.649, screen = {-0.076, -0.96}}, -- 15
}
