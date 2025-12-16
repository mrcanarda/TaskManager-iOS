//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Can Arda on 16.12.25.
//

import Combine
import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var searchText = ""
    
    private let tasksKey = "SavedTasks"
    
    init() {
        loadTasks()
    }
    
    // MARK: - Filtered Tasks
    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: - Add Task
    func addTask(title: String, priority: Task.Priority, category: String) {
        let newTask = Task(title: title, priority: priority, category: category)
        tasks.append(newTask)
        saveTasks()
    }
    
    // MARK: - Toggle Complete
    func toggleComplete(task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    // MARK: - Delete Task
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    // MARK: - Save to UserDefaults
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    // MARK: - Load from UserDefaults
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
}
