//
//  RoundTextEditor.swift (formerly PaneTextField.swift)
//  Phoenix (formerly CodeEdit)
//
//  Created by Austin Condiff on 11/2/23.
//

import SwiftUI
import Combine
import SwiftUIIntrospect

// hack to work-around the smart quote issue
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            self.isAutomaticQuoteSubstitutionEnabled = false
            self.isAutomaticDashSubstitutionEnabled = false
        }
    }
}

struct RoundTextEditor<LeadingAccessories: View, TrailingAccessories: View>: View {
    @Environment(\.colorScheme)
    var colorScheme

    @Environment(\.controlActiveState)
    private var controlActive

    @FocusState private var isFocused: Bool

    @Binding private var text: String

    let leadingAccessories: LeadingAccessories?

    let trailingAccessories: TrailingAccessories?

    var clearable: Bool

    var onClear: (() -> Void)

    var hasValue: Bool

    init(
        text: Binding<String>,
        @ViewBuilder leadingAccessories: () -> LeadingAccessories? = { EmptyView() },
        @ViewBuilder trailingAccessories: () -> TrailingAccessories? = { EmptyView() },
        clearable: Bool? = false,
        onClear: (() -> Void)? = {},
        hasValue: Bool? = false
    ) {
        _text = text
        self.leadingAccessories = leadingAccessories()
        self.trailingAccessories = trailingAccessories()
        self.clearable = clearable ?? false
        self.onClear = onClear ?? {}
        self.hasValue = hasValue ?? false
    }

    @ViewBuilder
    public func selectionBackground(
    ) -> some View {
        Color(.textBackgroundColor)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if let leading = leadingAccessories {
                leading
                    .frame(height: 20)
            }
            VStack {
                TextEditor(text: $text)
                    .font(.custom("SF Pro", fixedSize: 13))
                    .focused($isFocused)
                    .background(.clear)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 4)
                    .foregroundStyle(.primary)
            }
            if clearable == true {
                Button {
                    self.text = ""
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .opacity(text.isEmpty ? 0 : 1)
                .disabled(text.isEmpty)
            }
            if let trailing = trailingAccessories {
                trailing
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(minHeight: 22)
        .background(
            selectionBackground()
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .edgesIgnoringSafeArea(.all)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isFocused ? .secondary : .tertiary, lineWidth: 1.5)
                .cornerRadius(6)
                .disabled(true)
                .edgesIgnoringSafeArea(.all)
        )

        .onTapGesture {
            isFocused = true
        }
    }
}


