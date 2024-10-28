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

    private var feedback: UISelectionFeedbackGenerator!
    private var dataSource: [AccountCellModel] = []
    private var currentAccountIndex: Int = 0 {
        didSet { ui.pageControl.currentPage = currentAccountIndex }
    }

    override func loadView() {
        view = ui
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        feedback = UISelectionFeedbackGenerator()
        setupViews()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ui.accountsCollectionView.contentOffset.x = CGFloat(currentAccountIndex) * view.frame.width
        ui.accountsCollectionView.collectionViewLayout.invalidateLayout()
    }

    private func setupViews() {
        ui.accountsCollectionView.dataSource = self
        ui.accountsCollectionView.delegate = self
    }

    private func didSelectAccount() {
        guard !dataSource.isEmpty else { return }
        presenter.didSelectAccount(withID: dataSource[currentAccountIndex].id)
    }
}

extension AccountSliderVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        feedback.prepare()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newAccountIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
        guard newAccountIndex != currentAccountIndex else { return }

        currentAccountIndex = newAccountIndex
        feedback.selectionChanged()
        didSelectAccount()
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
        didSelectAccount()
        ui.spinner.stopAnimating()
    }
}
