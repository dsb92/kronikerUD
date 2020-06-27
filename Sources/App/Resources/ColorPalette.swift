import Foundation

enum ColorPalette {
    case lightSteelBlue
    
    var hexColor: String {
        switch self {
        case .lightSteelBlue:
            return "#A5C9DD"
        }
    }
}
