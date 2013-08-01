require 'prax/http'

module Prax
  class Response
    include HTTP
    include Timeout

    attr_reader :socket

    def initialize(socket)
      @socket = socket
      parse_response
    end

    def parse_response
      timeout(60) { parse_http_headers if @status_line = socket.gets }
    end

    def proxy_to(io)
      io.write "#{@status_line}\r\n"
      headers.each { |header, value| io.write "#{header}: #{value}\r\n" }
      io.write "\r\n"
      IO.copy_stream socket, io, content_length
      io.flush
    rescue Errno::EPIPE, Errno::ECONNRESET
    end
  end
end