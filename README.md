# flutter_spatial_navigation

A fast, lightweight Flutter package for TV (Android TV, Apple TV, Fire TV) D-pad spatial navigation, focus memory, and virtualized lazy lists.

## Features

- **Spatial D-Pad Traversal**: Android `FocusFinder`-style geometric navigation policy using major-axis gap and cross-axis alignment scoring ($13 \times \text{major}^2 + \text{minor}^2$).
- **Focus Memory Groups**: `TVFocusGroup` remembers the last-focused child when switching between rows or columns (e.g. Netflix/Android TV Leanback style).
- **TV-Optimized Virtualized Lists**: `TVLazyList` provides smooth scrolling with keyline alignment and safe focus transfer for dynamically mounted offscreen items.
- **TV Remote Key Support**: Built-in support for TV remotes including `select`, `enter`, `numpadEnter`, `gameButtonA`, `space`, and Android TV `KEYCODE_DPAD_CENTER`.
- **Directional Overrides**: Explicit `targetUp`, `targetDown`, `targetLeft`, `targetRight` callbacks on `TVFocusable` for custom jump routing or traps.
- **Context-Level Navigation APIs**: Control focus and toggles with `context.tvRequestFocus()`, `context.tvClearFocus()`, `context.tvSetNavigationEnabled()`, and more.
- **Long-Press Context Actions**: Optional `onLongSelect` callback on `TVFocusable` with configurable hold duration.
- **RTL Support**: Built-in awareness for Right-to-Left languages in horizontal lists.

---

## Getting Started

Add `flutter_spatial_navigation` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_spatial_navigation: ^0.1.0
```

Import it in your Dart code:

```dart
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';
```

---

## Usage

### 1. Global Navigation & Traversal Policy

Wrap the root of your application with `TVNavigation`:

```dart
void main() {
  runApp(
    const TVNavigation(
      child: MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );
}
```

`TVNavigation` automatically manages the lifecycle of the `TVNavigationController` and exposes `TVNavigationScope` throughout the widget tree without controller recreation leaks.

To enable spatial traversal on your screen, use `FocusTraversalGroup` with `TVSpatialTraversalPolicy`:

```dart
FocusTraversalGroup(
  policy: const TVSpatialTraversalPolicy(
    edgeBehavior: TVEdgeBehavior.escape, // or TVEdgeBehavior.trap
  ),
  child: Scaffold(
    body: ...,
  ),
)
```

### 2. Interactive TV Items with `TVFocusable`

`TVFocusable` handles focus state changes, remote select keys, and long press:

```dart
TVFocusable(
  autofocus: true,
  onSelect: () => print('Selected!'),
  onLongSelect: () => print('Long pressed!'),
  // Optional directional overrides:
  targetRight: () => sidebarNode,
  builder: (context, focused) {
    return AnimatedScale(
      scale: focused ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          border: focused ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: const Center(child: Text('Play Movie')),
      ),
    );
  },
)
```

### 3. Preserving Row Focus Memory with `TVFocusGroup`

Wrap each row or section with `TVFocusGroup`. When the user navigates away and comes back, focus returns to the previously active item:

```dart
TVFocusGroup(
  child: Row(
    children: [
      TVFocusable(...),
      TVFocusable(...),
    ],
  ),
)
```

### 4. TV Virtualized Rows with `TVLazyList`

`TVLazyList` prevents offscreen focus loss in long virtualized lists:

```dart
TVFocusGroup(
  child: SizedBox(
    height: 200,
    child: TVLazyList(
      itemCount: 1000,
      itemExtent: 180,
      focusAlignment: 0.0, // 0.0 = start keyline, 0.5 = center
      padding: const EdgeInsets.symmetric(horizontal: 48),
      itemBuilder: (context, index, focused) {
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.primaries[index % Colors.primaries.length],
            border: focused ? Border.all(color: Colors.white, width: 3) : null,
          ),
          child: Center(child: Text('Item $index')),
        );
      },
    ),
  ),
)
```

### 5. Context-Level Helper Methods

Use `BuildContext` extensions anywhere in your widget tree:

```dart
// Move focus programmatically
context.tvRequestFocus(node);

// Unfocus all (useful for modals/overlays)
context.tvClearFocus();

// Check focus state
final isFocused = context.tvIsFocused(node);
final currentNode = context.tvFocusedNode;

// Disable/enable navigation (e.g., during video playback)
context.tvSetNavigationEnabled(false);
context.tvSetNavigationEnabled(true);
```
