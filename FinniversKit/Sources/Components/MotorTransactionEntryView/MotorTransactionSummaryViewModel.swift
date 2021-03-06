//
//  Copyright © 2020 FINN AS. All rights reserved.
//

public struct MotorTransactionEntryViewModel {
    public let title: String
    public let detail: String
    public let description: String
    public let externalView: MotorTransactionEntryButtonViewModel?
    public let style: String?

    public init(title: String, detail: String, description: String, externalView: MotorTransactionEntryButtonViewModel?, style: String?) {
        self.title = title
        self.detail = detail
        self.description = description
        self.externalView = externalView
        self.style = style
    }
}

public struct MotorTransactionEntryButtonViewModel: MotorTransactionButtonViewModel {
    public var text: String
    public var style: String?
    public var action: String?
    public var url: String?
    public var fallbackUrl: String?

    public init(text: String, style: String? = nil, action: String? = nil, url: String? = nil, fallbackUrl: String? = nil) {
        self.text = text
        self.style = style
        self.action = action
        self.url = url
        self.fallbackUrl = fallbackUrl
    }
}
