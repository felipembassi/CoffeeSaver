import Foundation

public enum Strings {
    // MARK: - Navigation

    public enum Navigation {
        public static let discover = String(localized: "navigation.discover", bundle: .module)
        public static let saved = String(localized: "navigation.saved", bundle: .module)
    }

    // MARK: - Tab Bar

    public enum Tab {
        public static let discover = String(localized: "tab.discover", bundle: .module)
        public static let saved = String(localized: "tab.saved", bundle: .module)
    }

    // MARK: - Discovery

    public enum Discovery {
        public static let emoji = String(localized: "discovery.emoji", bundle: .module)
        public static let subtitle = String(localized: "discovery.subtitle", bundle: .module)
        public static let loading = String(localized: "discovery.loading", bundle: .module)
    }

    // MARK: - Saved Coffees

    public enum Saved {
        public enum Empty {
            public static let title = String(localized: "saved.empty.title", bundle: .module)
            public static let message = String(localized: "saved.empty.message", bundle: .module)
        }
    }

    // MARK: - Alerts

    public enum Alert {
        public enum Delete {
            public static let title = String(localized: "alert.delete.title", bundle: .module)
            public static let message = String(localized: "alert.delete.message", bundle: .module)
            public static let cancel = String(localized: "alert.delete.cancel", bundle: .module)
            public static let confirm = String(localized: "alert.delete.confirm", bundle: .module)
        }
    }

    // MARK: - Actions

    public enum Action {
        public static let tryAgain = String(localized: "action.tryAgain", bundle: .module)
    }

    // MARK: - Errors

    public enum Error {
        public static let generic = String(localized: "error.generic", bundle: .module)
    }
}
