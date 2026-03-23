// SubjectConversationsView.swift
// EchoStudy
// A11Y: List of past conversations for a subject

import SwiftUI

struct SubjectConversationsView: View {
    let subject: Subject
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(\.dismiss) private var dismiss
    @State private var showVoiceAssistant = false
    @State private var selectedConversation: Conversation?
    
    var body: some View {
        NavigationStack {
            Group {
                if subject.conversations.isEmpty {
                    EmptyStateView(
                        iconName: "bubble.left.and.bubble.right",
                        title: "Sin conversaciones",
                        message: "Inicia una conversación con el asistente para que aparezca aquí",
                        actionTitle: "Iniciar conversación",
                        action: { showVoiceAssistant = true }
                    )
                } else {
                    List(subject.conversations.sorted(by: { $0.updatedAt > $1.updatedAt })) { conversation in
                        Button {
                            selectedConversation = conversation
                            showVoiceAssistant = true
                        } label: {
                            conversationRow(conversation)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Conversaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                        .accessibilityLabel("Cerrar conversaciones")
                }
            }
            .sheet(isPresented: $showVoiceAssistant) {
                VoiceAssistantView(contextSubject: subject)
                    .environment(voiceEngine)
            }
        }
        .announceOnAppear("Conversaciones de \(subject.name). \(subject.conversations.count) conversaciones.")
    }
    
    // MARK: - Conversation Row
    
    private func conversationRow(_ conversation: Conversation) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(conversation.title)
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .lineLimit(1)
                
                Spacer()
                
                Text(conversation.updatedAt.accessibleRelativeString)
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
            
            if let firstMessage = conversation.messages.first {
                Text(firstMessage.content)
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    .lineLimit(2)
            }
            
            Text("\(conversation.messages.count) mensajes")
                .font(FontTheme.caption)
                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
        }
        .padding(.vertical, 4)
        // A11Y: Describe conversation for VoiceOver
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Conversación: \(conversation.title). \(conversation.updatedAt.accessibleRelativeString). \(conversation.messages.count) mensajes.")
        .accessibilityHint("Toca para continuar esta conversación")
        .accessibilityAddTraits(.isButton)
    }
}
