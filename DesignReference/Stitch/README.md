# SmartTrip Stitch Design Reference

This directory contains the Stitch-generated UI reference used for SmartTrip 2.0.

These files are design references only.

- `coastal_explorer/DESIGN.md` defines the intended visual language.
- `code.html` files describe screen layouts and styling.
- `screen.png` files provide visual references where available.

The production application is implemented in native SwiftUI.

The reference HTML is not compiled or embedded in the app. Keep this directory outside all app and test target membership, Compile Sources, and Copy Bundle Resources.

Current SmartTrip architecture remains:

View
→ ViewModel
→ Use Case
→ Repository Protocol
→ Core Data Repository
→ Core Data

Do not use prototype mock data as production state.

## Screenshot availability

The original export contained 13 files named `screen.png` whose entire contents were `<FIFE Image failed to fetch>`. These invalid image placeholders were omitted. Six valid screenshots are retained; all 19 screen HTML files and the design document are preserved. Numbered screen variants contain distinct HTML and are retained.
