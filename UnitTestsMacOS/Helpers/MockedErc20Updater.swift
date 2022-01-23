//
//  MockedErc20Updater.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/23/22.
//

@testable import Portal
import Combine

struct MockedERC20Updater: IERC20Updater {
    var onTokensUpdate = PassthroughSubject<[Erc20TokenCodable], Never>()
}
