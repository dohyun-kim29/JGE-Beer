//
//  UIKit+Alert.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/26.
//

import UIKit

extension UIViewController {
  internal func showErrorAlert(with message: String) {
    let alert = UIAlertController(title: nil,
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok",
                                  style: .default))
    present(alert, animated: true)
  }
}
