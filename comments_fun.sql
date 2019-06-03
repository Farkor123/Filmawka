-- functions
drop function if exists add_comment_to_movie;
DELIMITER //
create function add_comment_to_movie(movie_id int,user_id int,content MEDIUMTEXT) returns BOOLEAN reads sql data
begin
	if exists(select * from movies m where m.movie_id=movie_id) then
		insert into comments_movies(movie_id, user_id, comment_date,content) values (movie_id, user_id, NOW(),content);
		return true;
	else
		return false;
    end if;
end//
DELIMITER ;
drop function if exists add_comment_to_tv_series;
DELIMITER //
create function add_comment_to_tv_series(tv_series_id int,user_id int,content MEDIUMTEXT) returns BOOLEAN reads sql data
begin
	if exists(select * from tv_series t where t.tv_series_id=tv_series_id) then
		insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (tv_series_id, user_id, NOW(),content);
		return true;
	else
		return false;
    end if;
end//
DELIMITER ;
-- procedury
drop procedure if exists add_comment;
DELIMITER //
create procedure add_comment(id_commented int, user_id int,content MEDIUMTEXT,movie_or_tv_series int) -- tutaj 0 to movie, 1 to tv series
begin
	if is_user_logged_in(user_id) != 0
		then
			CASE 
            WHEN movie_or_tv_series=0 then
            BEGIN
				if !(add_comment_to_movie(id_commented,user_id,content))
				then select 'wrong movie_id';
                end if;
			END;
			WHEN movie_or_tv_series=1 then 
				BEGIN
					if !(add_comment_to_tv_series(id_commented,user_id,content))
					then select 'wrong tv_series_id';
					end if;
				END;
			ELSE
					select 'error: 0 dla komentarza do movie, 1 dla komentarza dla serii tv';
			END CASE;
	else
		select 'error: user nie jest zalogowany';
	end if;
end//
DELIMITER ;

