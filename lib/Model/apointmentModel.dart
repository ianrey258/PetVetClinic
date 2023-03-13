class ClinicApointmentModel{
  String? id,pet_owner_id,clinic_id,schedule_datetime,datetime_created,reason,payment,status;
  List? pet_list_ids;

  ClinicApointmentModel(
    this.id,
    this.pet_owner_id,
    this.clinic_id,
    this.schedule_datetime,
    this.datetime_created,
    this.reason,
    this.payment,
    this.status,
    this.pet_list_ids,
  );

  ClinicApointmentModel.fromMap(Map<String, dynamic> json):
    id = json['id'],
    pet_owner_id = json['pet_owner_id'],
    clinic_id = json['clinic_id'],
    schedule_datetime = json['schedule_datetime'],
    datetime_created = json['datetime_created'],
    reason = json['reason'],
    payment = json['payment'],
    status = json['status'],
    pet_list_ids = json['pet_list_ids']
    ;

  Map<String, dynamic> toMap() => {
      "id": id,
      "pet_owner_id": pet_owner_id,
      "clinic_id": clinic_id,
      "schedule_datetime": schedule_datetime,
      "datetime_created": datetime_created,
      "reason": reason,
      "payment": payment,
      "status": status,
      "pet_list_ids": pet_list_ids as List,
    };
}



