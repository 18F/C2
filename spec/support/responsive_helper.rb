module ResponsiveHelper

  def resize_window_to_mobile
    resize_window_by([640, 480])
  end

  def resize_window_to_tablet
    resize_window_by([960, 640])
  end

  def resize_window_default
    resize_window_by([1024, 768])
  end

  def resize_window_large
    resize_window_by([1600, 768])
  end

  private

  def resize_window_by(size)
    Capybara.page.driver.browser.resize(size[0], size[1])
  end

end
