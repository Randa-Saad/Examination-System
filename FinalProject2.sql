select * from Exams
select * from students_Exam
select * from Exam_Questions
select * from Student_Course
select * from Student_Answer
--------------------Add NewExam---------insert for Exams---------------------------
alter proc AddExam (@courseID int,
@loc varchar(20)='LAb4',@Date date=NULL,
@time time(0)='12:00:00',@dur int=2)
as 
begin
	if (@Date is NUll)
	begin
		select @Date=getdate()
	end
	if not exists (select * from Courses where Course_Id=@courseID)
		select 'No Course with this ID'
	else
	begin
		insert into Exams 
		values(@dur,@Date,@time,@courseID,@loc);
	/* return exam id */
		select concat('Exam with ID: ',max(Exam_Id),' has been created') 
		from Exams
	end
end
AddExam 1000 
select * from Exams
--------------------No Update---------Exams Table-------------
create trigger stopExamUpdating
on Exams
instead of update
as
	select 'update not allowed For Exams Table'
update Exams
	set Exam_Duration=3
	where Exam_Id=1
---------------Delete Exam-----------------------------
create proc DeleteExam @EID int
as
if exists (select * from students_Exam where Exam_ID=@EID)
	select 'you can not delete This Exam check the Relation with students_Exam'
else if exists (select * from Exam_Questions where exam_id=@EID)
	select 'you can not delete This Exam check the Relation with Exam_Questions'
else if exists (select * from Student_Answer where Exam_Id=@EID)
	select 'you can not delete This Exam check the Relation with Student_Answer'
else
begin
	delete from Exams
	where Exam_Id=@EID
end
DeleteExam 1
--select Exams
create proc showExam @EID int
as
	select * from Exams
	where Exam_Id=@EID
----------------Question Exam------------------------
alter proc createExam (@examId as int,@mcq  as int =5 , @TrueFalse as int = 5)
as 
begin 
	if not exists(select * from Exams where Exam_Id=@examId)
		select 'No Exam with this ID'
	else if exists (select * from Exam_Questions where exam_id=@examId)
		select 'This Exam has its Qustions'
	else
	begin
	declare @newExam as table (question_id int , Q_type varchar(10) , examID int )
	/* insert random questions into new exam table variable */
	insert into @newExam 
	select top (@mcq)  Q_Id,Q_Type,@examId from All_Questions 
	where Course_ID in (select Course_ID from Exams where Exam_Id=@examId)
					and Q_Type = 'MCQ'
	order by  NEWID() 
	insert into @newExam 
	select top (@TrueFalse)  Q_Id,Q_Type,@examId from All_Questions 
	where Course_ID in (select Course_ID from Exams where Exam_Id=@examId) 
					and Q_Type = 'TF' 
	order by  NEWID() 
	/*specify the new exam questions ids into exam_Qusetions table*/
	insert into Exam_Questions (Qe_id,exam_id) ---this table insertion
	select   question_id,examId from @newExam 
	end
end
createExam 3
select * from Exam_Questions
select * from All_Questions
---------------------Question-Exam delete-------------------------------
create proc deleteExamQuestions @EID int 
as
if exists (select * from Student_Answer where Exam_Id=@EID)
	select 'can not Delete this ExamQuestions'
else if exists (select * from students_Exam where Exam_ID=@EID)
	select 'can not delete this ExamQuestion'
else
begin
	delete from Exam_Questions
	where exam_id=@EID
end
---------------------Question-Exam noUpdate--------------------------
create trigger stopExamQuestUpdating
on Exam_Questions
instead of update
as
	select 'update not allowed For Exam_Questions Table'

---------------------Generate The Whole Exam----------------------------
alter proc genExam (@courseID int)
as
	if not exists (select * from Courses where Course_Id=@courseID)
		select 'No course with this ID'
	else
	begin
	exec AddExam @courseID;
	declare @ExID int = (select Max(Exam_Id) from Exams)
	exec createExam @ExID
	end

