# Point Reader

Enabled for kanagawa and outer-heaven through the shared Darwin bundle and
darwin-mac profile. No external speech service or additional configuration is used.

Press Shift + Command + Space to read the active application's selected text.
Without a selection, Point Reader reads the accessible element under the pointer
and its text descendants, without walking up to the window. Press the shortcut
again while speaking to stop. The Read menu also provides Stop Reading,
Accessibility Settings and Quit. Speech uses the default system voice.

After activating the host configuration separately, grant Point Reader access in
System Settings > Privacy & Security > Accessibility. Restart the app if macOS
requests it. Grant permission to the actual Point Reader application, not Terminal.
An application update may require renewing this permission. No switch is part of
installation preparation.

A shortcut registration failure is shown explicitly. Resolve the competing
shortcut and restart the app. Missing permissions open Accessibility settings;
missing readable text produces a brief system sound. Text is neither logged nor
copied to the clipboard. Protected fields and their descendants are excluded.

Block boundaries depend on the target application's accessibility tree. Some
applications expose a label, a text area or an entire document instead of a
paragraph. In those applications, select the precise text first. Images, canvas
content and applications without accessible text are unsupported; there is no OCR.
Traversal is limited to 128 elements and 16 levels within the pointed block.

The package runs extraction tests during its Nix build. Manual acceptance after
activation on each Mac: read a TextEdit selection, read an unselected browser
paragraph under the pointer, stop speech with the shortcut and menu, check a
protected field, check missing permission and competing shortcuts, and repeat
pointer checks on displays arranged on either side of and above the primary one.
