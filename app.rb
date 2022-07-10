require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
Dotenv.load
require_relative "./chiper.rb"

TITLE = "シン空き家バンクPJ"
PARAMKEY_USERID = "${USER_KEY}"
URL_FORM = "https://docs.google.com/forms/d/e/1FAIpQLSevg1gp7mOtauYtZOhFXnen918UQYGlJE3QP8RYwlo43bMozg/viewform?usp=pp_url&entry.675700530=#{PARAMKEY_USERID}"
URL_OLDHOUSE_EXPLAIN = "https://chie-no-wa.org/"

get '/' do
    "Hello world!"
end

def client
    @client ||= Line::Bot::Client.new { |config|
        config.channel_id = ENV["LINE_CHANNEL_ID"].chomp
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"].chomp
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"].chomp
    }
end
def button_message user_id
    {
        "type": "template",
        "altText": "This is a buttons template",
        "template": {
            "type": "buttons",
            # "thumbnailImageUrl": "https://example.com/bot/images/image.jpg",
            # "imageAspectRatio": "rectangle",
            # "imageSize": "cover",
            # "imageBackgroundColor": "#FFFFFF",
            "title": TITLE,
            "text": "希望条件を入力すると、希望に近い物件やイベントの情報が届きます。",
            "actions": [
                { "type": "uri", "label": "もっと詳しく", "uri": URL_OLDHOUSE_EXPLAIN },
                {
                    "type": "uri", "label": "条件を入力する",
                    "uri": URL_FORM.gsub(PARAMKEY_USERID, Chiper.encode(user_id))
                }
            ]
        }
    }
end

post '/callback' do
    body = request.body.read
    puts body
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
        error 400 do 'Bad Request' end
    end

    events = client.parse_events_from(body)
    events.each do |event|
        event_hash = event.to_hash
        #TODO: Line::Bot::Event::Follow
        #TODO: Line::Bot::Event::UnFollow
        if event.is_a?(Line::Bot::Event::Message)
            if event.type === Line::Bot::Event::MessageType::Text
                user_id = event_hash["source"]["userId"]
                puts message = button_message(user_id)
                client.reply_message(event['replyToken'], message)
            end
        end
    end
    200
end