# BaseEdge cover rules

## Exact output matrix

| ID | Name | Canvas | Artwork area | Fixed brand placement |
|---|---|---:|---:|---|
| `vertical` | 竖版 | 1242×1660 | 1242×1660 at (0,0) | issue upper-right; logo lower-right |
| `wechat-channel` | 视频号 | 1080×1260 | 960×1260 at (60,0) | issue upper-right inside artwork; logo lower-right inside artwork |
| `bilibili` | B站 | 1600×1000 | 1600×1000 at (0,0) | logo lower-right; no issue |
| `horizontal` | 横版 | 1920×1080 | 1920×1080 at (0,0) | logo lower-right; no issue |
| `wechat-article` | 公众号 | 900×383 | 900×383 at (0,0) | logo upper-right; no issue; copy zone depends on the recognized template |
| `base-image` | 底图 | 1080×1260 | 1080×422 at (0,0) | logo upper-right in artwork; no issue |

Export PNG. Use RGB or RGBA as appropriate without changing pixel dimensions.

## Special regions

### WeChat Channels

- Keep canvas 1080×1260.
- Render pure white at x=0..59 and x=1020..1079.
- Keep background, subject, assistant, logo, issue, titles, and faces within x=60..1019.

### Base image

- Use y=0..421 for artwork.
- Force y=422..1259 to pure `#000000`.
- Do not place any layer in the lower region.

## Raster sizing

### No-distortion adaptation

- Never transform a completed or flattened cover directly to a target canvas by setting both target width and target height. This creates non-uniform scaling whenever the aspect ratios differ.
- Keep proportional scaling locked for backgrounds, people, typography rendered as raster, logos, topic marks, textures, and decorations. At render and export time, require equal `scaleX` and `scaleY` for every raster layer.
- Build each output ratio as an independent scene from editable layers. Adapt with proportional scaling, cropping, repositioning, and selective removal of optional elements. Do not solve overflow by compressing the whole composition or a single layer.
- A wide, shallow format such as the 900×383 WeChat article cover requires a new composition; it must not be produced by squeezing a 1600×1000, 1920×1080, or portrait cover.
- Before approval, compare each rendered layer with its source aspect ratio. Reject any export with visibly widened or flattened faces, letterforms, logos, circles, halftone dots, or other known geometry.

### Background

#### Automatic background completion

For a flattened source cover, do not treat the whole source canvas as an immutable background. First separate these roles:

- `A` background/environment;
- `B` primary and assistant subjects;
- `C` title text;
- `D` title packaging and decorations that move with the title;
- `E` BaseEdge and issue branding.

Create a clean background plate for every target scene:

1. Build a foreground-removal mask from `B` through `E`, expanded enough to include antialiasing, shadows, glows, outlines, and texture contamination from those elements.
2. Preserve source background pixels outside that mask.
3. Inpaint the masked holes inside mapped source coverage so moving people, products, titles, packaging, or logos does not leave silhouettes, rectangles, or empty patches.
4. Outpaint every target-canvas region outside mapped source coverage, continuing the source perspective, lighting, texture, grain, depth, and color relationships.
5. Composite the protected subjects, title group, and branding back on top as independent proportional layers.

For title recomposition, clean the destination text bed before compositing. The clean plate must contain only continuous scene/background pixels. Ordinary glyph layers must have true alpha and no captured backing pixels. Colored material is allowed only when it belongs to the recorded `D` title-packaging layer; residual source text, ghost strokes, scanning lines, partial borders, and rectangular title crops are hard failures.

The generation model may receive only the clean-background task and its masks. Never send protected people, title text, title packaging, or BaseEdge branding for redrawing.

Do not use mirrored edges, stretched pixels, generic blur fill, repeated texture tiles, or a solid-color extension as a substitute for scene-aware background completion. Reject visible seams, rectangular patches, mask halos, duplicated objects, inconsistent perspective, or grain-scale changes.

Pixel protection applies outside the allowed background-edit mask. Verification must separately report:

- `unchanged_unmasked_source_pixels=true`;
- `inpaint_holes_complete=true`;
- `outpaint_regions_complete=true`;
- `visible_seams=false`;
- `mask_edge_halo=false`;
- `texture_and_perspective_continuous=true`.
- `clean_background_under_plain_text=true`;
- `no_ghost_text_or_residual_rules=true`;
- `no_rectangular_text_patch=true`;
- `colored_elements_packaging_only=true`.

Do not require zero changed pixels inside the allowed edit mask; those changes are the intended background repair.

