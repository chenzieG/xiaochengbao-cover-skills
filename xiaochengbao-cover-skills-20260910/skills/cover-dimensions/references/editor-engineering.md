# Editor engineering rules

## Stack and boundaries

- Frontend: React, TypeScript, Vite, Konva/react-konva, Zustand.
- Backend: Python 3.11+, FastAPI, Pillow.
- Local Windows application launched by `start.bat`; browser UI plus local services.
- Keep projects, uploaded assets, and exports on the local machine.
- Do not add AI, OCR, PSD, Tauri, accounts, cloud collaboration, or Photoshop integration unless separately requested.

## Configuration-driven scenes

- Load size JSON and composition-template JSON before normalizing a project.
- Store six scene objects keyed by preset ID.
- Store independent layers inside each scene.
- Never share mutable layer geometry objects across scenes.
- Re-normalize legacy background layers after asynchronous size configuration loads.
- Re-normalize again when opening an old saved project.

Each layer needs at least:

```json
{
  "id": "...",
  "kind": "background|subject|assistant|logo|issue",
  "asset": "...",
  "x": 0,
  "y": 0,
  "width": 0,
  "height": 0,
  "rotation": 0,
  "visible": true,
  "locked": false,
  "zIndex": 0,
  "variant": "white|black|null"
}
```

## Import behavior

- Background picker/drop zone always creates a background layer in every scene using width-fit.
- Primary and assistant drop zones accept transparent PNG and insert at native size.
- Do not classify every PNG dropped on the canvas as a subject: opaque PNG files are commonly backgrounds. Prefer an explicit target or inspect alpha before classification.
- Replace an existing background rather than stacking multiple backgrounds unintentionally.
- Preserve imported layer geometry when toggling visibility or lock.

## Konva rendering

- Keep preview scale separate from scene coordinates.
- Store all geometry in real canvas pixels.
- Set Stage preview dimensions and scale consistently.
- Pass image geometry explicitly:

```tsx
<KonvaImage
  image={image}
  x={layer.x}
  y={layer.y}
  width={layer.width}
  height={layer.height}
  rotation={layer.rotation}
  visible={layer.visible}
/>
```

Do not rely on spreading an arbitrary layer object into the Konva image node. Explicit geometry prevents intrinsic bitmap dimensions from overriding normalized display dimensions.

- Reset transformer scale to 1 after transform and persist the resulting width and height.
- Use corner anchors with `keepRatio` for raster layers.
- Clip or mask rendering to `artworkBounds`; draw forced white/black regions after artwork where required.
- Keep guides non-listening so they never capture mouse events.

## Layer interaction

- Select, drag, proportionally resize, show/hide, lock/unlock, delete, and reorder.
- Reorder layers by dragging list rows; do not show up/down arrow controls.
- A visibility click changes only `visible`.
- A lock click changes only `locked`.
- Prevent file drops from navigating the browser.
- Give background, subject, and assistant drop zones distinct visual feedback.

## Branding UI

- Provide visible black and white logo buttons in the property panel.
- Replace the logo asset/variant without changing its anchor or proportions.
- Keep brand layers within artwork bounds.
- Regenerate or reposition branding from configuration, not component constants.

## Persistence

- Save project metadata plus all six scene states.
- Reopen without reapplying a template or resetting manual positions.
- Apply migrations idempotently: reopening twice must not repeatedly scale a layer.
- Do not move layers when visibility is toggled.

## Export

- Export one scene or all six.
- Render from real scene pixels on the backend or an unscaled offscreen stage.
- Never export the CSS/Konva preview size.
- Apply width-fit and clipping consistently in preview and export.
- Export final PNG plus separable background, subject, branding, and scene JSON when requested.
- Validate output dimensions by reading the generated files, not by trusting filenames.

## Regression checklist

- Background width equals artwork width and `x` equals artwork x for every scene.
- Bilibili background spans exactly x=0..1599.
- Horizontal background spans x=0..1919.
- WeChat article background spans x=0..899.
- Video background spans x=60..1019; both 60 px margins remain white.
- Base-image artwork spans x=0..1079 only above y=422; lower region is black.
- Subjects retain native import dimensions until the user or a template changes them.
- Visibility toggles do not alter geometry.
- Black/white logo selection appears and survives save/open.
- Issue appears only on vertical and video-channel.
- TypeScript build succeeds.
- Single and batch exports match configured pixel sizes.
