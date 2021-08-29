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
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: "Scopri con VeronicaRouteBot le veroniche nel raggio di 10 km: clicca sulla graffetta (📎) e scegli la tua posizione o inserisci una località.\nSe trovi una veronica segnalala qui https://veronicaroute.com/segnala-una-veronica-2/")
        elsif params[:message][:chat][:type] == "private"
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: "Inserisci un indirizzo/una città o invia le tue coordinate usando la graffetta (📎).")
        end
      else 
        items = []
        Item.near(search, 10, units: :km).first(20).each do |item|
          items.push("<b><i>#{item.title}</i></b>\n#{item.url}")
        end
        if items.empty?
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: "Nessun risultato trovato.")
        else
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: items.join("\n---\n").prepend("<b>Risultati trovati</b>\n\n"), parse_mode: :HTML, disable_web_page_preview: true)
        end
      end
    end

    respond_to do |format|
      format.json { render json: {"done" => true}, status: 200}
    end
  end
end
