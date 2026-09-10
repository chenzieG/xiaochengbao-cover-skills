# BaseEdge six-cover specification

## Input modes and precedence

Determine whether the source is an approved finished cover or a loose/raw reference before composing.

### Approved finished-cover layout-locked extension

Use this mode when a finished BaseEdge cover is supplied with a request to extend, resize, adapt, or output other proportions. The approved composition is locked; the task is canvas extension, not redesign.

- Fit the complete approved composition into each artwork region with one uniform scale and translation. Use the same transform for title, subject, labels, decoration, and their spacing.
- Preserve the transformed source content with a protection mask. Outpaint only canvas pixels outside the protected region so the result remains one seamless image without a visible inset-card boundary.
- Save the transformed source as a protected reference raster and save a binary mask before calling the model. After the model returns, deterministically composite that protected reference back over the generated result. Repeat the restoration after final uniform scaling and outer-bleed trimming so protected output pixels are byte-identical to the expected transformed source.
- Never blend inward across the mask boundary. Any seam treatment must be restricted to pixels outside the mask. Validate `changed_pixel_count=0` and `max_channel_error=0` for every successful variant.
- Never move, resize, regenerate, or re-typeset individual elements. Never change title-to-subject spacing, label-to-subject spacing, line breaks, z-order, or relative scale.
- Classify attached title bars, translucent blocks, highlight rectangles, rules, underlines, frames, arrows, dots, and auxiliary English as `text_packaging`. Capture each element's full source bounds and transform it together with its paired text. All four edges must remain present; partial-height or partial-width packaging is rejected.
- Protect the source background itself, including its exact fabric/paper texture, scanlines, grain, concentric rings, grids, gradients, vignette, color and lighting. Do not generate a lookalike replacement inside source-covered pixels.
- Never tile, mirror, split into crops, or build a collage. A single protected source region plus seamless background outpainting is the allowed method.
- Use the supplied standard logo asset after generation. Never ask the image model to draw it.
- If no separate title is supplied, transcribe the clearly visible source title exactly. If genuinely illegible, fail with a title-identification error.
- If image generation/editing is unavailable, fail. Do not use a scripted montage as fallback.
- `底图` is a dedicated regenerated composition using the special structure below and the same exact title wording.

This section overrides independent composition, responsive layout, and per-element repositioning wherever they conflict.

### New-cover creation

Use this mode for raw subjects, backgrounds, products, people, or layout-only references. Require an exact supplied title and follow the general composition rules below.

## Output matrix

| Variant | Canvas | Artwork area | Branding |
|---|---:|---:|---|
| `竖版` | 1242 x 1660 | 1242 x 1660 at (0,0) | logo lower-right |
| `视频号` | 1080 x 1260 | 960 x 1260 at (60,0) | logo lower-right inside artwork |
| `bilibili` | 1600 x 1000 | 1600 x 1000 at (0,0) | logo lower-right |
| `横版` | 1920 x 1080 | 1920 x 1080 at (0,0) | logo lower-right |
| `公众号` | 900 x 383 | 900 x 383 at (0,0) | logo upper-right |
| `底图` | 1080 x 1260 | 1080 x 422 at (0,0) | logo upper-right inside artwork |

Export PNG in RGB or RGBA without changing pixel dimensions. DPI metadata does not determine digital display size.

### Image API size alignment

The final matrix above remains exact even when an image API accepts only multiples of 16 or enforces a minimum pixel count. Generate on a larger bleed canvas, uniformly downscale the entire result when required, and center-trim only generated outer bleed. Never trim protected source content and never resize or move elements independently.

Use:

```text
m = smallest positive integer satisfying API minimum pixels
API_W = ceil(finalArtworkWidth * m / 16) * 16
API_H = ceil(finalArtworkHeight * m / 16) * 16
postScale = 1 / m
trim = centered outer bleed after postScale
```

Record the API canvas and trim rectangle in `layout_lock_audit`. This technical trim is allowed and does not authorize composition cropping.

