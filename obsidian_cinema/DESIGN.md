---
name: Obsidian Cinema
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#e5bdbe'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#ac8889'
  outline-variant: '#5c3f40'
  surface-tint: '#ffb3b6'
  primary: '#ffb3b6'
  on-primary: '#68001a'
  primary-container: '#e11d48'
  on-primary-container: '#fffaf9'
  inverse-primary: '#be0037'
  secondary: '#ffb95f'
  on-secondary: '#472a00'
  secondary-container: '#ee9800'
  on-secondary-container: '#5b3800'
  tertiary: '#7bd0ff'
  on-tertiary: '#00354a'
  tertiary-container: '#007ca8'
  on-tertiary-container: '#f8fbff'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdada'
  primary-fixed-dim: '#ffb3b6'
  on-primary-fixed: '#40000c'
  on-primary-fixed-variant: '#920028'
  secondary-fixed: '#ffddb8'
  secondary-fixed-dim: '#ffb95f'
  on-secondary-fixed: '#2a1700'
  on-secondary-fixed-variant: '#653e00'
  tertiary-fixed: '#c4e7ff'
  tertiary-fixed-dim: '#7bd0ff'
  on-tertiary-fixed: '#001e2c'
  on-tertiary-fixed-variant: '#004c69'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
typography:
  display-lg:
    fontFamily: Montserrat
    fontSize: 64px
    fontWeight: '800'
    lineHeight: 72px
    letterSpacing: -0.02em
  display-sm:
    fontFamily: Montserrat
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  caption:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-max: 1440px
  gutter: 24px
  margin-desktop: 64px
  margin-mobile: 20px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
  section-gap: 80px
---

## Brand & Style

The design system is engineered for a high-end, cinematic immersion experience. It targets film enthusiasts and industry professionals who demand a premium, theater-like atmosphere during discovery. 

The aesthetic is **Cinematic Minimalism** mixed with **Glassmorphism**. By utilizing deep obsidian voids and vibrant, high-energy accents, the interface recedes into the background, allowing high-resolution film stills and trailers to become the focal point. The emotional response is one of "curated darkness"—sophisticated, focused, and expensive.

**Key Stylistic Pillars:**
- **Atmospheric Depth:** Use of multi-layered translucent surfaces to simulate the depth of a physical cinema space.
- **Media-First Philosophy:** UI elements are treated as secondary to the metadata and visual assets of the film.
- **Vibrant Interactivity:** Action points use high-saturation "Action Gold" or "Cinema Red" to pop against the desaturated backgrounds.

## Colors

The palette is anchored in a dual-tone dark mode. The **Background Void** (#020617) provides the absolute base, while the **Neutral** (#0F172A) serves as the primary surface color for cards and containers.

**Accent Strategy:**
- **Cinema Red (#E11D48):** Used for critical actions, branding, and "Live" indicators.
- **Action Gold (#F59E0B):** Specifically reserved for ratings, awards, and premium features to evoke a sense of quality.
- **Surface Glass:** All overlays must use a semi-transparent blur rather than a solid color to maintain the immersive feel of the background media.

## Typography

This design system uses a hierarchical font strategy. **Montserrat** is used for high-impact headlines and movie titles to provide a bold, authoritative voice. **Inter** is utilized for all body copy and metadata to ensure maximum legibility at small sizes against dark backgrounds.

- **Display Styles:** Use sparingly for hero movie titles.
- **Labels:** Always uppercase with increased letter spacing to provide a "technical" metadata feel (e.g., GENRE, RUNTIME).
- **Readability:** Ensure a minimum contrast ratio of 7:1 for body text by using light gray tints rather than pure white to reduce eye strain in low-light environments.

## Layout & Spacing

The layout follows a **Fluid 12-Column Grid** for desktop and a **4-Column Grid** for mobile. The philosophy is "Generous Breathing Room," allowing high-impact imagery to occupy significant screen real estate.

- **Grid:** Use 24px gutters to prevent content density from feeling overwhelming.
- **Section Gaps:** Maintain large vertical gaps (80px+) between different content rows (e.g., "Trending Now" vs "Recommended for You") to distinguish categories clearly.
- **Safe Areas:** On movie detail pages, the top 40% of the viewport is reserved for hero media, with content overlapping using a gradient fade.

## Elevation & Depth

Depth is conveyed through **Glassmorphism** and **Luminous Outlines** rather than traditional shadows.

- **Surface Layers:**
    - **Level 0 (Base):** #020617 (Obsidian).
    - **Level 1 (Cards):** #0F172A with a 1px border of `rgba(255,255,255,0.1)`.
    - **Level 2 (Modals/Overlays):** `rgba(15, 23, 42, 0.8)` with a 40px Backdrop Blur.
- **Shadows:** Use large, low-opacity "Ambient Glows" instead of black shadows. The glow should inherit a subtle tint of the primary color (Red or Gold) to suggest light reflecting from the screen.

## Shapes

The design system utilizes a **Rounded** (0.5rem base) shape language to soften the high-contrast visuals and make the interface feel modern and approachable.

- **Standard Elements:** 8px (0.5rem) for buttons and input fields.
- **Media Containers:** 16px (1rem) for movie posters and video thumbnails to create a "card" feel.
- **Interactive States:** On hover, media containers should slightly scale (1.05x) while maintaining their corner radius.

## Components

**Buttons:**
- **Primary:** Solid #E11D48 with white text. High-gloss finish.
- **Secondary:** Glass-style background with a 1px white-alpha border.
- **Icon Buttons:** Circular, translucent backgrounds, used for "Add to Watchlist" or "Like."

**Cards (Movie Posters):**
- Must feature a vertical aspect ratio (2:3).
- Include a subtle gradient overlay at the bottom to house the title and rating in white text for legibility over varied imagery.
- Hover state: Display a "Play" icon overlay with 60% opacity.

**Chips/Tags:**
- Used for genres (e.g., Sci-Fi, Drama).
- Pill-shaped with a dark blue-gray background (#1E293B) and `label-md` typography.

**Inputs:**
- Dark backgrounds (#020617) with a 1px border that glows "Action Gold" when focused.
- Search bars should be prominent, featuring a glassmorphic background when used in the navigation header.

**Progress Bars:**
- Used for "Watch Progress." 4px height, using Primary Red for the fill and a desaturated dark red for the track.