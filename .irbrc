require 'neuronet'

# IRB Tools
require 'irbtools/configure'
_ = Neuronet::VERSION.split('.')[0..1].join('.')
Irbtools.welcome_message = "### Neuronet(#{_}) ###"
require 'irbtools'
IRB.conf[:PROMPT][:Neuronet] = {
  PROMPT_I:    '> ',
  PROMPT_N:    '| ',
  PROMPT_C:    '| ',
  PROMPT_S:    '| ',
  RETURN:      "=> %s \n",
  AUTO_INDENT: true,
}
IRB.conf[:PROMPT_MODE] = :Neuronet
