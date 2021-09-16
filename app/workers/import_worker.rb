require 'csv'
class ImportWorker
  include Sidekiq::Worker

  def perform(*args)
    response = HTTParty.get("https://www.clicart.it/giacomo/dBase/Files/Main_DB_Bot.csv")

=begin    
    file.binmode
    file.write(response.body)
    file.rewind

    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx) 
  
    @items = []
  
    xlsx.sheet(0).each(title: "title", url: "url", lat: "long", long: "lat") do |row|
=end

    @items = []
    
    CSV.parse(response.body, :col_sep => "|", headers: true) do |row|
      # Latitudine e longitudine sono invertite nel file di partenza
      @items.push({title: row["title"], url: row["url"], long: row["lat"].gsub(",", "."), lat: row["long"].gsub(",", ".")}.merge({created_at: DateTime.now, updated_at: DateTime.now}))
    end

    Item.delete_all

    ActiveRecord::Base.connection.reset_pk_sequence!(Item.table_name)

    Item.insert_all(@items)
  end
end
