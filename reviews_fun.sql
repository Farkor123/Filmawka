use filmawka;
drop function if exists get_main_review_id_by_movie_id;
DELIMITER //
create function get_main_review_id_by_movie_id(movie_id int) returns int reads sql data
begin
	declare main_review_id int;
    select m.review_id from main_reviews_movie m where m.movie_id=movie_id into main_review_id;
        if main_review_id is null then
		signal sqlstate '10002';
    end if;
    
    return main_review_id;
end//
DELIMITER ;

drop function if exists get_main_review_id_by_tv_series_id;
DELIMITER //
create function get_main_review_id_by_tv_series_id(tv_series_id int) returns int reads sql data
begin
	declare main_review_id int;
    select m.review_id from main_reviews_tv_series m where m.tv_series_id=tv_series_id into main_review_id;
	if main_review_id is null then
	  signal sqlstate '10002';
    end if;
    
    return main_review_id;
end//
DELIMITER ;

drop function if exists get_points_from_waiting_review_movie;
DELIMITER //
create function get_points_from_waiting_review_movie(review_id int) returns int reads sql data
begin
	declare points int;
    select w.points from waiting_reviews_movies w where w.review_id=review_id into points;
	if points is null then
	  signal sqlstate '10002';
    end if;
    
    return points;
end//
DELIMITER ;

drop function if exists get_points_from_waiting_review_tv_series;
DELIMITER //
create function get_points_from_waiting_review_tv_series(review_id int) returns int reads sql data
begin
	declare points int;
    select w.points from waiting_reviews_tv_series w where w.review_id=review_id into points;
	if points is null then
	  signal sqlstate '10002';
    end if;
    
	return points;
end//
DELIMITER ;

drop function if exists get_the_most_pointed_review_of_movie;
DELIMITER //
create function get_the_most_pointed_review_of_movie(movie_id int) returns int reads sql data
begin
	declare review_id int;
    select w.review_id from waiting_reviews_movies w where w.movie_id=movie_id AND w.points=(select MAX(ww.points) 
		from waiting_reviews_movies ww where ww.movie_id=movie_id) LIMIT 1 into review_id;
    if review_id is null then
	  signal sqlstate '10002';
    end if;
    
	return review_id;
end//
DELIMITER ;

drop function if exists get_the_most_pointed_review_of_tv_series;
DELIMITER //
create function get_the_most_pointed_review_of_tv_series(tv_series_id int) returns int reads sql data
begin
	declare review_id int;
    select w.review_id from waiting_reviews_tv_series w where w.tv_series_id=tv_series_id AND w.points=(select MAX(ww.points) 
		from waiting_reviews_tv_series ww where ww.tv_series_id=tv_series_id) LIMIT 1 into review_id;
    if review_id is null then
	  signal sqlstate '10002';
    end if;
    
	return review_id;
end//
DELIMITER ;

drop function if exists get_wait_review_id_by_movie_id_and_user_id;
DELIMITER //
create function get_wait_review_id_by_movie_id_and_user_id(movie_id int,user_id int) returns int reads sql data
begin
	declare review_id int;
    select m.review_id from waiting_reviews_movies m where m.movie_id=movie_id and m.review_writer_id=user_id LIMIT 1 into review_id;
    if review_id is null then
	  signal sqlstate '10002';
    end if;
    
	return review_id;
end//
DELIMITER ;


drop function if exists get_wait_review_id_by_tv_series_id_and_user_id;
DELIMITER //
create function get_wait_review_id_by_tv_series_id_and_user_id(tv_series_id int,user_id int) returns int reads sql data
begin
	declare review_id int;
    select m.review_id from waiting_reviews_tv_series m where m.tv_series_id=tv_series_id and m.review_writer_id=user_id LIMIT 1 into review_id;
    if review_id is null then
	  signal sqlstate '10002';
    end if;
    
	return review_id;
end//
DELIMITER ;


