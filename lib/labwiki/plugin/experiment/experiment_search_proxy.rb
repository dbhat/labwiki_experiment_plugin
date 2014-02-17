require 'labwiki/plugin/experiment/experiment'
require 'labwiki/rack/search_handler'
require "em-synchrony"
require "em-synchrony/em-http"

module LabWiki::Plugin::Experiment
  class ExperimentSearchProxy
    def self.instance
      unless proxy = OMF::Web::SessionStore[self.to_s, :proxy]
        proxy = OMF::Web::SessionStore[self.to_s, :proxy] = self.new
      end
      proxy
    end

    def find(pattern, opts, wopts)
      unless @url
        js = wopts[:job_service]
        @url = "http://#{js[:host]}:#{js[:port] || 80}/jobs?"
      end

      opts[:mime_type] = 'text/ruby'
      files = OMF::Web::ContentRepository.find_files(pattern, opts)

      puts "FIND: '#{pattern}' - opts: #{opts}"

      if result = @results[pattern]
        if (Time.now - result[:time]) > 30
          # refresh
          @results.delete(pattern)
          result = nil
        end
      end

      unless result
        query(pattern)
        raise LabWiki::RetrySearchLaterException.new
      end
      experiments = result[:jobs].map do |r|
        {url: r["href"], name: r["name"], status: r['status'],
          mime_type: 'experiment', plugin: 'experiment'}
      end
      experiments.concat(files)
    end

    def query(pat)
      EventMachine.synchrony do
        begin
          resp = EventMachine::HttpRequest.new(@url).get(query: {pat: pat})
          unless (rcode = resp.response_header.status) == 200
            warn "Job search failed (#{rcode})- #{resp.response}"
          else
            reply = JSON.parse(resp.response)
            @results[pat] = {time: Time.now, jobs: reply}
            #p reply
          end

          #puts "RES: #{resp.methods.sort}"
          #puts "RES: #{resp.inspect}"
        rescue => ex
          warn "Exception while searching job service - #{ex}"
        end
      end
    end

    def initialize
      @results = {}
    end
  end
end
