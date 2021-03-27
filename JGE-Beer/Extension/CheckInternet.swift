//
//  CheckInternet.swift
//  JGE-Beer
//
//  Created by GoEun Jeong on 2021/03/27.
//

import Foundation
import Network

@available(iOS 12.0, *)
class CheckInternet {
    static let shared = CheckInternet()
    
    let monitor = NWPathMonitor()
    
    func isInternet() -> Bool {
        var isOkay = true
        monitor.pathUpdateHandler = { path in
           if path.status == .satisfied {
            isOkay = true
           } else {
            isOkay = false
           }
           print(path.isExpensive)
        }
        return isOkay
    }
    
}
