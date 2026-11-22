# App Store 提出用メタデータ — 額と壁

App Store Connect にそのまま貼れる形でまとめた。字数は実測値（全角1文字＝1文字で計算）。
最終更新 2026-11-23 ／ 対象バージョン 1.0（ビルド番号は CI の `github.run_number`）。

## 1. 基本情報

| 項目 | 値 |
| --- | --- |
| ホーム画面の表示名 | 額と壁 |
| App Store のアプリ名 | 額と壁（3文字／上限30） |
| Bundle ID | `com.shodai4.frameroompreview` |
| App Store Connect の Apple ID | 6837950059 |
| バージョン | 1.0 |
| 対応 | iPhone（iOS 17.0 以上）・縦向きのみ・iPad 非対応 |
| 価格 | 無料（広告あり） |
| アプリ内課金 | 広告非表示の買い切り `com.shodai4.frameroompreview.pro`（コード側は実装済み・App Store Connect への商品登録は未了） |
| 対応言語 | 日本語のみ |
| カテゴリ | プライマリ：グラフィック＆デザイン ／ セカンダリ：写真＆ビデオ |
| 年齢制限 | 4+（全年齢） |
| 端末の許可 | 写真（`NSPhotoLibraryUsageDescription`・PhotosPicker）／カメラ（`NSCameraUsageDescription`）／写真への追加のみ（`NSPhotoLibraryAddUsageDescription`） |

## 2. App Store に貼るテキスト

### アプリ名（30文字以内）
```
額と壁
```

### サブタイトル（30文字以内）
```
作品を壁にかけた姿を実寸で確かめる
```
（17文字）

### プロモーションテキスト（170文字以内・審査なしで更新できる）
```
作品の写真を壁にかけ、額縁とマットを選んで仕上がりを確かめる。F0〜F20 の号数から実寸を出し、壁の縮尺に合わせて置けます。保存は 1:1 と 4:5。
```
（77文字）

### 概要（4000文字以内）
```
作品の写真を壁にかけ、額縁とマットを選んで、飾った姿を確かめるアプリです。

■ 号数から実寸を出す
F0〜F20 の号数から仕上がりの寸法を出し、壁の縮尺に合わせて実寸どおりに置きます。マット幅と額縁の見付け幅を足した外寸で計算するので、額に入れたあとの大きさがそのまま分かります。

■ 額縁とマット
額なし・木枠・ウォルナット・金縁・アルミ黒の5種、マットは なし／細30mm／標準60mm／広100mm。壁は白壁・木目・モルタル・暗室に加えて、自分の部屋の写真も使えます。

■ 光と影
接地した濃い影と、壁に広がる淡い影の2層を、額縁の厚みに合わせて描きます。額縁は画像素材に頼らず、面の勾配と稜線で質感を作っています。

■ 書き出して共有
壁ごと 1:1（2048px）または 4:5（1638×2048px）で写真に保存できます。展示の案内や、額装を頼むときの見本に。

■ 端末のなかだけで
作品と部屋の写真は、端末のなかだけで扱います。外部へ送ることはありません（通信は広告の読み込みのみ）。

※ iPhone（iOS 17.0 以上）・縦向き。
```
（484文字）

### キーワード（100文字以内・カンマ区切り・スペースなし）
```
額縁,額装,マット,号数,展示,画廊,絵画,飾る,インテリア,アトリエ,作品
```
（38文字）

キーワードの考え方：アプリ名とサブタイトルに入っている語（額と壁／作品を壁にかけた姿を実寸で確かめる）は重複しても検索対象になるため、ここでは**入っていない語**を優先した。「額縁」「額装」「号数」を軸に、展示・飾る場面の語を足した。

## 3. URL

| 項目 | URL |
| --- | --- |
| サポートURL（必須） | https://shodai4.com/apps/frame-room-preview/support.html |
| プライバシーポリシーURL（必須） | https://shodai4.com/apps/frame-room-preview/privacy.html |
| マーケティングURL（任意） | https://shodai4.com/apps/frame-room-preview/ |
| サポートの入口（アプリのページ） | https://shodai4.com/apps/frame-room-preview/ |

3つとも公開済み（2026-11-23 に 200 OK を確認）。

## 4. 年齢制限（App の年齢制限）

- 全年齢（4+）。暴力・性的表現・ギャンブル・ホラー・医薬品・ユーザー生成コンテンツ・位置情報の共有はいずれも「なし」。
- 広告はプレビューの外、画面下部の帯に Google AdMob のバナーを表示する（内容は Google の広告ネットワークの審査を通ったもの）。

写真は利用者が選んだものだけを端末内で扱い、共有機能はない。

## 5. App のプライバシー（栄養ラベル）

アプリ本体は何も収集しない。広告SDK（Google Mobile Ads）分だけを、サードパーティの広告目的として申告する。

| データの種類 | 収集 | 使途 | トラッキング |
| --- | --- | --- | --- |
| 識別子（端末ID） | する（Google Mobile Ads SDK） | サードパーティの広告 | しない |
| 使用状況データ（広告の表示・反応） | する（Google Mobile Ads SDK） | サードパーティの広告 | しない |
| ユーザーのコンテンツ（作品・部屋の写真） | しない | 端末内のみ | — |
| 診断 | しない | — | — |

