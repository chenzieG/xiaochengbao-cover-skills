---
name: baseedge-cover-production
description: "Generate, outpaint, adapt, compose, export, and pixel-audit BaseEdge episode covers in six fixed platform variants. Use for new-cover creation and for extending an approved finished cover into other ratios. Approved-cover extension is layout-locked: preserve the complete approved composition and all relative coordinates exactly, apply only one uniform group transform, and outpaint only newly exposed background. Never independently rearrange typography, subject, decoration, labels, or branding. All variants omit issue/VOL markers."
---

# BaseEdge Cover Production

## 小橙报封面反馈与交付规则

单物体封面的 B 站、横版与公众号须检查文案组和主体轮廓的视觉分量，避免字大物小或缩字过度；比例反馈按共享参考中的“文案与物体的视觉比例”执行，具体迭代百分比不得固化为通用阈值。

处理已批准封面的尺寸适配、装饰遗漏、文案位置反馈、群执行诊断或交付时，必须读取 [设计保留、验收与群交付](../cover-dimensions/references/cover-workflow-lessons-20260910.md)。装饰不是固定品牌不等于可随意删除；用户指出缺失的元素必须进入本次保留清单。像素自检不能替代与原稿逐项核对。用户明确要求局部重排时按反馈执行，仍保持关联文字包装成组变换；未获得重排授权时保留本技能的成稿锁定约束。

Create six production-ready PNG covers. Treat [references/cover-spec.md](references/cover-spec.md) as the source of truth and read it before generating, adapting, exporting, or auditing covers.

## Choose the operating mode first

Classify the input before doing any visual work:

- **Approved-cover layout-locked extension**: the source is a finished BaseEdge cover containing its approved composition, and the request asks to extend, resize, or adapt it. Treat the whole approved composition as locked. Apply one shared uniform scale and translation to the complete design; outpaint only newly exposed background.
- **New-cover creation**: the source contains raw visual material or serves only as inspiration for a new episode design. Apply the creation workflow.

When the request says “延展尺寸”, “扩图”, “适配其他比例”, “制作其他尺寸”, or equivalent and supplies a finished cover, default to approved-cover layout-locked extension. Do not interpret it as permission to redesign or responsively rearrange the cover.

## Approved-cover layout-locked extension workflow

1. Read the clearly visible source title verbatim when no separate title is supplied. Never ask the user to repeat it, and never invent or paraphrase it.
2. Record the source canvas and bounding boxes for title, subject, labels, decoration, and logo. Preserve their normalized relative positions, sizes, overlaps, and z-order.
3. Choose one transform `(s, tx, ty)` for the complete approved design group: `x' = s*x + tx`, `y' = s*y + ty`. Apply the same `s`, `tx`, and `ty` to every protected element. Never assign per-element transforms.
4. Preserve the transformed approved content exactly. Use image editing/outpainting only outside its protected mask to fill newly exposed canvas. The protected source must not be regenerated, redrawn, re-typeset, or altered. A single protected source region is allowed; multiple crops, collage, tiling, mirroring, or visible inset-card boundaries are forbidden.
5. Preserve title, subject, texture, decoration, annotations, and their relationships pixel-faithfully inside the protected region. Do not change line breaks, font, tracking, boxes, rules, underlines, label positions, connector topology, or hierarchy.
5A. Treat every title background strip, translucent rectangle, highlight block, selection-style frame, underline, rule, and attached decoration as **text packaging**, never as background. Record its complete source bounds before adaptation. Transform the text and its packaging as one inseparable group; every original edge of every packaging element must remain visible. Cropping a strip to only its upper or lower half is a hard failure.
5B. The original background texture, grain, vignette, rings, grids, gradients, color relationships, and lighting belong to the protected source background. Do not replace them with a similar dark texture or newly generated ring pattern. Generation may fill only pixels outside the transformed source coverage.
6. Do not trust the image model to preserve masked pixels. Before generation, render the complete transformed approved composition to a protected reference PNG and create an exact binary protection mask. After generation, restore the protected reference over the model result pixel-for-pixel. If API scaling or bleed trimming is used, restore once at API-canvas resolution and restore a second time from the final-resolution protected reference after the uniform downscale and trim. Feathering, seam repair, or color matching may affect generated pixels only; it must never modify a protected pixel.
7. Use only the standard BaseEdge logo assets in this Skill: `assets/baseedge-logo-white.png` and `assets/baseedge-logo-black.png`. Do not retain or regenerate a distorted logo from the source raster.
8. Preserve every approved element through the same group transform. Do not move labels to available negative space, move the subject for balance, enlarge the title for readability, or reposition the logo independently, except where a platform's fixed Logo rule explicitly requires the standard Logo asset.
9. Treat `底图` as a dedicated regeneration variant and follow its special rules in the reference.
10. If both built-in generation and the approved Image API fallback are unavailable, fail the task clearly. Never use System.Drawing, GDI, CSS, Canvas, ImageMagick, or similar tools to redesign or rearrange artwork. Local Pillow processing is allowed only for the API-alignment workflow below, mandatory platform regions, color-mode conversion, protected-pixel restoration, and audit; it may not apply per-element transforms.
11. Visually and numerically compare every export against the expected uniformly transformed source. Reject any per-element movement, changed spacing, changed relative size, changed typography, invented/removed decoration, altered protected texture, or annotation change.

