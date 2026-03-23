// TopicDetailView.swift
// EchoStudy
// A11Y: Full topic view — auto-reads summary on appear, playback controls,
// subtopics, actions bar, source materials, related topics, feedback.

import SwiftUI

struct TopicDetailView: View {
    let topic: Topic
    @Environment(AppRouter.self) private var router
    @Environment(VoiceEngine.self) private var voiceEngine
    @State private var viewModel = TopicViewModel()
    @State private var showRelatedPicker = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(topic.title)
                                .font(FontTheme.title)
                                .foregroundStyle(ColorTheme.adaptiveText)
                                .accessibilityAddTraits(.isHeader)
                            
                            Spacer()
                            
                            ConfidenceBadge(confidence: topic.confidence)
                        }
                        
                        if let subject = topic.subject {
                            Text(subject.name)
                                .font(FontTheme.subheadline)
                                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Playback Controls
                    PlaybackControls(voiceEngine: voiceEngine, text: topic.fullSummary)
                        .padding(.horizontal)
                    
                    // MARK: - Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resumen")
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(viewModel.displaySummary ?? topic.fullSummary)
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 20))
                    .padding(.horizontal)
                    
                    // MARK: - Alternate Explanation
                    if viewModel.showAlternateExplanation {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Explicación alternativa")
                                    .font(FontTheme.title3)
                                    .foregroundStyle(ColorTheme.adaptiveText)
                                    .accessibilityAddTraits(.isHeader)
                                
                                Spacer()
                                
                                Button {
                                    viewModel.showAlternateExplanation = false
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                }
                                .accessibilityLabel("Cerrar explicación alternativa")
                            }
                            
                            Text(viewModel.alternateExplanation)
                                .font(FontTheme.body)
                                .foregroundStyle(ColorTheme.adaptiveText)
                        }
                        .padding(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(ColorTheme.accentHex.opacity(0.4), lineWidth: 1)
                        )
                        .glassEffect(in: .rect(cornerRadius: 20))
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .announceOnAppear("Explicación alternativa disponible")
                    }
                    
                    // MARK: - Subtopics
                    if !topic.subtopics.isEmpty {
                        subtopicsSection
                    }
                    
                    // MARK: - Source Materials
                    if !topic.sourceMaterials.isEmpty {
                        sourceMaterialsSection
                    }
                    
                    // MARK: - Related Topics
                    if viewModel.showRelatedTopics {
                        relatedTopicsSection
                    }
                    
                    // MARK: - Feedback
                    FeedbackCollectorView(
                        predictionId: topic.id.uuidString,
                        predictionType: "summary"
                    )
                    .padding(.horizontal)
                    
                    // Bottom spacing for actions bar
                    Spacer().frame(height: 80)
                }
                .padding(.vertical)
            }
            .background(ColorTheme.backgroundGradient.ignoresSafeArea())
            
            // MARK: - Fixed Actions Bar
            TopicActionsBar(
                onAlternateExplanation: {
                    Task { await viewModel.requestAlternateExplanation(for: topic) }
                },
                onToggleLength: {
                    viewModel.toggleSummaryLength(for: topic)
                },
                onRelate: {
                    showRelatedPicker = true
                },
                onQuiz: {
                    if let subject = topic.subject {
                        router.push(.quizSession(subject, [topic]))
                    }
                },
                isShortSummary: viewModel.isShowingShortSummary
            )
        }
        .navigationTitle(topic.title)
        .sheet(isPresented: $showRelatedPicker) {
            RelatedTopicPicker(currentTopic: topic) { otherTopic in
                Task { await viewModel.requestRelation(between: topic, and: otherTopic) }
            }
        }
        .announceOnAppear("Tema: \(topic.title). \(topic.shortSummary)")
        .onAppear {
            // A11Y: Auto-read summary on appear
            voiceEngine.speak(topic.fullSummary)
        }
    }
    
    // MARK: - Subtopics Section
    
    private var subtopicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subtemas")
                .font(FontTheme.title3)
                .foregroundStyle(ColorTheme.adaptiveText)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal)
            
            ForEach(topic.subtopics.sorted(by: { $0.orderIndex < $1.orderIndex })) { subtopic in
                SubtopicCard(subtopic: subtopic)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Source Materials
    
    private var sourceMaterialsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fuentes")
                .font(FontTheme.title3)
                .foregroundStyle(ColorTheme.adaptiveText)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(topic.sourceMaterials) { material in
                        MaterialThumbnail(material: material)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Related Topics
    
    private var relatedTopicsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Relación entre temas")
                .font(FontTheme.title3)
                .foregroundStyle(ColorTheme.adaptiveText)
                .accessibilityAddTraits(.isHeader)
            
            Text(viewModel.relationExplanation)
                .font(FontTheme.body)
                .foregroundStyle(ColorTheme.adaptiveText)
        }
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(ColorTheme.secondaryHex.opacity(0.4), lineWidth: 1)
        )
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding(.horizontal)
        .announceOnAppear("Relación entre temas disponible")
    }
}

