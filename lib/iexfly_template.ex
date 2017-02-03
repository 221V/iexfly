defmodule Iexfly.Template do
  
  #777
  
  require EEx # you have to require EEx before using its macros outside of functions
  
  EEx.function_from_file :def, :template_getpost_cat, "lib/templates/getpost_cat.eex", [:cat_id]
  EEx.function_from_file :def, :template_show_dog, "lib/templates/show_dog.eex", [:dog_id]
  EEx.function_from_file :def, :template_twice_1st, "lib/templates/twice_1st.eex", [:first_id, :second_id, :second_part]
  EEx.function_from_file :def, :template_twice_2nd, "lib/templates/twice_2nd.eex", [:second_value]
  
  #:erlydtl.compile_file('lib/templates/dtl_1st.dtl', :dtl_1st, [{:out_dir, 'deps/erlydtl/ebin'}])
  :erlydtl.compile('lib/templates/dtl_1st.dtl', :dtl_1st, [{:out_dir, 'deps/erlydtl/ebin'}])
  :erlydtl.compile('lib/templates/dtl_2nd.dtl', :dtl_2nd, [{:out_dir, 'deps/erlydtl/ebin'}, {:auto_escape, :false}])
  
end