## Workflow

1. Collect the episode topic, exact verbatim Chinese title, optional subtitle or English microcopy, reference images, and supplied BaseEdge logo asset. In new-cover creation, stop if the title is missing. In approved-cover regeneration, use the clearly readable title already present on the source.
2. Classify the composition as human, product/vehicle, machine/device, or collage.
3. Use the built-in image generation tool only for raster backgrounds, missing background space, subjects, or visual edits. Generate visual material without critical text, BaseEdge branding, watermarks, or issue markers.
4. Keep exact Chinese titles, English microcopy, and the supplied BaseEdge logo as deterministic editable layers. Never ask an image model to recreate the BaseEdge logo.
5. For new-cover creation, build six independent scenes. For approved-cover extension, never build independent layouts: retain one locked composition and extend the canvas around it.
6. Fit every background to the exact artwork width while preserving aspect ratio. Insert raster subjects proportionally; never stretch them non-uniformly.
7. Apply the information hierarchy and fixed brand placement from the reference. Omit issue markers everywhere, including `VOL.*`, episode numbers, and decorative issue glyphs.
8. Export each scene directly at its real pixel dimensions as PNG.
9. Run `scripts/audit_exports.ps1 -Directory <export-folder>` and fix every failed hard constraint.
10. Visually inspect title legibility, subject integrity, logo fidelity, scene balance, and platform-specific cropping.

For the `底图` variant, follow the dedicated base-image section in the reference. A supplied sample cover defines only canvas structure and region division unless the user explicitly authorizes reuse of its content.

## Non-negotiable rules

- Produce exactly six named variants: `竖版`, `视频号`, `bilibili`, `横版`, `公众号`, and `底图`.
- Preserve aspect ratio for all raster layers and preserve the full silhouette or essential geometry of the subject.
- Keep the video-channel side margins pure white and completely empty.
- Keep the lower reserve of the base-image variant pure `#000000` and completely empty.
- Use only `assets/baseedge-logo-white.png` or `assets/baseedge-logo-black.png`. Preserve its aspect ratio, Chinese wordmark, English wordmark, and red dot.
- Do not display an issue marker on any variant.
- Never carry a layout sample's content into another episode. A finished cover supplied for regeneration is the current episode's art-direction reference, not a reusable raster layer.
- Never invent, paraphrase, or shorten an episode title. Use the supplied title for new work; use the exact visible source title for approved-cover regeneration.
- In approved-cover extension, all variants must derive from the same locked source layout and differ only by the one group transform, canvas bounds, outpainted background, and mandatory platform-only regions.
- Text packaging must remain complete and uncropped in every variant. A background bar or highlight attached to a phrase must travel and scale with that phrase as one group, with all four source edges preserved.
- Source-covered background pixels are protected pixels. A visually similar regenerated texture is still a failure.
- Do not export from CSS-scaled or preview-resolution pixels.
- Do not overwrite source files unless the user explicitly requests replacement.

## Generation guidance

