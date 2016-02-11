class CsvUserImporter
  attr_accessor :first_name_col, :last_name_col, :email_col

  def initialize(csv_path, client)
    @csv = CSV.read(csv_path, headers: true)
    @client = client
    headers = @csv.headers()
    self.first_name_col = headers.find {|h| h.downcase.include? "first"}
    self.last_name_col = headers.find {|h| h.downcase.include? "last"}
    self.email_col = headers.find {|h| h.downcase.include? "email"}
  end

  def process_rows
    if !first_name_col || !last_name_col || !email_col
      raise "Couldn't determine one or more of first name, last name, email: #{@csv.headers()}"
    end

    @csv.each do |row|
      email = row[email_col]
      if email.blank?
        warn "Email is empty: " + row.inspect
      else
        User.for_email(email).update(   # for_email will standardize
          first_name: row[first_name_col].try(:titleize),
          last_name: row[last_name_col].try(:titleize),
          client_slug: @client
        )
      end
    end
  end
end
