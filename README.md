# Spatial D-pad Navigation for Flutter TV

Spatial D-pad navigation and focus management for Flutter applications designed for TV remotes, gamepads, and directional input.

`flutter_spatial_navigation` provides geometric focus traversal, focus memory between sections, TV-friendly focusable widgets, and virtualized lazy lists for building responsive TV interfaces.

> **Status:** Early release (`0.1.x`). APIs may evolve before `1.0.0`.

## Features

- 🎯 **Spatial D-pad navigation**
  - Geometric `up`, `down`, `left`, and `right` focus traversal.
  - Navigation is based on widget position rather than widget order.
  - Android `FocusFinder`-style scoring approach.

- 🧠 **Focus memory**
  - `TVFocusGroup` remembers the last focused item in a section.
  - Returning to a row restores the previous focus position.

- 📺 **TV-friendly focusable widgets**
  - `TVFocusable` provides focus state, select handling, and long-press support.
  - Easy to customize focused/unfocused UI.

- 🕹️ **TV remote and gamepad input**
  - Supports select/enter-style input.
  - Supports Android TV D-pad center input.
  - Supports keyboard/gamepad select keys.

- ↔️ **Directional focus overrides**
  - Explicitly control where focus moves with `targetUp`, `targetDown`, `targetLeft`, and `targetRight`.

- 📜 **Virtualized TV lists**
  - `TVLazyList` is designed for large horizontal or vertical TV carousels.
  - Handles focus transfer when items are dynamically mounted.
  - Supports configurable keyline alignment.

- 🌍 **RTL support**
  - Horizontal `TVLazyList` navigation respects `TextDirection.rtl`.

- 🎛️ **Navigation control**
  - Enable or disable D-pad navigation globally.
  - Programmatically request, clear, and inspect focus.

## Why spatial navigation?

Traditional Flutter focus traversal is often based on widget traversal order.

TV interfaces are different.

When a user presses:

```text
        ↑
        │
    ┌───────┐
 ←  │ Item  │  →
    └───────┘
        │
        ↓
```

the expected behavior is to move to the visually appropriate widget in that direction.

This package provides a spatial traversal policy that evaluates the geometry of focusable widgets and selects an appropriate candidate.

---

# Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_spatial_navigation: ^0.1.0
```

Then run:

```bash
flutter pub get
```

Import the package:

```dart
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';
```

---

# Quick Start

A minimal TV screen can use `TVSpatialTraversalPolicy` with `TVFocusable`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FocusTraversalGroup(
          policy: const TVSpatialTraversalPolicy(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TVFocusable(
                autofocus: true,
                onSelect: () {
                  debugPrint('Movie 1 selected');
                },
                builder: (context, focused) {
                  return _MovieCard(
                    title: 'Movie 1',
                    focused: focused,
                  );
                },
              ),
              TVFocusable(
                onSelect: () {
                  debugPrint('Movie 2 selected');
                },
                builder: (context, focused) {
                  return _MovieCard(
                    title: 'Movie 2',
                    focused: focused,
                  );
                },
              ),
              TVFocusable(
                onSelect: () {
                  debugPrint('Movie 3 selected');
                },
                builder: (context, focused) {
                  return _MovieCard(
                    title: 'Movie 3',
                    focused: focused,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({
    required this.title,
    required this.focused,
  });

  final String title;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: focused ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: 180,
        height: 240,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: focused
              ? Border.all(
                  color: Colors.white,
                  width: 3,
                )
              : null,
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
```

Press the remote D-pad:

- `LEFT` → previous item
- `RIGHT` → next item
- `UP` / `DOWN` → spatially appropriate item
- `SELECT` / `ENTER` → activate the focused item

---

# Core Components

## `TVSpatialTraversalPolicy`

The spatial traversal policy determines where focus should move when the user presses a directional key.

```dart
FocusTraversalGroup(
  policy: const TVSpatialTraversalPolicy(
    edgeBehavior: TVEdgeBehavior.escape,
  ),
  child: YourTvLayout(),
)
```

### Edge behavior

Two behaviors are available:

```dart
TVEdgeBehavior.escape
```

The directional key is not consumed when there is no candidate.

```dart
TVEdgeBehavior.trap
```

The directional key is consumed and focus remains on the current widget.

Example:

```dart
FocusTraversalGroup(
  policy: const TVSpatialTraversalPolicy(
    edgeBehavior: TVEdgeBehavior.trap,
  ),
  child: YourTvLayout(),
)
```

