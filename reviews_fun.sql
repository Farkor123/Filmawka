use filmawka;

-- functions
drop function if exists get_main_review_id_by_movie_id;
DELIMITER //
create function get_main_review_id_by_movie_id(movie_id int) returns int reads sql data
begin
	declare main_review_id int;
    select m.review_id from main_reviews m where m.movie_id=movie_id into main_review_id;
    return main_review_id;
end//
DELIMITER ;

drop function if exists get_points_from_waiting_review;
DELIMITER //
create function get_points_from_waiting_review(review_id int) returns int reads sql data
begin
	declare points int;
    select w.points from waiting_reviews w where w.review_id=review_id into points;
    return points;
end//
DELIMITER ;

drop function if exists get_the_most_pointed_review;
DELIMITER //
create function get_the_most_pointed_review(movie_id int) returns int reads sql data
begin
	declare review_id int;
    select w.review_id from waiting_reviews w where w.movie_id=movie_id AND w.points=(select MAX(ww.points) 
		from waiting_reviews ww where ww.movie_id=movie_id) into review_id;
    return review_id;
end//
DELIMITER ;

drop function if exists add_point_to_review;
DELIMITER //
create function add_point_to_review(waiting_review_id int,user_id_that_add_point int) returns BOOLEAN reads sql data
begin
	if not exists(select * from points_on_reviews p where p.user_id=user_id_that_add_point and p.waiting_reviews_id=waiting_review_id)
    AND exists(select * from waiting_reviews where review_id=waiting_review_id)
    AND exists(select * from users where user_id=user_id_that_add_point) 
    then
		insert into points_on_reviews(waiting_reviews_id,user_id) values(waiting_review_id,user_id_that_add_point);
		return true;
		end if;
    return false;
end//
DELIMITER ;

drop function if exists remove_point_from_review;
DELIMITER //
create function remove_point_from_review(waiting_review_id int,user_id_that_add_point int) returns BOOLEAN reads sql data
begin
	if exists(select * from points_on_reviews p where p.user_id=user_id_that_add_point and p.waiting_reviews_id=waiting_review_id)
    AND exists(select * from waiting_reviews where review_id=waiting_review_id)
    AND exists(select * from users where user_id=user_id_that_add_point) 
    then
		delete from points_on_reviews  where user_id=user_id_that_add_point and waiting_reviews_id=waiting_review_id;
		return true;
		end if;
    return false;
end//
DELIMITER ;



-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- procedures
drop procedure if exists get_waiting_reviews_info_by_movie_id;
DELIMITER //
create procedure get_waiting_reviews_info_by_movie_id(movie_id int)
begin

    declare title, original_title varchar(30);
     if exists(select * from movies m where m.movie_id = movie_id) then
		select m.title, m.original_title
		from movies m
		where m.movie_id = movie_id
		into title, original_title;
        end if;
        select *,title,original_title from waiting_reviews w where w.movie_id=movie_id;
        
end//
DELIMITER ;

drop procedure if exists get_waiting_reviews_info_by_review_id;
DELIMITER //
create procedure get_waiting_reviews_info_by_review_id(review_id int)
begin
		declare movie_id int;
		declare title, original_title varchar(30);
		select w.movie_id from waiting_reviews w where w.review_id=review_id into movie_id;
		if exists(select * from movies m where m.movie_id = movie_id) then
			select m.title, m.original_title
			from movies m
			where m.movie_id = movie_id
			into title, original_title;
        end if;
        select *,title,original_title from waiting_reviews w where w.review_id=review_id;
        
end//
DELIMITER ;



drop procedure if exists get_main_review_info_by_review_id;
DELIMITER //
create procedure get_main_review_info_by_review_id(review_id int)
begin
	declare movie_id int;
    declare title, original_title, first_name_writer,last_name_writer,
    first_name_moderator, last_name_moderator varchar(30);
    if exists(select * from main_reviews m where m.review_id=review_id) 
    then
		select m.movie_id from main_reviews m where m.review_id=review_id into movie_id;
    
		if exists(select * from movies m where m.movie_id = movie_id) then
			select m.title, m.original_title
			from movies m
			where m.movie_id = movie_id
			into title, original_title;
	
	
	
			select u.first_name,u.last_name from users u,main_reviews m 
				where u.user_id=m.accept_review_moderator AND review_id=m.review_id 
				into first_name_moderator,last_name_moderator;
            
			select u.first_name,u.last_name from users u,main_reviews m,waiting_reviews w 
				where u.user_id=w.review_id AND review_id=m.review_id AND w.review_id=m.old_review_id
				into first_name_writer,last_name_writer;

			select m.review_id,m.old_review_id,title,original_title,w.review_writer_id,first_name_writer,last_name_writer, m.accept_review_moderator 
				as review_moderator, first_name_moderator,last_name_moderator,m.review from main_reviews m,waiting_reviews w 
				where m.review_id=review_id AND m.old_review_id=w.review_id;
        
        
        ELSE 
			SELECT 'review istnieje do nieistniejacego filmu';
		end if;
			ELSE SELECT 'nieprawidlowe review id';
    end if;
