-- 1
CREATE PROC studentRegister 
@first_name varchar(20),
@last_name varchar(20), 
@password varchar(20), 
@email varchar(50),
@gender bit,
@address varchar(10)
AS 
INSERT INTO Users(firstName, lastName, password, gender, email, address)
VALUES(@first_name,@last_name,@password,@gender,@email,@address)
INSERT INTO Student(id)
VALUES (SCOPE_IDENTITY())
go

-- 1
CREATE PROC InstructorRegister 
@first_name varchar(20),
@last_name varchar(20), 
@password varchar(20), 
@email varchar(50),
@gender bit,
@address varchar(10)
AS 
INSERT INTO Users(firstName, lastName, password, gender, email, address)
VALUES(@first_name,@last_name,@password,@gender,@email,@address)
INSERT INTO Instructor(id)
VALUES (SCOPE_IDENTITY())
go

-- 2a
CREATE PROC userLogin
@ID int,
@password varchar(20),
@success bit OUTPUT,
@Type int OUTPUT
AS
DECLARE @alo varchar(20);
SET @alo = 
	(SELECT Users.password
	FROM Users
	WHERE Users.id = @ID)

if(@alo = @password)
	SET @success = 1
else
	SET @success = 0

IF (exists(SELECT * FROM Student WHERE Student.id = @ID))
	SET @Type = 2
ELSE IF (exists(SELECT * FROM Instructor WHERE Instructor.id = @ID))
	SET @Type = 0
ELSE IF (exists(SELECT * FROM Admin WHERE Admin.id = @ID))
	SET @Type = 1
go

-- 2b
CREATE PROC addMobile
@ID varchar(20),
@mobile_number varchar(20)
AS
INSERT INTO UserMobileNumber(id, mobileNumber)
VALUES (@id, @mobile_number)
go

-- 3a
CREATE PROC AdminListInstr
AS
SELECT id, firstName, lastName
FROM Instructor i 
		inner join Users u ON i.id = u.id
go

-- 3b
CREATE PROC AdminViewInstructorProfile
@instrID int
AS
SELECT *
FROM Instructor i inner join Users u ON i.id = u.id
WHERE i.id = @instrID
go

-- 3c
CREATE PROC AdminViewAllCourses
AS
SELECT name, creditHours, price, content, accepted
FROM Course
go

-- 3d
CREATE PROC AdminViewNonAcceptedCourses
AS 
SELECT name, creditHours, price, content 
FROM Course
WHERE accepted = 0
go

-- 3e
CREATE PROC AdminViewCourseDetails
@courseID int
AS
SELECT name, creditHours, price, content, accepted
FROM Course
WHERE Course.id = @courseID
go

 -- 3f
CREATE PROC AdminAcceptRejectCourse
@adminId int,
@courseId int
AS
if((SELECT accepted FROM Course WHERE id = @courseId) = 0)
	UPDATE Course
	SET accepted = 1, adminId = @adminId
	WHERE Course.id = @courseId
else if ((SELECT accepted FROM Course WHERE id = @courseId) = 1)
	UPDATE Course
	SET accepted = 0, adminId = @adminId
	WHERE Course.id = @courseId
go

-- 3g
CREATE PROC AdminCreatePromocode
@code varchar(6), 
@isuueDate datetime, 
@expiryDate datetime, 
@discount decimal(4,2), 
@adminId int
AS
INSERT INTO Promocode(code, issueDate, expiryDate, discountamount, adminId)
VALUES(@code, @isuueDate, @expiryDate, @discount,@adminId)
go

-- 3h
CREATE PROC AdminListAllStudents
AS
SELECT firstName, lastName
FROM Student s inner join Users u ON s.id = u.id
go

-- 3i
CREATE PROC AdminViewStudentProfile
@sid int
AS
SELECT firstName, lastName, gender, email, address, gpa
FROM Student s inner join Users u ON s.id = u.id
WHERE s.id = @sid
go

