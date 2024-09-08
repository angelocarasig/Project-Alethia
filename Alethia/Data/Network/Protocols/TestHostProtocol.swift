//
//  TestHostProtocol.swift
//  Alethia
//
//  Created by Angelo Carasig on 4/9/2024.
//

import Foundation

protocol TestHostProtocol {
    func testHost(url: String) async throws -> Host
}