---

# `TVFocusable`

`TVFocusable` is the main interactive widget for TV interfaces.

```dart
TVFocusable(
  autofocus: true,
  onSelect: () {
    debugPrint('Selected');
  },
  builder: (context, focused) {
    return MyCard(
      focused: focused,
    );
  },
)
```

The `builder` receives:

```dart
bool focused
```

so your UI can easily render a different appearance when the item has focus.

## Disable an item

```dart
TVFocusable(
  enabled: false,
  builder: (context, focused) {
    return const Text('Disabled');
  },
)
```

Disabled widgets cannot receive focus or respond to TV selection input.

---

# Select and Long Press

Normal selection:

```dart
TVFocusable(
  onSelect: () {
    debugPrint('Selected');
  },
  builder: ...,
)
```

Long press:

```dart
TVFocusable(
  onSelect: () {
    debugPrint('Short press');
  },
  onLongSelect: () {
    debugPrint('Long press');
  },
  builder: ...,
)
```

When `onLongSelect` is provided, a short press triggers `onSelect`, while holding the select key triggers `onLongSelect`.

---

# Directional Focus Overrides

Sometimes geometric navigation is not enough.

For example, a TV application may have a sidebar:

```text
┌──────────┬─────────────────────────────┐
│ Sidebar  │                             │
│          │       Content               │
│ Settings │                             │
│ Search   │                             │
│ Home     │                             │
└──────────┴─────────────────────────────┘
```

You can explicitly control a direction:

```dart
TVFocusable(
  targetRight: () => contentNode,
  builder: (context, focused) {
    return SidebarItem(
      focused: focused,
    );
  },
)
```

The callback is evaluated when the directional key is pressed.

Returning a `FocusNode` moves focus to that node:

```dart
targetRight: () => contentNode,
```

Returning `null` intentionally traps that direction:

```dart
targetRight: () => null,
```

If no override is provided, the spatial traversal policy is used automatically.

---

# `TVFocusGroup`

`TVFocusGroup` provides focus memory for a section of the UI.

This is useful for TV layouts containing multiple rows:

```dart
TVFocusGroup(
  child: Row(
    children: [
      TVFocusable(...),
      TVFocusable(...),
      TVFocusable(...),
    ],
  ),
)
```

Suppose the user focuses the third item:

```text
[A] [B] [C*]
```

then moves to another row:

```text
[D] [E] [F*]
```

When the user moves back to the first row, the package can restore focus to:

```text
[A] [B] [C*]
```

instead of always starting from the first item.

This is especially useful for streaming and media applications.

---

# `TVLazyList`

`TVLazyList` is designed for large TV carousels and lists.

```dart
TVLazyList(
  itemCount: 1000,
  itemExtent: 180,
  itemBuilder: (context, index, focused) {
    return MovieCard(
      index: index,
      focused: focused,
    );
  },
)
```

Only the items required by Flutter's lazy list are mounted.

The package keeps track of the currently mounted focus nodes and requests focus when the target item becomes available.

## Horizontal list

```dart
SizedBox(
  height: 220,
  child: TVLazyList(
    itemCount: 1000,
    itemExtent: 180,
    scrollDirection: Axis.horizontal,
    itemBuilder: (context, index, focused) {
      return MovieCard(
        index: index,
        focused: focused,
      );
    },
  ),
)
```

## Vertical list

```dart
TVLazyList(
  itemCount: 1000,
  itemExtent: 100,
  scrollDirection: Axis.vertical,
  itemBuilder: (context, index, focused) {
    return ListTile(
      title: Text('Item $index'),
      selected: focused,
    );
  },
)
```

---

# Focus Alignment

`TVLazyList` supports configurable focus alignment:

```dart
TVLazyList(
  itemCount: 1000,
  itemExtent: 180,
  focusAlignment: 0.0,
  itemBuilder: ...,
)
```

Common values include:

```text
0.0  → start/keyline
0.5  → center
1.0  → end
```

For example:

```dart
TVLazyList(
  focusAlignment: 0.5,
  ...
)
```

keeps the focused item closer to the center of the viewport.

---

# Initial Focus Position

You can start a lazy list at a specific item:

```dart
TVLazyList(
  itemCount: 1000,
  itemExtent: 180,
  initialIndex: 20,
  itemBuilder: ...,
)
```

