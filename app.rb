#!/usr/bin/ruby

require 'rubygems'
require 'pi_piper'
require 'thin'
require 'sinatra/base'
require 'sinatra/sse'
require 'dht-sensor-ffi'

class EnvironmentServer < Sinatra::Base
  include Sinatra::SSE
  set :bind, '0.0.0.0'

  get '/' do
    erb :index
  end

  post '/led' do
    led_switch = params[:led]
    puts led_switch
    if led_switch == "true"
      led_pin.on
    else
      led_pin.off
    end
  end

  get '/events' do
    sse_stream do |out|
      EM.add_periodic_timer(3) do
        val = DhtSensor.read(4, 11)
        puts "temperature #{val.temp}"
        out.push :event => "temperature", :data => "#{val.temp}"
        sleep 0.01
        out.push :event => "humidity", :data => "#{val.humidity}"
      end
    end
  end

end

EnvironmentServer.run!
