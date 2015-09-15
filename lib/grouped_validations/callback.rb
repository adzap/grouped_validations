class ActiveSupport::Callbacks::Callback
  def callback_method
    chain_config[:callback_method]
  end
end