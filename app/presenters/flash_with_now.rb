class FlashWithNow
  def show(flash, type, message)
    flash.now[type] = message
    return flash
  end
end