The protected-pixel sequence is mandatory: create the final-resolution expected reference and mask; derive the API-resolution pair with the same whole-group transform; restore at API resolution after generation; uniformly downscale and trim; restore the final-resolution pair again; then audit exact equality. Do not return `Protected source pixels changed during generation` merely because the model touched masked pixels—the restoration step must correct that before acceptance.

## Global issue-marker rule

Do not include an issue marker on any variant. Prohibited elements include `VOL.*`, episode numbers used as issue labels, and decorative issue-marker prefixes or suffixes.

## Approximate title regions and minimum visual scale

These ranges are production targets synthesized from the approved BaseEdge portrait, product, and editorial references. They prevent undersized copy and accidental drift; they are not rigid crop boxes. A same-topic approved reference remains the highest authority and may intentionally place the title across a person, product, or central scene.

Measure the complete Chinese title group, including every line but excluding the BaseEdge logo. Measure `text_packaging` separately, then require its complete bounds to remain visible. Font sizes below are approximate rendered capital/character heights, not application point sizes.

| Variant | Approximate complete Chinese-title region | Target title occupancy | Approx. dominant-line character height |
|---|---|---|---:|
| `竖版` 1242 x 1660 | `x=70..1180`, `y=120..650` | width 72–92% of canvas; height 18–32% | 115–195 px |
| `视频号` 1080 x 1260 | inside artwork: `x=90..990`, `y=90..570` | width 72–94% of 960 px artwork; height 20–36% | 95–175 px |
| `bilibili` 1600 x 1000 | `x=120..1510`, `y=80..610` | width 68–91% of canvas; height 24–50% | 90–175 px |
| `横版` 1920 x 1080 | `x=120..1810`, `y=80..630` | width 66–92% of canvas; height 24–50% | 105–195 px |
| `公众号` 900 x 383 | `x=28..760`, `y=25..245` | width 58–82% of canvas; height 38–62% | 48–92 px |
| `底图` upper 1080 x 422 | `x=120..960`, `y=55..350` | width 62–84% of upper region; height 42–70% | 68–125 px |

- These measurements apply to the full title hierarchy, not to every line equally. The hook/supporting line may be smaller, while the dominant phrase or question must sit near the upper half of the character-height range and remain readable at thumbnail size.
- For a two-line editorial title, the dominant second line should normally be at least `1.25x` the supporting first-line character height. If the approved design uses a single-size system, preserve that approved ratio instead.
- Do not reduce a dominant line merely to keep all text in an empty corner. Approved BaseEdge references deliberately allow title-to-subject overlap; preserve that depth relationship while protecting facial identity and critical product geometry.
- For product/device compositions, default to a left-title/right-subject division on wide canvases and an upper-title/lower-subject division on tall canvases. The title should fill its side rather than becoming a small label.
- For portrait/interview compositions, allow the title to span the central space and overlap upper figure zones when the approved reference does so. Do not shrink the scene or title to manufacture unused negative space.
- The title, packaging, English microcopy, and logo are different layers. Enlarging the title does not authorize stretching, cropping, or detaching its highlight, rules, arrows, frames, or subtitle.
- Reject a candidate when the complete Chinese title is below the lower occupancy bound without an approved reference supporting that scale, or when empty space grows because the title was arbitrarily reduced.

## Special pixel regions

### Vertical cover