Use width-fit, not cover-fit:

```text
scale = artworkWidth / sourceWidth
width = artworkWidth
height = sourceHeight * scale
x = artworkX
y = artworkY + (artworkHeight - height) / 2
```

The left and right image edges must coincide with the artwork edges. Preserve the source aspect ratio. Permit vertical overflow and clipping when the calculated height exceeds the artwork height. Do not permit horizontal underflow or overflow.

For video-channel, `artworkWidth` is 960. For base-image, it is 1080 and clipping is limited to the upper 422 px.

## Approved Tao-law copy regions

Use these fixed regions only when the source is explicitly recognized as the approved `tao_law_approved` product-cover template. Do not apply them to people-led or unrelated covers.

Coordinates use `[x1, y1, x2, y2]`, with the left/top edge inclusive and right/bottom edge exclusive. The entire copy group must fit inside the region: headline glyphs, red underline, quotation marks, the large red keyword, the `韬定律` badge, and any other decoration that moves with the title.

| Variant | Canvas | Required copy region |
|---|---:|---:|
| Vertical | 1242×1660 | `[58, 180, 1168, 726]` |
| WeChat Channels | 1080×1260 | `[104, 203, 974, 631]` |
| Bilibili | 1600×1000 | `[170, 140, 1130, 620]` |
| Horizontal | 1920×1080 | `[108, 128, 1168, 650]` |
| WeChat article | 900×383 | `[70, 70, 486, 278]` |
| Base image | 1080×1260 | `[130, 125, 920, 325]`, entirely within the upper 422 px artwork region |

For the WeChat article variant, the Tao-law copy region must also remain inside the platform copy-safe envelope `x=28..501`, `y=61..291`.

Measure the combined copy group, not text glyphs alone. Reject a scene when any edge crosses the required region, any decoration is clipped, or the group is non-uniformly compressed to force it into the box. Fixed copy regions constrain copy only; logo and issue placement continue to follow the branding rules.

### Subjects

- Insert transparent primary and assistant PNGs at their intrinsic pixel width and height.
- Center them initially inside the artwork area without resizing.
- Keep proportional scaling locked during user transforms.
- Never change position or dimensions when toggling visibility.

### Object visibility and cropping

Before resizing, create an `object_manifest` for recognizable products, devices, vehicles, tools, props, and other non-background objects. For each object record `object_id`, `role` (`hero`, `supporting`, or `decorative`), `source_bounds`, `source_silhouette_complete`, `source_crop_intentional`, and per-size `retention` (`required` or `optional`). Determine the semantic hero from title relevance, scale, repetition, and composition. Do not classify every recognizable or prominent prop as required.

- Every retained `required` object must remain recognizable as a complete object and stay inside the effective artwork area with at least `max(24 px, 2% of the shorter artwork edge)` clearance. For WeChat Channels, measure against x=60..1019; for the base image, measure against y=0..421.
- Do not crop through a camera body or lens, a phone or laptop screen, product controls, a vehicle wheel or stance, tool handles, or any other identifying extremity. A lens sliver, half device, truncated body, or accidental edge peek is a hard failure.
- A crop intentionally present in the approved source can be preserved only when it remains clearly intentional and recognizable. Never deepen that crop in a derived size.
- When an `optional` object cannot fit, remove the full object together with its shadow, outline, reflection, and edge fragments. Fully retained or fully omitted are the only valid states.
- A `required` object cannot be omitted to make room for copy. Recompose the title and object zones, proportionally scale the object, or extend the background.
- Supporting evidence can change scale materially between variants and may be omitted completely from the base image. The hero must remain dominant over supporting objects.

Produce `object_visibility_audit` with one entry for each of the six output sizes. Each entry must contain `size_name` and `objects`; each object record must contain `object_id`, `required`, `visible`, `full_silhouette_preserved`, `bounds`, `safe_margin_px`, `source_crop_intentional`, `intentionally_omitted`, and `fragment_visible`. Required objects must be visible, complete, fragment-free, and safely inset. Optional objects must be either complete and safely inset or fully omitted with `fragment_visible=false`.

### Calibrated product-led composition

Use the approved “影石十年” six-size set as a behavioral reference for product-led covers, not as a fixed template for unrelated artwork:

