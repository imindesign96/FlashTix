import SwiftUI

enum FlashTixColor {
    static let brandPink = Color(red: 0.96, green: 0.12, blue: 0.40)
    static let brandOrange = Color(red: 1.00, green: 0.42, blue: 0.24)
    static let ink = Color(red: 0.06, green: 0.05, blue: 0.10)
    static let secondaryText = Color.secondary

    static let brandGradient = LinearGradient(
        colors: [brandPink, brandOrange],
        startPoint: .leading,
        endPoint: .trailing
    )
}
