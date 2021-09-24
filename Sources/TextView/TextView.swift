import SwiftUI

/// A SwiftUI TextView implementation that supports both scrolling and auto-sizing layouts
public struct TextView: View {

    @Environment(\.layoutDirection) private var layoutDirection

    @Binding private var text: NSAttributedString
    
    @State private var calculatedHeight: CGFloat = 44
    @State private var isEmpty: Bool = false

    private var onEditingChanged: (() -> Void)?
    private var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
    private var onCommit: (() -> Void)?

    private var placeholderView: AnyView?
    private var foregroundColor: UIColor = .label
    private var autocapitalization: UITextAutocapitalizationType = .sentences
    private var multilineTextAlignment: TextAlignment = .leading
    private var font: UIFont = .preferredFont(forTextStyle: .body)
    private var returnKeyType: UIReturnKeyType?
    private var clearsOnInsertion: Bool = false
    private var autocorrection: UITextAutocorrectionType = .default
    private var truncationMode: NSLineBreakMode = .byTruncatingTail
    private var isEditable: Bool = true
    private var isSelectable: Bool = true
    private var isScrollingEnabled: Bool = false
    private var enablesReturnKeyAutomatically: Bool?
    private var autoDetectionTypes: UIDataDetectorTypes = []
    private var allowRichText: Bool

    private var internalText: Binding<NSAttributedString> {
        Binding(
            get: { text },
            set: {
                text = $0
                isEmpty = $0.string.isEmpty
            }
        )
    }

    /// Makes a new TextView with the specified configuration
    /// - Parameters:
    ///   - text: A binding to the text
    ///   - shouldEditInRange: A closure that's called before an edit it applied, allowing the consumer to prevent the change
    ///   - onEditingChanged: A closure that's called after an edit has been applied
    ///   - onCommit: If this is provided, the field will automatically lose focus when the return key is pressed
    public init(_ text: Binding<String>,
         shouldEditInRange: ((Range<String.Index>, String) -> Bool)? = nil,
         onEditingChanged: (() -> Void)? = nil,
         onCommit: (() -> Void)? = nil
    ) {
        _text = Binding(
            get: { NSAttributedString(string: text.wrappedValue) },
            set: { text.wrappedValue = $0.string }
        )

        _isEmpty = State(initialValue: text.wrappedValue.isEmpty)

        self.onCommit = onCommit
        self.shouldEditInRange = shouldEditInRange
        self.onEditingChanged = onEditingChanged

        allowRichText = false
    }

    /// Makes a new TextView that supports `NSAttributedString`
    /// - Parameters:
    ///   - text: A binding to the attributed text
    ///   - onEditingChanged: A closure that's called after an edit has been applied
    ///   - onCommit: If this is provided, the field will automatically lose focus when the return key is pressed
    public init(_ text: Binding<NSAttributedString>,
                onEditingChanged: (() -> Void)? = nil,
                onCommit: (() -> Void)? = nil
    ) {
        _text = text
        _isEmpty = State(initialValue: text.wrappedValue.string.isEmpty)

        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged

        allowRichText = true
    }

    public var body: some View {
        Representable(
            text: $text,
            calculatedHeight: $calculatedHeight,
            foregroundColor: foregroundColor,
            autocapitalization: autocapitalization,
            multilineTextAlignment: multilineTextAlignment,
            font: font,
            returnKeyType: returnKeyType,
            clearsOnInsertion: clearsOnInsertion,
            autocorrection: autocorrection,
            truncationMode: truncationMode,
            isEditable: isEditable,
            isSelectable: isSelectable,
            isScrollingEnabled: isScrollingEnabled,
            enablesReturnKeyAutomatically: enablesReturnKeyAutomatically,
            autoDetectionTypes: autoDetectionTypes,
            allowsRichText: allowRichText,
            onEditingChanged: onEditingChanged,
            shouldEditInRange: shouldEditInRange,
            onCommit: onCommit
        )
        .frame(
            minHeight: isScrollingEnabled ? 0 : calculatedHeight,
            maxHeight: isScrollingEnabled ? .infinity : calculatedHeight
        )
        .background(
            placeholderView?
                .foregroundColor(Color(.placeholderText))
                .multilineTextAlignment(multilineTextAlignment)
                .font(Font(font))
                .padding(.horizontal, isScrollingEnabled ? 5 : 0)
                .padding(.vertical, isScrollingEnabled ? 8 : 0)
                .opacity(isEmpty ? 1 : 0),
            alignment: .topLeading
        )
    }

}

public extension TextView {

    /// Specifies whether or not this view allows rich text
    /// - Parameter enabled: If `true`, rich text editing controls will be enabled for the user
    func allowsRichText(_ enabled: Bool) -> TextView {
        var view = self
        view.allowRichText = enabled
        return view
    }

    /// Specify a placeholder text
    /// - Parameter placeholder: The placeholder text
    func placeholder(_ placeholder: String) -> TextView {
        self.placeholder(placeholder) { $0 }
    }

