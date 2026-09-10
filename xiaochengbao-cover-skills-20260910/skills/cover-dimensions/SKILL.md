---
name: cover-dimensions
description: Build, adapt, implement, debug, export, and verify BaseEdge multi-size episode covers and the local React/Konva cover editor. Must be used when a Feishu message in the “🍊小橙报·封面扩展群” or “小橙报·封面扩展群” includes a cover image and @mentions “小橙报”, even when the message has no text. Also use when that group asks for 扩展尺寸、延展尺寸、封面适配、横版、竖版、视频号、B站、公众号 or 底图 variants, and for related sizing, distortion, clipping, branding, scene-state, or export work.
---

# BaseEdge Cover Dimensions

## 小橙报封面反馈与交付规则

单物体封面的 B 站、横版与公众号须检查文案组和主体轮廓的视觉分量，避免字大物小或缩字过度；比例反馈按共享参考中的“文案与物体的视觉比例”执行，具体迭代百分比不得固化为通用阈值。

处理已批准封面的尺寸适配、装饰遗漏、文案位置反馈、群执行诊断或交付时，必须读取 [设计保留、验收与群交付](references/cover-workflow-lessons-20260910.md)。装饰不是固定品牌不等于可随意删除；用户指出缺失的元素必须进入本次保留清单。像素自检不能替代与原稿逐项核对。用户明确要求局部重排时按反馈执行，仍保持关联文字包装成组变换；未获得重排授权时保留本技能的成稿锁定约束。

Treat the project JSON configuration as the source of truth. Do not hard-code canvas sizes, safe areas, logo anchors, or issue anchors inside React components.

## Mandatory Feishu routing

- Treat `🍊小橙报·封面扩展群` and `小橙报·封面扩展群` as the same designated Feishu group.
- In that group, the combination of **one attached cover image + an @mention of `小橙报`** is a complete dimension-extension command. Invoke this skill even when the text body is empty and do not ask the sender to add words such as “扩展尺寸”.
- For an image-plus-mention message with an empty text body, use the attached image as the source cover and default to producing and verifying all six configured variants: vertical, WeChat Channels, Bilibili, horizontal, WeChat article, and base image.
- If the same image-plus-mention message contains text, still invoke this skill and treat the text as additional constraints or a narrower requested output set.
- Any message in that group that @mentions or addresses `小橙报` and asks to expand, extend, resize, adapt, or generate other cover dimensions must also invoke this skill before any image generation or resizing action.
- Treat Chinese phrases including `扩展尺寸`, `延展尺寸`, `扩尺寸`, `适配尺寸`, `封面扩展`, `封面延展`, and requests for any named output variant as equivalent triggers.
- Do not route those requests to a generic image-generation or generic resize workflow. Follow this skill's six-scene adaptation, export, and verification rules.
- If the request is only asking for progress or status, report status without restarting or modifying the active cover job. Apply this skill again before any subsequent adaptation action.

Read the references required for the task:

- For cover creation, resizing, layout, branding, or visual QA, read [references/cover-rules.md](references/cover-rules.md).
- For editor implementation, debugging, persistence, or export, read [references/editor-engineering.md](references/editor-engineering.md).
- When the cover contains one person, two people, or a group, also apply the `baseedge-human-cover-layout` skill to each independent scene for people hierarchy, title avoidance, cropping, and visual QA.

## Core workflow

1. Identify and separate background, primary subject, optional assistant subject, title, title packaging, and branding. For a flattened source, create masks for protected foreground elements and a clean background plate.
1a. Before adapting any size, inspect every decorative element and classify its span behavior as `full-width`, `edge-anchored`, `local`, or `title-packaging`. Elements that run close to both source artwork edges—such as timelines, rulers, rails, long dividers, border circuits, and continuous bands—default to `full-width` unless the reference clearly shows otherwise.
1b. Build an `object_manifest` for every recognizable non-background object or prop (for example a camera, phone, product, vehicle, machine, laptop, tool, or symbolic device). Classify each as `hero`, `supporting`, or `decorative`, then record whether it is required in each target size. Visual prominence alone does not make an object required: identify the single semantic hero first; supporting evidence may be removed in compressed variants.
2. Create six independent scenes from the size configuration.
3. Build a full target-sized background for each artwork area. Preserve unmasked source background pixels, inpaint only the holes left by removed or moved foreground elements, and outpaint every target region outside mapped source coverage. The completed background must span the exact artwork width and height without seams.
4. Insert primary and assistant subjects at their native pixel dimensions. Never stretch them.
5. Apply a human, product, or collage template as an editable starting point.
6. Add BaseEdge branding from configuration and add the issue only on variants where it is enabled.
7. Allow each scene to retain independent position, size, visibility, lock, order, and deletion state.
8. Export at configured real pixel dimensions, not preview dimensions.
9. Reopen the saved project and verify that all six scenes restore exactly.

## Non-negotiable invariants