- For approved-cover extension, protect the complete transformed source composition and outpaint only outside that mask. Do not regenerate the foreground design.
- For edits, state invariants explicitly: preserve subject identity, product geometry, lighting direction, and any user-designated elements.
- For a single person, protect face and silhouette. For groups, preserve hierarchy and avoid tiny faces.
- For products and vehicles, preserve symmetry, centerline, stance, and mechanical perspective.
- For collages, keep one dominant anchor and reduce optional elements in narrow variants.
- Use white branding on dark artwork and black branding on light artwork unless the user specifies otherwise.
- For the base-image variant, convert only the upper artwork to monochrome while preserving tonal separation, materials, grain, depth, lighting direction, and subject recognition. Do not crush it into featureless black.
- In the base-image variant, monochrome/desaturate the **background and main-scene layers only**. Follow the approved base-image reference as its own platform treatment. When that reference uses a large plain-white editorial serif title and omits blue packaging or English microcopy, reproduce that exact simplified treatment; otherwise preserve the approved base title colors and packaging. Never carry packaging from another ratio into `底图` by default, and never simplify without an approved base-image reference.
- Remove old overlaid titles and captions without deleting real-world labels or necessary markings that belong to the photographed subject.
- Never ask the image model to recreate annotation typography or connector geometry. Models may hallucinate relationships. Add these only after generation from the source-design manifest.

## API-alignment workflow

When the image API requires dimensions divisible by 16 or a minimum pixel count:

1. Let `(W,H)` be the exact final artwork-region size, not necessarily the full platform canvas.
2. Choose the smallest integer `m >= 1` for which the padded API canvas satisfies the model's minimum pixel count.
3. Calculate `API_W = ceil(W*m/16)*16` and `API_H = ceil(H*m/16)*16`.
4. Place the locked source composition using the final group transform multiplied by `m`, offset by the planned symmetric bleed. Protect it while outpainting the surrounding background.
5. If `m > 1`, downscale the entire API result uniformly by exactly `1/m`. Never resize individual elements.
6. Center-trim only the outer generated bleed to exactly `(W,H)`. Never trim a protected source pixel or change the locked transform.
7. After trimming, assemble mandatory platform-only regions such as video-channel white margins and the base-image lower black reserve.
8. Restore the final-resolution protected reference through its binary mask after every resize, trim, color conversion, or compositing operation. This final restoration must be the last artwork operation before fixed platform-only margins/reserves and file export.

This outer-bleed trim is the only cropping exception. It is not composition cropping and must not be used to alter framing.

## Verification order

1. Canvas dimensions and PNG format.
2. Artwork bounds and background width-fit.
3. Subject aspect ratio and cropping.
4. Video-channel pure-white margins.
5. Base-image pure-black reserve.
6. Absence of all issue markers.
7. Logo variant, fidelity, and placement.
8. Title safe area, legibility, and hierarchy.
8A. Compare the complete Chinese-title bounding box, dominant-line character height, and title occupancy against the per-variant approximate ranges in `cover-spec.md`; reject unexplained undersizing.
9. Final real-pixel exports and filenames.
10. Source-design fidelity: title treatment, decoration inventory, texture family, annotation strings, and connector-line topology.

## Mandatory generation evidence

- `result.json` must include `generation_method` set to `built_in_imagegen` or `gpt_image_api_edit`.
- It must include `generation_evidence`, listing the newly generated clean artwork file used for every successful size.
- Every evidence file must exist inside the task output directory and be distinct from the supplied source file.
- A task without this evidence is failed, even when six correctly sized PNG files exist.
- Do not mark a result completed merely because dimensions or pixel-region audits pass.
- `result.json` must include `source_design_manifest` and `fidelity_audit`. `fidelity_audit.invented_connector_lines`, `changed_annotation_relationships`, `labels_overlap_subject`, and `redesigned_typography` must all be `0`/`false`; otherwise fail the task.
- `result.json` must include `layout_lock_audit` with one group transform per size, `per_element_relayout=false`, and `protected_content_unchanged=true`. Missing or false layout-lock evidence fails the task.
- Each `layout_lock_audit.transforms` item must record `final_artwork_size`, `api_canvas_size`, `generation_scale`, and `trim_rect`. The trim rectangle must remove only generated outer bleed.
- `result.json` must include `protected_pixel_audit` with one entry per successful output. Each entry must record `size_name`, `expected_reference_path`, `protected_mask_path`, `changed_pixel_count`, and `max_channel_error`. Both numeric values must be exactly `0`; otherwise fail the task.
- Use `scripts/restore_protected_pixels.py` for deterministic restoration and audit when Pillow is available. A model changing masked pixels is not itself a terminal failure: restore them first, then run the zero-error audit. Fail only when the protected reference/mask cannot be produced or restored exactly.
