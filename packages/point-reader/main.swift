import AppKit
import ApplicationServices
import AVFoundation
import Carbon

func attribute(_ element: AXUIElement, _ key: String) -> CFTypeRef? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, key as CFString, &value) == .success else { return nil }
    return value
}

func axElement(_ value: CFTypeRef?) -> AXUIElement? {
    guard let value = value, CFGetTypeID(value) == AXUIElementGetTypeID() else { return nil }
    return (value as! AXUIElement)
}

struct Element: ReadableElement {
    let raw: AXUIElement

    var isWindowContainer: Bool {
        let role = attribute(raw, kAXRoleAttribute) as? String
        return role == kAXWindowRole || role == kAXApplicationRole
    }

    var isProtected: Bool {
        var current: AXUIElement? = raw
        for _ in 0..<32 {
            guard let node = current else { break }
            if attribute(node, kAXSubroleAttribute) as? String == kAXSecureTextFieldSubrole { return true }
            if attribute(node, kAXRoleAttribute) as? String == kAXWindowRole { break }
            current = axElement(attribute(node, kAXParentAttribute))
        }
        return false
    }

    var selectedText: String? { attribute(raw, kAXSelectedTextAttribute) as? String }
    var text: String? {
        for key in [kAXValueAttribute, kAXTitleAttribute, kAXDescriptionAttribute] {
            if let value = nonempty(attribute(raw, key) as? String) { return value }
        }
        return nil
    }
    var children: [Element] {
        (attribute(raw, kAXChildrenAttribute) as? [AXUIElement] ?? []).map { Element(raw: $0) }
    }
}

final class ReaderApp: NSObject, NSApplicationDelegate {
    let speech = AVSpeechSynthesizer()
    var status: NSStatusItem!
    var hotKey: EventHotKeyRef?
    var handler: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        status = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        status.button?.title = "Read"
        status.button?.setAccessibilityLabel("Point Reader")
        let menu = NSMenu()
        for (title, action) in [("Stop Reading", #selector(stop)),
                                ("Accessibility Settings", #selector(settings)),
                                ("Quit", #selector(quit))] {
            let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
            item.target = self
            menu.addItem(item)
        }
        status.menu = menu

        var event = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let installed = InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
            guard let context = context else { return OSStatus(eventNotHandledErr) }
            Unmanaged<ReaderApp>.fromOpaque(context).takeUnretainedValue().read()
            return noErr
        }, 1, &event, Unmanaged.passUnretained(self).toOpaque(), &handler)
        let registered = installed == noErr ? RegisterEventHotKey(UInt32(kVK_Space), UInt32(cmdKey | shiftKey),
            EventHotKeyID(signature: 0x50524452, id: 1), GetApplicationEventTarget(), 0, &hotKey) : installed
        if registered != noErr {
            let alert = NSAlert()
            alert.messageText = "Point Reader could not register Shift + Command + Space."
            alert.informativeText = "Check other keyboard shortcuts, then restart Point Reader."
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
    }

    func read() {
        if speech.isSpeaking { stop(); return }
        guard AXIsProcessTrusted() else { settings(); return }
        let system = AXUIElementCreateSystemWide()
        AXUIElementSetMessagingTimeout(system, 0.1)
        let focused = axElement(attribute(system, kAXFocusedUIElementAttribute)).map { Element(raw: $0) }
        let text = readingText(focused: focused) {
            // CGEvent and AX both use global top-left coordinates, including secondary displays.
            guard let point = CGEvent(source: nil)?.location else { return nil }
            var hit: AXUIElement?
            guard AXUIElementCopyElementAtPosition(system, Float(point.x), Float(point.y), &hit) == .success,
                  let hit = hit else { return nil }
            return Element(raw: hit)
        }
        guard let text = text else { NSSound.beep(); return }
        speech.speak(AVSpeechUtterance(string: text))
    }

    @objc func stop() { speech.stopSpeaking(at: .immediate) }
    @objc func settings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
    @objc func quit() { stop(); NSApp.terminate(nil) }
}

let app = NSApplication.shared
let delegate = ReaderApp()
app.setActivationPolicy(.accessory)
app.delegate = delegate
app.run()