-- -----------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- procedures
drop procedure if exists add_point_to_review_movie;
DELIMITER //
create procedure add_point_to_review_movie(waiting_review_id int,user_id_that_add_point int)
begin
    	if not exists(select * from points_on_reviews_movie p where p.user_id=user_id_that_add_point and p.waiting_reviews_id=waiting_review_id)
    then
    
		if exists(select * from waiting_reviews_movies where review_id=waiting_review_id)
        then
			if is_user_logged_in(user_id_that_add_point) != 0 
			then
				insert into points_on_reviews_movie(waiting_reviews_id,user_id) values(waiting_review_id,user_id_that_add_point);
				select 'pomyslnie dodano punkt'  as info;
			else
				select 'error: uzytkownik niezalogowany' as info;
			end if;
		else
			select 'error: nieprawidlowe id od czekajacego review' as info;
		end if;
	else 
		select 'error: punkt zostal juz wczesniej dodany przez tego uzytkownika na ta recjezje' as info;
    end if;
end//
DELIMITER ;

drop procedure if exists add_point_to_review_tv_series;
DELIMITER //
create procedure add_point_to_review_tv_series(waiting_review_id int,user_id_that_add_point int) 
begin
	if exists(select * from waiting_reviews_tv_series where review_id=waiting_review_id)
    then
		if not exists(select * from points_on_reviews_tv_series p where p.user_id=user_id_that_add_point and p.waiting_reviews_id=waiting_review_id)
		then
			if is_user_logged_in(user_id_that_add_point) != 0 
			then
				insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values(waiting_review_id,user_id_that_add_point);
				select 'pomyslnie dodano punkt' as info;
			else
				select 'error: uzytkownik niezalogowany' as info;
			end if;
		else 
			select 'error: punkt zostal juz wczesniej dodany przez tego uzytkownika na ta recjezje' as info;
		end if;
    else
			select 'error: nieprawidlowe id od czekajacego review' as info;
	end if;
end//
DELIMITER ;

drop procedure if exists remove_point_from_review_movie;
DELIMITER //
create procedure remove_point_from_review_movie(waiting_review_id int,user_id_that_add_point int) 
begin
	if exists(select * from waiting_reviews_movies where review_id=waiting_review_id)
	then
		if exists(select * from points_on_reviews_movie p where p.user_id=user_id_that_add_point and p.waiting_reviews_id=waiting_review_id)
		then
				if is_user_logged_in(user_id_that_add_point) != 0 
					then
						delete from points_on_reviews_movie  where points_on_reviews_movie.user_id=user_id_that_add_point and points_on_reviews_movie.waiting_reviews_id=waiting_review_id;
						select 'pomyslnie usunieto punkt' as info;
					else
						select 'error: user nie zalogowany' as info;
					end if;
		else
			select 'error: recenzja wczesniej tego punktu nie miala' as info;
		end if;
	else
		select 'error: nieprawidlowe waiting review id' as info;
    end if;
end//
DELIMITER ;

drop procedure if exists remove_point_from_review_tv_series;
DELIMITER //
create procedure remove_point_from_review_tv_series(waiting_review_id int,user_id_that_add_point int)
begin
	if exists(select * from points_on_reviews_tv_series p where p.user_id=user_id_that_add_point and p.waiting_reviews_id=waiting_review_id)
    then
		if exists(select * from waiting_reviews_tv_series where review_id=waiting_review_id)
			then
				if is_user_logged_in(user_id_that_add_point) != 0
					then
						delete from points_on_reviews_tv_series  where user_id=user_id_that_add_point and waiting_reviews_id=waiting_review_id;
						select 'pomyslnie usunieto punkt' as info;
					else
						select 'error: user nie zalogowany lub nie ma prawa do usuwania tego punktu' as info;
					end if;
			else
				select 'error: nieprawidlowe waiting review id' as info;
			end if;
		else
			select 'error: nie udalo sie usunac punktu : recenzja wczesniej tego punktu nie miala' as info;
		end if;
		
