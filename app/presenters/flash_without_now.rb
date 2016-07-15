class FlashWithoutNow
  def show(flash, type, message)
    flash[type] = message
  end
end