genExam 100
select * from Exams
select * from Exam_Questions
select * from All_Questions
--------------ALL ANS---------------------------------------
create proc insertAllAnswers (@exam_id int , @st_id int ,
@answers varchar(100))
as 
begin 
	declare @t table (q_id int , ans_id int , mark int  ) 

	declare @carry_v varchar(10)
	declare @carry_q_id int ; 
	declare @carry_ans_id int ; 
	
	declare curs cursor for
	select trim(substring(TRIM(value),2,len(trim(value))-2)) from string_split(@answers,',')
	

	open curs 
	fetch next from curs into @carry_v 


	begin try 
		if( (trim(PARSENAME( REPLACE(@carry_v,':','.'),2)) IS NOT  NULL )and (trim(PARSENAME( REPLACE(@carry_v,':','.'),2)) IS NOT NULL) )
		begin
				while @@FETCH_STATUS = 0
				begin 
		
					if( (trim(PARSENAME( REPLACE(@carry_v,':','.'),2)) IS NOT  NULL )and (trim(PARSENAME( REPLACE(@carry_v,':','.'),2)) IS NOT NULL))
					begin
						
						SELECT @carry_q_id =try_convert(int,PARSENAME( REPLACE(@carry_v,':','.'),2))
						select @carry_ans_id =try_convert(int,PARSENAME( REPLACE(@carry_v,':','.'),1))
						declare @mark int ;
						select @mark = (case when  @carry_ans_id = Q_RightAnswer then 1 else 0 end)  from getQA
						where Q_Id = @carry_q_id 
						--select @carry_ans_id,@carry_q_id,@mark
						insert into @t 
						values (@carry_q_id,@carry_ans_id,@mark)
						
						fetch next from curs into @carry_v					
					end
					else 
					begin 
								close curs 
					end

		end	
			if not exists (select s.Q_Id from Student_Answer s inner join @t t
			on s.Exam_ID=@exam_id and @st_id=@st_id and s.Q_Id = t.q_id )
			begin
			insert into Student_Answer (Exam_Id,Student_Id,Q_Id,Student_Answer,marks)
			select @exam_id,@st_id, q_id,ans_id,mark  from @t
			end --insert into student_Ans

			if not exists(select * from students_Exam where Exam_ID=@exam_id and st_id=@st_id )
			begin
			insert into students_exam  --insert into Student_Exam
			values(@exam_id,@st_id)
			end
	end
	else 
		begin 
			select'no data inserted , please check that your values are inserted well   '
			close curs 		
		end
		
			
	end try 
	
	begin catch
		select'no data inserted , please check that your values are inserted well   '
		--select error_message() as message
		delete from @t 

	end catch
	deallocate curs
end 
exec insertAllAnswers 1,1,'{1:1},{6:1},{2:1}'
select * from Exam_Questions
select * from Student_Answer
----------------------noUpdate in Student_Ans----------------
create trigger triggerPreventinsertDuplicateAnswers
on	Student_Answer														-- to prevent inserting many answers
after insert
as
	if (select s.Student_Answer from Student_Answer s) = NULL
	begin
			select 'answer submit succ'
	end
	else
	begin
		rollback
		select 'not allowed to insert dulplicate answer'
	end

create trigger triggerPreventUpdateAnswer
on	Student_Answer
after update
as
	if update(Student_Answer)					-- to prevent update the student answer
	begin
		rollback
		select 'you are not allawed to update your answer'
		end
---------------Delete Student Ans--------------------------------
create proc DeleteStudentAns (@StID int, @Exam int)
as
	delete from Student_Answer
	where Exam_Id=@Exam and Student_Id=@stID
select * from Student_Answer
------------------Insert Student into course------------------------
create proc insertStudentCourse (@StID int, @course int)
as
if not exists(select * from Students where Student_Id=@StID)
	select 'No student with this ID'
else if not exists(select * from Courses where Course_Id=@course)
	select 'No student with this ID'
else
begin
	insert into Student_Course (Student_Id,Course_Id)
	values (@StID,@course)
