# GitHub Actions の定義（未設置）

`.github/workflows/` へ置くと動く。このリポジトリへの初回 push では、GitHub App に
`workflows` 権限がないため `.github/workflows/*.yml` を含められず、ここに退避している。

```sh
mkdir -p .github/workflows
cp ci/ios-build.yml .github/workflows/
git add .github/workflows && git commit -m "CI を設置" && git push
```

- `ios-build.yml` … TestFlight 配信。下記 4 つの Secrets が必要で、`main` への push ごとに走る。

| Secret | 内容 |
| --- | --- |
| `APP_STORE_CONNECT_KEY_ID` | App Store Connect API キーの Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | AuthKey_\*.p8 の中身 |
| `APPLE_TEAM_ID` | チーム ID（86WNUS2875） |
