//! DSP Module
//!
//! Real-time audio processing components.
//!
//! Includes:
//! - Processing graph for chaining effects
//! - Biquad IIR filters (lowpass, highpass, peaking, shelf)
//! - Parametric EQ (coming soon)
//! - Compressor (coming soon)
//! - Reverb (coming soon)

pub const graph = @import("graph.zig");
pub const biquad = @import("biquad.zig");

// Re-export commonly used types
pub const DspGraph = graph.DspGraph;
pub const Processor = graph.Processor;
pub const ProcessorNode = graph.ProcessorNode;
pub const makeProcessor = graph.makeProcessor;

pub const BiquadFilter = biquad.BiquadFilter;
pub const FilterType = biquad.FilterType;
pub const Coefficients = biquad.Coefficients;

test {
    _ = graph;
    _ = biquad;
}
