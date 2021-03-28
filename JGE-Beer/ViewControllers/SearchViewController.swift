//
//  SearchViewController.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import SnapKit

class SearchViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let randomView = BeerView()
    private var viewModel: SearchViewModel?
    
    private let searchBar = UISearchBar()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationTitle()
        bindViewModel()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationTitle() {
        self.navigationItem.titleView = searchBar
//        let searchController = UISearchController(searchResultsController: nil)
//        searchBar
//        searchController.searchBar = searchBar
//        searchController.searchBar.placeholder = "Search ID"
//        self.navigationItem.searchController = searchController
        self.navigationItem.title = "ID 검색"
        self.navigationItem.accessibilityLabel = "맥주 ID 검색"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupSubview() {
        view.backgroundColor = .white
        view.addSubview(randomView)
        
        randomView.snp.makeConstraints {
            $0.top.equalTo(view.layoutMarginsGuide)
            $0.size.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        viewModel = SearchViewModel()
        
        print(searchBar.rx.text.orEmpty)
        
        let searchTrigger = Driver<String>.merge(searchBar.rx.text.orEmpty.debounce(RxTimeInterval.microseconds(5), scheduler: MainScheduler.instance).distinctUntilChanged().asDriver(onErrorJustReturn: "0"))
        
        let input = SearchViewModel.Input(provider: MoyaProvider<BeerAPI>(),
                                          searchTrigger: searchTrigger)
        
        let output = viewModel?.transform(input: input)
        
        output?.beer
            .subscribe(onNext: { [weak self] beer in
                self?.randomView.configure(with: beer.first ?? Beer(id: 0, name: "", description: "", imageURL: "https://via.placeholder.com/150"))
                self?.setupSubview()
            })
            .disposed(by: disposeBag)
        
        //        output?.isLoading
        //            .filter { !$0 }
        //            .drive(refreshControl.rx.isRefreshing)
        //            .disposed(by: disposeBag)
        
        output?.errorRelay
            .subscribe(onNext: { [weak self] error in
                self?.showErrorAlert(with: error.localizedDescription)
            }).disposed(by: disposeBag)
    }
}
