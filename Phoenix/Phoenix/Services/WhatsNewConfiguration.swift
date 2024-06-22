import WhatsNewKit
import Foundation

struct WhatsNewConfiguration: WhatsNewCollectionProvider {
    var whatsNewCollection: WhatsNewCollection {
        WhatsNew(
            version: "0.1.9",
            title: .init(
                    text: .init(
                        "What's New in "
                        + AttributedString(
                            "Phoenix",
                            attributes: AttributeContainer().foregroundColor(.red)
                        )
                    )
                ),
            features: [
                .init(
                    image: .init(systemName: "gamecontroller.fill"),
                    title: "Custom Directory Scanning",
                    subtitle: "Add custom directories to your platforms in settings to autodetect games at launch."
                ),
                .init(
                    image: .init(systemName: "hare.fill"),
                    title: "Faster Game Autodetection",
                    subtitle: "Your games will be added in seconds, right in front of you."
                ),
                .init(
                    image: .init(systemName: "hourglass"),
                    title: "Loading Indicator",
                    subtitle: "See when your games are being autodetected with a slick indicator."
                )
            ],
            primaryAction: WhatsNew.PrimaryAction(
                title: "Continue",
                backgroundColor: .accentColor,
                foregroundColor: .white,
                onDismiss: {
                    print("WhatsNewView has been dismissed")
                }
            ),
            secondaryAction: WhatsNew.SecondaryAction(
                title: "Learn more",
                foregroundColor: .accentColor,
                action: .openURL(
                    .init(string: "https://github.com/phoenixlauncher/phoenix/releases/tag/v0.1.9-beta")
                )
            )
        )
    }
}