end//
DELIMITER ;





drop procedure if exists add_waiting_movie_review;
DELIMITER //
create procedure add_waiting_movie_review(movie_id int,user_id int,review MEDIUMTEXT)
begin
	if is_user_logged_in(user_id) != 0 
    then
		if exists(select * from movies m where m.movie_id = movie_id) then
			if not exists(select * from waiting_reviews_movies m where m.movie_id=movie_id and m.review_writer_id=user_id)
            then
				insert into waiting_reviews_movies(movie_id, review_writer_id, review, points,review_date) values (movie_id, user_id, review,0,NOW());
				select 'pomyslnie dodano recenzje' as info;
            else 
				select 'error: ten uzytkownik dodal juz recenzje do tego filmu';
			end if;
		else
			select 'error: nieprawidlowe movie id' as info;
		end if;
	else
		select 'error: user niezalogowany' as info;
	end if;
end//
DELIMITER ;

drop procedure if exists add_waiting_tv_series_review;
DELIMITER //
create procedure add_waiting_tv_series_review(tv_series_id int,user_id int,review MEDIUMTEXT)
begin
	if is_user_logged_in(user_id) != 0 
    then
		if exists(select * from tv_series m where m.tv_series_id = tv_series_id) then
			if not exists(select * from waiting_reviews_tv_series m where m.tv_series_id =tv_series_id and m.review_writer_id=user_id)
            then
				insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review, points,review_date) values (tv_series_id, user_id, review,0,NOW());
				select 'pomyslnie dodano recenzje' as info;
			else
				select 'error: ten uzytkownik dodal juz recenzje do tej serii' as info;
			end if;
		else
			select 'error: nieprawidlowe movie id' as info;
		end if;
	else
		select 'error: user niezalogowany' as info;
	end if;
end//
DELIMITER ;



