# Implements payment process for 'auth' or 'rebill' payment type where 3ds authorization is needed.

class TdsPayment < PayOnlinePayment
	def initialize(md, pares) 
		# gets transaction id, pd parameter, account id
		@id, @pd, @account_id = md.split(';')
		@pares = pares
		@po_root_url = "https://secure.payonlinesystem.com/payment/transaction/auth/3ds/"
		@vendor = get_vendor
		@merchant_id = get_merchant_id
		@psk = get_private_key
		@user_id = get_user_id
		@auth_token = get_auth_token
	end

	def pay
		TdsWorker.perform_async(@po_root_url, request_params, @auth_token)
	end

protected

	def request_params
		# Payment request params.
		# Security key is based on digested request param string including private security key.
		# Uses get_private_key and get_public_key from super class.
		security_key_string = "MerchantId=#{@merchant_id}&TransactionId=#{@id}&PARes=#{@pares}&PD=#{@pd}&PrivateSecurityKey=#{@psk}"
		"MerchantId=#{@merchant_id}&TransactionId=#{@id}&PARes=#{@pares}&PD=#{@pd}&SecurityKey=#{get_public_key(security_key_string)}&ContentType=xml&user_id=#{@user_id}"
	end

	def get_vendor
		Account.find(@account_id).service.vendor
	end

	def get_private_key
		@vendor.psk
	end

	def get_merchant_id
		@vendor.merchant_id
	end

	def get_user_id
		Account.find(@account_id).user_id
	end

	def get_auth_token
		User.find(@user_id).authentication_token
	end

end