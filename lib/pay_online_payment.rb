# Super class for PayOnline payment classes
class PayOnlinePayment
	def get_private_key(service_id)
		Service.find(service_id).vendor.psk
	end

	def get_public_key(security_key_string)
		# Digests security key string to send in request params
		Digest::MD5.hexdigest(security_key_string)
	end
end