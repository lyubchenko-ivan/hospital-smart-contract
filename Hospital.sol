// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Hospital {
  
  constructor() {
    admin  = msg.sender;
  }

  address public admin;

  string[] private specializes  = [
   
    "dentist",
    "surgeon",
    "urologist",
    "neurologist"
  
  ];

  
  struct Visit {
    
    uint diagnosis_id;
    address doctor;
    address patient;
    uint date;
  
  }

  struct Doctor {
   
    string full_name;
    uint speciality;
  
  }

  struct Patient {
  
    string full_name;
  
  }
  
  struct Diagnosis {
    
    string name;
    uint specialization;
  
  }
  
  
  Diagnosis[] private diagnosises;
  Visit[] private visits;
  address[] private patient_addresses;
  address[] private doctor_addresses;
  
  
  mapping (address => Patient) private patients;
  mapping (address => Doctor) private doctors;


  modifier check_speciality(uint id){
    require(id < specializes.length, "Speciality Not Found");
    _;
  }

  modifier new_user_validation {
    require(msg.sender == admin, "New members can be added only by admin");
    _;
  }

  modifier filling_by_specialised_doctor(uint specialization) {
    Doctor memory found_doctor = doctors[msg.sender];

    require(found_doctor.speciality != 0, "You are not a doctor");
    require(found_doctor.speciality == specialization, "You do not have access");
    _;
  }

  modifier check_diagnosis(uint _diagnosis_id) {
    require(_diagnosis_id < diagnosises.length, "Diagnosis not found");
    _;
  }



  function speciality(uint id) public view check_speciality(id) returns(string memory) {
    return specializes[id];
  }

  function diagnosis(uint id) public view returns(Diagnosis memory) {
    require(diagnosises.length > id, "Record Not Found");
    return diagnosises[id];
  } 

  function visit(uint id) public view returns(Visit memory) {
    require(visits.length > id, "Record Not Found");
    return visits[id];
  }

  function patient(address _patient) public view returns(Patient memory) {
    require(bytes(patients[_patient].full_name).length != 0, "Record Not Found");
    return patients[_patient];
  }

  function patient_address(uint _id) public view returns(address) {
    require(patient_addresses.length > _id, "Record Not Found");
    return patient_addresses[_id];
  }

  function doctor(address _doctor) public view returns(Doctor memory) {
    require(bytes(doctors[_doctor].full_name).length != 0, "Record Not Found");
    return doctors[_doctor];
  }

  function doctor_address(uint _id) public view returns(address) {
    require(doctor_addresses.length > _id, "Record Not Found");
    return doctor_addresses[_id];
  }

  function register_patient(string memory _full_name) public {
    patients[msg.sender] = Patient(_full_name);
    patient_addresses.push(msg.sender);
  }

  function register_doctor(address _person, string memory _full_name, uint _speciality) public new_user_validation {
    doctors[_person] = Doctor(_full_name, _speciality);
    doctor_addresses.push(_person);
  }

  function report_visit(address _patient_address, uint _diagnosis_id) public check_diagnosis(_diagnosis_id) filling_by_specialised_doctor(diagnosises[_diagnosis_id].specialization) {
    Patient memory _patient = patients[_patient_address];
    require(bytes(_patient.full_name).length != 0, "Patient not found");

    visits.push(Visit(_diagnosis_id, msg.sender, _patient_address, block.timestamp));
  }

  function doctors_overloading(address _doctor_address, uint start_date, uint to_date) public view returns (uint) {
    require(bytes(doctors[_doctor_address].full_name).length != 0, "Doctor not found");
    uint counter = 0;
    
    for (uint i = 0; i < visits.length; i++) {
      if (visits[i].doctor == _doctor_address && visits[i].date >= start_date && visits[i].date <= to_date)
        counter++;
    }

    return counter;
  }

  function count_diagnosed(uint diagnosis_id) public view check_diagnosis(diagnosis_id) returns(uint) {
    uint counter = 0;
    for (uint i = 0; i < visits.length; i++) {
      if(visits[i].diagnosis_id == diagnosis_id)
        counter++;
    }

    return counter;
  }

  function average_by_diagnosis(uint diagnosis_id) public view returns(uint) {
    uint visits_by_diagnosis = count_diagnosed(diagnosis_id);
    return (visits_by_diagnosis / visits.length) * 100;
  }

  function get_doctors_by_specialization(uint _spec_id) public view returns(Doctor[] memory) {
    Doctor[] memory response = new Doctor[](0);
    
    for (uint i = 0; i < doctor_addresses.length; i++) {
      if(doctors[doctor_addresses[i]].speciality == _spec_id) {
        Doctor[] memory res_copy = response;

        response = new Doctor[](response.length + 1);
        for (uint j = 0; j < res_copy.length; j++) {
          response[j] = res_copy[j];
        }

        response[response.length - 1] = doctors[doctor_addresses[i]];
      }
    }    

    return response;
  }

  function add_diagnosis(string memory _name, uint _spec_id) public {
    diagnosises.push(Diagnosis(_name, _spec_id));
  }

  function get_patient_addresses() public view returns(address[] memory) {
    address[] memory _address = new address[](0);

    for (uint i = 0; i < patient_addresses.length; i++) {
      address[] memory _copy = _address;
      _address = new address[](_address.length + 1);

      for (uint j = 0; j < _copy.length; j++) {
        _address[j] = _copy[j];
      }

      _address[i] = patient_addresses[i];
    }

    return _address;
  }

  function get_doctor_addresses() public view returns(address[] memory) {
    address[] memory _address = new address[](0);

    for (uint i = 0; i < doctor_addresses.length; i++) {
      address[] memory _copy = _address;
      _address = new address[](_address.length + 1);

      for (uint j = 0; j < _copy.length; j++) {
        _address[j] = _copy[j];
      }
      
      _address[i] = doctor_addresses[i];
    }

    return _address;
  }

  function specialities_len() public view returns(uint) {
    return specializes.length;
  }

} 