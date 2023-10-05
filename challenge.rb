require "json"
require "./company"
require "./user"

class Challenge
  def initialize
    set_companies
    set_users
    set_associations
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
    @companies = JSON.parse(companies_data).map { |company| Company.new(company) }
  end

  def set_users
    users_data = File.read("users.json")
    @users = JSON.parse(users_data).map { |user| User.new(user) }
  end

  def set_associations
    @companies.each do |company|
      company.users = @users.select { |user| user.company_id == company.id }
      company.users.each { |user| user.company = company }
    end
  end

  def write_output
    active_companies = @companies.select { |company| company.active_users.count > 0 }.sort_by { |company| company.id }

    File.write("output.txt", active_companies.map(&:display).join)
  end
end

Challenge.call