- Keep the canvas exactly 1242 x 1660 and compare every candidate directly against the approved 1242 x 1660 reference at 100% scale.
- For light editorial portrait covers, use the black BaseEdge logo template at the fixed lower-right platform coordinates and standard size. A white logo on the pale paper/table background is a hard failure.
- Preserve the approved editorial serif Chinese font silhouette. Do not substitute a sans-serif title, narrow the characters, reduce stroke contrast, or shrink the title to create artificial negative space.
- Preserve the approved title block occupancy, especially its near-full-width second line. Record and compare the normalized title bounds, first-to-second-line gap, English-subtitle baseline, and rightmost punctuation position.
- Preserve the approved vertical rhythm as one connected sequence: Chinese title, blue text packaging, English microcopy, interview figures, then table. Do not create a large empty band between the subtitle and the figures by moving the text upward or the scene downward independently.
- Preserve the two-person/table scene as one locked group. Compare both head boxes, shoulder widths, hand positions, chair edges, table horizon, and foreground table crop. Independently enlarging the people or table, lowering the whole scene, or allowing the foreground table to dominate is rejected.
- Keep the approved amount of breathing room between the two figures while maintaining their relative scale. Do not enlarge the right silhouette or left speaker independently.
- Protect facial silhouettes, hairlines, hands, cuffs, suit edges, and table lettering from regeneration. Blown-out face holes, fragmented fingers, missing cuffs, and white erosion artifacts are hard failures.
- Preserve the approved pale-paper tonality, grid, dotted fields, scanlines, and midtone detail. Do not bleach the center background or wash out the people and table until their material separation is lost.
- Preserve the complete blue underline/highlight, arrows, dotted fields, dashed frame, rules, and English subtitle as one `text_packaging` group. Their full bounds and attachment to the title must match the approved reference.
- Do not introduce a conspicuous blue strip or other decorative remnant into the lower-left foreground when it is absent from the approved vertical reference. The approved vertical reference, not another ratio's crop, controls the visible decorative inventory.
- Reject export if the normalized gap from English subtitle to the nearest figure is materially larger than the approved reference, or if title, figures, table, or logo were given separate transforms.

### Video channel

- Keep the canvas at 1080 x 1260.
- Keep `x=0..59` and `x=1020..1079` pure opaque white (`#FFFFFF`).
- Keep every visual and text layer inside `x=60..1019`.
- Do not allow antialiasing, shadows, transparent pixels, or artwork to bleed into the margins.

#### Light editorial portrait covers

- Treat an approved portrait/interview cover as four locked layer groups: `background_scene`, `text`, `text_packaging`, and `logo_template`. Never merge these groups conceptually or ask the image model to reinterpret them together.
- Preserve the approved Chinese font silhouette exactly. A serif/editorial title must not be replaced with a modern sans-serif approximation. Compare character width, stroke contrast, terminals, baseline, tracking, line breaks, and the complete title bounding box against the approved reference.
- Preserve the approved title scale and occupancy. Do not shrink the title merely to create more empty space. After the one-group transform, the title block's normalized left edge, top edge, width, height, and inter-line gap must match the approved reference within raster-rounding tolerance.
- Keep blue highlights, dotted fields, guide-like rules, arrows, selection-style frames, and English microcopy in the `text_packaging` group. Preserve their full geometry, opacity, color, attachment points, and z-order; do not enlarge a highlight into a generic solid bar or shorten/crop a rule.
- Preserve the complete interview tableau as one scene: both people, full heads, hands, chairs, table perspective, spacing, and relative scale. Do not independently enlarge either person, move a head, rebuild a hand, or alter the distance across the table.
- Protect faces, hair contours, hands, suit edges, chair silhouettes, and the table boundary from regeneration. Washed-out facial holes, eroded hands, doubled silhouettes, and altered anatomy are hard failures even when the overall style remains faceless or abstract.
- Match the approved tonal hierarchy. Preserve paper grain, pale-blue grid, dotted texture, halftone/scanline treatment, and enough midtone separation to keep both figures readable. Do not bleach the scene into featureless white or increase contrast until skin/hand detail disappears.
- Choose the deterministic logo template by local background luminance: use the black BaseEdge logo on light artwork and the white BaseEdge logo on dark artwork. The logo color choice is not aesthetic improvisation; reject a white logo that loses contrast on a pale background.
- Place the logo from the platform template at its fixed lower-right coordinates and standard size. Do not derive its location or size from the generated composition, and never reuse a logo raster embedded in the source artwork.
- Before export, compare the candidate and approved reference at the same 1080 x 1260 canvas and reject if any of these change: title font family/silhouette, title block occupancy, packaging bounds, person/table normalized bounding boxes, scene tonality, or logo template/color/coordinates.

