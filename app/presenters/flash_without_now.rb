class FlashWithoutNow
  def show(flash, type, message)
    flash[type] = message
    return flash
  end
end
