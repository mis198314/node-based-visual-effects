mod engine;
mod nodes;
mod ui;

use eframe::egui;
use crate::ui::CanvasUI;
use crate::engine::Pin;

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
        egui::SidePanel::left("library")
            .resizable(true)
            .default_width(200.0)
            .show(ctx, |ui| {
                ui.heading("Node Library");
                ui.separator();

                if ui.button("Add Pattern Node").clicked() {
                    self.canvas.engine.add_node("Pattern", vec![], vec![Pin { name: "Output".into() }]);
                }
                if ui.button("Add Invert Node").clicked() {
                    self.canvas.engine.add_node("Invert", vec![Pin { name: "Input".into() }], vec![Pin { name: "Output".into() }]);
                }
                if ui.button("Add Brightness Node").clicked() {
                    self.canvas.engine.add_node("Brightness", vec![
                        Pin { name: "Input".into() },
                        Pin { name: "Brightness".into() },
                        Pin { name: "Contrast".into() },
                    ], vec![Pin { name: "Output".into() }]);
                }
            });

        egui::SidePanel::right("viewport")
            .resizable(true)
            .default_width(300.0)
            .show(ctx, |ui| {
                ui.heading("Live Viewport");
                ui.separator();
                ui.label("Final Composite output will appear here.");
                
                if let Some(node_id) = self.canvas.selected_node {
                    ui.separator();
                    ui.heading("Node Properties");
                    ui.label(format!("Node ID: {:?}", node_id));
                    
                    ui.add(egui::Slider::new(&mut 0.5f32, 0.0..=1.0).text("Value 1"));
                    ui.add(egui::Slider::new(&mut 0.5f32, 0.0..=1.0).text("Value 2"));
                }
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