### Bilibili cover

- Keep the canvas exactly 1600 x 1000 and compare every candidate directly against the approved 1600 x 1000 reference at 100% scale.
- For light editorial portrait covers, use the black BaseEdge logo template at the fixed lower-right Bilibili coordinates and standard size. A white logo on the pale interview/table background is a hard failure.
- Preserve the approved editorial serif Chinese font silhouette. Replacing it with a modern sans-serif font, reducing stroke contrast, narrowing characters, or simplifying the title treatment is a hard failure.
- Preserve the deliberately asymmetric two-line title construction: the supporting first line begins at the approved left anchor; the dominant question line is much larger, starts farther to the right, and extends close to the approved right edge. Do not left-align both lines, center them as one block, or shrink the dominant line to avoid the figures.
- Preserve the approved title-to-subject overlap and depth relationship. The dominant question line may intentionally cross the upper figure zone; do not move the people downward, enlarge the empty band, or reduce the title merely to remove that relationship.
- Record and compare the normalized bounds of both Chinese lines, the rightmost punctuation, inter-line gap, English-subtitle baseline, and title-to-figure overlap. Material deviation in any of these is a hard failure.
- Preserve the complete blue underline/highlight, dotted fields, downward arrows, dashed baseline/frame, rules, and English subtitle as one `text_packaging` group. Keep their full edges, opacity, color, attachment points, and z-order; do not crop, enlarge, detach, or replace them with generic rectangles.
- Preserve both interview figures, chairs, hands, table horizon, foreground crop, and the distance across the table as one locked scene group. Do not enlarge the people, lower the scene, increase the table dominance, or alter either figure independently.
- Protect face silhouettes, hairlines, hands, cuffs, suit edges, chair boundaries, and table lettering from regeneration. White face holes beyond the approved faceless treatment, fragmented hands, missing cuffs, and blown-out erosion are hard failures.
- Preserve the approved pale paper/grid/halftone background and soft midtone separation. Do not bleach the center, increase contrast until anatomy disappears, or substitute a cleaner but different paper texture.
- Before export, reject any Bilibili candidate when: both Chinese lines share one left edge; the main question is visibly smaller than the approved reference; people or table are enlarged/lowered; packaging geometry is incomplete; the logo is white or off-template; or any title, packaging, scene, and logo element was independently re-laid out.

### Horizontal cover

- Keep the canvas exactly 1920 x 1080 and compare every candidate directly against the approved 1920 x 1080 reference at 100% scale.
- For light editorial portrait covers, use the black BaseEdge logo template at the fixed lower-right horizontal-cover coordinates and standard size. A white logo on the pale table/background is a hard failure.
- Preserve the approved high-contrast editorial serif Chinese font silhouette. A modern sans-serif substitution, reduced stroke contrast, narrower characters, or smaller typography is a hard failure.
- Preserve the horizontal cover's own asymmetric title construction rather than scaling the Bilibili arrangement: the first line is large and anchored in the upper-left; the dominant question line begins substantially farther right, is much larger, spans most of the canvas width, and ends near the approved right punctuation position.
- Preserve the intentional depth relationship between typography and portrait scene. The large question crosses the space between the figures and overlaps the upper right-silhouette zone; do not pull the title into a compact upper-left block or move the figures/table merely to avoid this overlap.
- Record and compare both Chinese-line bounding boxes, the dominant line's width and right edge, first-to-second-line offset, English-subtitle baseline, title-to-head overlap, and title-to-table gap. Material deviation is a hard failure.
- Preserve the complete blue underline/highlight, downward arrows, dotted fields, dashed baseline/frame, fine rules, and English subtitle as one `text_packaging` group. Keep their complete bounds and approved alignment under the dominant question; do not raise the English line, shorten the highlight, or detach the dotted fields.
- Preserve both people, hands, chairs, table horizon, foreground table crop, and spacing as one locked scene group. The approved horizontal scene keeps the people broader and more laterally separated while the table remains a low foreground plane; do not center both figures, lower the scene, or let the table consume extra vertical space.
- Protect the face silhouettes, hair contours, hands, cuffs, suit edges, chair backs, and table lettering. Excess white facial holes, fragmented hands, missing cuffs, and erased suit contours are hard failures.
- Preserve the approved pale paper/grid/halftone tonality and midtone separation. Do not bleach the central background or wash out the people and table until they lose material definition.
- Before export, reject any horizontal candidate when: the dominant line is materially smaller or begins too far left; both lines form a generic left-aligned block; the English subtitle is too high; people/table framing changes; packaging is incomplete; the logo is white or off-template; or title, packaging, scene, and logo were independently re-laid out.

