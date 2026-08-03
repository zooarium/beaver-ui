# beaver-ui AI Agent Context

This document provides context and guidelines for AI agents working on the beaver-ui codebase.

## 🎯 Project Overview

beaver-ui is a **project scaffold**, not a standalone app. Shared HTTP client, auth storage,
UI components, and layout all live in sibling packages `@aviary-ui/core` and `@aviary-ui/ui`
(`../aviary-ui/packages/*`, built via `make build` there first). This repo only wires up
routes, pages, and app-specific resources on top of that shared library — clone, rename,
build your app without touching aviary-ui.

## 🛠️ Tech Stack

| Layer | Library |
|-------|---------|
| UI framework | React 19 (functional components + hooks) |
| CSS | **Tabler CSS 1.2** (Bootstrap-based — use Bootstrap utility classes) |
| Icons | `@tabler/icons-react` (re-exported via `@aviary-ui/ui`) |
| Dialogs | `@radix-ui/react-dialog`, `@radix-ui/react-alert-dialog` |
| Routing | React Router DOM v7 |
| Server state | **TanStack Query v5** (`@tanstack/react-query`) |
| Forms | **React Hook Form v7** + **Zod v4** (`@hookform/resolvers`) — dependency present, no example file yet |
| Mocking | **MSW v2** (tests + optional dev mode) |
| Build | Vite 7 |
| Testing | Vitest + Testing Library |

> **No Tailwind.** Use Tabler/Bootstrap utility classes (`d-flex`, `gap-2`, `text-secondary`, `min-vh-100`, etc.).

## 📁 Source Structure

```
src/
  api/           auth.js · thing.js (scaffold template)
  config/        nav.jsx — NAV_ITEMS passed to AppLayout
  hooks/         useThing.js (scaffold template)
  infra/
    router/      index.jsx — route table
    config.js    app-specific env vars only (VITE_APP_NAME)
  mocks/         handlers.js · server.js · browser.js
  pages/         LoginPage.jsx · DashboardPage.jsx
  test/          setup.js
  App.jsx        provider stack
  main.jsx       entry point — configure() + conditional MSW worker + mount
```

There is **no local `src/ui/` barrel** — UI primitives (`Button`, `Card`, `FormField`,
`Spinner`, icons, `ErrorBoundary`, `ThemeProvider`, `NotificationProvider`, `PrivateRoute`,
`RootRedirect`, `RequireRole`, `RequirePermission`, …) come from `@aviary-ui/ui`. The HTTP
client (`apiRequest`, `authRequest`, `configure`) comes from `@aviary-ui/core`. Swapping
either implementation means editing aviary-ui only.

## 📐 Absolute Imports

`@/` maps to `src/`.

```js
import { useThing } from '@/hooks/useThing';
import { config }   from '@/infra/config';
import { Button, IconPlus } from '@aviary-ui/ui';
```

## 🗺️ Routes

| Path | Page | Guard |
|------|------|-------|
| `/login` | `LoginPage` | public |
| `/dashboard` | `DashboardPage` | `PrivateRoute` (`@aviary-ui/ui`) |
| `/` | `RootRedirect` (`@aviary-ui/ui`) → `/dashboard` or `/login` | — |

## 🌐 HTTP Layer & Config

`configure()` from `@aviary-ui/core`, called once in `main.jsx`, wires `apiBase` /
`authBase` / `refreshPath` from `VITE_API_BE_URL` / `VITE_API_URL` / `VITE_REFRESH_PATH`.
No `import.meta.env.*` outside `main.jsx` and `src/infra/config.js`.

- `apiRequest(path, opts)` (`@aviary-ui/core`) — authenticated API calls.
- `authRequest(path, opts)` (`@aviary-ui/core`) — auth-service calls (login, refresh).
- Refresh-on-401 and localStorage token handling live inside `@aviary-ui/core` — edit there, not here.

## 🛡️ Auth Guards

```jsx
import { PrivateRoute, RequireRole, RequirePermission } from '@aviary-ui/ui';

// Route-level
<PrivateRoute><ProtectedPage /></PrivateRoute>

// Component-level
<RequireRole role="admin"><AdminPanel /></RequireRole>
<RequirePermission permission="reports:export"><ExportButton /></RequirePermission>
```

`user.role` / `user.permissions[]` come from the shared auth storage in `@aviary-ui/core`.

## 🔁 TanStack Query — Data Fetching Pattern

See `src/hooks/useThing.js` (scaffold template) for the canonical shape:

```js
const { data, isLoading, error } = useQuery({
  queryKey: [THING_KEY, filters],
  queryFn: () => fetchThings(filters),
  select: (res) => res.data?.things ?? [],
});

const mutation = useMutation({
  mutationFn: (payload) => createThing(payload),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: [THING_KEY] });
    showNotification('Created successfully!', 'success');
  },
  onError: (err) => showNotification(err.message, 'error'),
});
```

Export the key constant from the hook file (`export const THING_KEY = 'things'`).
Global config in `App.jsx`: `staleTime: 30_000` (30s fresh window), `retry: 1`.
`useNotification()` comes from `@aviary-ui/ui`.

## 🧪 Testing & Mock API

MSW handlers in `src/mocks/handlers.js` back both tests and optional dev mode.
Set `VITE_MOCK_API=true` in `.env.development` to intercept requests in the browser
without a backend — `main.jsx` starts the worker conditionally on `DEV && VITE_MOCK_API`.
Tests always go through MSW via `src/mocks/server.js` regardless of that flag.

## 🚀 Common Tasks

### Add a new resource (API + hook + mock)
1. Copy `src/api/thing.js` → `src/api/foo.js`, replace `thing`/`Thing`/`things` with the resource name.
2. Copy `src/hooks/useThing.js` → `src/hooks/useFoo.js`, update imports and the exported key constant.
3. Add GET/POST/PUT/DELETE handlers to `src/mocks/handlers.js`.
4. Delete the scaffold comment blocks in the copied files.

### Add a new page
1. Create `src/pages/NewPage.jsx`, wrap with `<AppLayout navItems={NAV_ITEMS} appName={config.appName}>` (`@aviary-ui/ui`).
2. Lazy-import in `src/infra/router/index.jsx`.
3. Add `<Route>` (wrap in `<PrivateRoute>` if auth-required).
4. Add nav entry in `src/config/nav.jsx` — sidebar updates automatically.

### Add a sidebar menu icon
Icons come from `@aviary-ui/ui`, re-exported from `@tabler/icons-react` in
`aviary-ui/packages/ui/src/ui/icons.js` (single swap point for the icon library).
1. If the icon isn't already re-exported, add it there.
2. In `src/config/nav.jsx`, import the icon from `@aviary-ui/ui` and set it on the entry:
   `{ path, label, Icon }` in `NAV_ITEMS`.
3. `AppLayout` renders the sidebar from `navItems` automatically — no other file needs editing.

### Add a new form
Use RHF + Zod (dependency present, no local example yet): define a schema →
`useForm({ resolver: zodResolver(schema) })` → `register` inputs → `handleSubmit`.
Show field errors via `<FormField error={errors.field?.message}>` (`@aviary-ui/ui`).

## 📝 Coding Standards

- **Naming**: PascalCase for components, camelCase for variables/functions.
- **Imports**: use `@/` absolute imports for local files; import UI/HTTP primitives from `@aviary-ui/ui` / `@aviary-ui/core`, never re-implement them locally.
- **Formatting**: `make format` (Prettier) and `make lint` (ESLint) before committing.
- **Data fetching**: use TanStack Query hooks; never raw `useState` + `useEffect` for server state.