- Preserve aspect ratio for every raster layer.
- Never resize a flattened cover or any raster layer by assigning the target width and target height independently. Uniform scaling is mandatory: `scaleX` and `scaleY` must remain equal.
- Do not obtain another aspect ratio by squeezing or stretching the completed source cover. Recompose each target scene from independent editable layers; use proportional scaling, repositioning, clipping, and optional-layer removal to resolve the new ratio.
- Set background `x` to the artwork area's left edge and background width exactly to the artwork area's width.
- Background generation is mandatory when the target scene exposes pixels that the mapped source background does not provide. Use masked inpainting for holes inside the mapped source and outpainting for new canvas regions; do not leave blank, repeated, mirrored, blurred-fill, or hard-edged placeholder areas.
- Protect original background pixels only outside the explicit background-edit mask. A zero-change audit must not prohibit legitimate inpainting inside holes left by removed text, people, products, packaging, or logos.
- Before placing the adapted title, completely remove the old title and its non-packaging residue from the scene plate. Reconstruct continuous background beneath ordinary text, with no ghost glyphs, duplicated strokes, scan-line fragments, selection-box edges, or rectangular crop patches. Composite ordinary text from a true transparent layer. Only elements deliberately classified in the title-packaging layer (such as emphasis bars, underlines, badges, frames, arrows, dots, and approved auxiliary color accents) may retain colored shapes beneath or around text.
- Do not use `cover` scaling when the requirement is width-fit. Width may not exceed or fall short of the artwork boundary.
- Keep the video-channel 60 px white side margins empty.
- Keep the lower 838 px of the base image pure black and empty.
- Keep issue markers off Bilibili, horizontal, WeChat article, and base-image variants.
- Preserve the BaseEdge logo's proportions, Chinese wordmark, English wordmark, and red dot.
- For every one of the six variants, including a same-size vertical source, deterministically composite the matching full-canvas positioning asset from `F:\橙子\封面logo\白logo\` or `F:\橙子\封面logo\黑logo\` as the final branding pass. These twelve user-supplied files supersede every earlier Logo asset. Select by output size first and local background tone second: black wordmark on light artwork, white wordmark on dark artwork. Place the selected asset at canvas origin at its native dimensions; do not crop a vertical Logo for other sizes, resize it, reposition it, recreate it, or use legacy `logo_00000.png` assets. The tuned placement and any transparent/structural canvas regions are authoritative.
- Treat Windows UI, QQ mascots, yellow Z marks, circuit borders, and retro icon strips as optional episode graphics, never fixed branding.
- Preserve the spatial behavior of structural decorations. A source decoration that spans or nearly spans the artwork width must also span the target artwork width, with its left and right ends placed close to the effective artwork edges. Do not center-crop it, show only one half, shrink it into a floating strip, or misclassify it as a local sticker. For video-channel, align it to the 960 px artwork edges, not the outer white margins.
- Preserve the complete recognizable silhouette of every retained object. Scale and reposition it proportionally so the object—including lens, body, screen, controls, wheels, handles, and other identifying extremities—stays inside the effective artwork area with a safety margin of at least `max(24 px, 2% of the shorter artwork edge)`. Do not let a canvas edge cut through an object or leave only a lens, corner, half body, or other fragment. A crop already present in the source may be preserved only when it is clearly deliberate and must never be worsened.
- If a narrow variant cannot hold an `optional` object cleanly, remove the entire object and all of its shadows, outlines, and fragments. Never solve the layout by leaving a partial object peeking in from an edge. A `required` object may not be omitted; recompose the scene instead.
- Judge overlap semantically, not by rectangle intersection alone. Titles may deliberately overlap a low-information portion of a hero object when the reference composition calls for it, especially in the base-image treatment, but may not cover faces, product identity, controls, or the hero's recognizable silhouette.
- The base image is a distinct editorial derivative rather than a miniature copy of another variant. It may remove supporting objects and full-width episode decorations, darken/desaturate the scene, omit colored title packaging, and use a centered high-contrast title, provided the hero, wording, BaseEdge branding, and lower black reserve remain correct.
- Never mutate another scene when editing the active scene.
- Never derive exports from CSS-scaled preview pixels.
- Never deliver or force-release outputs that fail geometry, safe-area, person/head, branding, or pixel verification. Exhausted retries must end as an internal failure with no image delivery; the presence of six files is not evidence that they are qualified.

## Verification order

Check geometry first, then layer state, branding, and export:

1. Canvas and artwork-bound dimensions.
2. Background left/right edge coincidence.
3. Background completion: confirm all inpainted holes and outpainted canvas regions are filled, continuous, and free of repeated edges, seams, halos, or texture breaks; confirm unmasked source pixels remain unchanged.
3a. Text-bed cleanup: inspect beneath and around every moved title at full resolution. Reject residual old text, duplicate strokes, unintended horizontal rules, opaque crop backgrounds, or colored blocks that are not declared title packaging.
3b. Decoration-span audit: compare each structural decoration with its source span behavior. Reject a `full-width` item when either endpoint is missing, when it covers materially less of the target artwork width than the source proportion, or when its stroke thickness and internal marker proportions are distorted.
3c. Object-visibility audit: compare every output with the `object_manifest`. Reject a required object if its complete recognizable silhouette and safety margin are not preserved. Reject every visible optional object that is clipped or reduced to a fragment; optional objects must be either fully retained or fully removed.
4. Raster geometry: confirm every layer preserves its source aspect ratio and has equal horizontal and vertical scale. Reject the scene if people, type, logos, circles, or texture dots appear compressed or elongated.
5. Subject aspect ratio and native-size insertion.
6. Video white margins and base-image black reserve.
7. Logo variant, anchor, issue visibility, and issue text. Reject white branding on a light Logo region or black branding on a dark Logo region even when its geometry and source asset otherwise match.
8. Independent state and independently recomposed layout across all six scenes.
9. Saved-project round trip.
10. Single and batch PNG pixel dimensions.

Run the frontend TypeScript build after implementation changes. Test at least one portrait, one product/vehicle, and one collage project across all six variants.
