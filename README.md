# Roulette strategy simulator

## 概要

カジノにおけるヨーロピアンルーレットのシミューレータを作成しました。

ルーレットをプレイするときには、ベッティングする金額と場所が重要です。自分が使用したベッティング場所の戦略とベッティング額の戦略を実行した際にシミュレーションします。

Webを探したところでは、このような目的を実現するプログラムやツールがなかったので作成してみました。

プログラミング言語はRubyを利用しています。DockerizedしてあるのでDockerを実行できる環境ですぐに利用可能です。

1日のプレイ回数を指定し、1日が終わったときの状態を評価する意図のプログラムになっています。標準では1日あたり360回プレイして、100日分のシミュレーションを行います。実行結果はグラフ付きのHTMLレポート `report.html` として出力されます。

![レポートの概要（主要指標と資金の推移）](docs/images/report-overview.jpg)

上の画像は `SEED=12345` で実行したときのレポートです。このレポートのHTMLは [v2.0.0 のリリース](https://github.com/matsubo/roulett-strategy-simulator/releases/tag/v2.0.0) からダウンロードできます。

## 要件

- Docker
- docker-compose


## セットアップ

```
% git clone git@github.com:matsubo/roulett-strategy-simulator.git
% cd roulett-strategy-simulator
% docker compose build
```


## Run

シミュレーションの実行

```
% docker compose run app bundle exec ruby main.rb
```


実行が完了すると `report.html` が出力され、ターミナルにはそのパスとシード値が表示されます。

```
Report written to report.html (seed 12345)
```

`report.html` をブラウザで開くと（macOSなら `open report.html`）、以下のグラフと表が確認できます（グラフの描画にChart.jsをCDNから読み込みます）。

- 主要指標（破産率、利益の出た日の割合、最終資金の中央値、1日あたりの平均損益、払い戻し率、最大ドローダウン）
- 資金の推移: 全日の5〜95パーセンタイル・25〜75パーセンタイルの帯と中央値。全日の推移線も切り替えて表示可能
- 最終資金の分布
- 破産せずにプレイを続けている日の割合の推移
- 外側ベットごとの成績（賭けた回数、勝率、賭け金、払い戻し、払い戻し率、最大賭け金）
- 日ごとの最大ドローダウンと最終資金の散布図
- 日ごとの台帳

### スクリーンショット

最終資金の分布と、破産せずにプレイを続けている日の割合

![最終資金の分布と生存率](docs/images/report-distribution.jpg)

外側ベットごとの成績

![ベットごとの成績](docs/images/report-bets.jpg)

日ごとの最大ドローダウンと最終資金

![最大ドローダウンと最終資金の散布図](docs/images/report-risk.jpg)

日ごとの台帳

![日ごとの台帳](docs/images/report-ledger.jpg)

### 結果を固定したい場合

パラメータを付けずに実行するとランダムにルーレットが実行されます。実行結果を一定にしたい場合は `SEED` 環境変数に数字を渡せばシードを固定できます。
ターミナルやレポートに表示されるシードの値を設定すれば前回と同じ実行結果になります。

```
% docker compose run -e SEED=12345 app bundle exec ruby main.rb
```

### スピンごとのログ

`LOG_LEVEL=debug` を指定すると、スピンごとの出目・賭け金・資金が標準エラーに出力されます。

```
% docker compose run -e LOG_LEVEL=debug app bundle exec ruby main.rb
```

### テスト

```
% docker compose run --rm app bundle exec rake test
```

## System Design

### 基本設計方針

- プレイする戦略はプログラムを変更して実行するように作ってあります。オリジナルの戦略を実行するためにはやはりプログラムを書かないと表現できないためです。
- ベッティングの戦略は抽象化してあるので、どの戦略を使うかを簡単に選択できます。
- オブジェクト指向で書いてあります。

## クラスの説明

- PlaySuite（main.rb）
  - シミュレータの実行を管理
- Roulette::Simulator::Account
  - 資金の口座
- Roulette::Simulator::BetData
  - ベットする場所を管理
- Roulette::Simulator::Player
  - 1日分のプレイを行い、結果を `DayOutcome` として返す。どのような戦略を取るかはここで決める。
- Roulette::Simulator::DayOutcome
  - 1日分の結果（スピンごとの資金、破産したスピン、ベットごとの集計）
- Roulette::Simulator::Statistics
  - 全日の結果から統計値（パーセンタイル、破産率、ドローダウンなど）を計算
- Roulette::Simulator::Reports::Html
  - 統計値をHTMLレポートとして出力
- Roulette::Simulator::Reward
  - 掛けた場所に対していくら払い出すかを管理
- Roulette::Simulator::Table
  - ルーレットのテーブルとその賭ける場所の名称を表現
- Roulette::Simulator::OutsideBet
  - 外側ベット（色、ロー/ハイ、偶数/奇数、ダズン、カラム）ごとに、どの数字がどのサイドか、配当がいくらかを表現
- Roulette::Simulator::StreakStrategy
  - 同じサイドが指定回数連続したら逆側に賭け、負けるたびに賭け金を（配当+1）倍にする戦略
- Roulette::Simulator::Decisions::*
  - ランダムに賭ける場所と金額を決める（現在は未使用）
