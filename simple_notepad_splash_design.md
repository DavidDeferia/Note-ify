# Simple Notepad — Splash Screen Design

A modern dark splash screen for the Flutter **Simple Notepad** app, featuring a notebook icon that dashes from the left side of the screen to the right with a glowing cyan motion trail.

## Design overview

- **Background:** Deep navy (`#080D18`)
- **Accent:** Neon cyan (`#00D9FF`)
- **Secondary glow:** Violet (`#6558FF`)
- **Icon:** `edit_note_rounded` inside a rounded dark panel with a cyan outline and glow
- **App title:** `Simple Notepad`
- **Tagline:** `Your thoughts. One place.`
- **Loading label:** `PREPARING YOUR NOTES`
- **Footer:** `MADE FOR YOUR IDEAS`

## Layout

1. A notebook icon travels horizontally from off-screen left to off-screen right.
2. A cyan glowing line follows the notebook icon to create a dashing effect.
3. The app title and tagline sit below the animation.
4. A slim progress bar fills as the animation runs.
5. The screen fades into the notepad home screen after about 2.4 seconds.

## Animation behavior

- **Duration:** 1.6 seconds for the dash animation
- **Curve:** `Curves.easeInOutCubic`
- **Transition:** Fade into the existing notepad screen
- **Splash duration:** About 2.4 seconds
- **Dependencies:** Flutter SDK only; no extra animation package is required

## Color palette

| Purpose | Color |
|---|---|
| Main background | `#080D18` |
| Icon panel | `#111E30` |
| Cyan glow / trail | `#00D9FF` |
| Violet background glow | `#6558FF` |
| Main title | `#FFFFFF` |
| Supporting text | `#8997AD` |
| Loading track | `#202B3D` |

## Flutter integration

Create `lib/splash_screen.dart` and add the `SplashScreen` widget.

In `lib/main.dart`, import it:

```dart
import 'splash_screen.dart';
```

Set the `home` property in your existing `MaterialApp`:

```dart
home: SplashScreen(
  nextScreen: const MyHomePage(),
),
```

Replace `MyHomePage()` with the actual widget for your existing notepad home screen. Remove `const` if that widget does not support a const constructor.

Keep your current note-management and `SharedPreferences` code unchanged.

## Preview description

Picture a nearly black navy screen with a subtle cyan glow in the upper-right and a violet glow near the lower-left. A cyan-outlined notebook icon streaks across the screen, leaving a bright horizontal trail. Centered below it are the white title **Simple Notepad**, the muted tagline, a thin cyan progress bar, and the small uppercase loading label.

> This is an in-app splash screen. Android's native launch screen may appear first, before Flutter draws this design.