-- 3j
CREATE PROC AdminIssuePromocodeToStudent
@sid int, 
@pid varchar(6)
AS
INSERT INTO StudentHasPromcode(sid, code)
VALUES(@sid, @pid)
go

-- 4a
CREATE PROC InstAddCourse
@creditHours Int,
@name varchar(10),
@price  DECIMAL(6,2),
@instructorId int
AS
insert into Course (creditHours, name, price, instructorId)
values(@creditHours, @name, @price, @instructorId)
go

-- 4b
CREATE PROC UpdateCourseContent
@instrId int,
@courseId int,
@content varchar(20)
AS
if(exists(SELECT * FROM InstructorTeachCourse WHERE instId = @instrId and cid = @courseId))
	update Course
	set instructorId = @InstrId , content = @content
	where id = @courseId;
else
	print 'ERROR THIS INST DOESNT TEACH THIS COURSE'
go

--4b
CREATE PROC UpdateCourseDescription
@instrId int, @courseId int, @courseDescription varchar(200)
AS
if(exists(SELECT * FROM InstructorTeachCourse WHERE instId = @instrId and cid = @courseId))
	UPDATE Course
	SET instructorId = @InstrId , courseDescription = @courseDescription
	WHERE id = @courseId;
else
	print 'ERROR THIS INST DOESNT TEACH THIS COURSE'
go

-- 4c
CREATE PROC AddAnotherInstructorToCourse
@insid int,
@cid int,
@adderIns int
AS
if(exists(SELECT * FROM InstructorTeachCourse WHERE instId = @adderIns and cid = @cid))
	INSERT INTO InstructorTeachCourse(instId, cid)
	VALUES (@insid, @cid)
else
	print 'ERROR THIS INST DOESNT TEACH THIS COURSE'
go

-- 4d
CREATE PROC InstructorViewAcceptedCoursesByAdmin
@instrId int
as
SELECT * FROM Course
where instructorId = @instrId and accepted = 1;
go

-- 4e
CREATE PROC DefineCoursePrerequisites
@cid int , @prerequsiteId int
as
insert into CoursePrerequisiteCourse(cid,prerequisiteId)
values (@cid,@prerequsiteId)
go

--4f
CREATE PROC DefineAssignmentOfCourseOfCertianType
@instId int, @cid int , @number int, @type varchar(10), @fullGrade int, @weight decimal(4,1), @deadline
datetime, @content varchar(200)
as 
IF (exists(select * from InstructorTeachCourse I1 where I1.instructorId = @instId and I1.cid = @cid))
insert into Assignment(cid,number,type,fullgrade,weight,deadline,content)
values (@cid,@number,@type,@fullGrade,@weight,@deadline,@content)
else
	print 'ERROR THIS INST DOESNT TEACH THIS COURSE'
go

-- 4g
CREATE PROC updateInstructorRate
@insid int
AS
declare @tmp decimal(4,2)
SET @tmp = (select avg(rate) from StudentRateInstructor
where instId = @insid)
update Instructor
set rating = @tmp
where id = @insid
go

-- 4g
CREATE PROC ViewInstructorProfile
@instrId int 
AS
select firstName, lastName, gender, email, address, rating, mobileNumber from Users inner join UserMobileNumber on Users.id = UserMobileNumber.id inner join Instructor i ON i.id = @instrId
where Users.id = @instrId
go

-- 4h
CREATE PROC InstructorViewAssignmentsStudents
@instrId int, @cid int
as
select sid,cid,assignmentNumber,assignmentType from  StudentTakeAssignment w
inner join StudentTakeCourse s on w.cid = s.cid
where w.instId = @instrId and w.cid = @cid
go

