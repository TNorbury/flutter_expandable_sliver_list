# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [4.0.0] - 2021-03-03
### Changed
- release nullsafety

## 4.0.0-nullsafety.0 - 2021-02-01
### Changed
- Migrate to nullsafety

## 3.0.0+1 - 2020-10-01
### Changed
-   Upgrade Flutter to 1.22

## 3.0.0 - 2020-09-18
### Added
-   Added `insertItems()` to controller, which takes a list of items, and a list of indices to insert them at
-   Pass the index of the item into the builder (break change)
-   Added some null-safety to the controller
-   Added `setItems()` to controller, which takes a list of items to replace the controller and list state's lists.

### Changed
-   When expanding on initial insertion, don't called `expand()`, just set the status

### Fixed
-   Index out of bounds protection in internal list builder

## 2.1.1 - 2020-09-11
### Fixed
-   Initialize expandOnInitialInsertion in controller

## 2.1.0 - 2020-09-10
### Fixed
-   Add param to expand list when initial item is added

## 2.0.1 - 2020-09-10
### Fixed
-   Added null protection for adding/removing items to a list. Allows one to add or remove items to a list that hasn't been built.

## 2.0.0 - 2020-09-03
### Fixed
-   Add ability to insert and remove items from the list
-   Restructured internals so that the controller does most of the work, as opposed to the widget

## 1.0.0+2 - 2020-08-27
### Fixed
-   Make longer description for more pub points :)

## 1.0.0+1 - 2020-08-27
### Fixed
-   Use correct package URL in readme

## 1.0.0 - 2020-08-27
### Fixed
-   Initial release for the ExpandableSliverList
-   Create flutter test automation and code coverage

[Unreleased]: 
[4.0.0]: