use eframe::egui;
use egui::{Color32, Pos2, Rect, Stroke, Vec2};
use crate::engine::{GraphEngine, NodeId};

pub struct CanvasUI {
    pub engine: GraphEngine,
    pub node_positions: std::collections::HashMap<NodeId, Pos2>,
    pub active_link_start: Option<(NodeId, usize)>,
    pub selected_node: Option<NodeId>,
}

impl CanvasUI {
    pub fn new() -> Self {
        Self {
            engine: GraphEngine::new(),
            node_positions: std::collections::HashMap::new(),
            active_link_start: None,
            selected_node: None,
        }
    }

    pub fn draw(&mut self, ui: &mut egui::Ui) {
        // 1. Perform mutable layout operations first
        let rect = ui.available_rect_before_wrap();
        let response = ui.allocate_rect(rect, egui::Sense::click_and_drag());
        let mouse_pos = response.interact_pointer_pos().unwrap_or(Pos2::ZERO);
        
        // 2. Now get the painter for drawing
        let painter = ui.painter();

        // Draw Links
        for link in self.engine.links.values() {
            let start_pos = self.get_pin_pos(link.from_node, link.from_pin, false);
            let end_pos = self.get_pin_pos(link.to_node, link.to_pin, true);
            painter.line_segment([start_pos, end_pos], Stroke::new(2.0, Color32::GRAY));
        }

        // Draw Nodes
        let node_ids: Vec<NodeId> = self.engine.nodes.keys().collect();
        for id in node_ids {
            let node = &self.engine.nodes[id];
            let pos = self.node_positions.entry(id).or_insert(Pos2::new(100.0, 100.0));
            
            let node_rect = Rect::from_min_size(Pos2::new(pos.x, pos.y), Vec2::new(120.0, 80.0));
            
            let is_selected = self.selected_node == Some(id);
            let bg_color = if is_selected { Color32::from_rgb(60, 60, 80) } else { Color32::from_rgb(45, 45, 45) };
            
            painter.rect_filled(node_rect, 4.0, bg_color);
            painter.text(node_rect.center_top() + Vec2::new(0.0, 10.0), egui::Align2::CENTER_CENTER, &node.name, egui::FontId::proportional(14.0), Color32::WHITE);

            // Input Pins
            for (i, _pin) in node.inputs.iter().enumerate() {
                let pin_pos = self.get_pin_pos(id, i, true);
                painter.circle_filled(pin_pos, 4.0, Color32::LIGHT_BLUE);
                
                if response.clicked() && (mouse_pos - pin_pos).length() < 10.0 {
                    // Interaction logic: handled via state update or command queue
                }
            }

            // Output Pins
            for (i, _pin) in node.outputs.iter().enumerate() {
                let pin_pos = self.get_pin_pos(id, i, false);
                painter.circle_filled(pin_pos, 4.0, Color32::LIGHT_GREEN);
                
                if response.clicked() && (mouse_pos - pin_pos).length() < 10.0 {
                    self.active_link_start = Some((id, i));
                }
            }
            
            if response.clicked() && node_rect.contains(mouse_pos) {
                self.selected_node = Some(id);
            }
        }

        // Draw active wiring line
        if let Some((start_node, pin_idx)) = self.active_link_start {
            let start_pos = self.get_pin_pos(start_node, pin_idx, false);
            painter.line_segment([start_pos, mouse_pos], Stroke::new(2.0, Color32::YELLOW));
        }
    }

    fn get_pin_pos(&self, node_id: NodeId, pin_idx: usize, is_input: bool) -> Pos2 {
        let pos = self.node_positions.get(&node_id).cloned().unwrap_or(Pos2::ZERO);
        if is_input {
            Pos2::new(pos.x, pos.y + 30.0 + (pin_idx as f32 * 20.0))
        } else {
            Pos2::new(pos.x + 120.0, pos.y + 30.0 + (pin_idx as f32 * 20.0))
        }
    }
}
