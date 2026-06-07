# Inspect Page UI Redesign Design

## Overview

This design updates the contract inspection page at `web-frontend-jsp/inspect.jsp` into a dark "control console" experience while preserving all existing API integrations and business logic. The page should feel like a professional analysis terminal for labor-contract review rather than a generic Bootstrap form page.

The redesign applies only to the presentation layer:

- HTML layout structure inside `inspect.jsp`
- CSS variables, component styling, spacing, and typography
- Empty, loading, and result display presentation
- Small display-only labels and helper copy

The redesign must not change:

- API endpoints
- Request or response payload shapes
- Vue state names and core behavior
- Login state storage key
- Logout and redirect logic
- Markdown rendering mechanism

## Goals

- Create a distinctive "black obsidian control console" visual language
- Make the page feel more credible as a legal AI inspection tool
- Improve scanability of the main workflow: input, run analysis, inspect results
- Preserve readability for long Markdown reports
- Support both desktop and mobile layouts without changing functionality

## Non-Goals

- No backend changes
- No endpoint renaming
- No additional features or workflow changes
- No migration to React, Tailwind, or component libraries
- No changes to `login.jsp` in this task

## Current Constraints

The current frontend is a JSP page enhanced with Vue 3, Axios, Bootstrap 5, and Marked via CDN. The page already depends on the following reactive values and methods, which should remain intact:

- `currentUser`
- `contractText`
- `reviewResult`
- `modifyResult`
- `reviewLoading`
- `modifyLoading`
- `error`
- `activeTab`
- `logout`
- `submitReview`
- `submitModify`

The current backend contract used by the page must remain unchanged:

- `POST http://127.0.0.1:8001/api/v1/review`
- `POST http://127.0.0.1:8001/api/v1/agent_modify`

## Recommended Visual Direction

Recommended approach: **Black Obsidian Console**

Why this approach:

- It best matches the reference style the user selected
- It fits the product domain of review, analysis, and decision support
- It allows strong visual identity without harming long-form text readability

Key traits:

- Deep black and charcoal layered background
- Cool white body text with restrained cyan-blue highlights
- Fine borders, panel seams, and technical dividers
- Small status tags, metadata rows, and console-style headings
- Compact hero treatment replaced by a functional top system bar

## Layout Design

### 1. Top System Bar

The large hero area should be removed and replaced with a compact top bar.

Contents:

- Product title and icon
- Short system descriptor
- Current user display
- Logout button
- Small status badge such as "system ready"

Purpose:

- Reduce wasted vertical space
- Set the tone immediately
- Make the page feel like an active tool rather than a landing page

### 2. Main Workspace

Desktop layout:

- Left column for input and actions
- Right column for results and tabs

Mobile layout:

- Stack input above results
- Keep action buttons visible without horizontal crowding

Spacing principles:

- Use tighter spacing than the current Bootstrap-heavy layout
- Group related controls into framed panels
- Keep clear separation between action controls and content display

### 3. Input Panel

The input area becomes a control panel rather than a plain form block.

Elements:

- Panel title
- One-line helper description
- Large textarea framed like a console document editor
- Two primary action buttons
- Error area placed close to the action region

Visual treatment:

- Dark panel background with subtle inset shading
- Monospace-flavored labels and panel metadata
- Smaller radius corners than the current design
- Visible focus state on the textarea

### 4. Result Panel

The result side becomes a report viewer.

Elements:

- Panel title
- Mode tabs for review and modify results
- Empty state
- Loading state
- Markdown result container

Visual treatment:

- Stronger distinction between header controls and content body
- Clear active-tab styling
- Long-form result area with structured headings and sections
- Scroll-friendly composition without visual clutter

## Component Styling

### Color System

Primary background:

- `#0b0f14`
- `#11161d`
- `#161b22`

Text:

- Primary: `#f3f7fb`
- Secondary: `rgba(243, 247, 251, 0.72)`
- Muted: `rgba(243, 247, 251, 0.45)`

Accents:

- Info / primary: cyan-blue
- Success: cool green
- Warning / error: restrained orange-red

