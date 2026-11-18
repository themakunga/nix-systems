import Foundation

struct Fixture: ReadableElement {
    var isProtected = false
    var selectedText: String?
    var text: String?
    var children: [Fixture] = []
    var isWindowContainer = false
}

@main struct Tests {
    static func main() {
        assert(readingText(focused: Fixture(selectedText: " selected ")) { fatalError("Selection must win") } == "selected")
        assert(readingText(focused: Fixture(selectedText: " \n")) { Fixture(text: "block") } == "block")
        assert(readingText(focused: nil) { Fixture(children: [Fixture(text: "one"), Fixture(text: "two")]) } == "one\ntwo")
        assert(readingText(focused: nil) { Fixture(text: "parent", children: [Fixture(text: "duplicate")]) } == "parent")
        assert(readingText(focused: Fixture(isProtected: true, selectedText: "secret")) { fatalError("Protected focus must stop") } == nil)
        assert(readingText(focused: nil) { Fixture(isProtected: true, text: "secret") } == nil)
        assert(readingText(focused: nil) { Fixture(children: [Fixture(isProtected: true, text: "secret"), Fixture(text: "public")]) } == "public")
        assert(readingText(focused: nil) { Optional<Fixture>.none } == nil)
        assert(readingText(focused: nil) { Fixture(children: [Fixture(text: "whole window")], isWindowContainer: true) } == nil)
        var deep = Fixture(text: "outside depth limit")
        for _ in 0..<20 { deep = Fixture(children: [deep]) }
        assert(readingText(focused: nil) { deep } == nil)
        print("Point Reader extraction checks passed")
    }
}
