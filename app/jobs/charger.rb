class Charger < Job

  def initialize(options)
    @device = [ options[:operation], options[:merchant] ].join ':'
  end

  def perform
    Battery.charge(@device)
  end

end