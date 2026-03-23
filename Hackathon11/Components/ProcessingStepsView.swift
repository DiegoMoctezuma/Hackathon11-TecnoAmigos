// ProcessingStepsView.swift
// EchoStudy
// A11Y: Step-by-step processing progress with VoiceOver announcements

import SwiftUI

struct ProcessingStepItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    var state: StepState
    
    enum StepState {
        case pending, active, complete, error
    }
}

struct ProcessingStepsView: View {
    let steps: [ProcessingStepItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Procesando material")
                .font(FontTheme.title3)
                .foregroundStyle(ColorTheme.adaptiveText)
                .accessibilityAddTraits(.isHeader)
            
            ForEach(steps) { step in
                HStack(spacing: 12) {
                    // State icon
                    Group {
                        switch step.state {
                        case .pending:
                            Image(systemName: "circle")
                                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        case .active:
                            ProgressView()
                                .controlSize(.small)
                                .tint(ColorTheme.accentHex)
                        case .complete:
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(ColorTheme.successHex)
                                .symbolEffect(.bounce)
                        case .error:
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(ColorTheme.errorHex)
                        }
                    }
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true) // A11Y: Combined with text
                    
                    Text(step.title)
                        .font(step.state == .active ? FontTheme.headline : FontTheme.body)
                        .foregroundStyle(
                            step.state == .pending ?
                                ColorTheme.adaptiveTextSecondary :
                                ColorTheme.adaptiveText
                        )
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(step.title), \(stateLabel(step.state))")
            }
        }
        .padding(16)
        .glassEffect(in: .rect(cornerRadius: 20))
    }
    
    private func stateLabel(_ state: ProcessingStepItem.StepState) -> String {
        switch state {
        case .pending: return "pendiente"
        case .active: return "en progreso"
        case .complete: return "completado"
        case .error: return "error"
        }
    }
}
