{schema,
  [
    {version, "0.1"},
    {default_field, "timestamp"},
    {default_op, "or"},
    {n_val, 3},
    {analyzer_factory, {erlang, text_analyzers, noop_analyzer_factory}}
  ],
  [
    {field, [{name, "type"}, {required, true}]},
    {field, [{name, "timestamp"},
             {analyzer_factory, {erlang, text_analyzers, integer_analyzer_factory}},
             {type, date},
             {required, true}]},

    % Skip anything we don't care about
    {dynamic_field, [{name, "*"},
                     {skip, true}]}
  ]
}.