-- 4i
CREATE PROC InstructorgradeAssignmentOfAStudent
@instrId int, @sid int , @cid int, @assignmentNumber int, @type varchar(10), @grade decimal(5,2)
as
if (exists(select * from StudentTakeCourse s1 where s1.instId = @instrId and s1.cid = @cid))
UPDATE StudentTakeAssignment
SET grade = @grade
WHERE sid = @sid and cid = @cid and assignmentNumber = @assignmentNumber and assignmentType = @type
go

-- 4j
CREATE PROC ViewFeedbacksAddedByStudentsOnMyCourse
@instrId int, @cid int
as 
select number,comments,numberOfLikes from Feedback inner join Course on Course.id = Feedback.cid
where Course.instructorId = @instrId and Feedback.cid = @cid
go

-- 4k
CREATE PROC calculateFinalGrade
@cid int,
@sid int,
@insId int
AS
if(exists(SELECT * FROM StudentTakeCourse s WHERE s.cid = @cid and s.sid = @sid and s.instId = @insId))
	UPDATE StudentTakeCourse
	SET grade = (SELECT SUM((grade/fullgrade)*weight) FROM StudentTakeAssignment z 
	inner join Assignment a ON z.cid = a.cid WHERE sid = @sid and cid = @cid)
	WHERE sid = @sid and cid = @cid and instId = @insId
go

--4k
CREATE PROC InstructorIssueCertificateToStudent
@cid int,
@sid int,
@insId int,
@issueDate Datetime
AS
if(exists(SELECT * FROM StudentTakeCourse WHERE sid = @sid and cid = @cid and instId = @insId))
	if((SELECT grade FROM StudentTakeCourse WHERE sid = @sid and cid = @cid and instId = @insId) > 50)
		INSERT INTO StudentCertifyCourse(sid,cid,issueDate)
		VALUES(@sid, @cid, @issueDate)
	else
		print('USER FAILED COURSE');
else
	print('USER NOT REGISTERED IN THIS COURSE');
go 




-----------------5----------------

--5a
CREATE PROC viewMyProfile
@id INT
AS
SELECT id, firstName, lastName, password, gender, email, address
FROM Student s INNER JOIN Users u ON s.id = u.id
WHERE s.id = @id
GO

-- 5b
CREATE PROC editMyProfile
@id int,
@firstName varchar(10),
@lastName varchar(10),
@password varchar(10),
@gender binary,
@email varchar(10),
@address varchar(10)
AS
UPDATE Users
SET firstName = ISNULL(@firstName, firstName),
lastName = ISNULL(@lastName, lastName),
password = ISNULL(@password, password),
gender = ISNULL(@gender, gender),
email = ISNULL(@email, email),
address = ISNULL(@address, address)
WHERE id = @id
GO

-- 5c
CREATE PROC availableCourses
AS
SELECT name
FROM Course
WHERE accepted = 1
GO

-- 5d
CREATE PROC courseInformation
@id INT
AS
SELECT c.creditHours, c.name, c.courseDescription, u.firstName, u.lastName
FROM Course c INNER JOIN Users u ON c.instructorId = u.id
WHERE c.id = @id
GO

-- 5e
CREATE PROC enrollInCourse
@sid int,
@cid int,
@instr int
AS
DECLARE @preqID int;
if(not exists(SELECT * FROM CoursePrerequisiteCourse WHERE cid = @cid and prerequisiteId = @preqID))
	if(exists(SELECT * FROM InstructorTeachCourse WHERE instId = @instr and cid = @cid))
		INSERT INTO StudentTakeCourse(sid,cid,instId)
		VALUES(@sid, @cid, @instr)
	else
		print('THIS INSTRUCTOR DOES NOT TEACH THIS COURSE');
else
	if(exists(SELECT * FROM StudentCertifyCourse WHERE cid = @preqID and sid = @sid))
		INSERT INTO StudentTakeCourse(sid,cid,instId)
		VALUES(@sid, @cid, @instr)
	else
		print('THE STUDENT DID NOT TAKE THE PREREQUISITE');
