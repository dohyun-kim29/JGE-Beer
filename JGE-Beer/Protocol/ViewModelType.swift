//
//  ViewModelType.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/26.
//

import Foundation

protocol ViewModelType {
  associatedtype Input
  associatedtype Output

  func transform(input: Input) -> Output
}
