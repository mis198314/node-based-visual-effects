use slotmap::{SlotMap, new_key_type};
use std::collections::{HashSet, VecDeque};

new_key_type! {
    pub struct NodeId;
    pub struct LinkId;
}

#[derive(Clone, Debug)]
pub struct ImageBuffer {
    pub pixels: Vec<u8>,
    pub width: u32,
    pub height: u32,
}

#[derive(Clone, Debug)]
pub enum DataVariant {
    Float(f32),
    Image(ImageBuffer),
}

pub struct Pin {
    pub name: String,
}

pub struct Node {
    pub name: String,
    pub inputs: Vec<Pin>,
    pub outputs: Vec<Pin>,
    pub is_dirty: bool,
    pub cached_value: Vec<DataVariant>, // Values for output pins
}

pub struct Link {
    pub from_node: NodeId,
    pub from_pin: usize,
    pub to_node: NodeId,
    pub to_pin: usize,
}

pub struct GraphEngine {
    pub nodes: SlotMap<NodeId, Node>,
    pub links: SlotMap<LinkId, Link>,
}

impl GraphEngine {
    pub fn new() -> Self {
        Self {
            nodes: SlotMap::with_key(),
            links: SlotMap::with_key(),
        }
    }

    pub fn add_node(&mut self, name: &str, inputs: Vec<Pin>, outputs: Vec<Pin>) -> NodeId {
        let id = self.nodes.insert(Node {
            name: name.to_string(),
            inputs,
            outputs,
            is_dirty: true,
            cached_value: Vec::new(),
        });
        id
    }

    pub fn add_link(&mut self, from: NodeId, from_pin: usize, to: NodeId, to_pin: usize) -> Result<LinkId, String> {
        if self.detect_cycle(from, to) {
            return Err("Cycle detected: Links cannot form a loop.".to_string());
        }

        let link = Link {
            from_node: from,
            from_pin,
            to_node: to,
            to_pin,
        };
        
        let id = self.links.insert(link);
        self.mark_dirty(to);
        Ok(id)
    }

    fn detect_cycle(&self, start: NodeId, end: NodeId) -> bool {
        if start == end { return true; }
        
        let mut visited = HashSet::new();
        let mut stack = VecDeque::new();
        stack.push_back(end);

        while let Some(node_id) = stack.pop_front() {
            if node_id == start { return true; }
            if visited.insert(node_id) {
                for link in self.links.values() {
                    if link.from_node == node_id {
                        stack.push_back(link.to_node);
                    }
                }
            }
        }
        false
    }

    pub fn mark_dirty(&mut self, node_id: NodeId) {
        if let Some(node) = self.nodes.get_mut(node_id) {
            node.is_dirty = true;
        }
        
        let downstream: Vec<NodeId> = self.links.values()
            .filter(|l| l.from_node == node_id)
            .map(|l| l.to_node)
            .collect();

        for next in downstream {
            self.mark_dirty(next);
        }
    }

    pub fn get_evaluation_order(&self) -> Vec<NodeId> {
        let mut order = Vec::new();
        let mut visited = HashSet::new();
        let all_nodes: Vec<NodeId> = self.nodes.keys().collect();

        for node_id in all_nodes {
            self.dfs_visit(node_id, &mut visited, &mut order);
        }
        order
    }

    fn dfs_visit(&self, node_id: NodeId, visited: &mut HashSet<NodeId>, order: &mut Vec<NodeId>) {
        if visited.contains(&node_id) { return; }
        
        let upstream: Vec<NodeId> = self.links.values()
            .filter(|l| l.to_node == node_id)
            .map(|l| l.from_node)
            .collect();

        for up in upstream {
            self.dfs_visit(up, visited, order);
        }

        visited.insert(node_id);
        order.push(node_id);
    }
}
