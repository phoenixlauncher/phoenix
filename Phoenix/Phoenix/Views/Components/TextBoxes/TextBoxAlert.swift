//
//  TextBoxAlert.swift
//  Phoenix
//
//  Created by jxhug on 1/16/24.
//

import SwiftUI

struct TextBoxAlert: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var text: String
    
    let saveAction: (() -> Void)
    
    var body: some View {
        VStack {
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
            HStack(spacing: 15) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Text(LocalizedStringKey("alert_Cancel"))
                        .fontWeight(.medium)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.primary)
                        .padding()
                        .frame(width: 100, height: 40)
                    }
                    .cornerRadius(10)
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .cornerRadius(10)
                .background(Color.secondary.opacity(0.2).cornerRadius(10))
                .buttonStyle(.plain)
                
                Button(action: {
                    saveAction()
                    dismiss()
                }) {
                    HStack {
                        Text(LocalizedStringKey("alert_Save"))
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                        .font(.system(size: 16))
                        .padding()
                        .frame(width: 110, height: 42)
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .cornerRadius(10)
                .background(Color.accentColor.cornerRadius(10))
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 300, height: 120)
    }
}

#Preview {
    TextBoxAlert(text: Binding<String>(
        get: { "" }, set: { _ in }), saveAction: {})
}
