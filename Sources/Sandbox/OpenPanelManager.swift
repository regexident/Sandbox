// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import AppKit

public enum OpenPanelError: Swift.Error {
    case canceled
    case stopped
    case aborted
}

public protocol OpenPanelManagerProtocol {
    func securityScopedURL(fileURL: URL) -> Result<URL, OpenPanelError>
}

public class OpenPanelManager {
    public let title: String?
    public let message: String?
    public let prompt: String?

    public weak var delegate: NSOpenSavePanelDelegate? = nil

    public init(
        title: String? = OpenPanelManager.defaultTitle(),
        message: String? = OpenPanelManager.defaultMessage(),
        prompt: String? = OpenPanelManager.defaultPrompt()
    ) {
        self.title = title
        self.message = message
        self.prompt = prompt
    }

    public static func applicationName() -> String {
        let mainBundle = Bundle.main
        if let displayName = mainBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return displayName
        }
        if let bundleName = mainBundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return bundleName
        }
        return "Current App"
    }

    public static func defaultTitle() -> String {
        return NSLocalizedString(
            "Access permissions required",
            comment: "Sandbox open panel title."
        )
    }

    public static func defaultMessage(applicationName: String? = nil) -> String {
        let formatString = NSLocalizedString(
            "Please allow '%@' to access this file or folder to continue.",
            comment: "Sandbox open panel message."
        )
        let formatArgument = applicationName ?? self.applicationName()
        return String(format: formatString, formatArgument)
    }

    public static func defaultPrompt() -> String {
        return NSLocalizedString(
            "Allow",
            comment: "Sandbox open panel prompt."
        )
    }

    private static func openPanel() -> NSOpenPanel {
        assert(Thread.isMainThread, "Must be called from main thread.")

        let openPanel = NSOpenPanel()

        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.canCreateDirectories = false
        openPanel.isExtensionHidden = false
        openPanel.showsHiddenFiles = false

        return openPanel
    }
}

extension OpenPanelManager: OpenPanelManagerProtocol {
    public func securityScopedURL(fileURL: URL) -> Result<URL, OpenPanelError> {
        let openPanel = Self.openPanel()

        openPanel.title = self.title
        openPanel.message = self.message
        openPanel.prompt = self.prompt

        openPanel.delegate = self.delegate

        if openPanel.directoryURL == nil {
            openPanel.directoryURL = fileURL.deletingLastPathComponent()
        }

        // NSApplication.shared.activate(ignoringOtherApps: true)

        let response = DispatchQueue.main.sync {
            openPanel.runModal()
        }

        switch response {
        case .OK:
            return .success(openPanel.urls.first!)
        case .cancel:
            return .failure(.canceled)
        case .stop:
            return .failure(.stopped)
        case .abort:
            return .failure(.aborted)
        default:
            fatalError()
        }
    }
}
