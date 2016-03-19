class AttachmentDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  default_url_options[:host] = ::Rails.application.routes.default_url_options[:host]

  delegate_all

  def file_preview
    if file.content_type =~ /\Aimage/
      image_tag(
        object.url,
        alt: "",
        class: "image-with-border"
      )
    else
      link_text
    end
  end

  private

  def link_text
    I18n.t(
      "mailer.attachment_mailer.new_attachment_notification.attachment_cta",
      attachment_name: file.original_filename
    )
  end
end
