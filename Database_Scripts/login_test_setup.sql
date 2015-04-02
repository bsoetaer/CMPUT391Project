insert into persons 
VALUES ( 2, 'John', 'Doe', '15 Delaney St, St. Albert, AB', 'john.doe@hotmail.com', '7804594965' );

insert into persons 
VALUES ( 3, 'Mary', 'Clark', '15 St, Edmonton, AB', 'mary.clark@mri.com', '7804608000' );

insert into persons 
VALUES ( 4, 'Jim', 'Smith', '245 Henry Ave, Sherwood Park, AB', 'jim.smith@hotmail.com', NULL );

insert into persons 
VALUES ( 5, 'Jane', 'Doe', NULL, NULL, NULL );

INSERT INTO users
VALUES ('John','Doe', 'p', 2, SYSDATE );

INSERT INTO users
VALUES ('Mary','Clark', 'd', 3, SYSDATE );

INSERT INTO users
VALUES ('Mary1','Clark', 'p', 3, SYSDATE );

INSERT INTO users
VALUES ('Jim','Smith', 'd', 4, SYSDATE );

INSERT INTO users
VALUES ('Jane','Doe', 'r', 5, SYSDATE );

INSERT INTO family_doctor
VALUES(3,2);

INSERT INTO family_doctor
VALUES(3,5);

INSERT INTO family_doctor
VALUES(4,3);

INSERT INTO family_doctor
VALUES(4,5);

INSERT INTO radiology_record (record_id, patient_id ,doctor_id ,radiologist_id ,test_type ,prescribing_date ,test_date ,diagnosis ,description ) 
VALUES ('1','2','1','5','some test',to_date('2014', 'YYYY'),to_date('2015', 'YYYY'),'He is cool', 'Cool') ;

INSERT INTO radiology_record (record_id, patient_id ,doctor_id ,radiologist_id ,test_type ,prescribing_date ,test_date ,diagnosis ,description ) 
VALUES ('2','2','1','5','some test',to_date('2014', 'YYYY'),SYSDATE,'He is cool', 'Cool') ;

INSERT INTO radiology_record (record_id, patient_id ,doctor_id ,radiologist_id ,test_type ,prescribing_date ,test_date ,diagnosis ,description ) 
VALUES ('3','5','1','5','some test',to_date('2014', 'YYYY'),SYSDATE,'He is cool', 'Cool') ;

INSERT INTO radiology_record (record_id, patient_id ,doctor_id ,radiologist_id ,test_type ,prescribing_date ,test_date ,diagnosis ,description ) 
VALUES ('4','5','1','5','some test',to_date('2014', 'YYYY'),to_date('2015', 'YYYY'),'Redneck', 'Cool') ;

INSERT INTO radiology_record (record_id, patient_id ,doctor_id ,radiologist_id ,test_type ,prescribing_date ,test_date ,diagnosis ,description ) 
VALUES ('5','3','4','5','some test',to_date('2014', 'YYYY'),to_date('2015', 'YYYY'),'Crazy', 'Cool') ;