### Base image: mandatory 1080 x 1260 structure

Treat any supplied sample as a layout-format reference only. Do not treat its topic, subject, background, title, or wording as a reusable template.

Use RGB in the sRGB color space and export PNG at exactly 1080 x 1260 px. Divide the raster at the pixel boundary between rows 421 and 422:

- Upper content region: 1080 x 422 px, `x=0..1079`, `y=0..421`.
- Lower empty region: 1080 x 838 px, `x=0..1079`, `y=422..1259`.

Keep every visual element inside the upper region: current episode subject, environment, exact current title, supplied BaseEdge logo, and any original scene elements that must remain. Interpret “center the subject” relative to the upper 1080 x 422 region, never relative to the full 1080 x 1260 canvas.

Force every pixel in the lower region to opaque `#000000`. Do not place images, textures, gradients, lighting, shadows, titles, logos, decoration, transparent layers, or AI outpainting there. Add no dividing line, shadow, glow, texture, or gradient transition at `y=422`. Check `x=0` and `x=1079` for 1 px gray seams.

#### Dynamic episode content

- Rebuild the subject, background, composition, title text, title line count, title size, and visual elements from the current task.
- Use only the exact title supplied for the current episode.
- Do not reuse, paraphrase, complete, or invent wording from a reference image.
- For new-cover creation, request a missing title. For approved-cover regeneration, use the exact readable source title.

#### Source-image adaptation

- Treat the current source image as the only visual authority.
- Preserve subject shape, identity, color relationships before monochrome conversion, materials, texture, lighting, background style, and spatial relationships.
- Do not add or delete scene elements. The only deletion exception is old overlaid title/caption text that the user asked to replace.
- Distinguish overlaid editorial text from real labels or necessary markings that belong to the subject; preserve the latter.
- Scale and move content proportionally. Never stretch or compress people, products, or objects.
- Recompose within the upper region instead of merely cropping or flattening the source.
- When missing space must be filled, outpaint only absent background and spatial continuation consistent with the source.
- Do not use blurred fill, mirrored duplication, direct stretching, or invented foreground objects.

#### Monochrome treatment

- Convert only the background and main-scene layers in the upper region to black and white or the source-approved low-saturation treatment.
- Preserve highlights, midtones, shadows, material detail, grain, depth, lighting direction, and subject recognition.
- Avoid crushed blacks, clipped highlights, muddy low contrast, or loss of important detail.
- Keep the lower region independent and exactly black; do not derive it by extending or darkening the artwork.
- Exclude the deterministic title, text-packaging, and BaseEdge logo layers from scene desaturation. Preserve their original colors and effects exactly.

#### Title and logo composition

- Remove old editorial titles and captions from the source before adding the current title.
- Add the exact current title as a deterministic typography layer after visual generation or editing. Do not ask an image model to render Chinese text.
- Treat the approved `底图` reference as the authority for title treatment and decorative inventory. Do not inherit text packaging merely because it appears in the vertical, Bilibili, horizontal, video-channel, or WeChat variants.
- Preserve the approved base-image title treatment exactly. Plain `#FFFFFF` is required when the approved `底图` reference uses a simplified white title; colored edges, selection-box lines, highlight bars, rules, underlines, or English microcopy are required only when they are present in that approved base reference.
- Keep the title entirely within `y=0..421`, clear of the lower black region, and away from the subject's most important recognition area.
- Place the supplied standard BaseEdge logo in the upper-right of the content region.
- Never redraw, regenerate, trace, or typeset the BaseEdge logo with AI.

