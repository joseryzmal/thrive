class Company
  attr_reader :id, :top_up
  attr_accessor :users

  def initialize(params)
    @id = params["id"]
    @name = params["name"]
    @top_up = params["top_up"] || 0
    @email_status = params["email_status"] || false
    @users = []
  end

  def users_emailed
    return [] unless @email_status
    active_users.select { |user| user.email_status }
  end

  def users_not_emailed
    active_users - users_emailed
  end

  def active_users
    users.select { |user| user.active_status }.each { |user| user.top_up_tokens }
  end

  def users
    @users.sort_by { |user| [user.last_name, user.first_name] }
  end

  def top_up
    return 0 if @top_up < 0
    @top_up
  end

  def total_top_ups
    return 0 if @top_up < 0
    active_users.count * @top_up
  end

  def display
    %{
  Company Id: #{id}
  Company Name: #{@name}
  Users Emailed: #{users_emailed.map(&:display_balance).join}
  Users Not Emailed: #{users_not_emailed.map(&:display_balance).join}
    Total amount of top ups for #{@name}: #{total_top_ups}
  }
  end
end
