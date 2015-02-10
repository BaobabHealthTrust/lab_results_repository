require 'couchrest_model'

class Result < CouchRest::Model::Base
  
  def accession_number=(value)
    self['_id']=value.to_s
  end

  def accession_number
    self['_id']
  end

  property :patient do
    property :national_patient_id, String
    property :patient_name, String
    property :date_of_birth, String
    property :gender, String
  end
  property :order do   
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
  end 

  timestamps!

  design do
    view :by_npid,
         :map => "function(doc) {
                  if ((doc['type'] == 'Result') && (doc['patient'] != null && doc['patient']['national_patient_id'] != null)) {
                    emit(doc['patient']['national_patient_id'], 1);
                  }
                }"
    view :by_accession_number,
         :map => "function(doc) {
                  if ((doc['type'] == 'Result') && (doc['_id'] != null)) {
                    emit(doc['_id'], 1);
                  }
                }"
    view :by_accession_number_and_test_code,
         :map => "function(doc) {
                  if ((doc['type'] == 'Result') && doc['_id'] != null && doc['order'] != null && doc['order']['test_code'] != null) {
                    emit([doc['_id'], doc['order']['test_code']], 1);
                  }
                }"
  end
end