#### Light editorial portrait base-image standard

- Treat `底图` as a dedicated composition, not as a shrunken vertical cover placed above a black reserve.
- Keep the upper scene dark gray, monochrome, and low-saturation with visible midtones. Reject a pale, washed-out, nearly white scene or a replacement paper/texture treatment.
- Enlarge and recompose the complete interview scene to fill the full 1080 x 422 upper region. Both figures and the table must read at thumbnail size, extend laterally through the scene, and retain the approved relative scale and spacing. Do not reduce the people to a small centered island.
- Preserve both figures, heads, hair contours, hands, suits, chairs, table, and their relationship as one locked scene group. Protect anatomy and silhouettes from regeneration.
- Use the approved large, high-contrast editorial serif Chinese title in pure white, centered as a dominant two-line block across most of the upper region. Preserve its line breaks, occupancy, line gap, and intentional overlap with the figures. A small black modern sans-serif title is a hard failure.
- Omit the blue underline/highlight, arrows, dashed frame, selection-style marks, and English subtitle when they are absent from the approved `底图` reference. Their presence in another ratio does not authorize them here.
- Use the supplied black BaseEdge logo template at the fixed upper-right `底图` coordinates and standard size. A white logo is a hard failure for this approved treatment.
- Keep the complete title, scene, and logo inside `y=0..421`; keep `y=422..1259` opaque pure black with no texture, glow, seam, or transition.
- Reject the export when any of these occur: white or pale scene treatment; undersized centered figures; sans-serif or black title; title materially smaller than the approved reference; copied blue packaging or English subtitle; white/off-template logo; changed figure anatomy; or any non-black lower-reserve pixel.

### WeChat article

- Keep the canvas exactly 900 x 383 and compare every candidate directly against the approved 900 x 383 reference at 100% scale.
- Keep critical title copy within `x=28..610`, `y=32..225`, following the approved reference rather than shrinking it to a narrow generic safe box.
- For light editorial portrait covers, use the black BaseEdge logo template at the fixed upper-right WeChat coordinates and standard size. A white logo on the pale background is a hard failure.
- Preserve the approved high-contrast editorial serif Chinese font silhouette. Do not substitute a modern sans-serif face, narrow the characters, reduce stroke contrast, or shrink the dominant question line.
- Preserve the approved asymmetric two-line title structure: the first line begins near the upper-left; the dominant question line is much larger, starts farther right, and spans across the central portrait zone. Do not align both lines to one left edge or confine both lines to the empty upper-left corner.
- Preserve the title-to-portrait overlap: the supporting line passes above the left portrait, while the dominant question crosses the left head/upper-body zone and approaches the right silhouette. This editorial overlap is intentional; do not reduce the figures or title to avoid it.
- Record and compare both Chinese-line bounds, main-line right punctuation, first-to-second-line offset, English-subtitle baseline, title-to-head overlap, and logo clearance. Material deviation is a hard failure.
- Preserve the complete blue underline/highlight, downward arrows, dotted fields, dashed baseline/frame, fine rules, and English subtitle as one `text_packaging` group. Keep their complete geometry and alignment; do not crop the highlight, raise the English line, or detach arrows from the main title.
- Preserve the interview scene as a large full-width base layer: both figures, hands, chair backs, table horizon, foreground table crop, and visible table lettering. Do not reduce the people to small lower-right figures or leave a large empty white center.
- Protect facial silhouettes, hairlines, hands, cuffs, suit edges, chair boundaries, and table lettering. Excess white face erosion, fragmented hands, missing cuffs, and lost table detail are hard failures.
- Preserve the approved pale paper/grid/halftone tonality with enough midtone separation for both figures and the table. Do not bleach the background or wash out the scene into featureless white.
- Before export, reject any WeChat candidate when: the main question is materially smaller; both title lines are packed into the upper-left; the people/table scene is reduced or pushed right; packaging is incomplete; the logo is white or off-template; or title, packaging, scene, and logo were independently re-laid out.

