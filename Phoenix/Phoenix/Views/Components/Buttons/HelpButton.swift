//
//  HelpButton.swift
//  Phoenix
//
//  Created by James Hughes on 9/24/23.
//

import SwiftUI
import MarkdownUI

struct HelpButton: View {
    @State var showHelp: Bool = false
    @State var markdown: String = ""
    
    var url: URL
    
    var body: some View {
        Button (
            action: {
                fetchMarkdownContent(from: url)
                showHelp.toggle()
            }, label: {
                ZStack {
                    Circle()
                        .strokeBorder(Color(NSColor.separatorColor), lineWidth: 0.5)
                        .background(Circle().foregroundColor(Color(NSColor.controlColor)))
                        .shadow(color: Color(NSColor.separatorColor).opacity(0.3), radius: 1)
                        .frame(width: 20, height: 20)
                    Text("?").font(.system(size: 15, weight: .regular))
                }
            }
        )
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showHelp, content: {
            VStack {
                ScrollView {
                    Markdown(markdown)
                        .markdownTheme(.docC)
                }
                .padding()
            }
            .frame(minWidth: 600, idealWidth: 800, maxWidth: .infinity, minHeight: 300, idealHeight: 600, maxHeight: .infinity)
        })
    }
    
    private func fetchMarkdownContent(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let markdownString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.markdown = markdownString
                }
            }
        }.resume()
    }
}
