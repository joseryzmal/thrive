require "json"

class Challenge
  # @note Can be used for specs
  attr_reader :companies_with_employees

  def initialize
    set_companies
    set_users
    set_companies_with_employees
  end

  def call
    write_output
  end

  def self.call
    new.call
  end

  private

  def set_companies
    companies_data = File.read("companies.json")
    @companies = JSON.parse(companies_data).sort_by { |company| company["id"] }
  end

  def set_users
    users_data = File.read("users.json")
    @users = JSON.parse(users_data).sort_by { |user| [user["last_name"], user["first_name"]] }
  end

  def set_companies_with_employees
    grouped_companies = @companies.each_with_object({}) do |company, output|
      output[company["id"]] = company
    end

    @companies_with_employees = @users.each_with_object({}) do |user, result|
      company_id = user["company_id"]
      emailed_key = if grouped_companies[company_id]["email_status"] && user["email_status"]
        :emailed
      else
        :not_emailed
      end

      result[company_id] ||= {}
      result[company_id][emailed_key] ||= []

      top_up = grouped_companies[company_id]["top_up"]
      top_up = 0 if top_up < 0

      if user["active_status"] && grouped_companies[company_id]
        user["new_tokens"] = user["tokens"] + top_up
        result[company_id][emailed_key] << user
      end
    end
  end

  def write_output
    content = @companies.map do |company|
      id, name, top_up = company.values_at("id", "name", "top_up")

      if @companies_with_employees[id]
        emailed_users = @companies_with_employees[id][:emailed] || []
        not_emailed_users = @companies_with_employees[id][:not_emailed] || []
      else
        emailed_users = []
        not_emailed_users = []
      end

      total_users = emailed_users.size + not_emailed_users.size
      next unless total_users > 0

      top_up = 0 if top_up < 0
      total_top_ups = total_users * top_up

      %{
  Company Id: #{id}
  Company Name: #{name}
  Users Emailed: #{display_users(emailed_users)}
  Users Not Emailed: #{display_users(not_emailed_users)}
    Total amount of top ups for #{name}: #{total_top_ups}}
    end

    File.write("output.txt", content.join("\n"))
  end

  def display_users(users)
    users
      .map do |user|
        %{
    #{user["last_name"]}, #{user["first_name"]}, #{user["email"]}
      Previous Token Balance, #{user["tokens"]}
      New Token Balance #{user["new_tokens"]}}
      end
      .join
  end
end

Challenge.call