// MARK: - Topic Actions Bar

struct TopicActionsBar: View {
    let onAlternateExplanation: () -> Void
    let onToggleLength: () -> Void
    let onRelate: () -> Void
    let onQuiz: () -> Void
    let isShortSummary: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                actionButton(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Diferente",
                    action: onAlternateExplanation
                )
                
                actionButton(
                    icon: isShortSummary ? "text.badge.plus" : "text.badge.minus",
                    title: isShortSummary ? "Más largo" : "Más corto",
                    action: onToggleLength
                )
                
                actionButton(
                    icon: "link",
                    title: "Relacionar",
                    action: onRelate
                )
                
                actionButton(
                    icon: "questionmark.bubble",
                    title: "Quiz",
                    action: onQuiz
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .glassEffect(in: .rect(cornerRadius: 20))
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Acciones del tema")
    }
    
    private func actionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticService.shared.light()
            action()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(FontTheme.caption)
            }
            .foregroundStyle(ColorTheme.accentHex)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minWidth: 70, minHeight: 48)
            .glassEffect(in: .rect(cornerRadius: 14))
        }
        .accessibilityLabel(title)
        .accessibilityHint("Toca para \(title.lowercased()) este tema")
    }
}

// MARK: - Subtopic Card

struct SubtopicCard: View {
    let subtopic: Subtopic
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — always visible
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
                HapticService.shared.light()
            } label: {
                HStack {
                    Text(subtopic.title)
                        .font(FontTheme.headline)
                        .foregroundStyle(ColorTheme.adaptiveText)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(FontTheme.caption)
                        .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                }
                .padding(14)
            }
            .accessibilityLabel("Subtema: \(subtopic.title)")
            .accessibilityHint(isExpanded ? "Toca para colapsar" : "Toca para expandir")
            .accessibilityAddTraits(.isButton)
            
            // Content — expandable
            if isExpanded {
                Divider()
                    .padding(.horizontal, 14)
                
                Text(subtopic.content)
                    .font(FontTheme.body)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .lineSpacing(3)
                    .padding(14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .glassEffect(in: .rect(cornerRadius: 16))
    }
}

// MARK: - Related Topic Picker

struct RelatedTopicPicker: View {
    let currentTopic: Topic
    let onSelect: (Topic) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private var availableTopics: [Topic] {
        currentTopic.subject?.topics.filter { $0.id != currentTopic.id } ?? []
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if availableTopics.isEmpty {
                    EmptyStateView(
                        iconName: "link",
                        title: "Sin otros temas",
                        message: "Necesitas al menos dos temas en esta materia para relacionarlos"
                    )
                } else {
                    List(availableTopics) { topic in
                        Button {
                            onSelect(topic)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(topic.title)
                                    .font(FontTheme.headline)
                                    .foregroundStyle(ColorTheme.adaptiveText)
                                Text(topic.shortSummary)
                                    .font(FontTheme.subheadline)
                                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                    .lineLimit(2)
                            }
                        }
                        .accessibilityLabel("Relacionar con: \(topic.title)")
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Relacionar con...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .announceOnAppear("Selecciona un tema para relacionar con \(currentTopic.title)")
    }
}