- 「トラッキング」はすべて**しない**（ATT を要求しておらず、`PrivacyInfo.xcprivacy` も `NSPrivacyTracking=false`）。App Store Connect では「データをトラッキングに使用していますか」に **いいえ**。
- 提出前に Google の開示（<https://policies.google.com/technologies/partner-sites>）と AdMob SDK のデータ開示を照合し、過不足がないか最終確認する。

## 6. App Review 担当者向けメモ（Review Notes）

英日どちらも貼れるようにしてある。ASC の Review Notes は英語を推奨。

### English

```
No account or sign-in is required. Artwork and room photos are chosen with the system photo picker or taken with the camera; the app reads only those images and never asks for full photo-library access. Rendered previews are saved with add-only photo access (NSPhotoLibraryAddUsageDescription).

Everything (rendering, frame drawing, shadows, export) runs on the device. The app works offline; the only network traffic is the Google Mobile Ads banner. No App Tracking Transparency request; the privacy manifest declares no tracking.

To reach the core feature: tap 作品を置く to pick an artwork, then use the 壁／額／寸法／仕上 strips to change the wall, frame, size and finish, and 保存 to export.
```

### 日本語（控え）

```
ログイン不要。作品・部屋の写真は写真選択画面かカメラから読み、ライブラリ全体へのアクセスは求めません。書き出しは「追加のみ」の権限で保存。描画はすべて端末内、通信は広告のみ、ATTは要求せず。
```

## 7. スクリーンショット

- 必須：iPhone 6.9インチ（1290×2796px または 1320×2868px）。3〜10枚。
- 任意：iPhone 6.5インチ（1284×2778px）。iPad は非対応なので不要。
- 1枚目でアプリの核心が分かる画面を出す（起動 → 「作品を置く」→ 壁／額／寸法／仕上を変更 → 「保存」）。
- 端末の枠やキャプションを載せる場合も、実際のアプリ画面をそのまま使う（合成した偽のUIは不可）。
- 撮影は実機または iOS 17 以降のシミュレータ。作品写真を先に用意し、壁・額・マットの組み合わせが分かる1枚を1枚目にする。

## 8. 提出前チェックリスト

- [ ] App Store Connect にアプリレコードがある（Apple ID 6837950059）／Bundle ID `com.shodai4.frameroompreview`
- [ ] バージョン 1.0 に、CI がアップロードしたビルドを選択
- [ ] サポートURL・プライバシーポリシーURL が 200 で開く
- [ ] 「App のプライバシー」を第5節のとおり入力
- [ ] 年齢制限を 4+ に設定
- [ ] カテゴリを第1節のとおり設定
- [ ] スクリーンショットを 6.9インチで3枚以上
- [ ] 広告の本番IDへの差し替え（下記「未対応」を参照）
- [ ] アプリ内課金を出す場合は商品登録と審査提出、出さない場合は導線が「準備中」で押せないことを確認
- [ ] 輸出コンプライアンス：`ITSAppUsesNonExemptEncryption=false` 済み（追加質問なし）
- [ ] 審査用の連絡先メールと電話を記入

## 9. 未対応・提出前に判断がいること

1. **広告IDが Google のテスト用IDのまま**（`Sources/Views/BannerAdView.swift` の `adUnitID` と `Info.plist` の `GADApplicationIdentifier` が `ca-app-pub-3940256099942544` 系）。このまま審査に出すと広告はテスト広告のままで、収益も出ない。本番のアプリID・ユニットIDへ差し替えるか、いったん広告を外して出すかを決める。差し替えは Swift 側の変更なので、このタスクでは触っていない。
2. **アプリ内課金（広告非表示）が ASC 未登録**。商品を作らないまま提出すると、アプリ内の「広告を消す」が「準備中」で押せない状態になる。審査で「機能していない課金導線」と見られる可能性があるため、商品登録して提出するか、導線ごと外すかを決める。
3. **6本同時提出のスパム判定（ガイドライン4.3）**。同じ開発者から同じ分野のアプリをまとめて出すため、機能の違いが伝わるよう、概要とレビューメモで「何をするアプリか」を明確にしている。スクリーンショットもアプリごとに別の画面にすること。
4. **`PrivacyInfo.xcprivacy` は同梱済み**（追跡なし・UserDefaults の利用理由 CA92.1）。

## 10. 審査で聞かれやすい点と回答

| 想定される指摘 | 回答 |
| --- | --- |
| カメラ／写真を何に使うのか | 作品をその場で撮るため。撮った画像は端末内で扱う。 |
| 通信はあるのか | 広告の読み込みのみ。作品・部屋の写真、書き出した画像は送らない。 |
| 広告はどこから出ているのか | プレビューの外、画面下部の AdMob バナー。 |
| データはどこに保存されるのか | 端末内のみ。書き出した画像は写真アプリへ。アプリ内に残るのは購入状態だけ。 |
| 似たアプリが複数ある（4.3） | それぞれ目的が異なる（明暗を見る／配色を逆算する／額装を確かめる／構図を決める／号数と送料を調べる／乾燥日数を見積もる）。画面構成もデータも別で、共通のコードベースは使っていない。 |
