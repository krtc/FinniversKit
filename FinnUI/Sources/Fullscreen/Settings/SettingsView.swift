//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import SwiftUI
import FinniversKit

// MARK: - View Model

@available(iOS 13.0, *)
public protocol SettingsViewModel: ObservableObject {
    var sections: [SettingsSection] { get }
    var versionText: String { get }
}

// MARK: - View

@available(iOS 13.0.0, *)
public struct SettingsView<ViewModel: SettingsViewModel>: View {
    @ObservedObject private var viewModel: ViewModel
    private var sections: [SettingsSection] { viewModel.sections }
    private let onToggle: ((IndexPath, Bool) -> Void)?
    private let onSelect: ((IndexPath, UIView?) -> Void)?

    public init(
        viewModel: ViewModel,
        onToggle: ((IndexPath, Bool) -> Void)? = nil,
        onSelect: ((IndexPath, UIView?) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onToggle = onToggle
        self.onSelect = onSelect
    }

    public var body: some View {
        List {
            rows
            VersionView(text: viewModel.versionText)
        }
        .appearance { (view: UITableView) in
            view.separatorStyle = .none
            view.backgroundColor = .bgTertiary
        }
        .id(UUID())
        .edgesIgnoringSafeArea(.all)
    }

    private var rows: some View {
        ForEach(0..<sections.count) { section in
            self.sections[section].title.map(Header.init)

            ForEach(0..<self.sections[section].items.count) { row in
                self.cell(at: row, in: section)
                    .bottomDivider(self.isLastRow(row, in: section))
                    .frame(height: 48)
            }

            self.sections[section].footerTitle.map(Footer.init)
        }
    }

    private func cell(at row: Int, in section: Int) -> AnyView {
        let model = sections[section].items[row]
        let indexPath = IndexPath(row: row, section: section)
        let onSelect: (UIView?) -> Void = { view in
            self.onSelect?(indexPath, view)
        }

        switch model {
        case let model as SettingsViewToggleCellModel:
            return AnyView(ToggleCell(model: model, onToggle: { value in
                self.onToggle?(indexPath, value)
            }))
        case let model as SettingsViewConsentCellModel:
            return AnyView(BasicListCellWrapper(cell: BasicListCell(model: model), onSelect: onSelect))
        default:
            return AnyView(BasicListCellWrapper(cell: BasicListCell(model: model), onSelect: onSelect))
        }
    }

    private func isLastRow(_ row: Int, in section: Int) -> Bool {
        row != self.sections[section].items.count - 1
    }
}

// MARK: - Cells

@available(iOS 13.0.0, *)
private struct Header: View {
    let text: String

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(text.uppercased())
                    .finnFont(.detailStrong)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, .spacingM)
                    .padding(.bottom, .spacingS)
                Spacer()
            }
        }
        .background(Color.bgTertiary)
        .listRowInsets(EdgeInsets())
    }
}

@available(iOS 13.0.0, *)
private struct Footer: View {
    let text: String

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(text)
                    .finnFont(.caption)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, .spacingM)
                Spacer()
            }
            Spacer()
        }
        .background(Color.bgTertiary)
        .listRowInsets(EdgeInsets())
    }
}

@available(iOS 13.0.0, *)
private struct ToggleCell: View {
    let model: SettingsViewToggleCellModel
    let onToggle: (Bool) -> Void
    @SwiftUI.State private var isOn = true

    init(model: SettingsViewToggleCellModel, onToggle: @escaping (Bool) -> Void) {
        self.model = model
        self.onToggle = onToggle
        _isOn = State(initialValue: model.isOn)
        UISwitch.appearance().onTintColor = .primaryBlue
    }

    var body: some View {
        Toggle(isOn: isOnBinding) {
            BasicListCell(model: model).disabled(true)
        }
        .padding(.trailing, .spacingM)
        .background(Color.bgPrimary)
    }

    private var isOnBinding: Binding<Bool> {
        Binding(
            get: { self.isOn },
            set: {
                self.onToggle($0)
                self.isOn = $0
            }
        )
    }
}

@available(iOS 13.0.0, *)
private extension BasicListCell {
    init(model: SettingsViewConsentCellModel) {
        self.init(model: model, detailText: { _ in
            Text(model.status)
                .finnFont(.body)
                .foregroundColor(.textSecondary)
        })
    }
}

@available(iOS 13.0.0, *)
private struct VersionView: View {
    let text: String

    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: .spacingS) {
                Image(.finnLogoSimple)
                Text(text)
                    .finnFont(.detail)
                    .foregroundColor(.textPrimary)
            }
            .padding(EdgeInsets(top: 58, leading: .spacingM, bottom: .spacingS, trailing: .spacingM))
            Spacer()
        }
        .listRowInsets(EdgeInsets())
        .background(Color.bgTertiary)
    }
}

// MARK: - Previews

@available(iOS 13.0.0, *)
// swiftlint:disable:next superfluous_disable_command type_name
struct SettingsView_Previews: PreviewProvider {
    private static let viewModel = PreviewViewModel()

    static var previews: some View {
        ZStack {
            Color.bgTertiary
            SettingsView(viewModel: viewModel, onSelect: { indexPath, view in
                print("Cell at \(indexPath) selected, frame: \(String(describing: view?.superview?.frame))")
            })
        }.environment(\.colorScheme, .dark)
    }
}

@available(iOS 13.0.0, *)
private final class PreviewViewModel: SettingsViewModel {
    let versionText = "FinnUI Demo"

    @Published private(set) var sections = [
        SettingsSection(
            title: "Varslinger",
            items: [
                ToggleRow(
                    id: "priceChange",
                    title: "Prisnedgang på favoritter - Torget",
                    isOn: false
                ),
            ],
            footerTitle: "FINN varsler deg når prisen på en av dine favoritter på Torget blir satt ned."
        ),
        SettingsSection(
            title: "Meldinger",
            items: [
                ConsentRow(title: "Meldinger til e-post", status: "Av"),
            ]
        ),
        SettingsSection(
            title: "Personvern",
            items: [
                ConsentRow(title: "Få nyhetsbrev fra FINN", status: "Av"),
                ConsentRow(title: "Personlig tilpasset FINN", status: "På"),
                ConsentRow(title: "Motta viktig informasjon fra FINN", status: "På"),
                TextRow(title: "Smart reklame"),
                TextRow(title: "Last ned dine data"),
                TextRow(title: "Slett meg som bruker")
            ]
        )
    ]

    private struct TextRow: SettingsViewCellModel {
        let title: String
    }

    private struct ToggleRow: SettingsViewToggleCellModel {
        let id: String
        let title: String
        let isOn: Bool
    }

    private struct ConsentRow: SettingsViewConsentCellModel {
        let title: String
        let status: String
    }
}
