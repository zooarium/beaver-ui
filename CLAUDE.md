# CLAUDE.md

## Sidebar menu icons

Icons come from `@aviary-ui/ui`, which re-exports `@tabler/icons-react` from a
single file: `aviary-ui/packages/ui/src/ui/icons.js`.

To add/change an icon for a sidebar menu item:
1. If the icon isn't already re-exported, add it to
   `aviary-ui/packages/ui/src/ui/icons.js`.
2. In `src/config/nav.jsx`, import the icon from `@aviary-ui/ui` and set it on
   the entry: `{ path, label, Icon }` in `NAV_ITEMS` (sidebar) or
   `USER_MENU_ITEMS` (username dropdown).
3. `AppLayout` (`@aviary-ui/ui`, `aviary-ui/packages/ui/src/components/AppLayout.jsx`)
   renders the sidebar from the `navItems`/`userMenuItems` props automatically —
   no other file needs editing.