- Portrait and WeChat Channels: stack copy in the upper roughly 10–38% of the artwork; place the hero in the middle/lower field; place one smaller supporting product in a remaining corner only when it remains complete.
- Bilibili and horizontal: keep copy predominantly left and the hero predominantly right/lower. A supporting product may sit below the copy, but must remain visibly subordinate and complete.
- WeChat article: use a compact left-copy/right-hero composition. For a general product-led template, the combined copy group may occupy approximately `x=70..620, y=48..291`; the stricter Tao-law region applies only to `tao_law_approved`.
- Base image: keep the hero inside y=0..421 and allow a centered title to overlap its low-information center after a controlled dark/desaturated treatment. Supporting product props and the top full-width timeline may be removed completely. Colored title packaging may be replaced by clean high-contrast type; this is an intentional base-image transformation, not a fidelity failure.

Record `composition_relationship_audit`: `hero_role_identified`, `supporting_objects_subordinate`, `title_hero_overlap_intentional`, `critical_hero_details_uncovered`, `hero_recognizable`, and `reference_relationship_preserved`. Rectangle overlap alone is not a rejection condition when the last four fields are true.

## Branding

- Offer explicit black-logo and white-logo buttons.
- Use black on light artwork and white on dark artwork unless the user overrides it.
- Use only the current twelve user-supplied full-canvas positioning assets under `F:\橙子\封面logo\白logo\` and `F:\橙子\封面logo\黑logo\`; they replace all previous Logo files. Do not recreate the mark with text.
- Select the asset matching both output size and wordmark color, then overlay the entire asset at `(0,0)` at native canvas dimensions as the final deterministic branding pass. Do not derive other sizes from the vertical asset, crop and scale a common Logo, alter the tuned placement, or use legacy `logo_00000.png` / `logo_black_00000.png`.
- The WeChat Channels positioning assets also carry the approved side-margin treatment; the base-image positioning assets carry the approved lower black reserve. Preserve those authored pixels when applying the full-canvas asset.
- Maintain approved black- and white-wordmark variants with identical alpha geometry and red dot. Measure the destination behind the Logo before the final overlay: use black on light artwork and white on dark artwork. A geometrically correct Logo with insufficient luminance contrast is a hard failure.
- Preserve logo aspect ratio and red dot.
- Render the issue as the approved fixed style with dynamic `VOL.{issue}.`; do not substitute a generic font treatment or flattened incorrect mark.
- Show the issue only on vertical and video-channel scenes.

## Composition archetypes

## Decorative span behavior

Perform this classification before resizing:

- `full-width`: the element reaches or nearly reaches both source artwork edges. Extend/recompose it so both endpoints remain close to the target artwork edges.
- `edge-anchored`: one endpoint is intentionally tied to an artwork edge; preserve that anchor and extend inward as required.
- `local`: a self-contained icon or accent whose size is independent of the canvas.
- `title-packaging`: an accent that moves as one group with a specific title.

For full-width rulers, timelines, rails, bands, and long dividers, preserve end caps, marker order, line weight, and vertical position while adapting the horizontal run. Use editable/repeatable middle segments or scene-aware extension when necessary; do not non-uniformly stretch recognizable icons or end caps. The target coverage should preserve the source edge-margin ratio and should normally reach within 2–5% of both effective artwork edges. Cropping the strip to its middle or showing only half is a hard failure.

### Human

- Single person: protect face and silhouette; horizontal variants may use title-left/person-right.
- Double person: preserve ordering and relative scale; do not crop heads or separate the pair arbitrarily.
- Group: keep hierarchy; reduce minor figures before shrinking every face.

### Product

- Center-axis product: preserve symmetry and centerline.
- Vehicle: preserve full silhouette and stance.
- Machine/device: preserve mechanical geometry and perspective; never non-uniformly stretch.

### Collage

- Keep one dominant anchor.
- Retain at most one or two strong assistant elements in narrow variants.
- Allow assistant elements to be removed per scene.

## Information priority

1. Hero phrase.
2. Supporting title.
3. Primary subject.
4. BaseEdge logo.
5. Topic evidence/environment.
6. Issue where enabled.
7. Optional topic logo.
8. English microcopy and decoration.

Recompose each ratio from editable layers. Do not simply center-crop a flattened vertical cover.

## Fixed versus optional elements

Only BaseEdge logo and enabled issue marker are fixed. The following are optional episode-specific graphics:

- Windows Start, taskbar, system tray, and clock.
- Red QQ penguin.
- Yellow Z shape.
- Blue circuit border.
- Retro four-icon strip.
- Company/topic logos, English teasers, props, and decorative textures.

"Optional" permits removal only when the target composition genuinely cannot retain a local episode graphic. It does not permit truncating a retained structural decoration or changing a source `full-width` element into a partial strip.
