--------------------Table Students-----------------------------
---------------------------------------------------------------
--insert into student
alter proc insertStudent (@ID int, @fname varchar(20), 
@lname varchar(20), @age int, @add varchar(20), @did int)
as
if not EXISTS (select Dept_Id from Departments where Dept_Id=@did)
	select 'can not insert student in department not exists'
else if EXISTS (select Student_Id from Students where Student_Id=@ID)
	select 'This ID Already Exists'
else
begin
insert into Students (Student_Id,F_Name,L_Name,Age,Address,Dept_Id)
values (@ID, @fname, @lname, @age,@add,@did)
end
--select students
create proc showAllStudents
as 
select * from Students

create proc showOneStudent @id int
as
select * from Students where Student_Id=@id
--update name
alter proc upDateStudentName (@fname varchar(20),@lname varchar(20),@id int)
as
if(@fname='' or @lname='')
	select 'Please enter name as string'
else if not EXISTS (select * from Students where Student_Id=@id)
	select 'can not udate student with ID not Exists'
else
begin
	update Students
	set F_Name=@fname,L_Name=@lname
	where Student_Id=@id
end

upDateStudentName 'Ahmed','Ali',1
--update age
alter proc upDateStudentAge (@age int,@id int)
as
if(@age=NULL)
	select 'Please enter Valid Age'
else if not EXISTS (select * from Students where Student_Id=@id)
	select 'can not udate student with ID not Exists'
else
begin
	update Students
	set Age=@age
	where Student_Id=@id
end
--update Address
alter proc upDateStudentAddress (@add varchar(20),@id int)
as
if(@add=NULL)
	select 'Please enter Valid Address'
else if not EXISTS (select * from Students where Student_Id=@id)
	select 'can not udate student with ID not Exists'
else
begin
	update Students
	set Address=@add
	where Student_Id=@id
end
upDateStudentAddress 'Alex',1

--update Department
create proc upDateStudentDepartment (@did int,@id int)
as
if(@did=NULL)
	select 'Please enter Valid Address'
else if not EXISTS (select * from Students where Student_Id=@id)
	select 'can not udate student with ID not Exists'
if not EXISTS (select Dept_Id from Departments where Dept_Id=@did)
	select 'can not insert student in department not exists'
else
begin
	update Students
	set Address=@did
	where Student_Id=@id
end
upDateStudentDepartment 1,6
--Delete Student
create proc DeleteStudent @id int
as
if EXISTS(select * from Student_Course where Student_Id=@id)
	select 'can not delete Student has Relation with Student_Course'
else if EXISTS(select * from students_Exam where St_ID=@id)
	select 'can not delete Student has Relation with students_Exam'
else if EXISTS(select * from Student_Answer where Student_Id=@id)
	select 'can not delete Student has Relation with Student_Answer'
else
	delete from Students where Student_Id=@id
DeleteStudent 10
showAllStudents

---------------------------------------------------------------
-----------Table Courses---------------------------------------
---------------------------------------------------------------
--DisplayALLCourses
create proc DisplayCourses
as
	begin
		select * from Courses
	end
---Display only one Course
create proc DisplayOneCourse @id int
as
	begin
		select * 
		from Courses c
		where c.Course_Id = @id
	end
--insert courses
create proc InsertCourse @id int , @name varchar(50),@duration int ,
						  @desc nvarchar(100),@topic_id int
as
	begin
		
		if  exists(select * from Topic t where t.Topic_Id = @topic_id) --check if topic exists
		begin

		if not exists(select * from Courses c where c.Course_Id = @id) -- chcek if course exists
		begin
			insert into Courses
			values(@id,@name,@duration,@desc,@topic_id)
		end
		else
		begin
			select 'there is already a course with id '+ convert(varchar(20),@id)
		end

		end

		else
		begin
			select 'there is no id for such id'
		end

	end

InsertCourse 6,'HTML',20,'Front',3

--update courses
create proc UpdateCourse @id int , @name varchar(50),@duration int ,
						  @desc nvarchar(100),@topic_id int
as
	begin


	if  exists(select * from Topic t where t.Topic_Id = @topic_id) --check if topic exists
		begin

		if exists(select * from Courses c where c.Course_Id = @id)-- chcek if course exists
		begin
			update Courses 
			set Course_Name = @name,
				Course_Duration = @duration,
				Course_Description = @desc,
				Topic_Id = @topic_id
				
			where Course_Id = @id
			end
		else
		begin
			select 'there is no course with id '+ convert(varchar(20),@id)
			end
		end
		else
		begin
			select 'there is no id for such id'
		end

	end
