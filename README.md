# 額と壁

作品の写真を壁にかけ、額縁とマットを選び、仕上がりを写真として書き出す iOS アプリ。

号数（F0〜F20）から仕上がり寸法を出し、壁の縮尺に合わせて実寸どおりに置く。
F0 は小さく、F20 は大きい。額縁は画像素材を使わず、面の勾配・稜線・溝の重なりで質感を作る。
画面はアイボリー（`#F9F8F5`）と墨（`#1A1A1B`）、寸法は等幅で組む。

## 画面

- 上部：壁と作品。ピンチで拡大縮小（×0.6〜×1.6）。作品がないときは壁の上に白い枠と「作品を置く」。
- 下部：キャプション（号数・mm・アスペクト比）、`壁 / 額 / 寸法 / 仕上 / 保存` の文字だけの区切り、その下に選択肢。
- 最下部：AdMob バナー（テスト ID）。プレビューの外の独立した帯に置くので、プレビューにも書き出しにも重ならない。

## 機能

| 区分 | 内容 |
| --- | --- |
| 作品 | `PhotosPicker` で読み込み（表示は長辺 1200px に縮小）、カメラ撮影、傾き ±5 度、四隅インセット 0〜45% |
| 壁 | 白壁・木目・モルタル・暗室（すべて描画）＋自分の部屋の写真 |
| 額縁 | 額なし（側面塗り）・木枠・ウォルナット・金縁・アルミ黒。マット幅は なし／細 30mm／標準 60mm／広 100mm |
| 号数 | F0・F1・F2・F3・F4・F5・F6・F8・F10・F12・F15・F20 と、アスペクト比の表示 |
| 影 | 接地した濃い影と、壁に広がる淡い影の 2 層。額縁の厚みで濃さを変える |
| 書き出し | 壁ごと 1:1（2048px）／4:5（1638×2048px）で描画し、写真に保存（追加のみの権限） |

## 寸法の決め方

1. 仕上がり外寸（mm）＝ 号数の長辺・短辺 ＋ 2 ×（マット幅 ＋ 額縁の見付け幅）。
2. プレビュー領域の高さを壁の 900mm とみなして pt に換算する。
3. 画面の 86% を超える場合は縮めて収める。ピンチの拡大には 96% の上限を置く。
4. 書き出しも同じ関数に書き出し画素数を渡すだけなので、プレビューと仕上がりの比率が一致する。

| 例（プレビュー 390×500pt） | 外寸 | 画面上 |
| --- | --- | --- |
| F10・マット標準・木枠 | 706 × 631mm | 335.4pt 幅（作品 251.8pt、額縁 13.3pt） |
| F0・マットなし・額なし | 186 × 146mm | 103.3pt 幅（画面の 26%） |
| F20・マット広・金縁 | 1011 × 890mm | 335.4pt に縮む |

## 構成

| パス | 内容 |
| --- | --- |
| `project.yml` | XcodeGen 定義（Bundle ID `com.shodai4.frameroompreview`、iOS 17.0+、Team `86WNUS2875`、GoogleMobileAds を SPM で） |
| `Sources/FrameRoomPreviewApp.swift` | エントリポイント。AdMob の初期化、Pro の読み込み |
| `Sources/Theme.swift` | 色・書体・罫線 |
| `Sources/Models/` | 号数、額縁、マット、壁、比率、裁ち落とし、寸法計算（UI 非依存） |
| `Sources/Studio/StudioModel.swift` | 状態、写真の読み込み、書き出し |
| `Sources/Studio/ProStore.swift` | Pro 買い切りの土台（StoreKit 2） |
| `Sources/Services/PhotoLoader.swift` | 縮小読み込み・裁ち落とし・平均色 |
| `Sources/Services/ExportRenderer.swift` | `ImageRenderer` で壁ごと高解像度に描く |
| `Sources/Services/PhotoSaver.swift` | 写真への保存（`.addOnly`） |
| `Sources/Views/` | プレビュー、壁の描画、額縁の断面、操作パネル、カメラ、バナー |
| `Resources/Info.plist` | 写真・カメラの利用目的、暗号化の申告、AdMob アプリ ID |
| `Resources/PrivacyInfo.xcprivacy` | プライバシーマニフェスト（UserDefaults: CA92.1） |
| `scripts/` | 検証（計算・構文）、アイコン生成、TestFlight 配信 |
| `ci/ios-build.yml` | GitHub Actions の定義（`.github/workflows/` へ置く。理由は `ci/README.md`） |

## 検証

```sh
python3 scripts/verify-logic.py      # 寸法・割り付け・書き出し・裁ち落とし 39 件
python3 scripts/check-syntax.py      # Swift 全 21 ファイルの構文（tree-sitter）
python3 scripts/generate_icon.py     # アイコン（1024px）
```

`verify-logic.py` は Swift 側と同じ式を Python に写して突き合わせる。直近の結果:

- 号数の外寸（F10 標準 木枠 706×631mm）、F20 標準 金縁 1011×890mm
- 作品＋マット＋額縁＝外寸（誤差 0.01pt 以下）
- 大きい号数は 86% に縮み、拡大しても 96% を超えない
- 1:1 = 2048 角、4:5 = 1638×2048
- 2048px の書き出しで作品は約 1206px（4096px 読み込みで足りる）
- 裁ち落としの矩形（1200×900 に対し 120×72・1020×828）、上下左右 45% は 80% に縮める

コンパイルは GitHub Actions の `iOS TestFlight` で確かめる。

## ビルド

```sh
xcodegen generate
xcodebuild build -project FrameRoomPreview.xcodeproj -scheme FrameRoomPreview \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

## TestFlight 配信

`.github/workflows/ios-build.yml`（`ci/ios-build.yml` を設置）を置くと、`main` への push で
`iOS TestFlight` が `scripts/ci-testflight.sh` を実行する。ビルド番号は `github.run_number`。

アーカイブは署名なしで作り、埋め込みフレームワーク（GoogleMobileAds など SPM のバイナリ）に
ad-hoc の仮署名を付けてから、`-exportArchive` で配布用に署名する。署名なしのまま書き出すと
`ITMS-90035 Invalid Signature` で弾かれるため。

必要なリポジトリ Secrets:

| 名前 | 内容 |
| --- | --- |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect API キーの Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | AuthKey_\*.p8 の中身 |
| `APPLE_TEAM_ID` | チーム ID |

## 広告と Pro

- バナーは AdMob のテスト ID（アプリ ID `ca-app-pub-3940256099942544~1458002511`、枠 `ca-app-pub-3940256099942544/2934735716`）。本番で差し替える。
- Pro 買い切り（300〜500 円を想定）の土台を `ProStore` に用意した。商品 `com.shodai4.frameroompreview.pro` を App Store Connect に登録すると保存の画面に導線が出て、購入後はバナーが消える。商品が未登録のあいだは何も表示しない。

## 書き出しの画質とメモリ

- 表示は長辺 1200px の縮小画像、書き出しは元データから 4096px を上限に読み直す。
- 2048px の書き出しで作品が占めるのは約 1206px なので、4096px の読み込みで引き伸ばしは起きない。
- 生成は `ImageRenderer`（`scale = 1`、`isOpaque`）を `autoreleasepool` で囲み、描画後にすぐ手放す。