end//
DELIMITER ;


drop procedure if exists get_main_review_info_by_movie_id;
DELIMITER //
create procedure get_main_review_info_by_movie_id(movie_id int)
begin
	declare main_review_id int;
    declare title, original_title, first_name_writer,last_name_writer,
    first_name_moderator, last_name_moderator varchar(30);
     if exists(select * from movies m where m.movie_id = movie_id) then
		select m.title, m.original_title
		from movies m
		where m.movie_id = movie_id
		into title, original_title;
	
	SET main_review_id=get_main_review_id_by_movie_id(movie_id);
	if main_review_id IS NOT NULL then
		select u.first_name,u.last_name from users u,main_reviews m 
			where u.user_id=m.accept_review_moderator AND main_review_id=m.review_id 
			into first_name_moderator,last_name_moderator;
            
		select u.first_name,u.last_name from users u,main_reviews m,waiting_reviews w 
			where u.user_id=w.review_id AND main_review_id=m.review_id AND w.review_id=m.old_review_id
            into first_name_writer,last_name_writer;

		select m.review_id,m.old_review_id,title,original_title,w.review_writer_id,first_name_writer,last_name_writer, m.accept_review_moderator 
        as review_moderator, first_name_moderator,last_name_moderator,m.review from main_reviews m,waiting_reviews w 
			where m.review_id=main_review_id AND m.old_review_id=w.review_id;
        
        
        ELSE SELECT 'ten film nie ma main review';
	end if;
    ELSE SELECT 'nie ma filmu o takim id';
    end if;
end//
DELIMITER ;

drop procedure if exists edit_waiting_review;
DELIMITER //
create procedure edit_waiting_review(waiting_review_id int,review MEDIUMTEXT,user_id int)
begin
	if exists(select * from waiting_reviews w where w.review_id=waiting_review_id) 
	then
		if (select user_id from waiting_reviews where review_id=waiting_review_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1
        then
            if exists(select * from main_reviews m where m.old_review_id=waiting_review_id)
				then
					update waiting_reviews w set w.is_edited=true where w.review_id=waiting_review_id;
			end if;
			update waiting_reviews w set w.review=review where w.review_id=waiting_review_id;
		else
		select 'brak prawa do edycji tego review';
        end if;
	else
    select 'niewlasciwe id recenzji';
    end if;
end//
DELIMITER ;

drop procedure if exists set_waiting_review_to_main_review;
DELIMITER //
create procedure set_waiting_review_to_main_review(waiting_review_id int,moderator_id int)
begin
	declare new_review MEDIUMTEXT;
    declare movie_id int;
    if (select is_moderator from users where user_id=moderator_id)=1 then
		if exists(select * from waiting_reviews w where w.review_id=waiting_review_id)
			then
				SET movie_id=(select w.movie_id from waiting_reviews w where w.review_id= waiting_review_id);
				SET new_review=(select w.review from waiting_reviews w where w.review_id=waiting_review_id);
			if exists(select * from main_reviews m where m.movie_id=movie_id) 
				then
				UPDATE main_reviews m SET m.review=new_review,m.accept_review_moderator= moderator_id,m.old_review_id=waiting_review_id where m.movie_id=movie_id;
			else
				insert into main_reviews(old_review_id,accept_review_moderator,movie_id,review) values (waiting_review_id,moderator_id,movie_id,new_review);
		end if;
		else
			select 'nie ma takiego czekajcego review';
        end if;
	else
		select 'brak uprawnien';
	end if;
        
end//
DELIMITER ;

drop procedure if exists get_waiting_review_id_by_movie_id;
DELIMITER //
create procedure get_waiting_review_id_by_movie_id(movie_id int)
begin
	select w.review_id from waiting_reviews w where w.movie_id=movie_id ;
end//
DELIMITER ;

-- triggers
drop trigger if exists sum_points;
DELIMITER // 
CREATE TRIGGER sum_points AFTER INSERT ON points_on_reviews for each row
begin
	update waiting_reviews w SET w.points=w.points+1 WHERE new.waiting_reviews_id=w.review_id;
end//
DELIMITER ;

drop trigger if exists rem_points;
DELIMITER // 
CREATE TRIGGER rem_points AFTER DELETE ON points_on_reviews for each row
begin
	update waiting_reviews w SET w.points=w.points-1 WHERE OLD.waiting_reviews_id=w.review_id;
end//
DELIMITER ;



CALL get_waiting_review_id_by_movie_id(2);
select get_main_review_id_by_movie_id(1);
Call get_main_review_info(3);
select get_the_most_pointed_review(2);
select remove_point_from_review(7,1);
select get_points_from_waiting_review(7);
select add_point_to_review(7,1);
select get_points_from_waiting_review(7);
select remove_point_from_review(7,1);
select get_points_from_waiting_review(7);
SELECT * from main_reviews;
CALL set_waiting_review_to_main_review(6,1);
SELECT * from main_reviews;
CALL edit_waiting_review(1,"test edytowania");
SELECT * from waiting_reviews;
CALL get_waiting_reviews_info_by_movie_id(3);
CALL get_waiting_reviews_info_by_review_id(2);