import StoreKit
import SwiftUI

/// Pro（買い切り）の土台。商品が登録されれば購入導線が出る。
///
/// - 商品 ID: `com.shodai4.frameroompreview.pro`（App Store Connect で登録する）
/// - 購入状態は UserDefaults に控え、起動のたびに StoreKit の権利と突き合わせる。
final class ProStore: ObservableObject {
    static let productID = "com.shodai4.frameroompreview.pro"
    private static let defaultsKey = "proUnlocked"

    @Published private(set) var isPro: Bool
    @Published private(set) var product: Product?
    @Published private(set) var message: String?
    @Published private(set) var isPurchasing = false

    init() {
        isPro = UserDefaults.standard.bool(forKey: Self.defaultsKey)
    }

    /// 権利の確認と商品情報の取得。広告の表示可否に関わるので起動時に 1 回呼ぶ。
    func load() async {
        await refreshEntitlements()
        product = try? await Product.products(for: [Self.productID]).first
    }

    func purchase() async {
        guard let product, !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    setPro(true)
                    message = nil
                } else {
                    message = "購入を確認できませんでした。"
                }
            case .userCancelled:
                message = nil
            case .pending:
                message = "購入の承認待ちです。"
            @unknown default:
                message = nil
            }
        } catch {
            message = "購入できませんでした。時間をおいてお試しください。"
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func refreshEntitlements() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                unlocked = true
            }
        }
        setPro(unlocked)
    }

    private func setPro(_ value: Bool) {
        isPro = value
        UserDefaults.standard.set(value, forKey: Self.defaultsKey)
    }
}
