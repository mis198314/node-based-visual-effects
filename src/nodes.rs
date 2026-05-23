use rayon::prelude::*;
use crate::engine::{DataVariant, ImageBuffer, NodeId};

pub trait CompositorNode {
    fn evaluate(&mut self, inputs: &[DataVariant]) -> Vec<DataVariant>;
}

pub struct PatternNode {
    pub resolution: u32,
}

impl CompositorNode for PatternNode {
    fn evaluate(&mut self, _inputs: &[DataVariant]) -> Vec<DataVariant> {
        let width = self.resolution;
        let height = self.resolution;
        let mut pixels = vec![0u8; (width * height * 3) as usize];

        pixels.par_chunks_mut(3).enumerate().for_each(|(i, chunk)| {
            let x = (i as u32) % width;
            let y = (i as u32) / width;
            let color = if (x / 32 + y / 32) % 2 == 0 { 255 } else { 0 };
            chunk[0] = color;
            chunk[1] = color;
            chunk[2] = color;
        });

        vec![DataVariant::Image(ImageBuffer {
            pixels,
            width,
            height,
        })]
    }
}

pub struct InvertNode;

impl CompositorNode for InvertNode {
    fn evaluate(&mut self, inputs: &[DataVariant]) -> Vec<DataVariant> {
        if let Some(DataVariant::Image(img)) = inputs.get(0) {
            let mut pixels = img.pixels.clone();
            pixels.par_chunks_mut(3).for_each(|chunk| {
                chunk[0] = 255 - chunk[0];
                chunk[1] = 255 - chunk[1];
                chunk[2] = 255 - chunk[2];
            });

            return vec![DataVariant::Image(ImageBuffer {
                pixels,
                width: img.width,
                height: img.height,
            })];
        }
        vec![]
    }
}

pub struct BrightnessContrastNode {
    pub brightness: f32,
    pub contrast: f32,
}

impl CompositorNode for BrightnessContrastNode {
    fn evaluate(&mut self, inputs: &[DataVariant]) -> Vec<DataVariant> {
        if let Some(DataVariant::Image(img)) = inputs.get(0) {
            let mut pixels = img.pixels.clone();
            
            // Use values from inputs if provided, otherwise use internal state
            let b = inputs.get(1).and_then(|v| if let DataVariant::Float(f) = v { Some(*f) } else { None }).unwrap_or(self.brightness);
            let c = inputs.get(2).and_then(|v| if let DataVariant::Float(f) = v { Some(*f) } else { None }).unwrap_or(self.contrast);

            pixels.par_chunks_mut(3).for_each(|chunk| {
                for channel in chunk.iter_mut() {
                    let mut val = *channel as f32 / 255.0;
                    val = (val - 0.5) * c + 0.5 + b;
                    *channel = (val.clamp(0.0, 1.0) * 255.0) as u8;
                }
            });

            return vec![DataVariant::Image(ImageBuffer {
                pixels,
                width: img.width,
                height: img.height,
            })];
        }
        vec![]
    }
}
