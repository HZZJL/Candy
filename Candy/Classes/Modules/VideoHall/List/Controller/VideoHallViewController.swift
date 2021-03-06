//
//  VideoHallViewController.swift
//  QYNews
//
//  Created by Insect on 2018/12/18.
//  Copyright © 2018 Insect. All rights reserved.
//

import UIKit

class VideoHallViewController: VMCollectionViewController<VideoHallViewModel> {

    // MARK: - Lazyload
    fileprivate lazy var topView = TopView(frame: CGRect(x: 0, y: topH, width: Configs.Dimensions.screenWidth, height: 44))

    fileprivate lazy var topH = (navigationController?.navigationBar.height ?? 0) + UIApplication.shared.statusBarFrame.size.height

    /// 搜索框
    private lazy var titleView = SearchTitleView(frame: CGRect(x: SearchTitleView.x, y: SearchTitleView.y, width: SearchTitleView.width, height: SearchTitleView.height))

    /// 添加到 collectionView 上的
    private lazy var filterView: FilterView = {

        let filterView = FilterView(frame: .zero)
        filterView.delegate = self
        return filterView
    }()

    /// 添加到 view 上的
    fileprivate lazy var animateFilterView: FilterView = {

        let animateFilterView = FilterView(frame: .zero)
        animateFilterView.isHidden = true
        animateFilterView.delegate = self
        return animateFilterView
    }()

    private var filterViewHeight: CGFloat = 0

    init() {
        super.init(collectionViewLayout: VideoHallFlowLayout())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animateFilterView.frame = CGRect(x: 0, y: -filterViewHeight, width: Configs.Dimensions.screenWidth, height: filterViewHeight)
        filterView.frame = CGRect(x: 0, y: -filterViewHeight, width: Configs.Dimensions.screenWidth, height: filterViewHeight)
    }

    override func makeUI() {
        super.makeUI()

        navigationItem.titleView = titleView

        collectionView.register(R.nib.videoHallListCell)
        collectionView.refreshFooter = RefreshFooter()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        view.addSubview(topView)
        view.addSubview(animateFilterView)
        collectionView.addSubview(filterView)
    }

    override func bindViewModel() {
        super.bindViewModel()

        titleView.beginEdit
        .asObservable()
        .subscribe(viewModel.input.searchTap)
        .disposed(by: rx.disposeBag)

        collectionView.rx.modelSelected(VideoHallList.self)
        .asObservable()
        .subscribe(viewModel.input.selection)
        .disposed(by: rx.disposeBag)

        // 刷新
        viewModel.output
        .filterViewHeight
        .drive(onNext: { [weak self] in
            self?.filterViewHeight = $0
            self?.collectionView.contentInset = UIEdgeInsets(top: $0, left: 0, bottom: 0, right: 0)
            self?.viewDidLayoutSubviews()
        })
        .disposed(by: rx.disposeBag)

        // 视频分类
        viewModel.output
        .categories
        .drive(filterView.rx.categories)
        .disposed(by: rx.disposeBag)

        viewModel.output
        .categories
        .drive(animateFilterView.rx.categories)
        .disposed(by: rx.disposeBag)

        // 某个分类下的数据
        viewModel.output
        .items
        .drive(collectionView.rx.items(cellIdentifier: R.reuseIdentifier.videoHallListCell.identifier,
                                       cellType: VideoHallListCell.self)) { collectionView, item, cell in
            cell.item = item
        }
        .disposed(by: rx.disposeBag)

        // 点击了筛选
        topView.rx.tap
        .bind(to: rx.filterTap)
        .disposed(by: rx.disposeBag)

        setUpEmptyDataSet()
    }
}

// MARK: - FilterViewProtocol
extension VideoHallViewController: FilterViewProtocol {

    func filterView(_ filterView: FilterView, didSelectAt row: Int, item: Int) {
        if filterView == self.filterView {
            animateFilterView.selItem(row: row, item: item)
        } else {
            self.filterView.selItem(row: row, item: item)
        }
    }

    func searchKey(_ key: String) {
        viewModel.input.searchKey.onNext(key)
    }
}

// MARK: - UICollectionViewDelegate
extension VideoHallViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let height = filterViewHeight
        let contentOffsetY = scrollView.contentOffset.y + height + topH
        filterView.y = -height + contentOffsetY - contentOffsetY * 0.3
        topView.alpha = scrollView.contentOffset.y <= (-height - topH) ? 0 : scrollView.contentOffset.y / contentOffsetY * 2
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        animateFilterView.isHidden = true
        animateFilterView.y = -filterViewHeight
    }
}

extension VideoHallViewController {

    override var verticalOffset: CGFloat {
        topH + 180
    }

    override var emptyDataSetDescription: String {
        R.string.localizable.videoHallFilterResultEmptyPlaceholder()
    }
}

// MARK: - Reactive-extension
extension Reactive where Base: VideoHallViewController {

    var filterTap: Binder<Void> {

        Binder(base) { vc, _ in

            vc.animateFilterView.isHidden = false
            UIView.animate(withDuration: 0.35, animations: {

                vc.topView.alpha = 0
                vc.animateFilterView.y = vc.topH
            })
        }
    }
}
