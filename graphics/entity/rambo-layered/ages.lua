-- per-age factors for the layered Rambo sprites (body/shirt/shadow scale and shift multiply by body_scale)
return
{
  toddler = { body_scale = 0.3986, shirt_tint = {r = 0.5690, g = 0.6165, b = 0.4324} },
  child = { body_scale = 0.6109, shirt_tint = {r = 1.0000, g = 0.2879, b = 0.2473} },
  teen = { body_scale = 0.8179, shirt_tint = {r = 0.2879, g = 0.4966, b = 0.9583} },
  adult = { body_scale = 1.0000, shirt_tint = nil },
}
