# Jac Playground

An interactive, IDE-grade web playground for writing, running, and converting Jac code. Built with **Jac Client** (a React-like framework for Jac) featuring a fully responsive design that works seamlessly on desktop and mobile devices.

![Jac Playground](jac_playground/assets/jaseci.png)

## 🚀 Features

- **Jac Code Editor** - Monaco-powered editor with syntax highlighting
- **Code Execution** - Run Jac and Python code directly in the browser
- **Code Conversion** - Convert between Jac ↔ Python bidirectionally
- **Graph Visualization** - Visualize node/edge graphs with vis-network
- **Example Library** - Pre-built examples to learn Jac concepts
- **Responsive Design** - Full mobile support with touch-optimized UI
- **Debug Mode** - Step-through debugging support (in development)

## 📋 Prerequisites

- **Node.js** >= 18.x
- **pnpm** or **npm**
- **Jac CLI** - Install via `pip install jaclang`

## 🛠️ Installation

```bash
# Clone the repository
git clone https://github.com/jaseci-labs/jac-client-playground.git
cd jac-client-playground/jac_playground

# Install dependencies
pnpm install
# or
npm install
```

## 🏃 Running the Application

```bash
# Start the Jac server
jac serve app.jac
```

The playground will be available at `http://localhost:8000`

## 📁 Project Structure

```
jac_playground/
├── app.jac                    # Main application entry point
├── app.cl.jac                 # Backend walkers (code processing)
├── global.css                 # Tailwind CSS styles
├── package.json               # Node dependencies
├── vite.config.js             # Vite build configuration
│
├── components/                # UI Components
│   ├── PlayGroundLayout.jac   # Main layout orchestrator
│   ├── TopBar.jac             # Application header
│   ├── JacWorkspace.jac       # Editor + Graph split view
│   ├── ConversionEditor.jac   # Side-by-side conversion editor
│   ├── Visualizer.jac         # Graph visualization component
│   │
│   ├── Layout/                # Desktop-specific components
│   │   ├── DesktopLayout.jac  # Desktop layout (pure presentation)
│   │   ├── ActivityBar.jac    # Left sidebar with mode selection
│   │   ├── EditorToolbar.jac  # Run/Convert/Debug toolbar
│   │   ├── RightPanel.jac     # Examples & settings panel
│   │   └── DockableConsole.jac# Resizable output console
│   │
│   ├── Mobile/                # Mobile-specific components
│   │   ├── MobileLayout.jac   # Mobile layout (pure presentation)
│   │   ├── MobileBottomNav.jac# Bottom navigation tabs
│   │   ├── MobileFAB.jac      # Floating action button (Run/Convert)
│   │   ├── MobileModeSwitcher.jac # Mode dropdown in header
│   │   ├── MobileDebugController.jac # Debug controls
│   │   ├── MobilePanelRouter.jac # Panel routing logic
│   │   └── MobilePanels/      # Individual mobile panels
│   │       ├── CodePanel.jac
│   │       ├── GraphPanel.jac
│   │       ├── OutputPanel.jac
│   │       └── ExamplesPanel.jac
│   │
│   └── ui/                    # Reusable UI primitives
│       ├── Button.jac
│       ├── Panel.jac
│       ├── Badge.jac
│       └── separator.jac
│
├── hooks/                     # Custom React-like hooks
│   ├── usePlayground.jac      # 🔑 Central state management hook
│   └── useMobile.jac          # Viewport detection hooks
│
├── lib/                       # Utilities
│   └── utils.jac              # cn() classname utility
│
└── examples/                  # Jac example files
    ├── basic/                 # Basic syntax examples
    └── object_spatial/        # Graph/walker examples
```

## 🏗️ Architecture

### Headless Hook Pattern

The application uses a **headless architecture** where all business logic is centralized in a custom hook, and layouts are purely presentational:

```
┌─────────────────────────────────────────────────────────────┐
│                    usePlayground() Hook                      │
│                  📍 hooks/usePlayground.jac                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  • All state (mode, code, output, errors, etc.)     │    │
│  │  • All handlers (onRun, onConvert, onDebug, etc.)   │    │
│  │  • Side effects (auto-navigate on run)              │    │
│  │  • Examples data loading                             │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
     ┌─────────────────┐            ┌─────────────────┐
     │  DesktopLayout  │            │  MobileLayout   │
     │  (Pure UI)      │            │  (Pure UI)      │
     │                 │            │                 │
     │  ActivityBar    │            │  MobileHeader   │
     │  EditorToolbar  │            │  MobilePanels   │
     │  RightPanel     │            │  MobileFAB      │
     │  DockableConsole│            │  BottomNav      │
     └─────────────────┘            └─────────────────┘
```

