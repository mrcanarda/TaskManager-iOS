//
//  Task.swift
//  TaskManager
//
//  Created by Can Arda on 16.12.25.
//

import Foundation

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var category: String = "Personal"
    var createdAt: Date = Date()
    
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: String {
            switch self {
            case .low: return "green"
            case .medium: return "orange"
            case .high: return "red"
            }
        }
    }
}
