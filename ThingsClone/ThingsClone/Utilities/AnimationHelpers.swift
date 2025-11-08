//
//  AnimationHelpers.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI

// MARK: - Animation Extensions

extension Animation {
    /// Things-style spring animation
    static var thingsSpring: Animation {
        .spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0)
    }

    /// Smooth ease animation
    static var thingsEase: Animation {
        .easeInOut(duration: 0.25)
    }

    /// Quick bounce
    static var thingsBounce: Animation {
        .spring(response: 0.2, dampingFraction: 0.6, blendDuration: 0)
    }
}

// MARK: - Task Completion Animation

struct TaskCompletionModifier: ViewModifier {
    let isCompleted: Bool

    func body(content: Content) -> some View {
        content
            .scaleEffect(isCompleted ? 0.95 : 1.0)
            .opacity(isCompleted ? 0.6 : 1.0)
            .animation(.thingsSpring, value: isCompleted)
    }
}

extension View {
    func taskCompletionAnimation(_ isCompleted: Bool) -> some View {
        modifier(TaskCompletionModifier(isCompleted: isCompleted))
    }
}

// MARK: - Slide In Animation

struct SlideInModifier: ViewModifier {
    let show: Bool
    let edge: Edge

    func body(content: Content) -> some View {
        content
            .offset(
                x: show ? 0 : (edge == .leading ? -50 : edge == .trailing ? 50 : 0),
                y: show ? 0 : (edge == .top ? -50 : edge == .bottom ? 50 : 0)
            )
            .opacity(show ? 1 : 0)
            .animation(.thingsEase, value: show)
    }
}

extension View {
    func slideIn(_ show: Bool, from edge: Edge = .bottom) -> some View {
        modifier(SlideInModifier(show: show, edge: edge))
    }
}

// MARK: - Haptic Feedback

enum HapticFeedback {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

// MARK: - Shake Animation

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

extension View {
    func shake(trigger: Int) -> some View {
        modifier(ShakeEffect(animatableData: CGFloat(trigger)))
    }
}
