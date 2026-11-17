import Foundation

protocol ReadableElement {
    var isProtected: Bool { get }
    var selectedText: String? { get }
    var text: String? { get }
    var children: [Self] { get }
    var isWindowContainer: Bool { get }
}

func nonempty(_ value: String?) -> String? {
    guard let text = value?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
    return text
}

func readingText<E: ReadableElement>(focused: E?, pointed: () -> E?) -> String? {
    if let focused = focused {
        if focused.isProtected { return nil }
        if let selection = nonempty(focused.selectedText) { return selection }
    }
    guard let element = pointed() else { return nil }
    var remaining = 128
    func collect(_ node: E, depth: Int) -> [String] {
        // shortcut: bound AX traversal to one block; revisit for unusually large accessible groups.
        guard remaining > 0, depth < 16 else { return [] }
        remaining -= 1
        guard !node.isProtected, !node.isWindowContainer else { return [] }
        if let text = nonempty(node.text) { return [text] }
        return node.children.flatMap { collect($0, depth: depth + 1) }
    }
    return nonempty(collect(element, depth: 0).joined(separator: "\n"))
}
