//
//  DetailViewModel.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/30.
//

import RxSwift
import RxCocoa
import Moya

class DetailViewModel: ViewModelType {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - ViewModelType
    
    struct Input {
        let loadTrigger: Signal<Void>
        let provider: MoyaProvider<BeerAPI>
        let id: Int
    }
    
    struct Output {
        let beer: BehaviorRelay<[Beer]>
        let isLoading: Signal<Bool>
        let errorRelay: PublishRelay<Error>
    }
    
    func transform(input: Input) -> Output {
        let activityIndicator = ActivityIndicator()
        let beer = BehaviorRelay<[Beer]>(value: [])
        let errorRelay = PublishRelay<Error>()
        
        input.loadTrigger
            .asObservable()
            .flatMapLatest {
                input.provider.rx.request(.getDetailBeer(id: input.id))
                    .filterSuccessfulStatusCodes()
                    .map([Beer].self)
                    .trackActivity(activityIndicator)
                    .do(onError: { errorRelay.accept($0) })
                    .catchErrorJustReturn([])
            }
            .bind(to: beer)
            .disposed(by: disposeBag)
        
        return Output(beer: beer, isLoading: activityIndicator.asSignal(onErrorJustReturn: false), errorRelay: errorRelay)
    }
}
