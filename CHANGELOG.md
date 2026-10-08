# 0.1.2

* Add `onKeyEvent` callback support to `TVFocusable` for custom key interception.
* Improve select key handling and event consumption in `TVFocusable`.

# 0.1.1

* Fix scroll position loss when moving focus across rows by introducing `defaultTVRequestFocusCallback` in `TVSpatialTraversalPolicy`.
* Add `AutomaticKeepAliveClientMixin` and `PageStorageKey` to `TVLazyList` to prevent state disposal inside `SliverList` and `CustomScrollView`.
* Synchronize keyline scrolling in `TVLazyList` when focus enters an item from vertical navigation or group restoration.

# 0.1.0

* Initial public release.
* Added geometric D-pad spatial navigation.
* Added focus memory with TVFocusGroup.
* Added TVFocusable with remote select and long-press support.
* Added TVLazyList for virtualized TV carousels.
* Added directional focus overrides.
* Added navigation context extensions.
* Added RTL-aware horizontal navigation.