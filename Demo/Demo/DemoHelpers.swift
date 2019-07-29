//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//
import FinniversKit
import UIKit

enum TabletDisplayMode {
    case master
    case detail
    case fullscreen
}

public struct ContainmentOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let navigationController = ContainmentOptions(rawValue: 2 << 0)
    public static let tabBarController = ContainmentOptions(rawValue: 2 << 1)
    public static let bottomSheet = ContainmentOptions(rawValue: 2 << 2)
    public static let all: ContainmentOptions = [.navigationController, .tabBarController, .bottomSheet]
    public static let none = ContainmentOptions(rawValue: 2 << 3)

    /// Attaches a navigation bar, a tab bar or both depending on what is returned here.
    /// If you return nil the screen will have no containers.
    /// Or replace `return nil` with `self = .items`, `self = .navigationController` or `self = .tabBarController`
    ///
    /// - Parameter indexPath: The component's index path
    // swiftlint:disable:next cyclomatic_complexity
    init?(indexPath: IndexPath) {
        let sectionType = Sections.for(indexPath)
        switch sectionType {
        case .dna:
            guard let screens = DnaViews.items[safe: indexPath.row] else {
                return nil
            }
            switch screens {
            default: return nil
            }
        case .components:
            guard let screens = ComponentViews.items[safe: indexPath.row] else {
                return nil
            }
            switch screens {
            case .bannerTransparency:
                self = .bottomSheet
            default: return nil
            }
        case .cells:
            guard let screens = Cells.items[safe: indexPath.row] else {
                return nil
            }
            switch screens {
            default: return nil
            }
        case .recycling:
            guard let screens = RecyclingViews.items[safe: indexPath.row] else {
                return nil
            }
            switch screens {
            default: return nil
            }
        case .fullscreen:
            guard let screens = FullscreenViews.items[safe: indexPath.row] else {
                return nil
            }
            switch screens {
            case .consentToggleView:
                self = [.navigationController, .tabBarController]
            case .consentActionView:
                self = [.navigationController, .tabBarController]
            case .addressView:
                self = [.navigationController, .tabBarController]
            default: return nil
            }
        }
    }
}

enum Sections: String, CaseIterable {
    case dna
    case components
    case cells
    case recycling
    case fullscreen

    static var items: [Sections] {
        return allCases
    }

    var numberOfItems: Int {
        switch self {
        case .dna:
            return DnaViews.items.count
        case .components:
            return ComponentViews.items.count
        case .cells:
            return Cells.items.count
        case .recycling:
            return RecyclingViews.items.count
        case .fullscreen:
            return FullscreenViews.items.count
        }
    }

    static func title(for section: Int) -> String {
        let section = Sections.items[section]
        let rawClassName = section.rawValue
        return rawClassName
    }

    static func formattedNames(for section: Int) -> [String] {
        let section = Sections.items[section]
        let names: [String]
        switch section {
        case .dna:
            names = DnaViews.items.sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue.capitalizingFirstLetter }
        case .components:
            names = ComponentViews.items.sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue.capitalizingFirstLetter }
        case .cells:
            names = Cells.items.sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue.capitalizingFirstLetter }
        case .recycling:
            names = RecyclingViews.items.sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue.capitalizingFirstLetter }
        case .fullscreen:
            names = FullscreenViews.items.sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue.capitalizingFirstLetter }
        }
        return names
    }

    static func formattedName(for indexPath: IndexPath) -> String {
        let section = Sections.items[indexPath.section]
        var rawClassName: String
        switch section {
        case .dna:
            let names = DnaViews.items.sorted { $0.rawValue < $1.rawValue }
            rawClassName = names[indexPath.row].rawValue
        case .components:
            let names = ComponentViews.items.sorted { $0.rawValue < $1.rawValue }
            rawClassName = names[indexPath.row].rawValue
        case .cells:
            let names = Cells.items.sorted { $0.rawValue < $1.rawValue }
            rawClassName = names[indexPath.row].rawValue
        case .recycling:
            let names = RecyclingViews.items.sorted { $0.rawValue < $1.rawValue }
            rawClassName = names[indexPath.row].rawValue
        case .fullscreen:
            let names = FullscreenViews.items.sorted { $0.rawValue < $1.rawValue }
            rawClassName = names[indexPath.row].rawValue
        }

        return rawClassName.capitalizingFirstLetter
    }

    static func `for`(_ indexPath: IndexPath) -> Sections {
        return Sections.items[indexPath.section]
    }

    // swiftlint:disable:next cyclomatic_complexity
    static func viewController(for indexPath: IndexPath) -> UIViewController? {
        guard let section = Sections.items[safe: indexPath.section] else {
            return nil
        }
        var viewController: UIViewController?
        switch section {
        case .dna:
            let selectedView = DnaViews.items[safe: indexPath.row]
            viewController = selectedView?.viewController
        case .components:
            let selectedView = ComponentViews.items[safe: indexPath.row]
            viewController = selectedView?.viewController
        case .cells:
            let selectedView = Cells.items[safe: indexPath.row]
            viewController = selectedView?.viewController
        case .recycling:
            let selectedView = RecyclingViews.items[safe: indexPath.row]
            viewController = selectedView?.viewController
        case .fullscreen:
            let selectedView = FullscreenViews.items[safe: indexPath.row]
            viewController = selectedView?.viewController
        }

        let sectionType = Sections.for(indexPath)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            switch sectionType.tabletDisplayMode {
            case .master:
                if let unwrappedViewController = viewController {
                    viewController = SplitViewController(masterViewController: unwrappedViewController)
                }
            case .detail:
                if let unwrappedViewController = viewController {
                    viewController = SplitViewController(detailViewController: unwrappedViewController)
                }
            default:
                break
            }
        default:
            break
        }

        let shouldIncludeNavigationController = ContainmentOptions(indexPath: indexPath)?.contains(.navigationController) ?? false
        if shouldIncludeNavigationController {
            if let unwrappedViewController = viewController {
                viewController = UINavigationController(rootViewController: unwrappedViewController)
            }
        }

        let shouldIncludeTabBarController = ContainmentOptions(indexPath: indexPath)?.contains(.tabBarController) ?? false
        if shouldIncludeTabBarController {
            let tabBarController = UITabBarController()
            if let unwrappedViewController = viewController {
                tabBarController.viewControllers = [unwrappedViewController]
                viewController = tabBarController
            }
        }

        let shouldPresentInBottomSheet = ContainmentOptions(indexPath: indexPath)?.contains(.bottomSheet) ?? false
        if shouldPresentInBottomSheet {
            if let unwrappedViewController = viewController {
                let bottomSheet = BottomSheet(rootViewController: unwrappedViewController)
                viewController = bottomSheet
            }
        }

        return viewController
    }

    var tabletDisplayMode: TabletDisplayMode {
        switch self {
        case .dna, .components, .fullscreen, .cells:
            return .fullscreen
        case .recycling:
            return .fullscreen
        }
    }
}

extension Array {
    /// Returns nil if index < count
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : .none
    }
}

extension Foundation.Notification.Name {
    static let didChangeUserInterfaceStyle = Foundation.Notification.Name("didChangeUserInterfaceStyle")
}

@objc enum UserInterfaceStyle: Int {
    case light
    case dark

    var image: UIImage {
        switch self {
        case .light:
            return UIImage(named: "emptyMoon")!
        case .dark:
            return UIImage(named: "filledMoon")!
        }
    }
}
