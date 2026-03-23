// SubjectDetailView.swift
// EchoStudy
// A11Y: Subject detail with topic list, search, sort, voice assistant, upload.
// Swipe to delete topics. Drag handle for reorder.

import SwiftUI
import SwiftData

struct SubjectDetailView: View {
    let subject: Subject
    @Environment(AppRouter.self) private var router
    @Environment(VoiceEngine.self) private var voiceEngine
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SubjectViewModel()
    @State private var showVoiceAssistant = false
    @State private var showConversations = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Header
                subjectHeader
                
                // MARK: - Search
                AccessibleSearchBar(text: $viewModel.searchText, placeholder: "Buscar temas...")
                    .padding(.horizontal)
                
                // MARK: - Action Buttons
                actionRow
                
                // MARK: - Sort Options
                sortPicker
                
                // MARK: - Topic List
                topicsList
            }
            .padding(.vertical)
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle(subject.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        router.push(.uploadMaterialToSubject(subject))
                    } label: {
                        Label("Subir material", systemImage: "arrow.up.doc")
                    }
                    
                    Button {
                        showConversations = true
                    } label: {
                        Label("Conversaciones", systemImage: "bubble.left.and.bubble.right")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel("Más opciones para \(subject.name)")
            }
        }
        .sheet(isPresented: $showVoiceAssistant) {
            VoiceAssistantView(contextSubject: subject)
                .environment(voiceEngine)
        }
        .sheet(isPresented: $showConversations) {
            SubjectConversationsView(subject: subject)
        }
        .announceOnAppear("Materia \(subject.name). \(subject.topics.count) temas disponibles.")
    }
    
    // MARK: - Subject Header
    
    private var subjectHeader: some View {
        HStack(spacing: 12) {
            SubjectIcon(iconName: subject.iconName, colorHex: subject.colorHex, size: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(FontTheme.title2)
                    .foregroundStyle(ColorTheme.adaptiveText)
                    .accessibilityAddTraits(.isHeader)
                
                Text("\(subject.topics.count) temas · \(subject.conversations.count) conversaciones")
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Action Row
    
    private var actionRow: some View {
        HStack(spacing: 12) {
            // Converse button
            Button {
                HapticService.shared.medium()
                showVoiceAssistant = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "mic.fill")
                        .font(FontTheme.subheadline)
                    Text("Conversar")
                        .font(FontTheme.subheadline)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(minHeight: 48)
                .background(ColorTheme.primaryHex)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .accessibilityLabel("Conversar sobre \(subject.name)")
            .accessibilityHint("Abre el asistente de voz con contexto de esta materia")
            
            // Upload more button
            Button {
                HapticService.shared.light()
                router.push(.uploadMaterialToSubject(subject))
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(FontTheme.subheadline)
                    Text("Subir material")
                        .font(FontTheme.subheadline)
                }
                .foregroundStyle(ColorTheme.accentHex)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(minHeight: 48)
            }
            .glassEffect(in: .rect(cornerRadius: 14))
            .accessibilityLabel("Subir más material a \(subject.name)")
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Sort Picker
    
    private var sortPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SubjectViewModel.SortOption.allCases, id: \.self) { option in
                    Button {
                        HapticService.shared.selection()
                        viewModel.selectedSortOption = option
                    } label: {
                        Text(option.rawValue)
                            .font(FontTheme.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundStyle(
                                viewModel.selectedSortOption == option
                                    ? .white : ColorTheme.adaptiveText
                            )
                            .background(
                                viewModel.selectedSortOption == option
                                    ? ColorTheme.accentHex : Color.clear
                            )
                            .clipShape(Capsule())
                    }
                    .glassEffect(in: .capsule)
                    .accessibilityLabel("Ordenar por \(option.rawValue)")
                    .accessibilityAddTraits(viewModel.selectedSortOption == option ? .isSelected : [])
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Topics List
    
    private var topicsList: some View {
        VStack(spacing: 8) {
            let sorted = viewModel.sortedTopics(subject.topics)
            
            if sorted.isEmpty {
                EmptyStateView(
                    iconName: "doc.text.magnifyingglass",
                    title: "Sin temas todavía",
                    message: "Sube material de estudio para que la IA detecte temas automáticamente",
                    actionTitle: "Subir material",
                    action: { router.push(.uploadMaterialToSubject(subject)) }
                )
            } else {
                ForEach(sorted) { topic in
                    TopicRow(
                        title: topic.title,
                        summary: topic.shortSummary,
                        confidence: topic.confidence,
                        isVerified: topic.isUserVerified
                    )
                    .onTapGesture {
                        HapticService.shared.light()
                        router.push(.topicDetail(topic))
                    }
                    .accessibilityAddTraits(.isButton)
                    // Swipe to delete
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteTopic(topic, from: subject, context: modelContext)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
