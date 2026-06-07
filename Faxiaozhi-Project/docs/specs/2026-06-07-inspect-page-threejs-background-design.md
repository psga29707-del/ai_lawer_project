# Inspect Page Three.js Background Redesign

## Overview

This design replaces the current CSS-only ambient background on `web-frontend-jsp/inspect.jsp` with a more cinematic `Three.js + shader + canvas texture` background system.

The new direction is intended to create a darker, more philosophical atmosphere with these traits:

- A near-black starfield feel across the full page
- Full-page dotted atlas / star-map structure
- A left-dominant Sisyphus composition rendered as a precision dotted line drawing
- Very slow motion that feels like drift and breath, not active animation
- Strong preservation of the page's readability and workbench usability

## Goals

- Make the page background feel more profound, philosophical, and premium
- Use `Three.js` for a more refined visual system than CSS-only layers can provide
- Introduce a recognizable but still elegant Sisyphus visual metaphor
- Keep the page darker overall so the interface feels closer to a night sky / cosmic terminal
- Preserve the control-console UI and existing frontend behavior

## Non-Goals

- No changes to backend APIs
- No changes to Vue state or request logic
- No migration to a bundler or module-based frontend architecture
- No high-frequency particle motion or distracting visual effects
- No fully realistic illustration or colorful scene design

## Scope and File Boundary

All implementation remains inside:

- `web-frontend-jsp/inspect.jsp`

Expected edits:

- Add a `Three.js` CDN script
- Add a full-screen background mount container
- Add canvas / shader setup code inside the existing page script
- Remove or reduce the current CSS-only ambient background layers
- Keep the current page layout, panels, and logic intact

## Visual Direction

### Core Mood

The atmosphere should feel:

- Dark
- Quiet
- Cosmic
- Measured
- Philosophical
- Technically refined

This is not a sci-fi dashboard with aggressive animation. It should feel like a solemn analytical workbench suspended inside a cosmic drawing field.

### Sisyphus Representation

Chosen visual mode:

- `dotted technical line drawing`
- `left-side main composition with mild spill into upper-middle space`
- `precision drafting tone`, not rough poster art

The Sisyphus image should not be a realistic illustration. It should read more like:

- dotted contours
- arc guides
- circular measurement geometry
- plotting traces
- faded technical blueprint marks

The goal is to evoke the eternal push without competing with the interface content.

## Layer Architecture

The background should be composed from four visual layers:

### 1. Deep Space Base Layer

Purpose:

- Make the page meaningfully darker than the current version
- Create depth before any visible dotted structure appears

Characteristics:

- Nearly black base with subtle cold undertones
- Very restrained blue-cyan glow only at low intensity
- No obvious gradients that flatten the page

### 2. Full-Page Dot Star Map

Purpose:

- Spread a technical-cosmic point field across the entire page
- Tie the whole page together visually

Characteristics:

- Regular or semi-regular point distribution
- Slight density variation so it feels designed rather than random
- Dots should remain small, crisp, and understated

Motion:

- extremely slow drift
- mild brightness breathing
- no flashing or twinkling noise

### 3. Sisyphus Main Visual

Purpose:

- Bring in the philosophical theme directly
- Anchor the page with a left-side composition

Characteristics:

- Left-side primary figure mass
- Dotted line drawing of the pushing posture and boulder relationship
- Circular / orbital / drafting geometry layered around the figure
- Slight extension upward and inward so it influences the whole composition

Motion:

- almost still
- subtle luminance breathing
- tiny positional drift only
- include a very light scan reveal effect across small parts of the drawing

### 4. Atmospheric Scan Layer

Purpose:

- Add time, texture, and depth

Characteristics:

- very light scan lines
- very light haze
- occasional soft structural streaking

Constraint:

- This layer must remain far below the interface in visual importance

## Technical Approach

Recommended implementation:

- `Three.js` for the rendering scene
- `ShaderMaterial` for layered motion and blending
- offscreen `canvas` generation for the dotted field and Sisyphus drawing texture

### Why this approach

Compared with CSS-only backgrounds:

