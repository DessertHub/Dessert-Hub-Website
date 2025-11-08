//
//  TagsView.swift
//  ThingsClone
//
//  Created by Claude
//

import SwiftUI
import CoreData

struct TagsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.sortOrder, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>

    @State private var showingAddTag = false
    @State private var editingTag: Tag?

    var body: some View {
        List {
            if tags.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "tag")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("No Tags")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Tags help organize your to-dos")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .listRowBackground(Color.clear)
                }
            } else {
                ForEach(tags) { tag in
                    TagRow(tag: tag)
                        .onTapGesture {
                            editingTag = tag
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteTag(tag)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .onMove { indices, newOffset in
                    // Reorder tags
                    var tagsArray = Array(tags)
                    tagsArray.move(fromOffsets: indices, toOffset: newOffset)
                    for (index, tag) in tagsArray.enumerated() {
                        tag.sortOrder = Int32(index)
                    }
                    try? viewContext.save()
                }
            }
        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddTag = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddTag) {
            AddTagSheet()
        }
        .sheet(item: $editingTag) { tag in
            EditTagSheet(tag: tag)
        }
    }

    private func deleteTag(_ tag: Tag) {
        viewContext.delete(tag)
        try? viewContext.save()
    }
}

struct TagRow: View {
    @ObservedObject var tag: Tag

    private var taskCount: Int {
        (tag.tasks as? Set<TaskItem>)?.filter { !$0.isCompleted }.count ?? 0
    }

    var body: some View {
        HStack(spacing: 16) {
            if let colorHex = tag.colorHex {
                Circle()
                    .fill(Color(hex: colorHex) ?? .gray)
                    .frame(width: 24, height: 24)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tag.title ?? "")
                    .font(.system(size: 16, weight: .medium))

                if taskCount > 0 {
                    Text("\(taskCount) to-dos")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if taskCount > 0 {
                Text("\(taskCount)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(minWidth: 24, minHeight: 24)
                    .background(Color(hex: tag.colorHex ?? "#999999") ?? .gray)
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddTagSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var title = ""
    @State private var selectedColor = TagColor.blue

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Tag Name", text: $title)
                        .font(.headline)
                }

                Section {
                    ColorPickerGrid(selectedColor: $selectedColor)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTag()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func addTag() {
        let newTag = Tag(context: viewContext)
        newTag.id = UUID()
        newTag.title = title
        newTag.colorHex = selectedColor.hex
        newTag.sortOrder = 0

        try? viewContext.save()
        dismiss()
    }
}

struct EditTagSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var tag: Tag

    @State private var title: String
    @State private var selectedColor: TagColor

    init(tag: Tag) {
        self.tag = tag
        _title = State(initialValue: tag.title ?? "")
        _selectedColor = State(initialValue: TagColor.from(hex: tag.colorHex ?? "#3478F6"))
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Tag Name", text: $title)
                        .font(.headline)
                }

                Section {
                    ColorPickerGrid(selectedColor: $selectedColor)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle("Edit Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTag()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveTag() {
        tag.title = title
        tag.colorHex = selectedColor.hex
        try? viewContext.save()
        dismiss()
    }
}

struct ColorPickerGrid: View {
    @Binding var selectedColor: TagColor

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(TagColor.allColors) { color in
                ColorCircle(color: color, isSelected: selectedColor == color)
                    .onTapGesture {
                        selectedColor = color
                    }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ColorCircle: View {
    let color: TagColor
    let isSelected: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: color.hex) ?? .gray)
                .frame(width: 40, height: 40)

            if isSelected {
                Circle()
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(width: 48, height: 48)

                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
}

enum TagColor: String, Identifiable, CaseIterable, Equatable {
    case red = "#FF3B30"
    case orange = "#FF9500"
    case yellow = "#FFCC00"
    case green = "#34C759"
    case teal = "#5AC8FA"
    case blue = "#3478F6"
    case indigo = "#5856D6"
    case purple = "#AF52DE"
    case pink = "#FF2D55"
    case brown = "#A2845E"
    case gray = "#8E8E93"
    case black = "#1C1C1E"

    var id: String { rawValue }
    var hex: String { rawValue }

    static var allColors: [TagColor] {
        return allCases
    }

    static func from(hex: String) -> TagColor {
        return allCases.first { $0.hex.uppercased() == hex.uppercased() } ?? .blue
    }
}

#Preview {
    NavigationView {
        TagsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