UpdateCourse 6,'CSS',25,'Front',3
DisplayCourses
--delete courses
alter proc DeleteCourses @id int
as
	 if exists (select Course_Id from Student_Course 
				where Course_Id=@id) --check existence in table Student_Course 
			select 'you Can not delete Course has relation with Student_Course'
	else if  exists (select Course_Id from Instr_Course 
				where Course_Id=@id) --check existence in table Instr_Course 
			select 'you Can not delete Course has relation with Instr_Course'
	else if exists (select Course_Id from All_Questions 
				where Course_Id=@id) --check existence in table All_Questions 
			select 'you Can not delete Course has relation with All_Questions'
	else
	begin
		delete from Courses
		where Course_Id = @id
	end

DeleteCourses

-------------------------------------------------------------
--------------Table instructors------------------------------
-------------------------------------------------------------
---------Select----------
create proc showOneInstr 
@ins_id int
as
select * from Instructors where Instr_id=@ins_id

create proc showAllInstructors 
as
select * from Instructors

----------Insert-----------

alter proc insertInstructor
@ins_id int ,
@ins_fname varchar(50),
@ins_lname varchar(50),
@ins_salary money,
@ins_age int,
@dep_id int 
as
if not exists (select Dept_Id from Departments where Dept_Id=@dep_id)
	select 'No Department with this ID' --check Depart existence
else if exists (select Instr_Id from Instructors where Instr_Id=@ins_id)
	select 'there is instructor with the same ID' --check Instr existence
else
begin
insert into Instructors (Instr_Id,F_Name,L_Name,Salary,Age,Dept_Id)
values
(@ins_id,@ins_fname,@ins_lname,@ins_salary,@ins_age,@dep_id)
end
insertInstructor 6,'Mohamedr','Tharwat',12000,35,1

---------Delete-------------

create proc deleteInstructor
@ins_id int
as
if exists (select Instr_Id from Instr_Course where Instr_Id=@ins_id)
	select 'you can not delete instructor has relation with Instr_Course'
else
begin
	delete Instructors where Instr_id=@ins_id
end

deleteInstructor 6
  -------------Update--------

alter proc updateInstructor
@ins_id int ,
@ins_fname varchar(50),
@ins_lname varchar(50),
@ins_salary money,
@ins_age int,
@dep_id int 
as
if not exists (select Dept_Id from Departments where Dept_Id=@dep_id)
	select 'No Department with this ID' --check Depart existence
else if not exists (select * from Instructors where Instr_Id=@ins_id)
	select 'there is no Instructor with this ID'
else
begin
update Instructors 
set F_Name=@ins_fname,L_Name=@ins_lname,Salary=@ins_salary,Age=@ins_age,Dept_Id=@dep_id 
where Instr_id=@ins_id
end

updateInstructor 3,'Esraa','Nasser',45000,22,1

showAllInstructors 

----------------------------------------------------------------
------------------Table Department------------------------------
----------------------------------------------------------------
--select 
---all departments
create proc DisplayDepartments
as
	begin
		select * from Departments
	end
---only one department
create proc DisplayOneDept @id int
as
	begin
		select * 
		from Departments d 
		where d.Dept_Id = @id
	end
-- insert

create proc InsertDept @id int , @name varchar(50),@loc varchar(50)						 
as
	begin
		if not exists(select * from Departments d where d.Dept_Id = @id)
		begin
			insert into Departments
			values(@id,@name,@loc)
			end
		else
		begin
			select 'there is already a deparment with id '+ convert(varchar(20),@id)
			end
	end
InsertDept 6,DS,'Alex'

-- update
alter proc UpdateDept @id int , @name varchar(50),@loc varchar(50)
as
	begin
		if exists(select * from Departments d where d.Dept_Id = @id)
		begin
			update Departments 
			set Dept_Name = @name,
				Dept_location = @loc
			where Dept_Id = @id
			end
		else
		begin
			select 'there is no department with id '+ convert(varchar(20),@id)
			end
	end
UpdateDept 12,'MD','Cairo'
--delete
create proc DeleteDept @id int
as
if Exists (select * from Students where Dept_Id=@id)
	select 'Can not Delete Department has Students'
else if Exists (select * from Instructors where Dept_Id=@id)
	select 'Can not Delete Department has Instructors'
else 
delete from Departments where Dept_Id = @id
DeleteDept 1
DisplayDepartments