## Background sizing

For approved-cover layout-locked extension, calculate a contain-fit transform for the complete approved composition, then outpaint only uncovered canvas regions. If API alignment adds outer bleed, calculate the transform relative to the final trim rectangle so trimming cannot change composition.

Use width-fit, not cover-fit:

```text
scale = artworkWidth / sourceWidth
width = artworkWidth
height = sourceHeight * scale
x = artworkX
y = artworkY + (artworkHeight - height) / 2
```

The background's left and right edges must coincide exactly with the artwork boundaries. Preserve aspect ratio. Permit vertical overflow and clipping, never horizontal underflow or overflow.

## Information hierarchy

1. Main title or hero phrase.
2. Supporting title.
3. Primary subject.
4. BaseEdge logo.
5. Evidence, environment, or secondary subject.
6. Optional topic logo.
7. English microcopy and decoration.

## Composition rules

- Compose new covers independently. For approved-cover extension, lock the complete layout and apply only a single uniform group transform per variant.
- Keep titles legible at thumbnail size and maintain strong contrast.
- Do not cover faces, product identity, critical vehicle geometry, or the focal evidence.
- Keep exact text outside the image model. In approved-cover regeneration, preserve approved typography as an isolated alpha layer or reconstruct it only with the exact identified font. A clean alpha overlay is allowed; a rectangular source crop is forbidden.
- Treat topic logos, English teasers, props, borders, and decorative textures as optional episode elements.
- Use only the BaseEdge logo as fixed branding.

## Export naming

Use a common episode stem:

```text
基地边缘-<主题>-竖版.png
基地边缘-<主题>-视频号.png
基地边缘-<主题>-bilibili.png
基地边缘-<主题>-横版.png
基地边缘-<主题>-公众号.png
基地边缘-<主题>-底图.png
```

## Acceptance criteria

- Six files exist and match the exact output matrix.
- All files are valid PNGs at real pixel dimensions.
- The base-image file is RGB/sRGB at exactly 1080 x 1260 px.
- The base-image upper 422 px contains only the current episode's monochrome visual, exact supplied title, and supplied standard logo.
- For an approved light editorial portrait `底图`, the upper region uses the approved dark-gray full-width scene, large centered two-line white editorial-serif title, no absent cross-ratio packaging or English microcopy, and the fixed black upper-right logo template.
- No sample topic, title, subject, or decorative content leaks into an unrelated episode.
- Old editorial text is removed while real subject labels and necessary markings remain intact.
- No issue marker appears in any file.
- Video margins are 60 px pure opaque white on both sides.
- Base-image lower reserve is 838 px pure opaque black.
- Logo proportions and wordmarks are intact and correctly anchored.
- No raster layer is non-uniformly stretched.
- Each ratio has a deliberate, readable composition.
- For approved-cover extension, every non-base variant preserves the source composition's relative coordinates, sizes, spacing, overlaps, typography, rules, accents, subject, labels, and design character exactly after one uniform group transform.
- No regenerated output contains source-pixel collage, an inset-poster boundary, a disconnected pasted crop, a scaled copy of the source, tiled source texture, or flat filler background.
- No output changes the title font treatment, boxes, rules, underline shape, texture family, annotation strings, or annotation connector topology.
- No text-packaging element is clipped, shortened, split, or detached from its paired phrase; its complete transformed bounds remain visible.
- No source-covered background pixel is replaced by newly generated texture, rings, grain, gradient, vignette, or lighting.
- A source label without a connector line remains unconnected in every variant. No generated graphic may imply a technical relationship absent from the approved source.
