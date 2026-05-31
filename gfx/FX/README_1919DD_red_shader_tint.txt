1919DD red atmospheric pass
===========================

The uploaded mod package did not contain these shader files:

- gfx/FX/pdxmap.shader
- gfx/FX/terrain.shader
- gfx/FX/water.shader

Because the source shader files are absent from the mod package, this package does not invent replacement .shader files. A blind shader replacement can crash HOI4 at launch or break map rendering if it is not based on the exact vanilla shader source for your current HOI4 version.

What this package changes instead:

- map/terrain/colormap_water_0.dds
- map/terrain/colormap_water_1.dds
- map/terrain/colormap_water_2.dds
- map/terrain/underwater_terrain_0.dds
- map/terrain/underwater_terrain_1.dds
- map/terrain/underwater_terrain_2.dds
- map/terrain/colormap_rgb_cityemissivemask_a.dds
- map/terrain/reflection.dds

These DDS edits make the sea, underwater layer, reflections, and broad map atmosphere redder while preserving each DDS header, dimensions, mip count, and pixel format.

If you want real shader edits later, copy your current vanilla HOI4 shader files into the mod at gfx/FX/ and patch the final output color in each pixel shader with a small red grading function like:

float3 Apply1919DDRedGrade(float3 c)
{
    c.r = saturate(c.r * 1.10 + 0.025);
    c.g = saturate(c.g * 0.92);
    c.b = saturate(c.b * 0.84);
    return c;
}

Then apply it immediately before the shader returns its final color, for example:

OutColor.rgb = Apply1919DDRedGrade(OutColor.rgb);

Do this only on shader source matching your exact HOI4 version.
