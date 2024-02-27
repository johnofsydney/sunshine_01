require 'csv'

class ImportsController < ApplicationController
  before_action :authenticate_user!
  layout -> { ApplicationLayout }

  def annual_associated_entity
    render Imports::AnnualAssociatedEntityView.new
  end

  def index
    return unless current_user

    render Imports::AnnualDonorForm.new
  end

  def annual_donor_upload
    return unless current_user

    file = params['project']['filename'].tempfile

    csv = CSV.read(file, headers: true)
    csv.each do |row|
      donation_date = Date.new( "20#{row['Financial Year'].last(2)}".to_i, 6, 30) # saves bothering about the date format
      financial_year = Dates::FinancialYear.new(donation_date)

      transfer = Transfer.find_or_create_by(
        giver: Donor::RecordDonation.call(row["Donor Name"]),
        taker: RecordTransferTaker.call(row["Donation Made To"]),
        effective_date: financial_year.last_day, # group all donations for a financial year. There are too many otherwise.
        transfer_type: 'donation',
        evidence: 'https://transparency.aec.gov.au/AnnualDonor',
      )

      transfer.data ||= {}
      transfer.data[:donation_date] = {
        donation_date: {
          giver: Donor::RecordDonation.call(row["Donor Name"]),
          taker: RecordTransferTaker.call(row["Donation Made To"]),
          effective_date: financial_year.last_day, # TODO: use the real donation date
          transfer_type: 'donation',
          evidence: 'https://transparency.aec.gov.au/AnnualDonor',
          amount: row['Amount'].to_i,
        }
      }

      transfer.amount += row['Amount'].to_i

      Rails.logger.info "#{params['project']['filename']} || Transfer: #{transfer.inspect}"
      transfer.save
    end

    redirect_to groups_path
  end

  def people_upload
    return unless current_user

    file = params['project']['filename'].tempfile

    csv = CSV.read(file, headers: true)
    csv.each do |row|
      person = Person.find_or_create_by(name: row['Name'].titleize)

      person.save
    end

    redirect_to people_path
  end

  def groups_upload
    return unless current_user

    file = params['project']['filename'].tempfile

    csv = CSV.read(file, headers: true)
    csv.each do |row|
      group = Group.find_or_create_by(name: row['Name'].titleize)

      group.save
    end

    redirect_to groups_path
  end

  def infer_date(row)
    begin
      Date.parse(row['Date'])
    rescue => exception
      Date.new( "20#{row['Financial Year'].last(2)}".to_i, 6, 30)
    end
  end
end

