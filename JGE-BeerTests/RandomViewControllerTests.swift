//
//  RandomViewControllerTests.swift
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

class RandomViewControllerTests: XCTestCase {

  var viewModel: RandomViewModel!
  var disposeBag: DisposeBag!
  var scheduler: TestScheduler!
  var output: RandomViewModel.Output!

  override func setUpWithError() throws {
    viewModel = RandomViewModel()
    disposeBag = DisposeBag()
    scheduler = TestScheduler(initialClock: 0, resolution: 0.01)

    let buttonTrigger = scheduler.createHotObservable([.next(100, ())])
      .asDriver(onErrorJustReturn: ())

    let input = RandomViewModel.Input(provider: MoyaProvider<BeerAPI>(stubClosure: { _ in .immediate }), buttonTrigger: buttonTrigger)
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
      .next(100, Beer(id: 1, name: "Buzz", description: "A light, crisp and bitter IPA brewed with English and American hops. A small batch brewed only once.", imageURL: "https://images.punkapi.com/v2/keg.png"))
    ]
    
    XCTAssertEqual(observer.events, exceptEvents)
  }
}