- better control over layered movement
- better control over blending and darkness
- easier to tune atmospheric depth
- easier to create a refined dotted composition

Compared with a raw canvas-only implementation:

- cleaner layering and composition control
- easier fragment-level treatment
- better long-term tuning for visual polish

## Rendering Strategy

### Scene Setup

Use a simple full-screen plane scene:

- one orthographic / camera-like fullscreen setup
- one plane covering the viewport
- one custom shader material

The shader combines:

- base darkness
- point field behavior
- texture contribution from generated Sisyphus canvas
- very slow animated modulation

### Generated Canvas Texture

Build a canvas texture in JS that contains:

- full-page dotted map pattern
- left-side Sisyphus dotted line artwork
- drafting circles and guide lines

This texture should be monochrome or near-monochrome, leaning cold white.

The Sisyphus drawing should be simplified and design-driven rather than anatomically detailed.

### Shader Responsibilities

The shader should handle:

- overall tonal blending into the dark background
- micro drift of point layers
- soft breathing in brightness / opacity
- subtle vignette and spatial falloff near content-heavy areas

The shader should not attempt complex, noisy simulation.

## Motion Design

### Speed

Primary rule:

- everything slow

Suggested motion bands:

- drift loops around `20s - 60s`
- breathing loops around `12s - 24s`
- scan / reveal loops subtle and sparse

### Motion Character

The motion should feel like:

- old cosmic plotting paper suspended in air
- a drawing illuminated by a slow-moving invisible light
- the passage of time, not mechanical activity

It should not feel like:

- sparks
- loading animation
- fast star travel
- active particle storm

## Readability Protection

This is critical.

The page is still a working application, so the background must remain subordinate to the UI.

### Rules

- panel surfaces remain darker and more opaque than the background
- content areas reduce background contrast behind them
- brightest parts of the Sisyphus composition stay mostly left of the main reading zones
- the right result panel should not sit on top of the strongest visual details

### Practical Strategy

Use one or more of:

- fragment-space attenuation behind central content columns
- lower opacity near panel areas
- panel backgrounds with slightly stronger dark fill
- subtle mask falloff for the central reading region

## Performance Strategy

The page should remain lightweight enough for ordinary desktop browsing.

### Constraints

- no dense real-time particle simulation
- no heavy post-processing chain
- avoid excessive texture resolution
- prefer procedural repetition plus a single generated canvas texture

### Fallback Behavior

If `Three.js` initialization fails or WebGL is unavailable:

- keep the page usable
- fall back to a simpler dark CSS background
- do not break the page or hide content

## Interaction Boundary

The background is purely decorative.

- no pointer interaction
- no impact on form input, tabs, buttons, or scrolling
- no coupling with API request states

## Validation Checklist

After implementation, verify:

1. `inspect.jsp` still redirects correctly if no `faxiaozhi_user` exists
2. Review and modify requests still function unchanged
3. Background remains behind all content and does not block clicks
4. The page feels darker overall than the current CSS-only version
5. Dotted star map is visible across the page
6. Sisyphus main visual is clearly perceptible on the left side
7. Motion is slow and calm rather than distracting
8. Panel readability remains strong
9. Page still loads acceptably on desktop and remains usable on mobile

## Risks and Mitigations

Risk: The Sisyphus figure becomes too literal or illustrative.
Mitigation: Keep it abstracted into dotted drafting contours and geometric guides.

Risk: Motion becomes visually tiring.
Mitigation: Cap animation to slow drift and mild breathing only.

Risk: Background overpowers interface content.
Mitigation: Use stronger panel opacity, brightness attenuation, and left-biased composition.

Risk: Implementation becomes too heavy for a single JSP page.
Mitigation: Use a single fullscreen plane and generated texture approach rather than a complex scene graph.

## Final Recommendation

Proceed with a `Three.js + shader + canvas texture` background rebuild in `inspect.jsp`, centered on a left-dominant dotted Sisyphus technical drawing, full-page star-map dots, and extremely slow cosmic drift. Keep the interface itself intact and ensure the result feels darker, quieter, and more philosophically charged than the current ambient background.