### Benefits of This Architecture

| Aspect                            | Benefit                                    |
| --------------------------------- | ------------------------------------------ |
| **Single Source of Truth**        | All state lives in `usePlayground` hook    |
| **Change Once, Apply Everywhere** | Business logic changes affect both layouts |
| **No Code Duplication**           | Layouts only handle presentation           |
| **Easy Testing**                  | Test hook logic independently              |
| **Consistent Behavior**           | Desktop and mobile always in sync          |

### Responsive Breakpoints

```javascript
BREAKPOINTS = {
  mobile: 767, // ≤ 767px  → MobileLayout
  tablet: 1023, // 768-1023px → (future tablet layout)
  desktop: 1024, // ≥ 1024px → DesktopLayout
};
```

## 🔧 Adding New Features

### 1. Adding a New Handler/Logic

Edit **only** `hooks/usePlayground.jac`:

```jac
# In usePlayground.jac

# Add state
let [newFeatureEnabled, setNewFeatureEnabled] = useState(false);

# Add handler
def handleNewFeature() -> None {
    setNewFeatureEnabled(not newFeatureEnabled);
    # Your logic here
}

# Add to return object
return {
    # ... existing props
    "newFeatureEnabled": newFeatureEnabled,
    "onNewFeature": handleNewFeature
};
```

Both layouts automatically receive the new props!

### 2. Adding a Desktop-Only UI Element

Edit `components/Layout/DesktopLayout.jac`:

```jac
# Add new prop extraction
let newFeatureEnabled = props.newFeatureEnabled;
let onNewFeature = props.onNewFeature;

# Add UI element in JSX
<button onClick={onNewFeature}>
    {newFeatureEnabled and "Enabled" or "Disabled"}
</button>
```

### 3. Adding a Mobile-Only UI Element

Edit `components/Mobile/MobileLayout.jac` or create a new panel in `MobilePanels/`.

### 4. Adding a New Example

Add to the examples array in `usePlayground.jac` or create a `.jac` file in `examples/` folder:

```jac
{
    "id": "my_example",
    "title": "My Example",
    "category": "Basics",
    "code": "with entry {\n    print(\"Hello!\");\n}"
}
```

## 🎨 Styling

The project uses **Tailwind CSS v4** with custom CSS variables for theming:

```css
/* global.css */
:root {
  --color-background: #ffffff;
  --color-surface: #f8fafc;
  --color-border: #e2e8f0;
  --color-primary: #6366f1;
  --color-text-primary: #1e293b;
  --color-text-secondary: #64748b;
}
```

Use the `cn()` utility for conditional classnames:

```jac
cl import from "..lib.utils" { cn }

<div className={cn(
    "base-classes",
    condition and "conditional-class"
)} />
```

## 📱 Mobile-Specific Components

| Component               | Purpose                                        |
| ----------------------- | ---------------------------------------------- |
| `MobileBottomNav`       | Tab navigation (Code, Graph, Output, Examples) |
| `MobileFAB`             | Floating Run/Convert button                    |
| `MobileModeSwitcher`    | Mode dropdown in header                        |
| `MobileDebugController` | Collapsible debug controls                     |
| `MobilePanelRouter`     | Routes to active panel                         |

## 🔌 Backend Integration

The `app.cl.jac` file contains walkers for code processing:

```jac
walker code_processor {
    has source_code: str;
    has mode: str;  # "jacrun", "pyrun", "jac2py", "py2jac"

    # Returns execution result or converted code
}

walker load_example_list {
    # Loads examples from filesystem
}
```

## 🧪 Development Tips

1. **Hot Reload**: Changes to `.jac` files auto-compile when using `jac serve`
2. **Browser DevTools**: Use mobile device emulation to test responsive layouts
3. **Console Logging**: Use `print()` in Jac for debugging

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

Built with ❤️ using [Jac Language](https://github.com/Jaseci-Labs/jaclang) and [Jac Client](https://github.com/Jaseci-Labs/jac-client)
