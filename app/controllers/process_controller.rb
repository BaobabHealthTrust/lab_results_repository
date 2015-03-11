class ProcessController < ApplicationController

  def get_labs

    results = []

    patients = {}

    if !params[:id].blank?

      patient_orders = Result.by_npid.key(params[:id])

      patient_orders.each do |result|

        if patients[:national_patient_id].blank?

          patients[:national_patient_id] = {
              :patient => {
                  :national_patient_id => result[:patient][:national_patient_id],
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
              :status => result[:order][:status],
              :panel_loinc_code => result[:order][:panel_loinc_code]
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
              :patient => {
                  :national_patient_id => result[:patient][:national_patient_id],
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
              :status => result[:order][:status],
              :panel_loinc_code => result[:order][:panel_loinc_code]
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
                  :status => members["status"],
                  :panel_loinc_code => elements["panel_loinc_code"]
              }
          }

          outcome = Result.create_or_update(order)

          result << [accession_number, test_code, outcome]

        end

      end

    end

    render :text => result.to_json

  end

  def update_labs_only

=begin
    _json: [
        {
            "patient":{
                "national_patient_id":"P170000000031",
                "patient_name":"Test N/A Patient ",
                "date_of_birth":"19930701",
                "gender":"F"
            },
            "orders":{
                "KCH000001":{
                    "sample_type":"",
                    "who_order_test":"",
                    "date_time":"",
                    "sending_facility":"KCH",
                    "receiving_facility":"KCH",
                    "reason_for_test":"",
                    "results":{
                        "2324-2":{
                            "test_name":"Gamma glutamyl transferase",
                            "result":"",
                            "units":"",
                            "reference_range":"",
                            "entered_by":"User Super (1)",
                            "location_entered":"Ward 4B",
                            "date_time":"20150226182838",
                            "status":"Drawn"
                        }
                    }
                }
            }
        }
    ]
=end

    json = JSON.parse(params[:_json])

    patient = json[0] rescue nil

    npid = patient["patient"]["national_patient_id"] rescue nil

    if !patient.blank? and !npid.blank?

      accession_numbers = patient["orders"].keys

      accession_numbers.each do |num|

        tests = patient["orders"][num]["results"].keys

        tests.each do |test|

          object = Result.by_npid_accession_number_and_test_code.key(["#{npid}", "#{num}", "#{test}"]).each.first

          changed = false

          if (!object.order.result.blank? and !patient["orders"][num]["results"][test]["result"].blank? and
              object.order.result.strip != patient["orders"][num]["results"][test]["result"].strip) or
                (object.order.result.blank? and !patient["orders"][num]["results"][test]["result"].blank?)

            object.order.result = patient["orders"][num]["results"][test]["result"]

            changed = true

          end

          if (!object.order.units.blank? and !patient["orders"][num]["results"][test]["units"].blank? and
              object.order.units.strip != patient["orders"][num]["results"][test]["units"].strip) or
              (object.order.units.blank? and !patient["orders"][num]["results"][test]["units"].blank?)

            object.order.units = patient["orders"][num]["results"][test]["units"]

            changed = true

          end

          if (!object.order.reference_range.blank? and !patient["orders"][num]["results"][test]["reference_range"].blank? and
              object.order.reference_range.strip != patient["orders"][num]["results"][test]["reference_range"].strip) or
              (object.order.reference_range.blank? and !patient["orders"][num]["results"][test]["reference_range"].blank?)

            object.order.reference_range = patient["orders"][num]["results"][test]["reference_range"]

            changed = true

          end

          if (!object.order.entered_by.blank? and !patient["orders"][num]["results"][test]["entered_by"].blank? and
              object.order.entered_by.strip != patient["orders"][num]["results"][test]["entered_by"].strip) or
              (object.order.entered_by.blank? and !patient["orders"][num]["results"][test]["entered_by"].blank?)

            object.order.entered_by = patient["orders"][num]["results"][test]["entered_by"]

            changed = true

          end

          if (!object.order.location_entered.blank? and !patient["orders"][num]["results"][test]["location_entered"].blank? and
              object.order.location_entered.strip != patient["orders"][num]["results"][test]["location_entered"].strip) or
              (object.order.location_entered.blank? and !patient["orders"][num]["results"][test]["location_entered"].blank?)

            object.order.location_entered = patient["orders"][num]["location_entered"]

            changed = true

          end

          if (!object.order.result_date_time.blank? and !patient["orders"][num]["results"][test]["date_time"].blank? and
              object.order.result_date_time.strip != patient["orders"][num]["results"][test]["date_time"].strip) or
              (object.order.result_date_time.blank? and !patient["orders"][num]["results"][test]["date_time"].blank?)

            object.order.result_date_time = patient["orders"][num]["results"][test]["date_time"]

            changed = true

          end

          if (!object.order.status.blank? and !patient["orders"][num]["results"][test]["status"].blank? and
              object.order.status.strip != patient["orders"][num]["results"][test]["status"].strip) or
              (object.order.status.blank? and !patient["orders"][num]["results"][test]["status"].blank?)

            object.order.status = patient["orders"][num]["results"][test]["status"]

            changed = true

          end

          object.save if changed

        end

      end

    end

    render :text => json.to_json

  end

end
