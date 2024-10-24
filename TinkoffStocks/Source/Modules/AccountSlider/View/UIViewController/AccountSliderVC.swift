//
//  AccountSliderVC.swift
//  T-Stocks
//
//  Created by sleepcha on 9/10/24.
//

import UIKit

// MARK: - AccountSliderVC

class AccountSliderVC: UIViewController {
    var presenter: AccountSliderPresenter!
    private lazy var ui = AccountSliderUI()

    private var dataSource: [AccountCellModel] = []

    override func loadView() {
        view = ui
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let index = ui.pageControl.currentPage
        ui.accountsCollectionView.contentOffset.x = CGFloat(index) * view.frame.width
        ui.accountsCollectionView.collectionViewLayout.invalidateLayout()
    }

    private func setupViews() {
        ui.accountsCollectionView.dataSource = self
        ui.accountsCollectionView.delegate = self
    }

    private func didSelect() {
//        presenter.didSelectAccount(withIndex: dataSource[ui.pageControl.currentPage].id)
        presenter.didSelectAccount(withIndex: ui.pageControl.currentPage)
    }
}

extension AccountSliderVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentAccountIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        ui.pageControl.currentPage = currentAccountIndex
        didSelect()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.inset(by: view.safeAreaInsets).size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        view.safeAreaInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        view.safeAreaInsets.left + view.safeAreaInsets.right
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AccountCell.self, for: indexPath)!

        cell.configure(with: dataSource[indexPath.row])
        cell.gainPeriodButtonTapHandler = { [presenter] in presenter?.didTapGainPeriodButton() }
        return cell
    }
}

// MARK: - AccountSliderView

extension AccountSliderVC: AccountSliderView {
    func updateAccountList(_ newDataSource: [AccountCellModel]) {
        dataSource = newDataSource
        ui.pageControl.numberOfPages = newDataSource.count
        ui.accountsCollectionView.reloadData()
        didSelect()
    }
}

extension UICollectionView {
    func update(onlyVisibleItem: Bool) {
        guard onlyVisibleItem else {
            reloadData()
            return
        }
        reloadItems(at: indexPathsForVisibleItems)
    }
}
