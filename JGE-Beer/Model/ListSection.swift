//
//  ListSection.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/26.
//

import RxDataSources

struct ListSection {
  let header: String
  var items: [Beer]
}

extension ListSection: SectionModelType {
  init(original: ListSection, items: [Beer]) {
    self = original
    self.items = items
  }
}
