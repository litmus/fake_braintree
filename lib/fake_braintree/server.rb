require 'capybara'
require 'capybara/server'
require 'rack/handler/thin'

class FakeBraintree::Server
  def boot
    with_thin_runner do
      server = Capybara::Server.new(FakeBraintree::SinatraApp)
      server.boot
      ENV['GATEWAY_PORT'] = server.port.to_s
    end
  end

  private

  def with_thin_runner
    default_server_process = Capybara.server
    Capybara.server do |app, port|
      p = fork {
        Rack::Handler::Thin.run(app, :Port => port)
      }
      ENV['BRAINTREE_PROCESS'] = p.to_s
      Process.detach(p)
    end
    yield
  ensure
    Capybara.server(&default_server_process)
  end
end
