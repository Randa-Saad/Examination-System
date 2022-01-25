----------------Report 1--------------------
create proc showDeprtStudent @did int
as
	select * from Students
	where Dept_Id=@did
showDeprtStudent 1
----------------Report 2-----------------------------------
alter proc studentGrades @stID int
as
	select Course_Name,isnull(Grade,0) from Student_Course SC inner join
	Courses C on C.Course_Id=SC.Course_Id
	where Student_Id=@stID
studentGrades 1
----------------Report 3--------------------
alter proc CourseData @inst_id int
as
	select C.Course_Name,count(SC.Student_Id) as StudentsNum 
	from Instructors I 
	inner join Instr_Course IC on I.Instr_Id=IC.Instr_Id
	inner join Courses C on C.Course_Id=IC.Course_Id
	inner Join Student_Course SC on SC.Course_Id=C.Course_Id
	where I.Instr_Id=@inst_id
	group by C.Course_Name

CourseData 3
--------------------Report 4----------------------------------
alter proc TopicCourses @topicID int
as
	select * from Courses 
	where Topic_Id=@topicID

TopicCourses 3
select * from Courses
------------------Report 5------------------
create proc ExamQuestion @EID int
as
	select AQ.* from All_Questions AQ
	inner join Exam_Questions EQ on EQ.QE_id=AQ.Q_Id
	where EQ.exam_id=@EID

-----------Report 6--------------------
create proc getStudentAns (@Exam int, @stud int)
as
	select AQ.Q_body,ans.ans_description,SA.marks 
	from Student_Answer SA inner join
	All_Questions AQ on SA.Q_Id=AQ.Q_Id
	inner join Q_ans ans on ans.ans_id=SA.Student_Answer
	where Exam_Id=@Exam and Student_Id=@stud
getStudentAns 1,1