シン空き家バンクUI検討
==

方針
--

* LINEBOT + (enquete system)


リンク
--

* [LINE Developers console](https://developers.line.biz/console/)
* [LINE アカウントマネージャ](https://manager.line.biz/)


起動方法（ローカル）
--

1. MessagingAPIチャネル作成
    * 以下を参考にLINEBOTを作成する
        * 【参考】[Ruby + SinatraでLINE Botを作ろう – Part 1](https://www.mizucoffee.com/archives/1076)
    * `.env`ファイルを作成する
        ```
        LINE_CHANNEL_ID=#チャネルID
        LINE_CHANNEL_SECRET=#チャネルシークレット
        LINE_CHANNEL_TOKEN=#チャネルアクセストークン（長期）
        ```
    * 「Webhook設定 - Webhook URL」にはあとでngrok出力URL（https）の末尾に`/callback`を付与
        * https://xxxxx.jp.ngrok.io/callback
1. サンプルプログラムのセットアップと起動
    ```sh
    $ bundle install # インストール
    #$ bundle exec ruby regist.rb # リッチメニュー登録→上手くいかないのでやめ
    $ bundle exec ruby app.rb -o 0.0.0.0 # ローカルサーバ起動
    ```
1. 公開（`ngrok`）
    * `.env`が正しく設定されていないと動かない！
        ```sh
        $ ngrok http 4567
        ngrok                                               (Ctrl+C to quit)
        Hello World! https://ngrok.com/next-generation

        Session Status    online
        Session Expires   1 hour, 58 minutes
        Terms of Service  https://ngrok.com/tos
        Version           3.0.6
        Region            Japan (jp)
        Latency           31ms
        Web Interface     http://127.0.0.1:4040
        Forwarding        https://xxxxx.jp.ngrok.io -> http://localhost:4567

        Connections       ttl     opn     rt1     rt5     p50     p90
                        0       0       0.00    0.00    0.00    0.00
        ```


調査
--

### 友達追加時の応答メッセージ

* LINEアカウントマネージャで定型文を応答
    * なぜか動いてない
    * Botモードだから？
* LINEBOTで定型文を応答
    * 未調査（たぶんいける

### ユーザIDの取得（解決

* Q: webhookへのリクエストにユーザIDが含まれるか？
* A: 含まれる（`events[n]->source[:userId]`）
* 解決する問題：
    * 個人情報を保持しなくてよい
    * アンケート（ヒアリング）と紐づけが必要
        * LINEのユーザID生のままではよろしくない？
        * 暗号化する？→LINEメッセージ送信時に生のユーザIDが必要なため

### DB代わりのアンケートシステム（解決

* 無料のアンケートシステム
* 引数で隠しパラメータを含めることが出来ること
    * ユーザに紐づけ
* 結果を保持してくれること
    * GoogleSpreadSheet書き込みでも良い

→[Googleフォームでできそう](https://blog.nakachon.com/2016/12/22/how-to-add-url-parameter-for-google-form/)

### DB抽出→LINE一斉送信

* DB抽出
    * DBでもスプレッドシートでも何とかなりそう
* LINE一斉送信
    * LINEユーザIDが必要
    * アンケートに入れておく
        * 外部に漏れても迷惑かからないように可逆暗号化しておくべき

### LINE:複数ユーザへのメッセージ送信（解決

* [マルチキャストメッセージ](https://developers.line.biz/ja/reference/messaging-api/#send-multicast-message)で実現する
* ↑`curl`サンプルがあるので、最初は手運用かな
* 指定するユーザIDはスプレッドシートに暗号化されている
    * 複合化は`chiper.rb`で行なえる、はず
    * できた（下記参照）
* 【課題・注意点】
    * 同時に送信できるユーザIDは500件
    * 同じユーザIDでも暗号化文字列が異なる？
        * 復号化すると同じになる不思議→ivがランダムだからだわ：要調査

```
curl -v -X POST https://api.line.me/v2/bot/message/multicast \
-H 'Content-Type: application/json' \
-H 'Authorization: Bearer {LINE_CHANNEL_TOKEN}' \
-H 'X-Line-Retry-Key: 2d931510-d99f-494a-8c67-87feb05e1594' \
-d '{
    "to": ["user_id(line)", ...],
    "messages":[
        {
            "type":"text",
            "text":"Hello, world1"
        },
        {
            "type":"text",
            "text":"Hello, world2"
        }
    ]
}'
```