require "openssl"
require "base64"

module SparkleAppcast
  class Signer
    attr_reader :private_key_path

    def initialize(private_key_path)
      @private_key_path = private_key_path
    end

    def sign(data)
      # Sparkle is signing SHA1 digest with DSA private key and encoding it in Base64.
      # See <https://github.com/sparkle-project/Sparkle/blob/master/bin/sign_update>.
      digest = OpenSSL::Digest::SHA1.digest(data)
      signature = private_key.sign(OpenSSL::Digest::SHA1.new, digest)
      Base64.strict_encode64(signature)
    end

    private

    def private_key
      @private_key ||= OpenSSL::PKey::DSA.new(File.binread(private_key_path))
    end
  end
end
