# documentation:
# https://github.com/plataformatec/simple_form
# https://github.com/plataformatec/simple_form/blob/master/lib/generators/simple_form/templates/config/initializers/simple_form.rb
SimpleForm.setup do |config|
  config.wrappers :default, class: :input, hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    b.use :html5
    b.use :placeholder

    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    ## Inputs
    b.use :label_input
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
    b.use :error, wrap_with: { tag: :span, class: :error }
  end

  config.boolean_label_class = 'checkbox'
  config.boolean_style = :nested
  config.button_class = 'btn'
  config.default_wrapper = :default
  config.error_notification_class = 'error_notification'
  config.error_notification_tag = :div

  # The asterisk for required fields is added by CSS - make it simply be the label text
  config.label_text = ->(label, _required, _explicit_label) { label }

  config.browser_validations = true
end
