class ProcessController < ApplicationController

  def get_labs

    results = []

    patients = {}

    if !params[:id].blank?

      patient_orders = Result.by_npid.key(params[:id])

      patient_orders.each do |result|

        if patients[:national_patient_id].blank?

          patients[:national_patient_id] = {
              :national_patient_id => result[:patient][:national_patient_id],
              :patient => {
                  :patient_name => result[:patient][:patient_name],
                  :date_of_birth => result[:patient][:date_of_birth],
                  :gender => result[:patient][:gender]
              },
              :orders => {}
          }

        end

        order = {}

        if patients[:national_patient_id][:orders][result[:order][:accession_number]].blank?

          order = {
              :sample_type => result[:order][:sample_type],
              :who_ordered_test => result[:order][:who_ordered_test],
              :date_time => result[:order][:date_time],
              :sending_facility => result[:order][:sending_facility],
              :receiving_facility => result[:order][:receiving_facility],
              :reason_for_test => result[:order][:reason_for_test],
              :results => {}
          }

        else

          order = patients[:national_patient_id][:orders][result[:order][:accession_number]]

        end

        if !result[:order][:test_code].blank?

          order[:results][result[:order][:test_code]] = {
              :test_name => result[:order][:test_name],
              :result => result[:order][:result],
              :units => result[:order][:units],
              :reference_range => result[:order][:reference_range],
              :entered_by => result[:order][:entered_by],
              :location_entered => result[:order][:location_entered],
              :result_date_time => result[:order][:result_date_time],
              :status => result[:order][:status]
          }

        end

        patients[:national_patient_id][:orders][result[:order][:accession_number]] = order

      end

      patients.keys.each do |npid|

        results << patients[npid]

      end

    end

    render :text => results.to_json

  end

  def get_specific_labs

    results = []

    patients = {}

    if !params[:id].blank?

      patient_orders = Result.by_accession_number.key(params[:id])

      patient_orders.each do |result|

        if patients[:national_patient_id].blank?

          patients[:national_patient_id] = {
              :national_patient_id => result[:patient][:national_patient_id],
              :patient => {
                  :patient_name => result[:patient][:patient_name],
                  :date_of_birth => result[:patient][:date_of_birth],
                  :gender => result[:patient][:gender]
              },
              :orders => {}
          }

        end

        order = {}

        if patients[:national_patient_id][:orders][result[:order][:accession_number]].blank?

          order = {
              :sample_type => result[:order][:sample_type],
              :who_ordered_test => result[:order][:who_ordered_test],
              :date_time => result[:order][:date_time],
              :sending_facility => result[:order][:sending_facility],
              :receiving_facility => result[:order][:receiving_facility],
              :reason_for_test => result[:order][:reason_for_test],
              :results => {}
          }

        else

          order = patients[:national_patient_id][:orders][result[:order][:accession_number]]

        end

        if !result[:order][:test_code].blank?

          order[:results][result[:order][:test_code]] = {
              :test_name => result[:order][:test_name],
              :result => result[:order][:result],
              :units => result[:order][:units],
              :reference_range => result[:order][:reference_range],
              :entered_by => result[:order][:entered_by],
              :location_entered => result[:order][:location_entered],
              :result_date_time => result[:order][:result_date_time],
              :status => result[:order][:status]
          }

        end

        patients[:national_patient_id][:orders][result[:order][:accession_number]] = order

      end

      patients.keys.each do |npid|

        results << patients[npid]

      end

    end

    render :text => results.to_json

  end

  def create_or_update_labs

    source = params[:_json]

    source = JSON.parse(source) if source.class.to_s.downcase == "string"

    render :text => {"Error" => "Invalid Input"}.to_json and return if source.blank?

    result = []

    source.each do |patient|

      npid = patient["patient"]["national_patient_id"]

      patient_name = patient["patient"]["patient_name"]

      date_of_birth = patient["patient"]["date_of_birth"]

      gender = patient["patient"]["gender"]

      patient["orders"].each do |accession_number, members|

        members["results"].each do |test_code, elements|

          order = {
              :patient => {
                  :national_patient_id => npid,
                  :patient_name => patient_name,
                  :date_of_birth => date_of_birth,
                  :gender => gender
              },
              :order => {
                  :accession_number => accession_number,
                  :sample_type => members["sample_type"],
                  :who_ordered_test => members["who_ordered_test"],
                  :date_time => members["date_time"],
                  :sending_facility => members["sending_facility"],
                  :receiving_facility => members["receiving_facility"],
                  :reason_for_test => members["reason_for_test"],
                  :test_code => test_code,
                  :test_name => elements["test_name"],
                  :result => elements["result"],
                  :units => elements["units"],
                  :reference_range => elements["reference_range"],
                  :entered_by => elements["entered_by"],
                  :location_entered => elements["location_entered"],
                  :result_date_time => elements["date_time"],
                  :status => members["status"]
              }
          }

          outcome = Result.create_or_update(order)

          result << [accession_number, test_code, outcome]

        end

      end

    end

    render :text => result.to_json

  end

end
