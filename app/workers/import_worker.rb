class ImportWorker
  include Sidekiq::Worker

  def perform(*args)
    response = HTTParty.get("https://clicart.it/giacomo/db-x-bot.xlsx")

    file = Tempfile.new
    file.binmode
    file.write(response.body)
    file.rewind

    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)

    @items = []
  
    xlsx.sheet(0).each(title: "title", url: "url", lat: "long", long: "lat") do |row|
      @items.push(row.merge({created_at: DateTime.now, updated_at: DateTime.now}))
    end

    Item.delete_all

    ActiveRecord::Base.connection.reset_pk_sequence!(Item.table_name)

    Item.insert_all(@items)
  end
end
