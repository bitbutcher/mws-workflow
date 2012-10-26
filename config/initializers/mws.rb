module Mws
  
  def self.connection
    @connection ||= Mws.connect(
      merchant: ENV['MWS_MERCHANT'], 
      access: ENV['MWS_ACCESS_TOKEN'], 
      secret: ENV['MWS_SECRET']
    )
  end

end