end
select * from Student_Course
-----------------Function To Get CourseID from Exam ID-------
create function getCourseFromExam(@exam_id int )
returns int 
as
begin
return (select course_id  from Exams where Exam_Id = @exam_id)
end
------------------Calc Grade----------------------------------
---------Function to calculate the Exam result---------------
--------If the student already joined the course------------
---------it will just updated the result-----------
alter proc calResult (@exam_id int , @st_id int  )
as
begin
if not exists(select * from Students where Student_Id=@st_id)
	select 'No student with this ID'
else if not exists (select * from Exams where Exam_Id=@exam_id)
	select 'No exam with this id'
else
begin
	declare @ex_result int 
	select @ex_result = sum(marks)*10 from student_answer
	where student_id= @st_id and exam_id =@exam_id
	select ISNULL( @ex_result, -1) as result
	if not exists(select * from Student_Course where Student_Id =@st_id and Course_Id = dbo.getCourseFromExam(@exam_id))
	begin
	insert into Student_Course 
	values(@st_id , dbo.getCourseFromExam(@exam_id), @ex_result)
	end
	else
	begin
	update Student_Course
	set Grade=@ex_result
	where Student_Id=@st_id and Course_Id=dbo.getCourseFromExam(@exam_id)
	end
end
end
select * from Student_Answer
select * from Student_Course
calResult 1,1
---------Delete Student_Course---------------
create proc DeleteStudentCourse (@stID int, @CourseID int)
as
	delete from Student_Course
	where Student_Id=@stID and Course_Id=@CourseID
---------------------------------------------------------------------
----------------Table Q_ans------------------------------------------
---------------------------------------------------------------------
--showAllQ_ans
alter proc showAllOptions
as
select * from Q_ans

--show choices for Question
create proc showQuestionChoises @QID int
as
	select Q.* from Q_ans Q inner join 
	Q_Options O on Q.ans_id=O.option_id
	where O.question_id=1
--insert
create proc addOption (@ans int, @desc varchar(100))
as 
if exists (select * from Q_ans where ans_id=@ans)
	select 'can not insert option with exists ID'
else
begin
	insert into Q_ans (ans_id,ans_description)
	values (@ans,@desc)
end
addOption 15,'Mohamed Salah'
--update
create proc updateOption (@ans int, @desc varchar(100))
as 
if not exists (select * from Q_ans where ans_id=@ans)
	select 'can not update option with non exists ID'
else
begin
	update Q_ans 
	set ans_description=@desc
	where ans_id=@ans
end
updateOption 100,'ronaldo'
--delete
create proc deleteOption @id int
as
if exists (select * from All_Questions where Q_RightAnswer=@id)
	select 'can not delete Qusetion answer'
else if exists (select * from Q_Options where option_id=@id)
	select 'can not delete Qusetion choice'
else
begin
	delete from Q_ans
	where ans_id=@id
end
deleteOption 1
showAllOptions
----------------------------------------------------------------
--------------------------Table Q_Options-------------------------------
----------------------------------------------------------------
--select
create proc displayOptions
as
	select * from Q_Options

--insert
alter proc addOneChoice (@QID int, @ansID int)
as
if not exists (select * from All_Questions where Q_Id=@QID)
	select 'can not insert non existance Question'
else if not exists (select * from Q_ans where ans_id=@ansID)
	select 'can not insert non existance Question'
else if exists (select * from Q_Options where question_id=@QID and option_id=@ansID)
	select 'this is already inserted'
else
begin
	if exists (select * from All_Questions where Q_Id=@QID and Q_Type='TF')
		begin
			if (@ansID=1 or @ansID=2)
				insert into Q_Options(question_id,option_id)
				values (@QID,@ansID)
			else
				select 'allowed only True or False for TF Questions'
		end
	else
		insert into Q_Options(question_id,option_id)
		values (@QID,@ansID)
end
addOneChoice 1,1
---delete
create proc deleteOnechoice (@QID int,@ans int)
as
delete from Q_Options
where question_id=@QID and option_id=@ans

