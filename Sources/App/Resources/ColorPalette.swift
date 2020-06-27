import Foundation

enum ColorPalette {
    case lightSteelBlue
    case lightGreen
    case navajoWhite
    case beige
    
    var hexColor: String {
        switch self {
        case .lightSteelBlue:
            return "#A5C9DD"
        case .lightGreen:
            return "#93EF9A"
        case .navajoWhite:
            return "#FBDC83"
        case .beige:
            return "#D7E7BD"
        }
    }
}
