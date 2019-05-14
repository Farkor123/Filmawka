-- functions
drop function if exists add_comment_to_movie;
DELIMITER //
create function add_comment_to_movie(movie_id int,user_id int,content MEDIUMTEXT) returns BOOLEAN reads sql data
begin
	if exists(select * from movies m where m.movie_id=movie_id) then
		insert into comments(movie_id, user_id, comment_date,content) values (movie_id, user_id, NOW(),content);
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
	if exists(select * from tv_series t where t.tv_series_id.tv_series_id=tv_series_id) then
		insert into comments(tv_series_id, user_id, comment_date,content) values (tv_series_id, user_id, NOW(),content);
		return true;
	else
		return false;
    end if;
end//
DELIMITER ;
drop procedure if exists add_comment;
DELIMITER //
create procedure add_comment(id_commented int, user_id int,content MEDIUMTEXT,movie_or_tv_series int) -- tutaj 0 to movie, 1 to tv series
begin
	if exists(select * from users u where u.user_id=user_id)
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
					select 'select 0 for movie, or 1 for tv series in move_or_tv_series';
			END CASE;
	else
		select 'wrong user_id';
	end if;
end//
DELIMITER ;

drop procedure if exists remove_comment;
DELIMITER //
create procedure remove_comment(comment_id int, user_id int)
begin
	if ((select c.user_id from comments c where c.comment_id=comment_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1)
    then
		DELETE FROM comments  where comments.comment_id = comment_id;
    else
    select 'wrong comment_id or user without permission';
    END IF;
end//
DELIMITER ;

drop procedure if exists edit_comment;
DELIMITER //
create procedure edit_comment(comment_id int, user_id int,content MEDIUMTEXT) 
begin
	if ((select c.user_id from comments c where c.comment_id=comment_id)=user_id OR (select u.is_moderator from users u where u.user_id=user_id)=1)
    then
		UPDATE  comments c SET c.content=content  where c.comment_id = comment_id;
    else
    select 'wrong comment_id or user without permission';
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
    declare content mediumtext;
	declare finished boolean default false;
    declare output LONGTEXT default '';
    
   
	declare comment_cursor cursor for
    select c.user_id, c.comment_date,c.content
    from comments c
    where c.movie_id=movie_id
    order by c.comment_date desc;
    
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
    from comments c
    where c.tv_series_id=tv_series_id
    order by c.comment_date desc;
    
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



-- triggers
drop trigger if exists comment_updated;
DELIMITER // 
CREATE TRIGGER comment_updated AFTER UPDATE ON comments for each row
begin
	insert into edited_comments(edited_comment_id,comment_edit_date,content_before_edit) values(OLD.comment_id,CURDATE(),OLD.content);
end//
DELIMITER ;

drop trigger if exists comment_removed;
DELIMITER // 
CREATE TRIGGER comment_removed AFTER DELETE ON comments for each row
begin
	insert into edited_comments(edited_comment_id,comment_edit_date,content_before_edit) values(OLD.comment_id,CURDATE(),'remove comment:'+OLD.content);
end//
DELIMITER ;
