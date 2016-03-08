class AttachmentDecorator < Draper::Decorator
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  delegate_all

  def file_preview
    if file.content_type =~ /\Aimage/
      link_to image_tag(file.url, alt: "", class: "image-with-border"), file.url 
    else
      return '<br><table class="button"><tr><td>' + link_to('Click to view ' + file.original_filename, file.url) + '</td></tr></table>'
    end
  end
end
