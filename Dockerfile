# syntax=docker/dockerfile:1

###############
# Build Stage #
###############
FROM swift:6.0 AS builder
WORKDIR /app

# Swift Package Manager のファイルをコピーして依存関係を解決
COPY Package.* ./
RUN swift package resolve

# ソースコードをすべてコピー
COPY . .

# リリースビルド（生成される実行ファイル名は Package.swift の products 設定に合わせる）
RUN swift build -c release --product ProjectRulesIO

#################
# Runtime Stage #
#################
# 軽量なイメージを利用（ここでは Swift の slim イメージを利用していますが、必要なランタイムライブラリがない場合は適宜 ubuntu 等に変更してください）
FROM swift:6.0-slim
WORKDIR /app

# ビルドステージからバイナリをコピー
COPY --from=builder /app/.build/release/ProjectRulesIO .
# Public フォルダもコピーする
COPY --from=builder /app/Public ./Public
# Vapor はデフォルトで環境変数 PORT が存在する場合そのポートでリッスンするようになっています。
# 必要に応じて環境変数を設定してください
ENV PORT=8080

# Docker コンテナ内で外部からアクセス可能にするため、ホスト名は 0.0.0.0 でリッスンするようにします。
# Vapor の設定であれば production ビルド時は自動的に 0.0.0.0 を利用する場合が多いですが、
# 明示的に設定したい場合は、アプリケーション側で hostname を 0.0.0.0 に設定してください。

EXPOSE 8080

# コンテナ起動時に実行されるコマンド
CMD ["./ProjectRulesIO"]
