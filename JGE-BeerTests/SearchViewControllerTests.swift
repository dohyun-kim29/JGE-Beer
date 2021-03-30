//
//  SearchViewControllerTests.swift
//  JGE-BeerTests
//
//  Created by GoEun Jeong on 2021/03/30.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest
import Moya

@testable import JGE_Beer

class SearchViewControllerTests: XCTestCase {

  var viewModel: SearchViewModel!
  var disposeBag: DisposeBag!
  var scheduler: TestScheduler!
  var output: SearchViewModel.Output!

  override func setUpWithError() throws {
    viewModel = SearchViewModel()
    disposeBag = DisposeBag()
    scheduler = TestScheduler(initialClock: 0, resolution: 0.01)

    let searchTrigger = scheduler.createHotObservable([.next(100, "3")])
      .asDriver(onErrorJustReturn: "0")

    let input = SearchViewModel.Input(provider: MoyaProvider<BeerAPI>(stubClosure: { _ in .immediate }), searchTrigger: searchTrigger)
    output = viewModel.transform(input: input)
  }

  // MARK: - RxTest

  func testIndicatorEvents() throws {
    let observer = scheduler.createObserver(Bool.self)

    output.isLoading
      .drive(observer)
      .disposed(by: disposeBag)

    scheduler.start()

    let exceptEvents: [Recorded<Event<Bool>>] = [
      .next(0, false),
      .next(100, true),
      .next(100, false)
    ]

    XCTAssertEqual(observer.events, exceptEvents)
  }

  func testUserData() throws {
    let observer = scheduler.createObserver(Beer?.self)

    output.beer
      .map({ $0.first })
      .bind(to: observer)
      .disposed(by: disposeBag)

    scheduler.start()

    let exceptEvents: [Recorded<Event<Beer?>>] = [
      .next(0, nil),
      .next(100, Beer(id: 3, name: "Berliner Weisse With Yuzu - B-Sides", description: "Japanese citrus fruit intensifies the sour nature of this German classic.", imageURL: "https://images.punkapi.com/v2/keg.png"))
    ]
    
    XCTAssertEqual(observer.events, exceptEvents)
  }
}
