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
VALUES ('Jane','Doe', 'p', 5, SYSDATE );

INSERT INTO family_doctor
VALUES(3,2);

INSERT INTO family_doctor
VALUES(3,5);

INSERT INTO family_doctor
VALUES(4,3);

INSERT INTO family_doctor
VALUES(4,5);
