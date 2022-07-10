require 'openssl'

class Chiper

    ALGORITHM = 'AES-256-CBC'
    SECRET_KEY = "1234"

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

    u1 = "U80092846061fcf297e22fd39a2cb2e6d"
    e1 = "c4f2117c478c714b114f33c143d463bf3f176b98df440ef65676e399359ae5ce59f529cfb1f1b0b0f0202ae69c796928450439b7761f2b1d877b2ffd9a309892"

    u2 = Chiper.decode(e1)
    e2 = Chiper.encode(u1)

    u3 = Chiper.decode(e2)

    p [u1==u2, u2==u3, e1==e2]
    p ({
        "u1": u1, "u2": u2, "u3": u3,
        "e1": e1, "e2": e2,
    })

    p Chiper.decode("invalid-text")
end