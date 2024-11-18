//
//  PortfolioScreenVC.swift
//  T-Stocks
//
//  Created by sleepcha on 8/14/24.
//

import UIKit

// MARK: - PortfolioScreenVC

final class PortfolioScreenVC: UITableViewController {
    var presenter: PortfolioScreenPresenter!

    private let summaryView = PortfolioSummaryView()

    private lazy var gradientView = GradientView(
        mainColor: .accountBackground,
        accentColor: .accountAccent
    )

    private lazy var bounceAreaView = UIView {
        $0.backgroundColor = .accountBackground
        $0.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview()
        }
    }

    private lazy var menuButton = UIBarButtonItem {
        $0.tintColor = .white
        $0.image = UIImage(systemName: "gearshape.fill")
        $0.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [logoutMenuItem])
    }

    private lazy var logoutMenuItem = UIAction(
        title: C.UI.logoutButtonTitle,
        image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
        attributes: .destructive,
        handler: { [weak self] _ in self?.presenter.logoutMenuItemTapped() }
    )

    private var isShowingError: Bool = false {
        didSet {
            guard oldValue != isShowingError else { return }
            tableView.isScrollEnabled = !isShowingError
            tableHeaderView?.isHidden = isShowingError
            bounceAreaView.isHidden = isShowingError
            menuButton.tintColor = isShowingError ? .brandLabel : .white

            guard isShowingError else { tableView.backgroundView = nil; return }
            dataSource = DataSource(sections: [])
            summaryView.update(with: nil)
            tableView.reloadData()
        }
    }

    private var tableHeaderView: UIView? { tableView.tableHeaderView }
    private var navBarHeight: CGFloat? { navigationController?.navigationBar.frame.height }
    private var dataSource = DataSource<PortfolioItemCellModel>(sections: [])

    override func loadView() {
        tableView = UITableView(frame: .zero, style: .grouped).configuring {
            $0.backgroundColor = .systemBackground
            $0.separatorStyle = .singleLine
            $0.sectionFooterHeight = 0
            $0.sectionHeaderHeight = AssetKindHeaderView.defaultHeight
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addApplicationObservers()
        setupViews()
        presenter.viewReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewAppearing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.viewDisappearing()
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()
        updateBounceAreaFrame()
    }

    private func setupViews() {
        tableView.register(PortfolioItemCell.self)
        tableView.register(AssetKindHeaderView.self)
        tableView.addSubview(bounceAreaView)
        tableView.sendSubviewToBack(bounceAreaView)
        setupTableHeaderView()

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.standardAppearance = UINavigationBarAppearance {
            $0.configureWithOpaqueBackground()
            $0.shadowColor = nil
        }
        navigationItem.titleView = summaryView
        navigationItem.rightBarButtonItem = menuButton
    }

    // AccountSlider is injected in assembly
    private func setupTableHeaderView() {
        guard let tableHeaderVC = children.first else { return }
        addChild(tableHeaderVC)
        tableView.tableHeaderView = tableHeaderVC.view
        tableHeaderVC.didMove(toParent: self)
    }

    private func updateBounceAreaFrame() {
        // extend above the tableView
        bounceAreaView.frame = view.frame
        bounceAreaView.frame.origin.y = -bounceAreaView.frame.height
        bounceAreaView.frame.size.height += (tableHeaderView?.frame.height ?? 0)
    }

    private func updateAlphaValues(offset: CGFloat) {
        guard let tableHeaderView, let navBarHeight, navBarHeight > 0 else { return }

        // update tableHeaderView alpha if we haven't scrolled it away yet
        if offset < tableHeaderView.frame.maxY {
            setHeaderAlpha(to: 1 - offset / navBarHeight)
        }

        // correcting for the already scrolled distance (navBarHeight)
        let newOffset = offset - navBarHeight
        setNavBarAlpha(to: newOffset / navBarHeight)
    }

    private func setHeaderAlpha(to alpha: CGFloat) {
        let alpha = min(max(alpha, 0), 1)
        tableHeaderView?.alpha = alpha
        gradientView.alpha = alpha
    }

    private func setNavBarAlpha(to alpha: CGFloat) {
        let alpha = min(max(alpha, 0), 1)
        navigationItem.standardAppearance?.backgroundColor = .accountBackground.withAlphaComponent(alpha)
        summaryView.contentView.alpha = alpha
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension PortfolioScreenVC {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y + view.safeAreaInsets.top
        updateAlphaValues(offset: contentOffset)
        let gradientOffset = (tableHeaderView?.frame.height ?? 0) + contentOffset * 0.5
        gradientView.setGradientOffset(gradientOffset)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.numberOfItems(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath]
        let cell = tableView.dequeue(PortfolioItemCell.self, for: indexPath)!

        cell.configure(with: model)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath]
        presenter.didSelectItem(withID: model.id)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath]

        presenter.willShowLogoForItem(withID: model.id) { image in
            guard let image else { return }
            (cell as? PortfolioItemCell)?.setLogo(image: image)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            let title = dataSource.sections[section].header,
            let headerView = tableView.dequeue(AssetKindHeaderView.self)
        else { return nil }

        headerView.setTitle(title)
        return headerView
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let adjustedFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: C.UI.defaultFont)
        let scaleFactor = adjustedFont.pointSize / C.UI.defaultFont.pointSize
        return scaleFactor * C.UI.defaultRowHeight
    }
}

// MARK: - ApplicationObserving

extension PortfolioScreenVC: ApplicationObserving {
    func willResignActive(notification: Notification) {
        guard view.window != nil else { return }
        presenter.viewDisappearing()
    }

    func didBecomeActive(notification: Notification) {
        guard view.window != nil else { return }
        presenter.viewAppearing()
    }
}

// MARK: - PortfolioScreenView

extension PortfolioScreenVC: PortfolioScreenView {
    func updateItemList(with newDataSource: DataSource<PortfolioItemCellModel>, portfolioSummary: PortfolioSummary) {
        isShowingError = false
        summaryView.update(with: portfolioSummary)
        dataSource = newDataSource
        tableView.reloadData()
    }

    func showErrorMessage(message: String) {
        isShowingError = true
        tableView.backgroundView = PortfolioErrorView(errorMessage: message) { [weak presenter] in
            presenter?.didTapRefreshButton()
        }
    }

    func showDialog(dialog: Dialog) {
        present(dialog.make(.actionSheet), animated: true)
    }
}

// MARK: - Constants

private extension C.UI {
    static let defaultFont = UIFont.systemFont(ofSize: 17)
    static let defaultRowHeight: CGFloat = 292 / 3
    static let logoutButtonTitle = String(localized: "PortfolioScreenVC.logoutButtonTitle", defaultValue: "Выйти")
    static let menuTitle = String(localized: "PortfolioScreenVC.menuTitle", defaultValue: "Меню")
}
