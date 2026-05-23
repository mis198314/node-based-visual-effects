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

## Prerequisites
- Rust toolchain (stable)
- C++ build tools (required for `eframe` dependencies on some platforms)

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/node-based-vfx.git
   cd node-based-vfx
   ```

2. Run the application:
   ```bash
   cargo run --release
   ```

## Features
- **DAG-based Evaluation:** Correct execution order based on node dependencies.
- **Reactive Dirty Tracking:** Only re-evaluates nodes that have changed.
- **Parallel Execution:** Image buffers are processed using all available CPU cores via Rayon.
- **Cycle Prevention:** Prevents invalid graph states during link creation.
