
module LabWiki::Plugin
  module Experiment; end
end

require 'labwiki/plugin/experiment/experiment_widget'
require 'labwiki/plugin/experiment/renderer/experiment_setup_renderer'
require 'labwiki/plugin/experiment/renderer/experiment_running_renderer'

LabWiki::PluginManager.register :experiment, {
  :search => lambda do ||
  end,
  :selector => lambda do ||
  end,
  :on_session_init => lambda do
    #repo = OMF::Web::ContentRepository.register_repo(id, opts)
    #OMF::Web::SessionStore[:execute, :repos] << repo
    puts ">>>> EXPERIMENT NEW SESSION"
  end,
  :widgets => [
    {
      :name => 'experiment',
      :context => :execute,
      :priority => lambda do |opts|
        (opts[:mime_type].start_with? 'text/ruby') ? 500 : nil
      end,
      :widget_class => LabWiki::Plugin::Experiment::ExperimentWidget
    }
  ],
  :renderers => {
    :experiment_setup_renderer => LabWiki::Plugin::Experiment::ExperimentSetupRenderer,
    :experiment_running_renderer => LabWiki::Plugin::Experiment::ExperimentRunningRenderer
  },
#  :resources => File.dirname(__FILE__) + File.SEPARATOR + 'resource'
  :resources => File.dirname(__FILE__) + '/resource' # should find a more portable solution
}

