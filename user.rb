class User
  attr_reader :id, :company_id, :last_name, :first_name, :email, :active_status, :email_status
  attr_accessor :company

  def initialize(params)
    @id = params["id"]
    @first_name = params["first_name"]
    @last_name = params["last_name"]
    @email = params["email"]
    @company_id = params["company_id"] || nil
    @email_status = params["email_status"] || false
    @active_status = params["active_status"] || false
    @tokens = params["tokens"] || 0
    @new_tokens = 0
    @company = nil
  end

  def top_up_tokens
    @new_tokens = @tokens + company.top_up if company && active_status
  end

  def display_balance
    %{
    #{last_name}, #{first_name}, #{email}
      Previous Token Balance, #{@tokens}
      New Token Balance #{@new_tokens}}
  end
end
