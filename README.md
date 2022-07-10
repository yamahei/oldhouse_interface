シン空き家バンクUI検討
==

方針
--

* LINEBOT + (enquete system)

起動方法（ローカル）
--

1. インストール
    ```sh
    $ bundle install
    ```
2. ローカルサーバ起動
    ```sh
    $ bundle exec ruby app.rb -o 0.0.0.0
    ```
3. 公開（`ngrok`）
    ```sh
    $ ngrok http 80
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
4. MessagingAPI（LINEBOT）チェンネル作成、WebhookURL登録
    * 以下を参考にLINEBOTを作成する
      * 【参考】[Ruby + SinatraでLINE Botを作ろう – Part 1](https://www.mizucoffee.com/archives/1076)
    * 「Webhook設定 - Webhook URL」にはngrok出力URL（https）の末尾に`/callback`を付与
      * https://xxxxx.jp.ngrok.io/callback


調査
--

### 友達追加時の応答メッセージ

* LINEアカウントマネージャで定型文を応答
    * なぜか動いてない
* LINEBOTで定型文を応答
    * 未調査

### ユーザIDの取得

* Q: webhookへのリクエストにユーザIDが含まれるか？
* A: 含まれる（`events[n]->source[:userId]`）
* 解決する問題：
    * 個人情報を保持しなくてよい
    * アンケート（ヒアリング）と紐づけが必要
        * LINEのユーザID生のままではよろしくない？
        * 暗号化する？→LINEメッセージ送信時に生のユーザIDが必要なため


### DB代わりのアンケートシステム

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
