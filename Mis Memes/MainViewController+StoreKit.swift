//
//  MainViewController+StoreKit.swift
//  Mis Memes
//
//  Created by Christyan Duarte on 11/29/18.
//  Copyright © 2018 Making your app. All rights reserved.
//
import StoreKit

extension MainViewController: SKProductsRequestDelegate {
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func requestProducts() {
        let ids: Set<String> = ["premium"]
        let productsRequest = SKProductsRequest(productIdentifiers: ids)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.premiumProduct = response.products.first
    }
    
    func buyPremium() {
        let alertViewController = showBuyConfirmationDialog(message: NSLocalizedString("premium_message", comment: ""), title: NSLocalizedString("premium_title", comment: "")) { response  in
            if response {
                guard let product = self.premiumProduct else { return }
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            } else {
                return
            }
        }
        present(alertViewController, animated: true, completion: nil)
    }
    
}

extension MainViewController: SKPaymentTransactionObserver {
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        let productID = notification.object as? String
        if let productID = productID, productID == "premium" {
            isPremium = true
            selectImage()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if !isPremium {
            buyPremium()
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            showAlertDialog(message: localizedDescription, title: NSLocalizedString("appname", comment: ""), controller: self)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        UserDefaults.standard.set(true, forKey: "premium")
        NotificationCenter.default.post(name: .MisMemesPurchaseNotification, object: identifier)
        selectImage()
    }
    
}
