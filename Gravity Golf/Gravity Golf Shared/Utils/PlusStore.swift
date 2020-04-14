//
//  Store.swift
//  Magic
//
//  Created by Andrew Finke on 11/16/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import StoreKit

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // MARK: - Types -
    
    enum StoreError: Error {
        case unableToMakePayments
        case noProduct
    }
    
    // MARK: - Properties -
    
    private static let unlockLevelsIdentifier = "com.andrewfinke.space.golf.unlock-levels"
    
    private let queue = SKPaymentQueue.default()
    private var unlockLevelsProduct: SKProduct?
    private var purchaseHandler: ((_ result: Result<Bool, StoreError>) -> Void)?
    
    // MARK: - Initalization -
    
    override init() {
        super.init()
        queue.add(self)
        sync()
    }
    
    // MARK: - Helpers -
    
    func sync() {
        let request = SKProductsRequest(productIdentifiers: [
            Store.unlockLevelsIdentifier
        ])
        request.delegate = self
        request.start()
    }
    
    func restore() {
        queue.restoreCompletedTransactions()
    }
    
    func hasUnlockedAllLevels() -> Bool {
        return UserDefaults.standard.bool(forKey: Store.unlockLevelsIdentifier)
    }
    
    func purchaseUnlockLevels(completion: @escaping (_ result: Result<Bool, StoreError>) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(.unableToMakePayments))
            return
        }
        
        guard let unlockLevelsProduct = self.unlockLevelsProduct else {
            completion(.failure(.noProduct))
            return
        }
        
        self.purchaseHandler = completion
        let payment = SKPayment(product: unlockLevelsProduct)
        queue.add(payment)
    }
    
    // MARK: - SKProductsRequestDelegate -
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var unlockLevels: SKProduct?
        for product in response.products {
            if product.productIdentifier == Store.unlockLevelsIdentifier {
                unlockLevels = product
            } else {
                fatalError()
            }
        }
        self.unlockLevelsProduct = unlockLevels
    }
    
    // MARK: - SKPaymentTransactionObserver -
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                finish(transaction: transaction, success: true)
            case .failed:
                finish(transaction: transaction, success: false)
            case .restored:
                finish(transaction: transaction, success: true)
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
    
    // MARK: - Helpers -
    
    func finish(transaction: SKPaymentTransaction, success: Bool) {
        purchaseHandler?(.success(success))
        purchaseHandler = nil
        queue.finishTransaction(transaction)
        UserDefaults.standard.set(success, forKey: Store.unlockLevelsIdentifier)
    }
}
