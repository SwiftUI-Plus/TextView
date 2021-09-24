import SwiftUI

extension TextView.Representable {
    final class Coordinator: NSObject, UITextViewDelegate {

        private var originalText: NSAttributedString = .init()
        private var text: Binding<NSAttributedString>
        private var calculatedHeight: Binding<CGFloat>

        var onCommit: (() -> Void)?
        var onEditingChanged: (() -> Void)?
        var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?

        init(text: Binding<NSAttributedString>,
             calculatedHeight: Binding<CGFloat>,
             shouldEditInRange: ((Range<String.Index>, String) -> Bool)?,
             onEditingChanged: (() -> Void)?,
             onCommit: (() -> Void)?) {
            self.text = text
            self.calculatedHeight = calculatedHeight
            self.shouldEditInRange = shouldEditInRange
            self.onEditingChanged = onEditingChanged
            self.onCommit = onCommit
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            originalText = text.wrappedValue
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = NSAttributedString(attributedString: textView.attributedText)
            TextView.Representable.recalculateHeight(view: textView, result: calculatedHeight)
            onEditingChanged?()
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if onCommit != nil, text == "\n" {
                onCommit?()
                originalText = NSAttributedString(attributedString: textView.attributedText)
                textView.resignFirstResponder()
                return false
            }

            return true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            // this check is to ensure we always commit text when we're not using a closure
            if onCommit != nil {
                text.wrappedValue = originalText
            }
        }

    }

}
