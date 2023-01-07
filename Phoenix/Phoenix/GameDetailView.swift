//
//  GameDetailView.swift
//  Phoenix
//
//  Created by Kaleb Rosborough on 2022-12-28.
//
import SwiftUI

struct GameDetailView: View {
  private func loadImageFromFile(filePath: String) -> NSImage? {
    do {
      if filePath != "" {
        let imageData = try Data(contentsOf: URL(string: filePath)!)
        return NSImage(data: imageData)
      } else {
        return nil
      }
    } catch {
      logger.write("[ERROR]: Error loading image : \(error)")
    }
    return nil
  }

  @State var editingGame: Bool = false
  @State var showingAlert: Bool = false
  @Binding var selectedGame: String?
  @Binding var refresh: Bool

  // make gradient colors
  static let color0 = Color(red: 0/255, green: 230/255, blue: 2/255);
  static let color1 = Color(red: 14/255, green: 173/255, blue: 89/255);
  static let color2 = Color(red: 0/255, green: 230/255, blue: 2/255);
  static let color3 = Color(red: 79/255, green: 84/255, blue: 84/255);
  static let color4 = Color(red: 55/255, green: 54/255, blue: 53/255);

  //make gradients
  let playGradient = Gradient(colors: [color0, color1, color2]);
  let settingsGradient = Gradient(colors: [color3, color4]);

  var body: some View {
    ScrollView {
      GeometryReader { geometry in
        if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
          let game = games[idx]

          //create header image
          Image(nsImage: loadImageFromFile(filePath: game.metadata["header_img"]!) ?? NSImage(imageLiteralResourceName: "PlaceholderImage"))
            .resizable()
            .scaledToFill()
            .frame(width: geometry.size.width, height: getHeightForHeaderImage(geometry))
            .blur(radius: getBlurRadiusForImage(geometry))
            .clipped()
            .offset(x: 0, y: getOffsetForHeaderImage(geometry))
        }
      }.frame(height: 400)

      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          VStack(alignment: .leading) {
            HStack(alignment: .top) {
              //play button
              Button(action: {
                if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                  do {
                    let game = games[idx]
                    if game.launcher != "" {
                      try shell(game)
                    } else {
                      showingAlert = true
                    }
                  } catch {
                    logger.write("\(error)") // handle or silence the error here
                  }
                }
              }, label: {
                Image(systemName: "play.fill")
                  .foregroundColor(Color.white)
                  .font(.system(size: 25))
                Text(" Play")
                  .fontWeight(.medium)
                  .foregroundColor(Color.white)
                  .font(.system(size: 25))
              })
              .alert("No launcher configured. Please configure a launch command to run \(selectedGame ?? "this game")", isPresented: $showingAlert) {}
              .buttonStyle(.plain)
              .frame(width: 175, height: 50)
              .background(LinearGradient(
                gradient: playGradient,
                startPoint: .init(x: 0, y: 0.5),
                endPoint: .init(x: 1, y: 0.5)
              ))
              .cornerRadius(10)
              .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))

              //settings button
              Button(action: {
                editingGame.toggle()
              }, label: {
                Image(systemName: "gear")
                  .fontWeight(.bold)
                  .foregroundColor(Color.white)
                  .font(.system(size: 27))
              })
              .sheet(isPresented: $editingGame, onDismiss: {
                // Refresh game list
                refresh.toggle()
              }, content: {
                let idx = games.firstIndex(where: { $0.name == selectedGame })
                let game = games[idx!]
                EditGameView(currentGame: .constant(game))
              })
              .buttonStyle(.plain)
              .frame(width: 50, height: 50)
              .background(LinearGradient(
                gradient: settingsGradient,
                startPoint: .init(x: 0.50, y: 0),
                endPoint: .init(x: 0.50, y: 1)
              ))
              .cornerRadius(10)
            }//hstack
            .frame(alignment: .leading)

            //description
            VStack(alignment: .leading) {
              // Game Description
              if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                let game = games[idx]
                Text(game.metadata["description"] ?? "No game selected")
              }
            }//vstack
            .frame(maxWidth: 450)  // controls the width of the description text
            .font(.system(size: 14.5))
            .lineSpacing(3.5)
            .padding(.top, 5)
          }//vstack
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(EdgeInsets(top: 10, leading: 17.5, bottom: 0, trailing: 0))

          HStack(alignment: .top) {
            // Game Info
            VStack(alignment: .leading) {
              Text("Time Played:").padding(5)
              Text("Last Played:").padding(5)
              Text("Platform:").padding(5)
              Text("Rating:").padding(5)
              Text("Genres:\n\n").padding(5)
              Text("Developer:").padding(5)
              Text("Publisher:").padding(5)
              Text("Release Date:").padding(5)
            }
            VStack(alignment: .trailing) {
              if let idx = games.firstIndex(where: { $0.name == selectedGame }) {
                let game = games[idx]
                Text(game.metadata["time_played"] ?? "").padding(5)
                Text(game.metadata["last_played"] ?? "").padding(5)
                switch game.platform {
                case Platform.MAC:
                  Text("MacOS").padding(5)
                case Platform.STEAM:
                  Text("Steam").padding(5)
                case Platform.GOG:
                  Text("GOG").padding(5)
                case Platform.EPIC:
                  Text("Epic Games").padding(5)
                case Platform.EMUL:
                  Text("Emulated").padding(5)
                case Platform.NONE:
                  Text("Other").padding(5)
                }
                Text(game.metadata["rating"] ?? "").padding(5)
                Text(game.metadata["genre"] ?? "").padding(5)
                Text(game.metadata["developer"] ?? "").padding(5)
                Text(game.metadata["publisher"] ?? "").padding(5)
                Text(game.metadata["release_date"] ?? "No date").padding(5)
              }
            }
          }
          .frame(minWidth: 350).padding(.top, 5)  // specify min width for the game details (ensures padding on right side)
          .font(.system(size: 14.5))
        }
      }
    }
    .edgesIgnoringSafeArea(.all)
    .navigationTitle(selectedGame ?? "Phoenix")
  }
}