drop procedure if exists remove_comment_movie;
DELIMITER //
create procedure remove_comment_movie(comment_id int, user_id int)
begin
	if exists (select 1 from comments_movies c where c.comment_id=comment_id) 
    then
		if ((select c.user_id from comments_movies c where c.comment_id=comment_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1) 
        and
        is_user_logged_in(user_id) != 0
		then
			if exists(select 1 from edited_comments_movies)
            then
				DELETE from edited_comments_movies where edited_comments_movies.edited_comment_id =comment_id;
			end if;
			DELETE FROM comments_movies  where comments_movies.comment_id = comment_id;
		else
			select 'error: user bez odpowiedniego prawa, lub user niezalogowany';
		END IF;
	else
		select 'error: nieprawidowe comment_id';
    END IF;
end//
DELIMITER ;

drop procedure if exists edit_comment_movie;
DELIMITER //
create procedure edit_comment_movie(comment_id int, user_id int,content MEDIUMTEXT) 
begin
	if exists (select 1 from comments_movies c where c.comment_id=comment_id) 
    then
		if ((select c.user_id from comments_movies c where c.comment_id=comment_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1) 
        and
        is_user_logged_in(user_id) != 0
		then
			UPDATE  comments_movies c SET c.content=content  where c.comment_id = comment_id;
		else
			select 'error: user bez odpowiedniego prawa, lub user niezalogowany';
		END IF;
    ELSE
			select 'error: nieprawidowe comment_id';
    END IF;
end//
DELIMITER ;

drop procedure if exists remove_comment_tv_series;
DELIMITER //
create procedure remove_comment_tv_series(comment_id int, user_id int)
begin
	if exists (select 1 from comments_tv_series c where c.comment_id=comment_id) 
    then
		if ((select c.user_id from comments_tv_series c where c.comment_id=comment_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1) 
        and
        is_user_logged_in(user_id) != 0
		then
			if exists(select 1 from edited_comments_tv_series)
            then
				DELETE from edited_comments_tv_series where edited_comments_tv_series.edited_comment_id =comment_id;
			end if;
            
			DELETE FROM comments_tv_series  where comments_tv_series.comment_id = comment_id;
		else
			select 'error: user bez odpowiedniego prawa, lub user niezalogowany';
		END IF;
	else
		select 'error: nieprawidowe comment_id';
    END IF;
end//
DELIMITER ;

drop procedure if exists edit_comment_tv_series;
DELIMITER //
create procedure edit_comment_tv_series(comment_id int, user_id int,content MEDIUMTEXT) 
begin
	if exists (select 1 from comments_tv_series c where c.comment_id=comment_id) 
    then
		if ((select c.user_id from comments_tv_series c where c.comment_id=comment_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1) 
        and
        is_user_logged_in(user_id) != 0
		then
			UPDATE  comments_tv_series c SET c.content=content  where c.comment_id = comment_id;
		else
			select 'error: user bez odpowiedniego prawa, lub user niezalogowany';
		END IF;
    ELSE
			select 'error: nieprawidowe comment_id';
    END IF;
end//
DELIMITER ;



drop procedure if exists get_all_comments_by_movie_id;
DELIMITER //
create procedure get_all_comments_by_movie_id(movie_id int) 
begin
	declare user_name text;
    declare user_surname text;
    declare user_id int;
    declare comment_date date;
    declare comment_id int;
    declare content mediumtext;
	declare finished boolean default false;
    declare output LONGTEXT default '';
    
   
	declare comment_cursor cursor for
    select c.user_id, c.comment_date,c.content,c.comment_id
    from comments_movies c
    where c.movie_id=movie_id
    order by c.comment_id desc;
    
    declare continue handler for not found set finished = true;
		open comment_cursor;
		get_comments: loop
    
		fetch comment_cursor into user_id, comment_date,content,comment_id;
		if finished = true then
			leave get_comments;
		end if;
		select u.first_name,u.last_name from users u where u.user_id=user_id into user_name,user_surname;
		set output = concat(output,comment_date,' id komentarza: ',comment_id,'\n',user_name,' ',user_surname,' id: ',user_id, '\n',content, '\n','\n');
    
		end loop get_comments;
		close comment_cursor;
		
        if(output='')
        then
			set output=concat('brak komentarzy do filmu: ',(select m.title from movies m where m.movie_id=movie_id LIMIT 1));
        else
			set output = concat('komentarze do filmu: ',(select m.title from movies m where m.movie_id=movie_id LIMIT 1),'\n \n',output);
		end if;
        select output;

end//
DELIMITER ;

drop procedure if exists get_all_comments_by_tv_series;
DELIMITER //
create procedure get_all_comments_by_tv_series(tv_series_id int) 
begin
	declare user_name text;
    declare user_surname text;
    declare user_id int;
    declare comment_date date;
    declare content mediumtext;
	declare finished boolean default false;
    declare output LONGTEXT default '';
    
   
	declare comment_cursor cursor for
    select c.user_id, c.comment_date,c.content
    from comments_tv_series c
    where c.tv_series_id=tv_series_id
	order by c.comment_id desc;
    
    declare continue handler for not found set finished = true;
		open comment_cursor;
		get_comments: loop
    
		fetch comment_cursor into user_id, comment_date,content;
		if finished = true then
			leave get_comments;
		end if;
		select u.first_name,u.last_name from users u where u.user_id=user_id into user_name,user_surname;
		set output = concat(output,comment_date,'\n',user_name,' ',user_surname,' id: ',user_id, '\n',content, '\n','\n');
    
		end loop get_comments;
		close comment_cursor;
		
        if(output='')
        then
			set output=concat('brak komentarzy do serii tv: ',(select m.title from tv_series m where m.tv_series_id=tv_series_id LIMIT 1));
        else
			set output = concat('komentarze do serii tv: ',(select m.title from tv_series m where m.tv_series_id=tv_series_id LIMIT 1),'\n \n',output);
		end if;
        select output;

end//
DELIMITER ;
drop procedure if exists get_comments_movie_by_user;
DELIMITER //
create procedure get_comments_movie_by_user(movie_id int,user_id int)
begin
	declare user_name text;
    declare user_surname text;
    declare comment_date date;
    declare comment_id int;
    declare content mediumtext;
	declare finished boolean default false;
    declare output LONGTEXT default '';
   
	declare comment_cursor cursor for
    select c.comment_date,c.content,c.comment_id
    FROM comments_movies c where  c.movie_id=movie_id and c.user_id=user_id
    order by c.comment_id desc;
    
    
		declare continue handler for not found set finished = true;
		open comment_cursor;
		select u.first_name,u.last_name from users u where u.user_id=user_id into user_name,user_surname;
		get_comments: loop
    
		fetch comment_cursor into comment_date,content,comment_id;
		if finished = true then
			leave get_comments;
		end if;

		set output = concat(output,comment_date,' id komentarza: ',comment_id,'\n',content, '\n','\n');
    
		end loop get_comments;
		close comment_cursor;
		
        if(output='')
        then
			set output=concat('brak komentarzy do filmu: ',(select m.title from movies m where m.movie_id=movie_id LIMIT 1),'\n','uzytkownik: ','\n',
            user_name,' ',user_surname,' id: ',user_id, '\n \n',output);
        else
			set output = concat('komentarze do filmu: ',(select m.title from movies m where m.movie_id=movie_id LIMIT 1),'\n','uzytkownik: ','\n',
            user_name,' ',user_surname,' id: ',user_id, '\n \n',output);
		end if;
        select output;
end//
DELIMITER ;

drop procedure if exists get_comments_tv_series_by_user;
DELIMITER //
create procedure get_comments_tv_series_by_user(tv_series_id int,user_id int)
begin
	declare user_name text;
    declare user_surname text;
    declare comment_date date;
    declare comment_id int;
    declare content mediumtext;
	declare finished boolean default false;
    declare output LONGTEXT default '';
   
	declare comment_cursor cursor for
    select c.comment_date,c.content,c.comment_id
    FROM comments_tv_series c where  c.tv_series_id=tv_series_id and c.user_id=user_id
    order by c.comment_id desc;
    
    
		declare continue handler for not found set finished = true;
		open comment_cursor;
		select u.first_name,u.last_name from users u where u.user_id=user_id into user_name,user_surname;
		get_comments: loop
    
		fetch comment_cursor into comment_date,content,comment_id;
		if finished = true then
			leave get_comments;
		end if;

		set output = concat(output,comment_date,' id komentarza: ',comment_id,'\n',content, '\n','\n');
    
		end loop get_comments;
		close comment_cursor;
		
        if(output='')
        then
			set output=concat('brak komentarzy do filmu: ',(select m.title from tv_series m where m.tv_series_id=tv_series_id LIMIT 1),'\n','uzytkownik: ','\n',
            user_name,' ',user_surname,' id: ',user_id, '\n \n',output);
        else
			set output = concat('komentarze do filmu: ',(select m.title from tv_series m where m.tv_series_id=tv_series_id LIMIT 1),'\n','uzytkownik: ','\n',
            user_name,' ',user_surname,' id: ',user_id, '\n \n',output);
		end if;
        select output;
end//
DELIMITER ;

DELIMITER ;
drop procedure if exists get_info_of_the_most_commented_movies;
DELIMITER //
create procedure get_info_of_the_most_commented_movies()
begin
	declare max_c int;
	CREATE TEMPORARY TABLE new_tbl SELECT count(c.comment_id) as comment_count,m.movie_id,m.title,m.description from comments_movies c,movies m where 
	c.movie_id=m.movie_id group by m.movie_id order by m.movie_id;
    set max_c=(SELECT MAX(comment_count) from new_tbl);
    select * from new_tbl n where n.comment_count=max_c;
    drop temporary table new_tbl;
end//
DELIMITER ;


DELIMITER ;
drop procedure if exists get_info_of_the_most_commented_tv_series;
DELIMITER //
create procedure get_info_of_the_most_commented_tv_series()
begin
	declare max_c int;
	CREATE TEMPORARY TABLE new_tbl SELECT count(c.comment_id) as comment_count,m.tv_series_id,m.title,m.description from comments_tv_series c,tv_series m where 
	c.tv_series_id=m.tv_series_id group by m.tv_series_id order by m.tv_series_id;
    set max_c=(SELECT MAX(comment_count) from new_tbl);
    select * from new_tbl n where n.comment_count=max_c;
    drop temporary table new_tbl;
end//
DELIMITER ;


-- triggers
drop trigger if exists comment_updated_movies;
DELIMITER // 
CREATE TRIGGER comment_updated_movies AFTER UPDATE ON comments_movies for each row
begin
	insert into edited_comments_movies(edited_comment_id,comment_edit_date,content_before_edit) values(OLD.comment_id,CURDATE(),OLD.content);
end//
DELIMITER ;

drop trigger if exists comment_updated_tv_series;
DELIMITER // 
CREATE TRIGGER comment_updated_tv_series AFTER UPDATE ON comments_movies for each row
begin
	insert into edited_comments_tv_series(edited_comment_id,comment_edit_date,content_before_edit) values(OLD.comment_id,CURDATE(),OLD.content);
end//
DELIMITER ;

