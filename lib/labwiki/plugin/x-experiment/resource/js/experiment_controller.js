L.provide('LW.plugin.experiment.controller', ['#LW.init'], function () {

  if (typeof(LW.plugin.experiment) == "undefined") LW.plugin.experiment = {};

  LW.plugin.experiment.controller = function(opts) {

    function ctxt() {};

    ctxt.submit = function(form_el, fopts ) {
      function get_value(name, def_value) {
        var e = form_el.find('td.' + name).children();
        var v = e.val();
        if (v == "") v = e.text();
        if (v == "") v = def_value;
        return v;
      }

      var opts = {
        action: 'start_experiment',
        col: 'execute',
        widget_id: fopts.widget_id,
        name: get_value('propName', fopts.name),
        script: fopts.script,
        slice: get_value('propSlice', fopts.slice),
        gimi_exp: get_value('propExperiment', fopts.experiment)
      };

      var found_exp = exps.findWhere({name: opts.gimi_exp});
      if (typeof(found_exp) != "undefined") {
        opts.irods_path = found_exp.get('path');
      }
      //var pv = opts.properties = {};
      opts.properties = _.map(fopts.properties, function(prop, index) {
        var val = get_value('prop' + index, prop['default']);
        return {name: prop.name, value: val, comment: prop.comment};
      });

      LW.execute_controller.refresh_content(opts, 'POST');
    }

    return ctxt;
  };
})