----------------------------------------------------------------
-----------------Table Topic------------------------------------
----------------------------------------------------------------
--select
create proc showAllTopics
as
select * from Topic 

create proc showOneTopic
@topic_id int 
as
select * from Topic where Topic_id=@topic_id
--insert
create proc insertTopic 
@topic_id int,
@topic_name varchar(50)
as
if Exists (select * from Topic where Topic_Id=@topic_id)
	select 'There is Topic with The same ID'
else
insert Topic values(@topic_id,@topic_name)
insertTopic 6,'Web'
--delete
create proc DeleteTopic
@id_topic int
as
if exists (select * from Courses)
	select 'can not delete Topic has courses'
else
delete Topic where Topic_id=@id_topic 
DeleteTopic 6
--update
create proc updateTopic 
@topic_id int,
@topic_name varchar(50)
as
if not exists (select * from Topic where Topic_Id=@topic_id)
	select 'there is no topic with is ID'
else
update Topic set Topic_Name=@topic_name where Topic_id=@topic_id

updateTopic 6,'Communications'
showAllTopics
---------------------------------------------------------------
-------------------Insrt_Courses-------------------------------
---------------------------------------------------------------
--select 
---all instrCourses
create proc DisplayinstrCourses
as
	begin
		select * from Instr_Course
	end
---only one department
create proc DisplayOneinstrCourses @instrid int, @courseid int
as
	begin
		select * 
		from Instr_Course ic
		where ic.Course_Id=@courseid And ic.Instr_Id=@instrid
	end
-- insert
create proc InsertinstrCourses @instrid int, @courseid int,@eval varchar(50)
as
if exists(select * from Instr_Course ic 
		  where ic.Course_Id=@courseid And ic.Instr_Id=@instrid)
	select 'the an Instructor is already assined to this course'
else if not exists (select * from Instructors where Instr_Id=@instrid)
	select 'there is no instructor with this ID'
else if not exists (select * from Courses where Course_Id=@courseid)
	select 'there is no course with is ID'
else
begin
	insert into Instr_Course
	values(@instrid,@courseid,@eval)
end
InsertinstrCourses 1,6,'good'

-- update
-----to update instructor of the course
alter proc UpdateInstrCourse @oldInstrid int, @courseid int,@newInstID int,@eval varchar(50)
as
if not exists (select * from Instructors where Instr_Id=@oldInstrid)
	select 'there is no instructor with this ID'
else if not exists (select * from Courses where Course_Id=@courseid)
	select 'there is no course with is ID'
else
begin
if exists(select * from Instr_Course ic where ic.Course_Id=@courseid And ic.Instr_Id=@oldInstrid)
		begin
		if not exists (select * from Instructors where Instr_Id=@newInstID)
			select 'there is no instructor with this ID'
		else
			update Instr_Course
			set Instr_Id = @newInstID , 
				Evaluation = @eval
			where Course_Id=@courseid And Instr_Id=@oldInstrid
			end
		else
		begin
			select 'this no such intructor assined to this course'
			end
end
-----to update course of the instructor
create proc UpdateCourseInstr @Instrid int, @oldcourseid int,@newCourseID int,@eval varchar(50)
as
if not exists (select * from Instructors where Instr_Id=@Instrid)
	select 'there is no instructor with this ID'
else if not exists (select * from Courses where Course_Id=@oldcourseid)
	select 'there is no course with is ID'
else
begin
if exists(select * from Instr_Course ic where ic.Course_Id=@oldcourseid And ic.Instr_Id=@Instrid)
		begin
		if not exists (select * from Courses where Course_Id=@newCourseID)
			select 'there is no instructor with this ID'
		else
			update Instr_Course
			set Instr_Id = @newCourseID , 
				Evaluation = @eval
			where Course_Id=@oldcourseid And Instr_Id=@Instrid
			end
		else
		begin
			select 'this no such intructor assined to this course'
			end
end
--delete
create proc DeleteinstrCourses @instrid int, @courseid int
as
	begin
		if exists(select * from Instr_Course ic where ic.Course_Id=@courseid And ic.Instr_Id=@instrid)
		begin
			delete from Instr_Course
			where Course_Id=@courseid And Instr_Id=@instrid
			end
		else
		begin
			select 'there is no such intructor assined to this course'
			end
	end
UpdateInstrCourse 1,6,5,'vgood'
UpdateCourseInstr 5,6,4,'vgood'
select * from Instr_Course

SET IDENTITY_INSERT exam_questions ON