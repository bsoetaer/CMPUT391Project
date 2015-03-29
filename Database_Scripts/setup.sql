/*
 *  File name:  setup.sql
 *  Function:   to create the initial database schema for the CMPUT 391 project,
 *              Winter Term, 2015
 *  Author:     Prof. Li-Yan Yuan
 *
 *  Modified by: Braeden Soetaert
 *  Modifications: Added default admin user and made ids identities.
 */
DROP TABLE family_doctor;
DROP TABLE pacs_images;
DROP TABLE radiology_record;
DROP TABLE users;
DROP TABLE persons;
DROP SEQUENCE person_seq;
DROP SEQUENCE record_seq;
DROP SEQUENCE image_id_sequence;

/*
 *  To store the personal information
 */
CREATE TABLE persons (
   person_id INT,
   first_name varchar(24),
   last_name  varchar(24),
   address    varchar(128),
   email      varchar(128),
   phone      char(10),
   PRIMARY KEY(person_id),
   UNIQUE (email)
);

/*
 *  To store the log-in information
 *  Note that a person may have been assigned different user_name(s), depending
 *  on his/her role in the log-in  
 */
CREATE TABLE users (
   user_name varchar(24),
   password  varchar(24),
   class     char(1),
   person_id int,
   date_registered date,
   CHECK (class in ('a','p','d','r')),
   PRIMARY KEY(user_name),
   FOREIGN KEY (person_id) REFERENCES persons
);

/*
 *  to indicate who is whose family doctor.
 */
CREATE TABLE family_doctor (
   doctor_id    int,
   patient_id   int,
   FOREIGN KEY(doctor_id) REFERENCES persons,
   FOREIGN KEY(patient_id) REFERENCES persons,
   PRIMARY KEY(doctor_id,patient_id)
);

/*
 *  to store the radiology records
 */
CREATE TABLE radiology_record (
   record_id   int,
   patient_id  int,
   doctor_id   int,
   radiologist_id int,
   test_type   varchar(24),
   prescribing_date date,
   test_date    date,
   diagnosis    varchar(128),
   description   varchar(1024),
   PRIMARY KEY(record_id),
   FOREIGN KEY(patient_id) REFERENCES persons,
   FOREIGN KEY(doctor_id) REFERENCES  persons,
   FOREIGN KEY(radiologist_id) REFERENCES  persons
);

/*
 *  to store the pacs images
 */
CREATE TABLE pacs_images (
   record_id   int,
   image_id    int,
   thumbnail   blob,
   regular_size blob,
   full_size    blob,
   PRIMARY KEY(record_id,image_id),
   FOREIGN KEY(record_id) REFERENCES radiology_record
);

/*
 * Make person id auto-increment.
 */
CREATE SEQUENCE person_seq;

CREATE OR REPLACE TRIGGER persons_id 
BEFORE INSERT ON persons
FOR EACH ROW

BEGIN
  SELECT person_seq.NEXTVAL
  INTO   :new.person_id
  FROM   dual;
END;
/

/*
 * Make record id auto-increment.
 */
CREATE SEQUENCE record_seq;

CREATE OR REPLACE TRIGGER record_id
BEFORE INSERT ON radiology_record
FOR EACH ROW

BEGIN
  SELECT record_seq.NEXTVAL
  INTO   :new.record_id
  FROM   dual;
END;
/

/*
 * Make image id auto-increment.
 */
 /*
CREATE SEQUENCE image_seq;

CREATE OR REPLACE TRIGGER image_id
BEFORE INSERT ON pacs_images
FOR EACH ROW

BEGIN
  SELECT image_seq.NEXTVAL
  INTO   :new.image_id
  FROM   dual;
END;
/
*/
CREATE SEQUENCE image_id_sequence;
/*
 * Add default admin into persons.
 */
INSERT INTO persons
VALUES ( NULL, 'Admin', 'Admin', NULL, NULL, NULL );

/*
 * Add default admin into users.
 * Default Admin's person id is 1 due to int field and
 * sequences.
 */
INSERT INTO users
VALUES ('Admin','Admin', 'a', 1, SYSDATE );
