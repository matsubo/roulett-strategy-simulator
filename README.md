# Roulette strategy simulator

## 概要

カジノにおけるヨーロピアンルーレットのシミューレータを作成しました。

ルーレットをプレイするときには、ベッティングする金額と場所が重要です。自分が使用したベッティング場所の戦略とベッティング額の戦略を実行した際にシミュレーションします。

Webを探したところでは、このような目的を実現するプログラムやツールがなかったので作成してみました。

プログラミング言語はRubyを利用し、グラフ化にはGnuplotを利用しています。DockerizedしてあるのでDockerを実行できる環境ですぐに利用可能です。

1日のプレイ回数を指定し、1日が終わったときの状態を評価する意図のプログラムになっています。プログラムの実行が完了すると以下のグラフが出力されます。横軸がプレイ回数、縦軸が資金量です。それぞれの線は1日分のプレイを意味しています。

グラフでは1日あたり360回プレイして、100日分のシミュレーションを行った結果です。


![result](https://user-images.githubusercontent.com/98103/200162790-ff4136e5-4267-4ecd-b087-c14df768bfed.png)

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


1日分の実行ごとに以下の統計情報が出力されます。

```
Draw request: 360 # プレイ予定回数
Draw executed: 360 # 実際にプレイした回数（途中で資金がなくなったらプレイできない）
Max bet: 24 # 最大ベット数
Bet count: 37 # 何回プレイに参加したか
Bet ratio: 10.278% # 何回プレイに参加したか/プレイ回数
Credit: 225 # 最終残高
Absolute Drawdown: 77.778%　# 資金の最大落ち込み率
PL(%): 12.5% # 資金の増減割合
Win: 18 # ベット金額より賞金が上回ったプレイ
Lose: 19 # ベット金額より賞金が下回ったプレイ
Won(%): 48.649 % # 勝つ割合
Seed: 9674385 # 乱数のシード値
```


シミュレーション全体が完了したときに以下の統計情報が出力されます。
```
Bankrupt: 16 # 残高が0を下回る回数
Bankrupt rate: 16.0%　# 残高が0を下回る確率
```


### 結果を固定したい場合

パラメータを漬けずに実行するとランダムにルーレットが実行されます。デバッグをするときに実行結果を一定にしたい場合は `SEED` 環境変数に数字を渡せばシードを固定できます。
シミュレーションを実行した後に出力されるシードの値を設定すれば前回と同じ実行結果になります。


```
% docker-compose run app bundle exec ruby main.rb

```



```
% docker-compose run app bundle exec ruby main.rb
```


## System Design

### 基本設計方針

- プレイする戦略はプログラムを変更して実行するように作ってあります。オリジナルの戦略を実行するためにはやはりプログラムを書かないと表現できないためです。
- ベッティングの戦略は抽象化してあるので、どの戦略を使うかを簡単に選択できます。
- オブジェクト指向で書いてあります。

## クラスの説明

- Roulette::Simulator::PlaySuite
  - シミュレータの実行を管理
- Roulette::Simulator::Account
  - 資金の口座
- Roulette::Simulator::BetData
  - ベットする場所を管理
- Roulette::Simulator::Player
  - どこにいくら賭けるかというプレイを行う管理。どのような戦略を取るかはここで決める。
- Roulette::Simulator::Record
  - 過去に出た数字を記録
- Roulette::Simulator::Reward
  - 掛けた場所に対していくら払い出すかを管理
- Roulette::Simulator::Table
  - ルーレットのテーブルとその賭ける場所の名称を表現
- Roulette::Simulator::Decisions::*
  - 賭ける場所と金額を決める
