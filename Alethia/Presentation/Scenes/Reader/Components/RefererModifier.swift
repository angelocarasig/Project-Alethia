//
//  RefererModifier.swift
//  Alethia
//
//  Created by Angelo Carasig on 20/9/2024.
//

import Foundation
import Kingfisher

struct RefererModifier : AsyncImageDownloadRequestModifier {
    let referer: String
    
    func modified(for request: URLRequest, reportModified: @escaping (URLRequest?) -> Void) {
        var modifiedRequest = request
        modifiedRequest.setValue(referer, forHTTPHeaderField: "Referer")
        
        reportModified(modifiedRequest)
    }
    
    var onDownloadTaskStarted: ((Kingfisher.DownloadTask?) -> Void)?
}