The accent colors should be used sparingly so the page remains sophisticated and tool-like.

### Typography

Typography should balance technical character with readability.

- Headers, labels, status chips, and metadata rows use a more terminal-like stack
- Long body text and Markdown result content keep a readable UI sans stack
- Avoid decorative typography that hurts Chinese text legibility

### Surfaces and Borders

Panels should use:

- Layered dark surfaces
- Thin translucent borders
- Inner glow or soft inset shadow for depth
- Small technical corner or divider accents where useful

Avoid:

- Soft, oversized card styling
- Large playful gradients
- Bright glossy buttons

### Buttons

The two action buttons should read as operator commands.

- Equal visual weight, but with clear primary and secondary differentiation
- Strong disabled state
- Crisp hover and active feedback
- Full-width on mobile, compact but prominent on desktop

## Content States

### Empty State

When no review or modification result exists, the panel should guide the user gently.

Behavior:

- Show a centered empty state
- Include an icon, short instruction, and low-noise supporting copy
- Distinguish review empty state from modify empty state

### Loading State

Loading should feel like the system is running analysis, not just spinning.

Behavior:

- Keep the current request logic
- Restyle the state with stronger status messaging and system-progress tone
- Preserve clarity that the user should wait rather than interact repeatedly

### Error State

Error styling should become more intentional.

Behavior:

- Keep error text from existing logic
- Present it in a compact alert panel consistent with the dark theme
- Place it close to the action context

## Markdown Report Styling

The Markdown output is a critical part of the experience and needs dedicated styling.

Required improvements:

- Strong visual hierarchy for headings
- Comfortable paragraph spacing
- Better list indentation and spacing
- Distinct blockquote styling for legal references or notes
- Better inline code and preformatted treatment if present
- Clear separation between sections without feeling noisy

Readability rule:

The result area should look like a serious report viewer, not a hacker terminal. Technical atmosphere is welcome, but long reading comfort has higher priority.

## Responsiveness

Desktop:

- Two-column workspace
- Top system bar remains compact
- Result area gets the larger visual emphasis

Tablet:

- Reduced panel padding
- Buttons may remain side-by-side if space allows

Mobile:

- Single-column stacking
- Buttons remain in a clean two-up layout on wider phones and stack vertically below 480px viewport width
- Top metadata compresses cleanly
- No tiny decorative details that become noise

## Accessibility and Usability

The redesign should preserve and improve practical usability.

- Maintain strong contrast on dark surfaces
- Preserve visible focus states
- Avoid relying only on color to indicate active state
- Keep button labels explicit
- Ensure long text is readable with appropriate line height

## Implementation Plan Scope

Implementation is intentionally narrow and isolated to `inspect.jsp`.

Expected edit categories:

- Replace the current page-level CSS block
- Restructure the top navigation and hero into a compact system header
- Refactor the main body into console panels
- Restyle tabs, textarea, buttons, result container, and helper sections
- Keep the existing Vue script logic intact except for minimal display-only binding adjustments if needed

## Validation Checklist

After implementation, verify:

1. Review request still submits and renders `res.data.report`
2. Modify request still submits and renders `res.data.modified_text`
3. Logout still clears `faxiaozhi_user` and redirects correctly
4. Empty, loading, result, and error states all render correctly
5. Desktop and mobile layouts remain usable
6. Markdown headings, lists, and blockquotes are visually clear

## Risks and Mitigations

Risk: The design becomes too "sci-fi" and harms report readability.
Mitigation: Keep decorative details around the frame and controls, not inside the main report body.

Risk: Dark theme reduces perceived spacing and hierarchy.
Mitigation: Use strong spacing rhythm, muted metadata text, and clear panel headers.

Risk: Bootstrap defaults leak into the visual system.
Mitigation: Override core components explicitly at the page level rather than relying on defaults.

## Final Recommendation

Proceed with a focused redesign of `inspect.jsp` using the Black Obsidian Console direction. Keep all API and workflow behavior unchanged, but substantially upgrade the visual identity, state presentation, and report readability so the page feels like a professional legal analysis console rather than a generic demo page.
