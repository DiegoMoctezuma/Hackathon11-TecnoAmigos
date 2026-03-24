// QuizHistoryView.swift
// EchoStudy
// A11Y: Quiz history with trend charts

import SwiftUI
import SwiftData
import Charts

struct QuizHistoryView: View {
    @Query(sort: \QuizSession.completedAt, order: .reverse) private var sessions: [QuizSession]
    @Environment(VoiceEngine.self) private var voiceEngine
    
    private var chartData: [(date: Date, score: Int)] {
        sessions.reversed().map { session in
            let pct = session.totalQuestions > 0
                ? Int(Double(session.score) / Double(session.totalQuestions) * 100)
                : 0
            return (date: session.completedAt, score: pct)
        }
    }
    
    private var trendDescription: String {
        guard chartData.count >= 2 else {
            return "Aún no hay suficientes datos para mostrar una tendencia."
        }
        let recent = Array(chartData.suffix(5))
        let first = recent.first?.score ?? 0
        let last = recent.last?.score ?? 0
        let diff = last - first
        
        if diff > 0 {
            return "Tu rendimiento ha mejorado un \(diff)% en tus últimos \(recent.count) quizzes."
        } else if diff < 0 {
            return "Tu rendimiento ha bajado un \(abs(diff))% en tus últimos \(recent.count) quizzes. No te desanimes, sigue practicando."
        } else {
            return "Tu rendimiento se ha mantenido estable en tus últimos \(recent.count) quizzes."
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if sessions.isEmpty {
                    EmptyStateView(
                        iconName: "chart.line.uptrend.xyaxis",
                        title: "Sin historial",
                        message: "Completa tu primer quiz para ver tu progreso aquí"
                    )
                } else {
                    // MARK: - Trend Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tu progreso")
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        if chartData.count >= 2 {
                            Chart(chartData, id: \.date) { item in
                                LineMark(
                                    x: .value("Fecha", item.date),
                                    y: .value("Score", item.score)
                                )
                                .foregroundStyle(ColorTheme.accentHex)
                                .interpolationMethod(.catmullRom)
                                
                                PointMark(
                                    x: .value("Fecha", item.date),
                                    y: .value("Score", item.score)
                                )
                                .foregroundStyle(ColorTheme.accentHex)
                                .symbolSize(40)
                                
                                AreaMark(
                                    x: .value("Fecha", item.date),
                                    y: .value("Score", item.score)
                                )
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [ColorTheme.accentHex.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                            .chartYScale(domain: 0...100)
                            .chartYAxis {
                                AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                                    AxisValueLabel {
                                        if let intValue = value.as(Int.self) {
                                            Text("\(intValue)%")
                                                .font(FontTheme.caption)
                                                .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                                        }
                                    }
                                }
                            }
                            .frame(height: 200)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Gráfico de tendencia de rendimiento")
                            .accessibilityValue(trendDescription)
                        }
                        
                        // Trend description for VoiceOver
                        Text(trendDescription)
                            .font(FontTheme.body)
                            .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                    }
                    .padding(16)
                    .glassEffect(in: .rect(cornerRadius: 20))
                    .padding(.horizontal)
                    
                    // MARK: - Session List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quizzes completados")
                            .font(FontTheme.title3)
                            .foregroundStyle(ColorTheme.adaptiveText)
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(sessions) { session in
                            sessionRow(session)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(ColorTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Historial")
        .announceOnAppear("Historial de quizzes. \(sessions.count) quizzes completados.")
    }
    
    private func sessionRow(_ session: QuizSession) -> some View {
        let pct = session.totalQuestions > 0
            ? Int(Double(session.score) / Double(session.totalQuestions) * 100)
            : 0
        let color: Color = pct >= 80 ? ColorTheme.successHex :
                           pct >= 50 ? ColorTheme.warningHex : ColorTheme.errorHex
        
        return HStack(spacing: 12) {
            // Score circle
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 3)
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: Double(pct) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
                
                Text("\(pct)%")
                    .font(FontTheme.caption)
                    .foregroundStyle(color)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.subject?.name ?? "Quiz")
                    .font(FontTheme.headline)
                    .foregroundStyle(ColorTheme.adaptiveText)
                
                Text("\(session.score)/\(session.totalQuestions) correctas")
                    .font(FontTheme.subheadline)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
                
                Text(session.completedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(FontTheme.caption)
                    .foregroundStyle(ColorTheme.adaptiveTextSecondary)
            }
            
            Spacer()
        }
        .padding(14)
        .glassEffect(in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.subject?.name ?? "Quiz"). \(pct) por ciento. \(session.score) de \(session.totalQuestions) correctas. \(session.completedAt.formatted(date: .abbreviated, time: .shortened))")
    }
}
