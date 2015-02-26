require 'couchrest_model'

class Result < CouchRest::Model::Base

  property :patient do
    property :national_patient_id, String
    property :patient_name, String
    property :date_of_birth, String
    property :gender, String
  end
  property :order do
    property :accession_number, String
    property :sample_type, String  
    property :who_ordered_test, String  
    property :date_time, String      
    property :sending_facility, String      
    property :receiving_facility, String    
    property :reason_for_test, String
    property :test_code, String     
    property :test_name, String  
    property :result, String  
    property :units, String    
    property :reference_range, String    
    property :entered_by, String   
    property :location_entered, String   
    property :result_date_time, String
    property :status, String
  end

  property :voided, TrueClass, :default => false
  property :_rev, String

  timestamps!

  def self.create_or_update(order)

    accession_number = order[:order][:accession_number] rescue nil

    test_code = order[:order][:test_code] rescue nil

    return false if accession_number.blank? or test_code.blank?

    existing = Result.by_accession_number_and_test_code.key([accession_number, test_code]).each

    if existing.count > 0

      existing = existing.first

      changed = Result.compare_orders(existing, order)

      if changed

        order[:_rev] = existing[:_rev]

        result = existing.update_attributes(order)

        return result

      else

        return false

      end

    else

      result = Result.create(order)

      return result

    end

  end

  def self.compare_orders(current_order, incoming_order)

    changed = false

    if (current_order["patient"]["national_patient_id"].strip rescue "") != (incoming_order[:patient][:national_patient_id].strip rescue "")

      changed = true

    elsif (current_order["patient"]["patient_name"].strip rescue "") != (incoming_order[:patient][:patient_name].strip rescue "")

      changed = true

    elsif (current_order["patient"]["date_of_birth"].strip rescue "") != (incoming_order[:patient][:date_of_birth].strip rescue "")

      changed = true

    elsif (current_order["patient"]["gender"].strip rescue "") != (incoming_order[:patient][:gender].strip rescue "")

      changed = true

    elsif (current_order["order"]["accession_number"].strip rescue "") != (incoming_order[:order][:accession_number].strip rescue "")

      changed = true

    elsif (current_order["order"]["sample_type"].strip rescue "") != (incoming_order[:order][:sample_type].strip rescue "")

      changed = true

    elsif (current_order["order"]["who_ordered_test"].strip rescue "") != (incoming_order[:order][:who_ordered_test].strip rescue "")

      changed = true

    elsif (current_order["order"]["date_time"].strip rescue "") != (incoming_order[:order][:date_time].strip rescue "")

      changed = true

    elsif (current_order["order"]["receiving_facility"].strip rescue "") != (incoming_order[:order][:receiving_facility].strip rescue "")

      changed = true

    elsif (current_order["order"]["sending_facility"].strip rescue "") != (incoming_order[:order][:sending_facility].strip rescue "")

      changed = true

    elsif (current_order["order"]["reason_for_test"].strip rescue "") != (incoming_order[:order][:reason_for_test].strip rescue "")

      changed = true

    elsif (current_order["order"]["test_code"].strip rescue "") != (incoming_order[:order][:test_code].strip rescue "")

      changed = true

    elsif (current_order["order"]["test_name"].strip rescue "") != (incoming_order[:order][:test_name].strip rescue "")

      changed = true

    elsif (current_order["order"]["result"].strip rescue "") != (incoming_order[:order][:result].strip rescue "")

      changed = true

    elsif (current_order["order"]["units"].strip rescue "") != (incoming_order[:order][:units].strip rescue "")

      changed = true

    elsif (current_order["order"]["reference_range"].strip rescue "") != (incoming_order[:order][:reference_range].strip rescue "")

      changed = true

    elsif (current_order["order"]["entered_by"].strip rescue "") != (incoming_order[:order][:entered_by].strip rescue "")

      changed = true

    elsif (current_order["order"]["location_entered"].strip rescue "") != (incoming_order[:order][:location_entered].strip rescue "")

      changed = true

    elsif (current_order["order"]["result_date_time"].strip rescue "") != (incoming_order[:order][:result_date_time].strip rescue "")

      changed = true

    end

    return changed

  end

  design do
    view :by_npid,
         :map => "function(doc) {
                  if ((doc['type'] == 'Result') && (doc['patient'] != null && doc['patient']['national_patient_id'] != null)) {
                    emit(doc['patient']['national_patient_id'], 1);
                  }
                }"
    view :by_accession_number,
         :map => "function(doc) {
                  if ((doc['type'] == 'Result') && (doc['order'] != null && doc['order']['accession_number'] != null)) {
                    emit(doc['order']['accession_number'], 1);
                  }
                }"
    view :by_accession_number_and_test_code,
         :map => "function(doc) {
                  if ((doc['type'] == 'Result') && doc['order'] != null && doc['order']['accession_number'] != null && doc['order']['test_code'] != null) {
                    emit([doc['order']['accession_number'], doc['order']['test_code']], 1);
                  }
                }"
    view :by_accession_number_and_npid,
         :map => "function(doc) {
                  if ((doc['type'] == 'Result') && (doc['order'] != null && doc['order']['accession_number'] != null) && (doc['patient'] != null && doc['patient']['national_patient_id'] != null)) {
                    emit([doc['order']['accession_number'], doc['patient']['national_patient_id']], 1);
                  }
                }"
    view :by_npid_accession_number_and_test_code,
         :map => "function(doc) {
                  if ((doc['type'] == 'Result') && doc['order'] != null && doc['order']['accession_number'] != null &&
                      doc['order']['test_code'] != null && (doc['patient'] != null && doc['patient']['national_patient_id'] != null)) {
                    emit([doc['patient']['national_patient_id'], doc['order']['accession_number'], doc['order']['test_code']], 1);
                  }
                }"
  end
end