    /// Specify a placeholder with the specified configuration
    ///
    /// Example:
    ///
    ///     TextView($text)
    ///         .placeholder("placeholder") { view in
    ///             view.foregroundColor(.red)
    ///         }
    func placeholder<V: View>(_ placeholder: String, _ configure: (Text) -> V) -> TextView {
        var view = self
        let text = Text(placeholder)
        view.placeholderView = AnyView(configure(text))
        return view
    }

    /// Specify a custom placeholder view
    func placeholder<V: View>(_ placeholder: V) -> TextView {
        var view = self
        view.placeholderView = AnyView(placeholder)
        return view
    }

    /// Enables auto detection for the specified types
    /// - Parameter types: The types to detect
    func autoDetectDataTypes(_ types: UIDataDetectorTypes) -> TextView {
        var view = self
        view.autoDetectionTypes = types
        return view
    }

    /// Specify the foreground color for the text
    /// - Parameter color: The foreground color
    func foregroundColor(_ color: UIColor) -> TextView {
        var view = self
        view.foregroundColor = color
        return view
    }

    /// Specifies the capitalization style to apply to the text
    /// - Parameter style: The capitalization style
    func autocapitalization(_ style: UITextAutocapitalizationType) -> TextView {
        var view = self
        view.autocapitalization = style
        return view
    }

    /// Specifies the alignment of multi-line text
    /// - Parameter alignment: The text alignment
    func multilineTextAlignment(_ alignment: TextAlignment) -> TextView {
        var view = self
        view.multilineTextAlignment = alignment
        return view
    }

    /// Specifies the font to apply to the text
    /// - Parameter font: The font to apply
    func font(_ font: UIFont) -> TextView {
        var view = self
        view.font = font
        return view
    }

    /// Specifies the font weight to apply to the text
    /// - Parameter weight: The font weight to apply
    func fontWeight(_ weight: UIFont.Weight) -> TextView {
        font(font.weight(weight))
    }

    /// Specifies if the field should clear its content when editing begins
    /// - Parameter value: If true, the field will be cleared when it receives focus
    func clearOnInsertion(_ value: Bool) -> TextView {
        var view = self
        view.clearsOnInsertion = value
        return view
    }

    /// Disables auto-correct
    /// - Parameter disable: If true, autocorrection will be disabled
    func disableAutocorrection(_ disable: Bool?) -> TextView {
        var view = self
        if let disable = disable {
            view.autocorrection = disable ? .no : .yes
        } else {
            view.autocorrection = .default
        }
        return view
    }

    /// Specifies whether the text can be edited
    /// - Parameter isEditable: If true, the text can be edited via the user's keyboard
    func isEditable(_ isEditable: Bool) -> TextView {
        var view = self
        view.isEditable = isEditable
        return view
    }

    /// Specifies whether the text can be selected
    /// - Parameter isSelectable: If true, the text can be selected
    func isSelectable(_ isSelectable: Bool) -> TextView {
        var view = self
        view.isSelectable = isSelectable
        return view
    }

    /// Specifies whether the field can be scrolled. If true, auto-sizing will be disabled
    /// - Parameter isScrollingEnabled: If true, scrolling will be enabled
    func enableScrolling(_ isScrollingEnabled: Bool) -> TextView {
        var view = self
        view.isScrollingEnabled = isScrollingEnabled
        return view
    }

    /// Specifies the type of return key to be shown during editing, for the device keyboard
    /// - Parameter style: The return key style
    func returnKey(_ style: UIReturnKeyType?) -> TextView {
        var view = self
        view.returnKeyType = style
        return view
    }

    /// Specifies whether the return key should auto enable/disable based on the current text
    /// - Parameter value: If true, when the text is empty the return key will be disabled
    func automaticallyEnablesReturn(_ value: Bool?) -> TextView {
        var view = self
        view.enablesReturnKeyAutomatically = value
        return view
    }

    /// Specifies the truncation mode for this field
    /// - Parameter mode: The truncation mode
    func truncationMode(_ mode: Text.TruncationMode) -> TextView {
        var view = self
        switch mode {
        case .head: view.truncationMode = .byTruncatingHead
        case .tail: view.truncationMode = .byTruncatingTail
        case .middle: view.truncationMode = .byTruncatingMiddle
        @unknown default:
            fatalError("Unknown text truncation mode")
        }
        return view
    }

}

final class UIKitTextView: UITextView {

    override var keyCommands: [UIKeyCommand]? {
        return (super.keyCommands ?? []) + [
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(escape(_:)))
        ]
    }

    @objc private func escape(_ sender: Any) {
        resignFirstResponder()
    }

}

struct RoundedTextView: View {
    @State private var text: NSAttributedString = .init()

    var body: some View {
        VStack(alignment: .leading) {
            TextView($text)
                .padding(.leading, 25)

            GeometryReader { _ in
                TextView($text)
                    .placeholder("Enter some text")
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color(.placeholderText))
                    )
                    .padding()
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))

            Button {
                text = NSAttributedString(string: "This is interesting", attributes: [
                    .font: UIFont.preferredFont(forTextStyle: .headline)
                ])
            } label: {
                Spacer()
                Text("Interesting?")
                Spacer()
            }
            .padding()
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedTextView()
    }
}