---

# Programmatic Focus Control

The package provides `BuildContext` extensions for common focus operations.

## Request focus

```dart
context.tvRequestFocus(movieNode);
```

## Clear focus

```dart
context.tvClearFocus();
```

## Get the currently focused node

```dart
final node = context.tvFocusedNode;
```

## Check whether a node is focused

```dart
final focused = context.tvIsFocused(movieNode);
```

## Check whether this context contains focus

```dart
final hasFocus = context.tvHasFocusWithin;
```

## Move focus in a direction

```dart
context.tvFocusInDirection(
  TraversalDirection.right,
);
```

---

# Temporarily Disable D-pad Navigation

Some screens need to temporarily take control of remote input.

For example, while displaying a video player overlay:

```dart
context.tvSetNavigationEnabled(false);
```

Re-enable navigation:

```dart
context.tvSetNavigationEnabled(true);
```

You can also access the current state:

```dart
final enabled = context.tvIsNavigationEnabled;
```

---

# Global Navigation Controller

For applications that need explicit control over navigation state:

```dart
final controller = TVNavigationController();

runApp(
  TVNavigation(
    controller: controller,
    child: const MyApp(),
  ),
);
```

Navigation can then be disabled:

```dart
controller.setEnabled(false);
```

and enabled again:

```dart
controller.setEnabled(true);
```

If no controller is supplied, `TVNavigation` manages its own controller lifecycle.

---

# Recommended TV Layout

For a typical streaming application, a structure like this works well:

```dart
FocusTraversalGroup(
  policy: const TVSpatialTraversalPolicy(),
  child: Column(
    children: [
      TVFocusGroup(
        child: TVLazyList(
          itemCount: 20,
          itemExtent: 220,
          itemBuilder: ...,
        ),
      ),

      TVFocusGroup(
        child: TVLazyList(
          itemCount: 50,
          itemExtent: 180,
          itemBuilder: ...,
        ),
      ),

      TVFocusGroup(
        child: TVLazyList(
          itemCount: 100,
          itemExtent: 180,
          itemBuilder: ...,
        ),
      ),
    ],
  ),
)
```

This gives each section its own focus memory while allowing the spatial traversal policy to move between sections.

---

# Example Application

A complete example is included in the repository:

```text
example/
```

It demonstrates multiple TV rows using `TVFocusGroup` and `TVLazyList`.

Run it with:

```bash
cd example
flutter run
```

---

# API Overview

| API | Purpose |
|---|---|
| `TVFocusable` | Focusable TV interaction widget |
| `TVFocusGroup` | Remembers the last focused descendant |
| `TVSpatialTraversalPolicy` | Geometric D-pad navigation |
| `TVEdgeBehavior` | Controls behavior at navigation boundaries |
| `TVLazyList` | Virtualized TV-oriented list/carousel |
| `TVNavigation` | Navigation state lifecycle wrapper |
| `TVNavigationController` | Enable/disable navigation |
| `TVNavigationScope` | Navigation state inherited widget |
| `TVNavigationContext` | `BuildContext` focus/navigation helpers |

---

# Supported Input

`TVFocusable` recognizes common select/confirm inputs including:

- Select
- Enter
- Numpad Enter
- Gamepad A
- Gamepad Select
- Space
- Android TV D-pad center

Directional navigation uses:

- Arrow Up
- Arrow Down
- Arrow Left
- Arrow Right

---

# RTL

Horizontal `TVLazyList` navigation takes the current `TextDirection` into account.

For RTL interfaces:

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: TVLazyList(
    ...
  ),
)
```

left/right navigation is adjusted accordingly.

---

# Design Goals

This package is intentionally focused on TV-style navigation rather than replacing Flutter's complete focus system.

The goals are:

1. Make D-pad navigation predictable.
2. Make focus behavior match the visual layout.
3. Preserve focus when moving between TV sections.
4. Handle large virtualized TV lists safely.
5. Make TV remote interaction easy to implement.
6. Keep the API small and Flutter-native.

---

# Package Status

This package is currently in the `0.1.x` development series.

The API may change before `1.0.0`.

Feedback, bug reports, and contributions are welcome.

If you encounter a focus-navigation layout that does not behave as expected, please open an issue with:

- Flutter version
- Dart version
- Target TV/device
- Layout structure
- Expected focus movement
- Actual focus movement

---

# License

This project is open source and distributed under the license included in the repository.