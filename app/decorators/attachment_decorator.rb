class AttachmentDecorator < Draper::Decorator
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  delegate_all

  def file_preview
    if file.content_type =~ /\Aimage/
      image_tag(file.url, alt: "", class: "image-with-border")
    else
      link_to(file.original_filename, file.url)
    end
  end
end