GO

-- 5f
CREATE PROC addCreditCard
@sid INT,
@number VARCHAR(15),
@cardHolderName VARCHAR(16),
@expiryDate DATETIME,
@cvv VARCHAR(3)
AS
INSERT INTO CreditCard VALUES (@number, @cardHolderName, @expiryDate, @cvv);
INSERT INTO StudentAddCreditCard VALUES (@sid, @number);
GO

-- 5g
CREATE PROC viewPromocode
@sid INT
AS
SELECT p.*
FROM StudentHasPromcode s INNER JOIN Promocode p ON s.code = p.code
WHERE s.sid = @sid
GO

-- 5h
CREATE PROC payCourse
@cid int,
@sid int
AS
if(exists(SELECT * FROM StudentAddCreditCard WHERE sid = @sid))
	UPDATE StudentTakeCourse
	SET payedfor = 1
	WHERE cid = @cid and sid = @sid
else
	print 'STUDENT HAS NO CREDIT CARD TO PAY WITH'
GO

-- 5i
CREATE PROC enrollInCourseViewContent
@id int,
@cid int
AS
if((SELECT payedfor FROM StudentTakeCourse WHERE sid = @id and cid = @cid) = 1)
	SELECT content FROM Course WHERE cid = @cid
else
	print('STUDENT NOT ENROLLED IN THIS COURSE');
go

-- 5j
CREATE PROC viewAssign
@courseId INT,
@Sid VARCHAR(10)
AS
SELECT *
FROM Assignment
WHERE cid = @courseId AND number = CAST(@Sid AS INT)
go

-- 5k
CREATE PROC submitAssign
@assignType VARCHAR(10),
@assignnumber int,
@sid int,
@cid int
AS
if(exists(SELECT * FROM StudentTakeCourse z WHERE z.sid = @sid and z.cid = @cid))
INSERT INTO StudentTakeAssignment (sid, cid, assignmentNumber, assignmentType)
VALUES(@sid, @cid, @assignnumber, @assignType)
go

-- 5l
CREATE PROC viewAssignGrades
@assignnumber int,
@assignType VARCHAR(10), 
@cid INT, 
@sid INT,
@assignGrade INT OUTPUT
AS
if(exists(SELECT * FROM StudentTakeAssignment z WHERE z.assignmentNumber = @assignnumber and z.assignmentType = @assignType and z.sid = @sid and z.cid = @cid))
SET @assignGrade = (SELECT grade FROM StudentTakeAssignment z WHERE z.assignmentNumber = @assignnumber and z.assignmentType = @assignType and z.sid = @sid and z.cid = @cid)
go

-- 5m
CREATE PROC viewFinalGrade
@cid int,
@sid int,
@finalgrade decimal(10,2) OUTPUT
AS
if(exists(SELECT * FROM StudentTakeCourse WHERE @sid = sid and cid = @cid))
SET @finalgrade = (SELECT grade FROM StudentTakeCourse WHERE @sid = sid and cid = @cid)
go

-- 5n
CREATE PROC addFeedback
@comment VARCHAR(100),
@cid int,
@sid int
AS
if(exists(SELECT * FROM StudentTakeCourse s WHERE s.cid = @cid and s.sid = @sid))
INSERT INTO Feedback(cid, comments, sid)
VALUES(@cid, @comment, @sid)
go

-- 5o
CREATE PROC rateInstructor
@rate Decimal(2,1),
@sid int,
@insid int
AS
if(exists(SELECT * FROM StudentTakeCourse s WHERE s.instId = @insid and s.sid = @sid))
INSERT INTO StudentRateInstructor (sid, instId, rate)
VALUES(@sid, @insid, @rate)
go

-- 5p
CREATE PROC viewCertificate
@cid int,
@sid int
AS
SELECT * FROM StudentCertifyCourse WHERE cid = @cid and sid = @sid
GO