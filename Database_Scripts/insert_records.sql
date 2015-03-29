
insert into persons (person_id,first_name,last_name ,address,email,phone) values	('1','Doctor', 'Smith', 'asdf 75 st', 'supercool@cool.com','7804504215' ) ;
insert into persons (person_id,first_name,last_name ,address,email,phone) values	('2','Sam', 'Riley', 'asdf 75 st', 'asdf@cool.com','7854504215' ) ; 
insert into persons (person_id,first_name,last_name ,address,email,phone) values ('3','Doctor', 'Magic', '8752 Cedar Drive', 'magic@cool.com','7854504213' ) ;
insert into persons (person_id,first_name,last_name ,address,email,phone) values ('4','SomeBody', 'Youknow', '2231 Cedar Drive', 'smb@cool.com','7854504289' ) ;
insert into persons (person_id,first_name,last_name ,address,email,phone) values ('5','Radi', 'ologist', '5414 Cedar Drive', 'rad@rad.com','7854504215' ) ;


INSERT INTO family_doctor (doctor_id,patient_id) VALUES ('1','2') ;
INSERT INTO family_doctor (doctor_id,patient_id) VALUES ('3','4');


INSERT INTO radiology_record (record_id, patient_id ,doctor_id ,radiologist_id ,test_type ,prescribing_date ,test_date ,diagnosis ,description ) 
VALUES ('1','2','1','3','some test',to_date('2014', 'YYYY'),to_date('2015', 'YYYY'),'He is cool', 'Cool') ;
