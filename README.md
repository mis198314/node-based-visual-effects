# Node-Based Visual Effects (VFX) Compositor

A real-time, node-based VFX compositor built in Rust. This application allows users to create complex image processing pipelines by connecting modular nodes via a visual graph interface.

## Architecture

```text
[ Input Nodes ] --> [ Processing Nodes ] --> [ Output/Viewport ]
      |                    |                        |
 (Pattern Gen)        (Invert/B&C)             (Texture Frame)
      |                    |                        |
      +----[ Graph Engine / DAG ]-------------------+
             (Topological Sort, Cycle Detection)
```

## Technical Stack
- **Language:** Rust 2021
- **GUI:** `egui` / `eframe` (Immediate Mode GUI)
- **Parallelism:** `rayon` (Data-parallel pixel processing)
- **Graph Management:** `slotmap` (Stable identifiers)

## Quick Install

To install and run the application on your system, use the one-line installer for your OS:

### Linux
```bash
curl -sSL https://raw.githubusercontent.com/mis198314/node-based-visual-effects/master/scripts/install.sh | bash
```

### macOS
```bash
curl -sSL https://raw.githubusercontent.com/mis198314/node-based-visual-effects/master/scripts/install-macos.sh | bash
```

### Windows (PowerShell)
```powershell
iwr -useb https://raw.githubusercontent.com/mis198314/node-based-visual-effects/master/scripts/install.ps1 | iex
```

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/mis198314/node-based-visual-effects.git
   cd node-based-visual-effects
   ```

2. Run the application:
   ```bash
   cargo run --release
   ```

## Features
- **DAG-based Evaluation:** Correct execution order based on node dependencies.
- **Reactive Dirty Tracking:** Only re-evaluates nodes that changed.
- **Parallel Execution:** Image buffers are processed using all available CPU cores via Rayon.
- **Cycle Prevention:** Prevents invalid graph states during link creation.
