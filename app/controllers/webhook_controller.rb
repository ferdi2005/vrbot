require 'telegram/bot'
class WebhookController < ApplicationController
  def receive
    return if params[:message].nil?

    # trovo le coordinate
    if !params[:message][:text].nil?
      params[:message][:text].start_with?("/start") ? search = nil : search = params[:message][:text]
    elsif !params[:message][:location].nil?
      search = [params[:message][:location][:latitude], params[:message][:location][:longitude]]
    else
      search = nil
    end

    Telegram::Bot::Client.run(ENV["TOKEN"]) do |bot|
      if search.nil?
        if params[:message][:text].start_	with?("/start")
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: "Benvenuto in questo bot! Usa l'opzione che trovi nel menu con la graffetta (📎) per inviarmi la tua posizione o inserisci un indirizzo.")
        elsif params[:message][:chat][:type] == "private"
          bot.api.send_message(chat_id: params[:message][:chat][:id], text: "Inserisci un indirizzo o invia le tue coordinate usando la graffetta.")
        end
      else 
        items = []
        Item.near(search, 30, units: :km).each do |item|
          items.push("<b>#{item.title}</b>\n#{item.url}")
        end
        bot.api.send_message(chat_id: params[:message][:chat][:id], text: items.join("\n---"))
      end
    end
  end
end
