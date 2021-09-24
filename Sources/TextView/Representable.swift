import SwiftUI

extension TextView {
    struct Representable: UIViewRepresentable {

        @Binding var text: NSAttributedString
        @Binding var calculatedHeight: CGFloat

        let foregroundColor: UIColor
        let autocapitalization: UITextAutocapitalizationType
        var multilineTextAlignment: TextAlignment
        let font: UIFont
        let returnKeyType: UIReturnKeyType?
        let clearsOnInsertion: Bool
        let autocorrection: UITextAutocorrectionType
        let truncationMode: NSLineBreakMode
        let isEditable: Bool
        let isSelectable: Bool
        let isScrollingEnabled: Bool
        let enablesReturnKeyAutomatically: Bool?
        var autoDetectionTypes: UIDataDetectorTypes = []
        var allowsRichText: Bool

        var onEditingChanged: (() -> Void)?
        var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
        var onCommit: (() -> Void)?

        func makeUIView(context: Context) -> UIKitTextView {
            context.coordinator.textView
        }

        func updateUIView(_ view: UIKitTextView, context: Context) {
            view.attributedText = text
            view.font = font
            view.adjustsFontForContentSizeCategory = true
            view.textColor = foregroundColor
            view.autocapitalizationType = autocapitalization
            view.autocorrectionType = autocorrection
            view.isEditable = isEditable
            view.isSelectable = isSelectable
            view.isScrollEnabled = isScrollingEnabled
            view.dataDetectorTypes = autoDetectionTypes
            view.allowsEditingTextAttributes = allowsRichText

            switch multilineTextAlignment {
            case .leading:
                view.textAlignment = view.traitCollection.layoutDirection ~= .leftToRight ? .left : .right
            case .trailing:
                view.textAlignment = view.traitCollection.layoutDirection ~= .leftToRight ? .right : .left
            case .center:
                view.textAlignment = .center
            }

            if let value = enablesReturnKeyAutomatically {
                view.enablesReturnKeyAutomatically = value
            } else {
                view.enablesReturnKeyAutomatically = onCommit == nil ? false : true
            }

            if let returnKeyType = returnKeyType {
                view.returnKeyType = returnKeyType
            } else {
                view.returnKeyType = onCommit == nil ? .default : .done
            }

            if !isScrollingEnabled {
                view.textContainer.lineFragmentPadding = 0
                view.textContainerInset = .zero
            }

            Self.recalculateHeight(view: view, result: $calculatedHeight)
            view.setNeedsDisplay()
        }

        @discardableResult func makeCoordinator() -> Coordinator {
            Coordinator(
                text: $text,
                calculatedHeight: $calculatedHeight,
                shouldEditInRange: shouldEditInRange,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit
            )
        }

        static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
            let newSize = view.sizeThatFits(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude))

            guard result.wrappedValue != newSize.height else { return }
            DispatchQueue.main.async { // call in next render cycle.
                result.wrappedValue = newSize.height
            }
        }

    }

}
