//
//  TimeAwareShader.swift
//  
//
//  Created by Pirita Minkkinen on 9/10/23.
//

import Foundation

protocol TimeAwareShader: MetalConfigurable {
    var time: Float { get set }
}

/*
 Current Time:

 currentTime: This could be the absolute time since the start of the application or since the shader began its operation. Depending on the context, this might be in seconds, milliseconds, or another unit.
 Delta Time:

 deltaTime: Represents the time elapsed since the last frame or since the last time the shader was executed. This is often used to create frame-rate independent animations.
 Start Time:

 startTime: The time when the shader or a specific effect started. This can be useful for effects that are based on the duration since the start.
 Duration:

 effectDuration: If your shader effect has a set duration (like a fade in/out), you might want to specify how long that effect should last.
 Periodicity:

 period: For cyclic effects like sine wave modulations, a period variable can define the cycle's length.
 Phase Shift:

 phaseShift: If you're using trigonometric functions to drive animations (like a pulsing effect), a phase shift can be used to offset the start of the cycle.
 Time Multiplier:

 timeMultiplier: A multiplier to artificially speed up or slow down the effect of time on the shader. For instance, a multiplier of 2 would make animations happen twice as fast.
 Pause/Resume:

 isPaused: A boolean to indicate if the time effects are paused. If true, the shader might ignore the passage of deltaTime or use a saved state.
 All
 */
