require 'telegram/bot'
class WebhookController < ApplicationController
  def receive
    return if params[:message].nil?

    # trovo le coordinate
    if !params[:message][:text].nil?
      if params[:message][:text].start_with?("/start") 
        search = nil 
      else
        result = Geocoder.search(params[:message][:text])
        search = result.try(:first).try(:coordinates)
      end
    elsif !params[:message][:location].nil?
      search = [params[:message][:location][:latitude], params[:message][:location][:longitude]]
    else
      search = nil
    end

    Telegram::Bot::Client.run(ENV["TOKEN"]) do |bot|
      if search.nil?
        if params[:message][:text].start_with?("/start")
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: "Benvenuto in questo bot! Usa l'opzione che trovi nel menu con la graffetta (📎) per inviarmi la tua posizione o inserisci un indirizzo o una città.")
        elsif params[:message][:chat][:type] == "private"
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: "Inserisci un indirizzo o invia le tue coordinate usando la graffetta.")
        end
      else 
        items = []
        Item.near(search, 30, units: :km).first(50).each do |item|
          items.push("<b><i>#{item.title}</i></b>\n#{item.url}")
        end
        if items.empty?
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: "Nessun risultato trovato.")
        else
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: items.join("\n---\n").prepend("<b>Risultati trovati</b>\n\n"), parse_mode: :HTML)
        end
      end
    end

    respond_to do |format|
      format.json { render json: {"done" => true}, status: 200}
    end
  end
end
