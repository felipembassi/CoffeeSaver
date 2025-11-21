import Foundation
import CommonUI

/// Defines all available screens in the application.
///
/// Each case represents a distinct screen that can be displayed.
/// This enum is used by the ScreenFactory to construct the appropriate screen.
public enum AppScreen: ScreenType {
    case discovery
    case saved

    public var id: String {
        switch self {
        case .discovery: return "discovery"
        case .saved: return "saved"
        }
    }
}
