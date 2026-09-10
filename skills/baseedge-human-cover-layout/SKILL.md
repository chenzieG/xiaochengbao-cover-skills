---
name: baseedge-human-cover-layout
description: Compose, adapt, review, and correct people-led BaseEdge episode covers. Use when a BaseEdge or 小橙报 cover contains one person, two people, or a group and the task involves 人物排版、人物布局、人物层级、标题避让、构图适配, or adapting the people composition across vertical, video-channel, Bilibili, horizontal, WeChat article, and base-image variants. Use alongside cover-dimensions when dimensions are being extended.
---

# BaseEdge Human Cover Layout

## 小橙报封面反馈与交付规则

处理已批准封面的尺寸适配、装饰遗漏、文案位置反馈、群执行诊断或交付时，必须读取 [设计保留、验收与群交付](../cover-dimensions/references/cover-workflow-lessons-20260910.md)。装饰不是固定品牌不等于可随意删除；用户指出缺失的元素必须进入本次保留清单。像素自检不能替代与原稿逐项核对。用户明确要求局部重排时按反馈执行，仍保持关联文字包装成组变换；未获得重排授权时保留本技能的成稿锁定约束。

Use this skill for the composition of people-led BaseEdge covers. When the task also changes output dimensions, apply `cover-dimensions` first for canvas, artwork, branding, and export constraints, then apply this skill independently to each scene.

## Classify the people structure

- **Single person:** protect the face, silhouette, gesture, and gaze direction. Place copy into the open space created by the pose or gaze.
- **Two people:** designate one primary and one assistant. Keep the primary larger and sharper in the foreground; keep the assistant smaller, lower-contrast, and behind or beside the primary without merging faces or limbs.
- **Group:** preserve the intended hierarchy. Reduce, crop, or remove minor figures before shrinking every face to illegibility.

Do not infer hierarchy only from left-to-right order. Use focus, scale, contrast, pose, narrative importance, and the supplied reference composition.

## Shared composition rules

1. Keep every person at uniform scale. Never widen, flatten, or independently resize height and width.
2. Protect faces first. Titles, handwriting, logos, topic marks, texture strips, and decorative shapes must not cross eyes, nose, mouth, or the defining facial silhouette unless the reference explicitly uses a controlled overlap.
3. Preserve believable anatomy and relative scale. Do not separate an interacting pair arbitrarily or create accidental fused bodies, duplicated limbs, or hard seams.
4. Build a clear reading order: hero phrase, supporting title, primary person, BaseEdge logo, environment, optional topic mark, microcopy.
5. Treat titles and people as separate editable layers. Adapt a new ratio through proportional scaling, repositioning, cropping, line-break changes, and removal of optional elements; never squeeze a flattened cover.
6. Use depth intentionally: primary person in front with stronger contrast; assistant behind with reduced contrast; environment softest.
7. Keep enough negative space around the face and headline. Do not fill every gap with decoration.

## Layout archetypes by output

### Vertical 1242×1660

- Reserve roughly the upper quarter for the headline.
- Let the primary person dominate the middle and lower-right or center-right region.
- Place the assistant behind and left when the source relationship supports it.
- Keep the issue upper-right and BaseEdge logo lower-right.
- Avoid shrinking both people merely to expose the full background.

### WeChat Channels 1080×1260

- Keep both 60 px white side margins empty and compose only inside the 960 px artwork width.
- Use a compact top headline and a middle-to-lower people group.
- Keep faces, title, issue, and logo inside the artwork region.
- Keep the issue upper-right and BaseEdge logo lower-right.

### Bilibili 1600×1000

- Prefer a title-left, people-right composition for one or two people.
- Place the primary at the right foreground and the assistant at the left-rear of the people group.
- Use the lower-left for optional English microcopy when it remains legible.
- Place the BaseEdge logo lower-right. Do not show the issue.

### Horizontal 1920×1080

- Strengthen the left-copy/right-people split and preserve a broad negative-space field.
- Keep the primary large at the right; keep the assistant behind and closer to the center.
- Prevent title lines from extending through faces or the primary silhouette.
- Place the BaseEdge logo lower-right. Do not show the issue.

### WeChat article 900×383

- Recompose specifically for the shallow strip. Never derive it by squeezing another scene.
- Keep essential copy inside the strict safe area `x=28..501`, `y=61..291`.
- Concentrate the primary and assistant on the right half, allowing body cropping while protecting faces and recognition.
- Place the BaseEdge logo upper-right. Do not show the issue.
- Remove low-priority handwriting, topic marks, or microcopy when they compete with the headline.

### Base image 1080×1260

- Use only the upper `1080×422` artwork region; keep the lower 838 px pure black and empty.
- Use a simplified people crop or blurred environmental image behind a short, high-contrast headline.
- Place the BaseEdge logo upper-right. Do not show the issue.
- Do not place any person, title, or decoration below y=421.

## Two-person BaseEdge pattern

For a composition with one dominant foreground person and one contextual assistant:

- Primary: right or center-right, largest, sharpest, face unobstructed.
- Assistant: left-rear, smaller and quieter, but still recognizable.
- Headline: left or top, with line breaks adjusted per ratio.
- Topic handwriting or company mark: secondary to the headline; allow light overlap with empty space, not facial features.
- English microcopy: optional lower-left element on spacious horizontal variants; remove it before reducing headline or face legibility.
- Background: full-width, width-fitted, low-contrast support layer.

This is an archetype, not a requirement to reverse a supplied composition. Preserve a deliberately different source hierarchy when it is clear and functional.

## Visual QA

Reject or revise the scene when any of these occur:

- A face, body, title, or logo is visibly stretched or flattened.
- The headline crosses important facial features or makes the subject unreadable.
- Primary and assistant have lost their hierarchy or appear at implausible relative scale.
- Cropping cuts through the top of a head, eyes, jaw, or a narrative hand/prop without a deliberate reason.
- Any reported `head_bounds` touches or crosses the effective canvas edge, or leaves less than 24 px of safety around the complete head. A manifest claim such as `heads_clipped=false` never overrides measured bounds.
- Two people fuse into one silhouette, repeat unexpectedly, or create a hard rectangular seam.
- The same flattened composition was merely resized across ratios.
- Branding, issue visibility, safe areas, or reserved regions violate `cover-dimensions`.

Review each output at full export size and at thumbnail size. The headline and primary face must remain identifiable in both views.
