require 'openssl'

class Chiper

    ALGORITHM = 'AES-256-CBC'
    SECRET_KEY = "1234"
    # 要検討：
    #   ivをランダムにするとより安全（かもしれない）？
    #   同じ文字列を暗号化しても結果が異なる→運用めんどいかも
    # FIXED_IV = "0123456789abcdef"←うまくいかねぇ16バイトならいいんじゃないのか？

    # https://noknow.info/it/ruby/implemented_encryption_decryption_using_openssl?lang=ja
    # [Ruby] OpenSSLを利用して暗号 / 復号するライブラリを実装してみた

    # Encrypt using CBC mode.
    def self.encode(plainText, secretKey=SECRET_KEY)
        cipher = ::OpenSSL::Cipher.new(ALGORITHM)
        cipher.encrypt
        iv = cipher.random_iv
        cipher.key = paddingKey(secretKey, 32)
        encrypted = cipher.update(plainText) + cipher.final
        return (encrypted + iv).unpack('H*')[0]
    end


    # Decrypt using CBC mode.
    def self.decode(cipherText, secretKey=SECRET_KEY)
        cipher = ::OpenSSL::Cipher.new(ALGORITHM)
        cipher.decrypt
        rawData = [cipherText].pack('H*')
        cipher.iv = rawData.slice(rawData.length - 16, 16)
        cipher.key = paddingKey(secretKey, 32)
        return cipher.update(rawData.slice(0, rawData.length - 16)) + cipher.final
    end

    # 0 Padding with 32 length or cut out until 32 length.
    def self.paddingKey(key, length)
        return key if key.length == length
        return key.slice(0, length) if key.length > length

        (length - key.length).times { key << '0' }
        return key
    end

end

if __FILE__ == $0 then

    encripts = [
        "c4f2117c478c714b114f33c143d463bf3f176b98df440ef65676e399359ae5ce59f529cfb1f1b0b0f0202ae69c796928450439b7761f2b1d877b2ffd9a309892",
        "b1f27afe71d280f3294f27c8f75952da594c6adf26ba74c95ef8a00ca015bed865b80a8cb191850efb84a20cdc7122b05467a4f68f2badb04aa3063f5520b5d0",
        "ab9b0a977c0652a19ded0c903e657b40f324d5405d8012abee435a3dce6e54f96cf7ac86883cac41b6f2adfc27f4ecee633e56555fac92d4599cc33e69e30d22",
        "ca0247626f8dae05da0f18098bfdb7d63466e23855d2dfb273337f59ad1a2b38ddc09eaf2e94e7ede9de09cba04cc17afcbd486b63ad009cc38045737c290cb3",
    ]
    p encripts.map{|e| Chiper.decode(e) }
    # ["U80092846061fcf297e22fd39a2cb2e6d", "U80092846061fcf297e22fd39a2cb2e6d", "U0d115aa4f9fde50fe20fe7e9804d11b1", "Ubc7f5ce08baa77ba9a4743a418d450ef"]

end