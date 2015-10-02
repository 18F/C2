# create the Bootstrap input group component
# http://getbootstrap.com/components#input-groups
# https://github.com/plataformatec/simple_form#custom-inputs
class CurrencyInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    merged_input_options.reverse_merge!(step: 0.01)

    input = @builder.number_field(attribute_name, merged_input_options)
    currency_tag = template.content_tag(:div, '$', class: 'input-group-addon')
    input.prepend(currency_tag)

    template.content_tag(:div, input, class: 'input-group')
  end
end
