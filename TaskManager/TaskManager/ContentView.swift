//
//  ContentView.swift
//  TaskManager
//
//  Created by Can Arda on 16.12.25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showAddTask = false
    @State private var newTaskTitle = ""
    @State private var selectedPriority: Task.Priority = .medium
    @State private var selectedCategory = "Personal"
    
    let categories = ["Personal", "Work", "Shopping", "Health", "Other"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search tasks...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Task List
                    if viewModel.filteredTasks.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.6))
                            Text("No tasks yet!")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Tap + to add your first task")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.filteredTasks) { task in
                                TaskRow(task: task, viewModel: viewModel)
                            }
                            .onDelete(perform: viewModel.deleteTask)
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Task Manager")
            .toolbar {
                Button {
                    showAddTask = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(
                    isPresented: $showAddTask,
                    taskTitle: $newTaskTitle,
                    priority: $selectedPriority,
                    category: $selectedCategory,
                    categories: categories,
                    onAdd: {
                        viewModel.addTask(
                            title: newTaskTitle,
                            priority: selectedPriority,
                            category: selectedCategory
                        )
                        newTaskTitle = ""
                        selectedPriority = .medium
                        selectedCategory = "Personal"
                    }
                )
            }
        }
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: Task
    let viewModel: TaskViewModel
    
    var body: some View {
        HStack {
            Button {
                viewModel.toggleComplete(task: task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                
                HStack {
                    Text(task.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    
                    Circle()
                        .fill(Color(task.priority.color))
                        .frame(width: 8, height: 8)
                    
                    Text(task.priority.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @Binding var isPresented: Bool
    @Binding var taskTitle: String
    @Binding var priority: Task.Priority
    @Binding var category: String
    let categories: [String]
    let onAdd: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task title", text: $taskTitle)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd()
                        isPresented = false
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
