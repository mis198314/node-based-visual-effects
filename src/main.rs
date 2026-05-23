mod engine;
mod nodes;
mod ui;

use eframe::egui;
use crate::ui::CanvasUI;

struct VFXApp {
    canvas: CanvasUI,
}

impl VFXApp {
    fn new(_cc: &eframe::CreationContext<'_>) -> Self {
        Self {
            canvas: CanvasUI::new(),
        }
    }
}

impl eframe::App for VFXApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::SidePanel::right("viewport").show(ctx, |ui| {
            ui.heading("Live Viewport");
            ui.label("Final Composite output will appear here.");
            // TextureHandle rendering logic would be integrated here
        });

        egui::CentralPanel::default().show(ctx, |ui| {
            self.canvas.draw(ui);
        });
    }
}

fn main() -> eframe::Result<()> {
    let native_options = eframe::NativeOptions::default();
    eframe::run_native(
        "Node-Based VFX Compositor",
        native_options,
        Box::new(|cc| Box::new(VFXApp::new(cc))),
    )
}
