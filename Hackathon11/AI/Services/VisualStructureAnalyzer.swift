// VisualStructureAnalyzer.swift
// EchoStudy
// Deep spatial analysis of text block relationships for hierarchy detection
// REQUIRES: OCRService.swift

import Foundation
import UIKit

// MARK: - Hierarchy Node

struct TextHierarchyNode: Identifiable {
    let id = UUID()
    var text: String
    var level: Int // 0 = root, 1 = child, 2 = grandchild
    var bounds: CGRect
    var children: [TextHierarchyNode]
    
    var accessibleDescription: String {
        let indent = String(repeating: "  ", count: level)
        var desc = "\(indent)\(text)"
        for child in children {
            desc += "\n\(child.accessibleDescription)"
        }
        return desc
    }
}

// MARK: - Analyzer

actor VisualStructureAnalyzer {
    static let shared = VisualStructureAnalyzer()
    
    private init() {}
    
    /// Analyzes spatial relationships between text blocks to build a hierarchy tree
    func analyzeHierarchy(from image: UIImage) async throws -> [TextHierarchyNode] {
        let textPositions = try await OCRService.shared.extractTextWithPositions(from: image)
        
        guard !textPositions.isEmpty else { return [] }
        
        // Sort by Y position (top to bottom, remembering Vision flips Y)
        let sorted = textPositions.sorted { $0.bounds.midY > $1.bounds.midY }
        
        // Estimate text size from bounding box height
        let avgHeight = sorted.map(\.bounds.height).reduce(0, +) / Double(sorted.count)
        
        // Classify into levels based on text block height (larger = title)
        var nodes: [(text: String, bounds: CGRect, level: Int)] = []
        for item in sorted {
            let level: Int
            if item.bounds.height > avgHeight * 1.5 {
                level = 0 // Title/heading
            } else if item.bounds.height > avgHeight * 1.1 {
                level = 1 // Subheading
            } else {
                level = 2 // Body text
            }
            nodes.append((text: item.text, bounds: item.bounds, level: level))
        }
        
        // Build hierarchy tree
        return buildTree(from: nodes)
    }
    
    /// Detects relationships based on spatial proximity
    func detectRelationships(from image: UIImage) async throws -> [(from: String, to: String, type: String)] {
        let textPositions = try await OCRService.shared.extractTextWithPositions(from: image)
        
        var relationships: [(from: String, to: String, type: String)] = []
        
        for i in 0..<textPositions.count {
            for j in (i + 1)..<textPositions.count {
                let a = textPositions[i]
                let b = textPositions[j]
                
                let distance = hypot(a.bounds.midX - b.bounds.midX, a.bounds.midY - b.bounds.midY)
                
                // Close proximity = related
                if distance < 0.15 {
                    let type = abs(a.bounds.midY - b.bounds.midY) > abs(a.bounds.midX - b.bounds.midX) ? "vertical" : "horizontal"
                    relationships.append((from: a.text, to: b.text, type: type))
                }
            }
        }
        
        return relationships
    }
    
    // MARK: - Private
    
    private func buildTree(from nodes: [(text: String, bounds: CGRect, level: Int)]) -> [TextHierarchyNode] {
        var roots: [TextHierarchyNode] = []
        var currentRoot: TextHierarchyNode?
        var currentChildren: [TextHierarchyNode] = []
        
        for node in nodes {
            if node.level == 0 {
                // Save previous root with its children
                if var root = currentRoot {
                    root.children = currentChildren
                    roots.append(root)
                }
                currentRoot = TextHierarchyNode(text: node.text, level: 0, bounds: node.bounds, children: [])
                currentChildren = []
            } else {
                let child = TextHierarchyNode(text: node.text, level: node.level, bounds: node.bounds, children: [])
                currentChildren.append(child)
            }
        }
        
        // Don't forget the last root
        if var root = currentRoot {
            root.children = currentChildren
            roots.append(root)
        }
        
        // If no titles detected, make everything flat
        if roots.isEmpty {
            return nodes.map { TextHierarchyNode(text: $0.text, level: 0, bounds: $0.bounds, children: []) }
        }
        
        return roots
    }
}
