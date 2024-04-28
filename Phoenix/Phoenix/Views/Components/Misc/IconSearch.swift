//
//  IconSearch.swift
//  Phoenix
//
//  Created by jxhug on 5/17/24.
//

import SwiftUI
import SwiftyJSON
import CachedAsyncImage

struct IconSearch: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State var searchTerm: String = ""
    
    @Binding var selectedIcon: String
    
    @State var fetchedIcons: [String] = []
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 10)
    
    func getSearch() {
        print("Searhchchchch")
        let query = "\(searchTerm) palette=false"
        if let url = URL(string: "https://api.iconify.design/search?query=\(query)") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                guard let data = data else {
                    print("No data received")
                    return
                }
                let json = try? JSON(data: data)
                fetchedIcons = json?["icons"].arrayValue.map({$0.stringValue}) ?? []
                print(fetchedIcons)
            }
            task.resume()
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            TextField(String(localized: "platforms_SearchIcon"), text: $searchTerm, prompt: Text(String(localized: "platforms_SearchIconDesc")))
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    selectedIcon = ""
                    getSearch()
                }
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(fetchedIcons, id: \.self) { icon in
                        Button(action: {
                            selectedIcon = "https://api.iconify.design/\(icon).svg"
                        }) {
                            CachedAsyncImage(url: URL(string: "https://api.iconify.design/\(icon).svg")) { phase in
                            switch phase {
                                case .success(let image):
                                    image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .if(colorScheme == .dark) { view in
                                        view.colorInvert()
                                    }
                                default:
                                    ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(0.5)
                                }
                            }
                            .frame(width: 20, height: 20)
                        }
                        .background(RoundedRectangle(cornerSize: CGSize(width: 3, height: 3)).fill(selectedIcon == "https://api.iconify.design/\(icon).svg" ? Color.accentColor : .clear))
                        .buttonStyle(.plain)
//                        .cornerRadius(2.5)
                    }
                }
                .padding()
            }
            if selectedIcon != "" {
                Button(action: {
                    dismiss()
                }) {
                    Text("Select Icon")
                }
            }
        }
        .padding()
        .frame(width: 300, height: 200, alignment: .topLeading)
    }
}