drop procedure if exists remove_waiting_movie_review;
DELIMITER //
create procedure remove_waiting_movie_review(waiting_review_id int,user_id int)
begin
	if is_user_logged_in(user_id) != 0 
    then
		if exists(select * from waiting_reviews_movies m where review_id=waiting_review_id)
		then
    
			if (select review_writer_id from waiting_reviews_movies where review_id=waiting_review_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1
			then
				if exists(select * from points_on_reviews_movie p where waiting_review_id=p.waiting_reviews_id)
				then
					DELETE from points_on_reviews_movie  where waiting_review_id=waiting_reviews_id;
				end if;
				if exists(select * from main_reviews_movie m where m.old_review_id=waiting_review_id)
				then
					DELETE from main_reviews_movie where old_review_id=waiting_review_id;
				end if;
                
					DELETE from waiting_reviews_movies where review_id=waiting_review_id;
					select 'pomyslnie usunieto recenzje' as info;
			else 
				select 'error: brak odpowiednich uprawnien 'as info;
			end if;
		else
			select 'error: niewlasciwy id oczekujacej recenzji'as info;
		end if;
	else
		select 'error: user niezalogowany ' as info;
	end if;
end//
DELIMITER ;



drop procedure if exists remove_waiting_tv_series_review;
DELIMITER //
create procedure remove_waiting_tv_series_review(waiting_review_id int,user_id int)
begin
	if is_user_logged_in(user_id) != 0 
    then
		if exists(select * from waiting_reviews_tv_series m where review_id=waiting_review_id)
		then
    
		if ((select review_writer_id from waiting_reviews_tv_series where review_id=waiting_review_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1)
		then
			if exists(select * from points_on_reviews_tv_series p where waiting_review_id=p.waiting_reviews_id)
            then
				DELETE from points_on_reviews_tv_series  where waiting_review_id=waiting_reviews_id;
            end if;
            if exists(select * from main_reviews_tv_series m where m.old_review_id=waiting_review_id)
            then
				DELETE from main_reviews_tv_series where old_review_id=waiting_review_id;
			end if;
				DELETE from waiting_reviews_tv_series where review_id=waiting_review_id;
				select 'pomyslnie usunieto recenzje' as info;
            else 
				select 'error: brak odpowiednich uprawnien 'as info;
			end if;
		else
        select 'error: niewlasciwy id oczekujacej recenzji'as info;
		end if;
	else
		select 'error: user niezalogowany ' as info;
	end if;
end//
DELIMITER ;




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
        select *,title,original_title from waiting_reviews_movies w where w.movie_id=movie_id;
        
end//
DELIMITER ;

drop procedure if exists get_waiting_reviews_info_by_tv_series_id;
DELIMITER //
create procedure get_waiting_reviews_info_by_tv_series_id(tv_series_id int)
begin

    declare title, original_title varchar(30);
     if exists(select * from tv_series t where t.tv_series_id = tv_series_id) then
		select m.title, m.original_title
		from  tv_series m
		where m.tv_series_id = tv_series_id
		into title, original_title;
        end if;
        select *,title,original_title from waiting_reviews_tv_series w where w.tv_series_id=tv_series_id;
        
end//
DELIMITER ;

drop procedure if exists get_waiting_reviews_movie_info_by_review_id;
DELIMITER //
create procedure get_waiting_reviews_movie_info_by_review_id(review_id int)
begin
		declare tv_id int;
		declare title, original_title varchar(30);
        

			select w.movie_id from waiting_reviews_movies w where w.review_id=review_id into tv_id;

			select m.title, m.original_title
			from movies m
			where m.movie_id = tv_id
			into title, original_title;

        select *,title,original_title from waiting_reviews_movies w where w.review_id=review_id;
        
end//
DELIMITER ;

drop procedure if exists get_waiting_reviews_tv_series_info_by_review_id;
DELIMITER //
create procedure get_waiting_reviews_tv_series_info_by_review_id(review_id int)
begin
		declare tv_id int;
		declare title, original_title varchar(30);
        
			select w.tv_series_id from waiting_reviews_tv_series w where w.review_id=review_id into tv_id;
			select m.title, m.original_title
			from tv_series m
			where m.tv_series_id = tv_id
			into title, original_title;
            
        select *,title,original_title from waiting_reviews_tv_series w where w.review_id=review_id;
        
end//
DELIMITER ;



drop procedure if exists get_main_movie_review_info_by_review_id;
DELIMITER //
create procedure get_main_movie_review_info_by_review_id(review_id int)
begin
	declare tv_id int;
    declare txt text;
    declare title, original_title, first_name_writer,last_name_writer,
    first_name_moderator, last_name_moderator varchar(30);
    
    if exists(select * from main_reviews_tv_series m where m.review_id=review_id) 
    then
		select m.movie_id from main_reviews_movie m where m.review_id=review_id into tv_id;
        
			select m.title, m.original_title
			from movies m
			where m.movie_id = tv_id
			into title, original_title;

				
	
			select u.first_name,u.last_name from users u,main_reviews_movie m 
				where u.user_id=m.accept_review_moderator AND review_id=m.review_id 
				into first_name_moderator,last_name_moderator;
            
			select u.first_name,u.last_name from users u,main_reviews_movie m,waiting_reviews_movies w 
				where u.user_id=w.review_id AND review_id=m.review_id AND w.review_id=m.old_review_id
				into first_name_writer,last_name_writer;

			select m.review_id,m.old_review_id,title,original_title,w.review_writer_id,first_name_writer,last_name_writer, m.accept_review_moderator 
				as review_moderator, first_name_moderator,last_name_moderator,m.review from main_reviews_movie m,waiting_reviews_movies w 
				where m.review_id=review_id AND m.old_review_id=w.review_id;
        
			ELSE SELECT 'nieprawidlowe review id';
    end if;
end//
DELIMITER ;










drop procedure if exists get_main_tv_series_review_info_by_review_id;
DELIMITER //
create procedure get_main_tv_series_review_info_by_review_id(review_id int)
begin
	declare tv_id int;
    declare txt text;
    declare title, original_title, first_name_writer,last_name_writer,
    first_name_moderator, last_name_moderator varchar(30);
    if exists(select * from main_reviews_tv_series m where m.review_id=review_id) 
    then

			select m.tv_series_id from main_reviews_tv_series m where m.review_id=review_id into tv_id;
        

			select m.title, m.original_title
			from tv_series m
			where m.tv_series_id = tv_id
			into title, original_title;
				
	
			select u.first_name,u.last_name from users u,main_reviews_tv_series m 
				where u.user_id=m.accept_review_moderator AND review_id=m.review_id 
				into first_name_moderator,last_name_moderator;
            
			select u.first_name,u.last_name from users u,main_reviews_tv_series m,waiting_reviews_tv_series w 
				where u.user_id=w.review_id AND review_id=m.review_id AND w.review_id=m.old_review_id
				into first_name_writer,last_name_writer;

			select m.review_id,m.old_review_id as 'id filmu/serii tv',title,original_title,w.review_writer_id,first_name_writer,last_name_writer, m.accept_review_moderator 
				as review_moderator, first_name_moderator,last_name_moderator,m.review from main_reviews_tv_series m,waiting_reviews_tv_series w 
				where m.review_id=review_id AND m.old_review_id=w.review_id;
        
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
		select u.first_name,u.last_name from users u,main_reviews_movie m 
			where u.user_id=m.accept_review_moderator AND main_review_id=m.review_id 
			into first_name_moderator,last_name_moderator;
            
		select u.first_name,u.last_name from users u,main_reviews_movie m,waiting_reviews_movies w 
			where u.user_id=w.review_id AND main_review_id=m.review_id AND w.review_id=m.old_review_id
            into first_name_writer,last_name_writer;

		select m.review_id,m.old_review_id,title,original_title,w.review_writer_id,first_name_writer,last_name_writer, m.accept_review_moderator 
        as review_moderator, first_name_moderator,last_name_moderator,m.review,m.review_date from main_reviews_movie m,waiting_reviews_movies w 
			where m.review_id=main_review_id AND m.old_review_id=w.review_id;
        
        
        ELSE SELECT 'ten film nie ma main review';
	end if;
    ELSE SELECT 'nie ma filmu o takim id';
    end if;
end//
DELIMITER ;

drop procedure if exists get_main_review_info_by_tv_series_id;
DELIMITER //
create procedure get_main_review_info_by_tv_series_id(tv_series_id int)
begin
	declare main_review_id int;
    declare title, original_title, first_name_writer,last_name_writer,
    first_name_moderator, last_name_moderator varchar(30);
     if exists(select * from tv_series m where m.tv_series_id = tv_series_id) then
		select m.title, m.original_title
		from tv_series m
		where m.tv_series_id = tv_series_id
		into title, original_title;
	
	SET main_review_id=get_main_review_id_by_tv_series_id(tv_series_id);
	if main_review_id IS NOT NULL then
		select u.first_name,u.last_name from users u,main_reviews_tv_series m 
			where u.user_id=m.accept_review_moderator AND main_review_id=m.review_id 
			into first_name_moderator,last_name_moderator;
            
		select u.first_name,u.last_name from users u,main_reviews_tv_series m,waiting_reviews_tv_series w 
			where u.user_id=w.review_id AND main_review_id=m.review_id AND w.review_id=m.old_review_id
            into first_name_writer,last_name_writer;

		select m.review_id,m.old_review_id,title,original_title,w.review_writer_id,first_name_writer,last_name_writer, m.accept_review_moderator 
        as review_moderator, first_name_moderator,last_name_moderator,m.review, m.review_date from main_reviews_tv_series m,waiting_reviews_tv_series w 
			where m.review_id=main_review_id AND m.old_review_id=w.review_id;
        
        
        ELSE SELECT 'ta seria tv nie ma main review';
	end if;
    ELSE SELECT 'nie ma serii tv o takim id';
    end if;
end//
DELIMITER ;



drop procedure if exists edit_waiting_movie_review;
DELIMITER //
create procedure edit_waiting_movie_review(waiting_review_id int,review MEDIUMTEXT,user_id int)
begin
	if exists(select * from waiting_reviews_movies w where w.review_id=waiting_review_id) 
	then
		if ((select review_writer_id from waiting_reviews_movies where review_id=waiting_review_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1)
        AND is_user_logged_in(user_id) != 0 
        then
            if exists(select * from main_reviews_movie m where m.old_review_id=waiting_review_id)
				then
					update waiting_reviews_movies w set w.is_edited=true,w.review=review where w.review_id=waiting_review_id;
			end if;
			update waiting_reviews_movies w set w.review=review where w.review_id=waiting_review_id;
		else
		select 'brak prawa do edycji tego review lub user nie zalogowany';
        end if;
	else
    select 'niewlasciwe id recenzji';
    end if;
end//
DELIMITER ;

drop procedure if exists edit_waiting_tv_series_review;
DELIMITER //
create procedure edit_waiting_tv_series_review(waiting_review_id int,review MEDIUMTEXT,user_id int)
begin
	if exists(select * from waiting_reviews_tv_series w where w.review_id=waiting_review_id) 
	then
		if ((select review_writer_id from waiting_reviews_tv_series where review_id=waiting_review_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1)
        AND is_user_logged_in(user_id) != 0 
        then
            if exists(select * from main_reviews_tv_series m where m.old_review_id=waiting_review_id)
				then
					update waiting_reviews_tv_series w set w.is_edited=true,w.review=review where w.review_id=waiting_review_id;
                    else
                    update waiting_reviews_tv_series w set w.review=review where w.review_id=waiting_review_id;
			end if;
			
		else
		select 'brak prawa do edycji tego review lub user nie zalogowany';
        end if;
	else
    select 'niewlasciwe id recenzji';
    end if;
end//
DELIMITER ;


drop procedure if exists set_waiting_review_movie_to_main_review;
DELIMITER //
create procedure set_waiting_review_movie_to_main_review(waiting_review_id int,moderator_id int)
begin
	declare new_review MEDIUMTEXT;
    declare tv_id int;
    declare is_movie boolean;
    
    if (select is_moderator from users where user_id=moderator_id)=1 AND is_user_logged_in(moderator_id) != 0   then
		if exists(select * from waiting_reviews_movies w where w.review_id=waiting_review_id)
			then
				SET tv_id=(select w.movie_id from waiting_reviews_movies w where w.review_id= waiting_review_id LIMIT 1);

				SET new_review=(select w.review from waiting_reviews_movies w where w.review_id=waiting_review_id);
			if exists(select * from main_reviews_movie m where m.movie_id=tv_id)
			then
					UPDATE main_reviews_movie m SET m.review=new_review,m.accept_review_moderator= moderator_id,m.old_review_id=waiting_review_id,review_date=NOW() where m.movie_id=tv_id;
			else
					insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review,review_date) values (waiting_review_id,moderator_id,tv_id,new_review,NOW());
			end if;
		else
			select 'nie ma takiego czekajcego review';
        end if;
	else
		select 'brak uprawnien lub moderator nie zalogowany';
	end if;
        
end//
DELIMITER ;

drop procedure if exists set_waiting_review_tv_series_to_main_review;
DELIMITER //
create procedure set_waiting_review_tv_series_to_main_review(waiting_review_id int,moderator_id int)
begin
	declare new_review MEDIUMTEXT;
    declare tv_id int;
    if (select is_moderator from users where user_id=moderator_id)=1 AND is_user_logged_in(moderator_id) != 0  then
		if exists(select * from waiting_reviews_tv_series w where w.review_id=waiting_review_id)
			then

				SET tv_id=(select w.tv_series_id from waiting_reviews_tv_series w where w.review_id=waiting_review_id LIMIT 1);
				SET new_review=(select w.review from waiting_reviews_tv_series w where w.review_id=waiting_review_id);
			if exists(select * from main_reviews_tv_series m where m.tv_series_id=tv_id) OR exists (select * from main_reviews_tv_series m where m.tv_series_id=tv_id) 
			then
				UPDATE main_reviews_tv_series m SET m.review=new_review,m.accept_review_moderator= moderator_id,m.old_review_id=waiting_review_id,m.review_date=NOW() where m.tv_series_id=tv_id;
			else
				insert into main_reviews_tv_series(old_review_id,accept_review_moderator,tv_series_id,review,review_date) values (waiting_review_id,moderator_id,tv_id,new_review,NOW());
			end if;
		else
			select 'nie ma takiego czekajcego review';
        end if;
	else
		select 'brak uprawnien lub user nie zalogowany';
	end if;
        
end//
DELIMITER ;


drop procedure if exists get_all_reviews_by_movie_id;
DELIMITER //
create procedure get_all_reviews_by_movie_id(movie_id int) 
begin
	declare user_name text;
    declare user_surname text;
    declare user_id int;
    declare review_date datetime;
    declare review mediumtext;
    	declare points int;
    declare is_edited boolean;
    declare edit varchar(5);
	declare finished boolean default false;
    declare output LONGTEXT default '';

   
	declare tv_cursor cursor for
    select w.review_writer_id, w.review_date,w.review,w.points,w.is_edited
    from waiting_reviews_movies w
    where w.movie_id=movie_id
    order by w.review_date desc;
    
    declare continue handler for not found set finished = true;
		open tv_cursor;
		get_comments: loop
    
		fetch tv_cursor into user_id, review_date,review,points,is_edited;
		if finished = true then
			leave get_comments;
		end if;
          if (is_edited=1) then
			set edit='tak';
		else
			set edit='nie';
		end if;
		select u.first_name,u.last_name from users u where u.user_id=user_id into user_name,user_surname;
		set output = concat(output,review_date,'\n','recenzent: ',user_name,' ',user_surname,' id: ',user_id, '\n','punkty: ',points,', edytowane: ',edit,'\n','recenzja: ',review, '\n','\n');

    
		end loop get_comments;
		close tv_cursor;
		
        if(output='')
        then
			set output=concat('brak recenzji filmu: ',(select m.title from movies m where m.movie_id=movie_id LIMIT 1));
        else
			set output = concat('recenzje filmu: ',(select m.title from movies m where m.movie_id=movie_id LIMIT 1),'\n \n',output);
		end if;
        select output;

end//
DELIMITER ;

drop procedure if exists get_all_reviews_by_tv_series;
DELIMITER //
create procedure get_all_reviews_by_tv_series(tv_series_id int) 
begin
	declare user_name text;
    declare user_surname text;
    declare user_id int;
    declare review_date datetime;
    declare review mediumtext;
    declare points int;
    declare is_edited boolean;
    declare edit varchar(5);
    
	declare finished boolean default false;
    declare output LONGTEXT default '';
    
   
	declare tv_cursor cursor for
    select w.review_writer_id, w.review_date,w.review,w.points,w.is_edited
    from waiting_reviews_tv_series w
    where w.tv_series_id=tv_series_id
    order by w.review_date desc;
    
    declare continue handler for not found set finished = true;
		open tv_cursor;
		get_comments: loop
    
		fetch tv_cursor into user_id, review_date,review,points,is_edited;
		if finished = true then
			leave get_comments;
		end if;
        if (is_edited=1) then
			set edit='tak';
		else
			set edit='nie';
		end if;
		select u.first_name,u.last_name from users u where u.user_id=user_id into user_name,user_surname;
		set output = concat(output,review_date,'\n','recenzent: ',user_name,' ',user_surname,' id: ',user_id, '\n','punkty: ',points,', edytowane: ',edit,'\n','recenzja: ',review, '\n','\n');
    
		end loop get_comments;
		close tv_cursor;
		
        if(output='')
        then
			set output=concat('brak recenzji serii tv: ',(select m.title from tv_series m where m.tv_series_id=tv_series_id LIMIT 1));
        else
			set output = concat('recenzje serii tv: ',(select m.title from tv_series m where m.tv_series_id=tv_series_id LIMIT 1),'\n \n',output);
		end if;
        select output;

end//
DELIMITER ;




drop procedure if exists get_waiting_review_id_by_movie_id;
DELIMITER //
create procedure get_waiting_review_id_by_movie_id(movie_id int)
begin
	select w.review_id from waiting_reviews_movies w where w.movie_id=movie_id ;
end//
DELIMITER ;

drop procedure if exists get_waiting_review_id_by_tv_series_id;
DELIMITER //
create procedure get_waiting_review_id_by_tv_series_id(tv_series_id int)
begin
	select w.review_id from waiting_reviews_tv_series w where w.tv_series_id=tv_series_id ;
end//
DELIMITER ;

drop procedure if exists points_on_movie_reviews_by_id;
DELIMITER //
create procedure points_on_movie_reviews_by_id(movie_id int)
begin
	select * from points_on_movie_reviews p where p.movie_id=movie_id;
end//
DELIMITER ;

drop procedure if exists points_on_tv_series_reviews_by_id;
DELIMITER //
create procedure points_on_tv_series_reviews_by_id(tv_series_id int)
begin
	select * from points_on_tv_series p where p.tv_series_id=tv_series_id;
end//
DELIMITER ;


-- views

 drop view if exists points_on_movie_reviews;
 create view points_on_movie_reviews AS
 select m.title as 'tytul filmu',w.review,w.points,w.movie_id,w.review_id from waiting_reviews_movies w, movies m where w.movie_id=m.movie_id order by w.points desc;

 drop view if exists points_on_tv_series;
 create view points_on_tv_series AS
 select t.title as 'tytul serii',w.review,w.points,w.tv_series_id,w.review_id from waiting_reviews_tv_series w, tv_series t where w.tv_series_id=t.tv_series_id order by w.points desc;

-- triggers
drop trigger if exists sum_points_movie;
DELIMITER // 
CREATE TRIGGER sum_points_movie AFTER INSERT ON points_on_reviews_movie for each row
begin
	update waiting_reviews_movies w SET w.points=w.points+1 WHERE new.waiting_reviews_id=w.review_id;
end//
DELIMITER ;

drop trigger if exists rem_points_movie;
DELIMITER // 
CREATE TRIGGER rem_points_movie AFTER DELETE ON points_on_reviews_movie for each row
begin
	update waiting_reviews_movies w SET w.points=w.points-1 WHERE OLD.waiting_reviews_id=w.review_id;
end//
DELIMITER ;

-- triggers
drop trigger if exists sum_points_tv_series;
DELIMITER // 
CREATE TRIGGER sum_points_tv_series AFTER INSERT ON points_on_reviews_tv_series for each row
begin
	update waiting_reviews_tv_series w SET w.points=w.points+1 WHERE new.waiting_reviews_id=w.review_id;
end//
DELIMITER ;

drop trigger if exists rem_points_tv_series;
DELIMITER // 
CREATE TRIGGER rem_points_tv_series AFTER DELETE ON points_on_reviews_tv_series for each row
begin
	update waiting_reviews_tv_series w SET w.points=w.points-1 WHERE OLD.waiting_reviews_id=w.review_id;
end//
DELIMITER ;