create proc deleteAllchoices (@QID int) --for a Question
as
delete from Q_Options
where question_id=@QID
-----Q_Options NoUpdate------------------
create trigger stopUpdatingChoices
on Q_Options
instead of update
as
	select 'update not allowed For Q_Options Table'
displayOptions
-----------------------------------------------------------------
-------------All Question Table----------------------------------
-----------------------------------------------------------------
--select
create proc SelectFromAllQuestions(@projection varchar(15) = null ,@q_id int = null , @q_type varchar(10) = null , @course_id int = null)
as 
begin 
	if (@projection is null or @projection = '*')
	select * from All_Questions 
	where (@Q_Id is null or Q_Id = @q_id) and (@Q_Type is null or Q_Type =@q_type ) and (@Course_ID is null or Course_ID = @course_id)

	else if ( @projection ='Qtype' )
	select Q_Type as Qtype from All_Questions 
	where (@Q_Id is null or Q_Id = @q_id) and (@Q_Type is null or Q_Type =@q_type ) and (@Course_ID is null or Course_ID = @course_id)

	else if (@projection ='QBody' )
	select Q_body QBody from All_Questions 
	where (@Q_Id is null or Q_Id = @q_id) and (@Q_Type is null or Q_Type =@q_type ) and (@Course_ID is null or Course_ID = @course_id)

	else if (@projection = 'course')
	select Course_ID  course from All_Questions 
	where (@Q_Id is null or Q_Id = @q_id) and (@Q_Type is null or Q_Type =@q_type ) and (@Course_ID is null or Course_ID = @course_id)

	else if (@projection ='rightAnswer')
	select Q_RightAnswer rightAnswer from All_Questions 
	where (@Q_Id is null or Q_Id = @q_id) and (@Q_Type is null or Q_Type =@q_type ) and (@Course_ID is null or Course_ID = @course_id)

end 
-----insert
create proc insertQuestion (@q_id int , @q_type varchar(10) = null , @q_body varchar(200)= null ,@rigth_answer int = null ,@course_id int = null )
						 
as
begin
	if(@q_id is not null and @q_type  is not null and @q_type is not null and  @q_body is not null  and @course_id is not null )
	begin
		if not exists (select * from Q_ans where ans_id=@rigth_answer)
			select 'can not insert answer does not exists'
		else if not exists(select * from  All_Questions where q_id = @q_id)
		begin
			insert into All_Questions
			values(@q_id,@q_type,@q_body,@rigth_answer,@course_id)
			end
		else
		begin
			select 'there is already a question  assigned with this id'
		end
	end
	else 
	begin 
		select 'please insert all values required' 
	end 
end
--update
create proc UpdateQuestion @id int , @type varchar(50),@body varchar(200) ,
						  @RA int,@course_id int
as
	begin


	if  exists(select * from Courses c where c.Course_Id = @course_id) --check if topic exists
		begin

	if  exists(select * from Q_ans where ans_id = @RA) --check if topic exists
		begin

		if exists(select * from  All_Questions q where q.Q_Id = @id)-- chcek if Question exists
		begin
			update All_Questions 
			set Q_Id = @id , 
				Q_Type = @type,
				Q_body = @body,
				Q_RightAnswer = @RA,
				Course_ID = @course_id
				
			where Q_Id = @id
			end
		else
		begin
			select 'there is no question with id '+ convert(varchar(20),@id)
		end
		end
		else
		begin
			select 'there is no id for such answer'
		end
		end
		else
		begin
			select 'there is no id for such course'
		end


	end
--delete
create proc DeleteQuestion @id int
as
	begin
if exists (select * from Exam_Questions where QE_id=@id)
	select 'Can not Delete Question in Exam'
else
begin
		if exists(select * from All_Questions q where q.Q_Id = @id)
		begin
			delete from All_Questions
			where Q_Id = @id
			end
		else
		begin
			select 'there is no question with id '+ convert(varchar(20),@id)
			end
end
	end
 

