# Implements payment process for 'rebill' payment type. It means user chooses saved card,
# sending rebill anchor (stored in db) to PO web service.

class RebillPayment < PayOnlinePayment
	def initialize(service_id, amount, order_id, user_id, merchant_id, rebill_anchor, auth_token)
		@service_id = service_id
		@amount = amount
		@order_id = order_id
		@user_id = user_id
		@merchant_id = merchant_id
		@rebill_anchor = rebill_anchor
		@auth_token = auth_token
		@po_root_url = "https://secure.payonlinesystem.com/payment/transaction/rebill/"
	end

	def pay
		PayOnlineWorker.perform_async(@po_root_url, request_params, @auth_token)
	end

protected

	def request_params
		# Payment request params.
		# Security key is based on digested request param string including private security key.
		# Uses get_private_key and get_public_key from super class.
		security_key_string = "MerchantId=#{@merchant_id}&RebillAnchor=#{@rebill_anchor}&OrderId=#{@order_id}&Amount=#{@amount}&Currency=RUB&PrivateSecurityKey=#{get_private_key(@service_id)}"
		"MerchantId=#{@merchant_id}&RebillAnchor=#{@rebill_anchor}&OrderId=#{@order_id}&Amount=#{@amount}&Currency=RUB&SecurityKey=#{get_public_key(security_key_string)}&ContentType=xml&user_id=#{@user_id}"
	end

end