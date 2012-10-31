class Charger < Job

  def initialize(options)
    @task = [ options[:merchant], options[:operation] ].join ':'
  end

  def perform
    Battery.charge(@task)
  end

end