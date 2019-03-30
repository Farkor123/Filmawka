use filmawka;

-- functions
drop function if exists get_category;
DELIMITER //
create function get_category(category_id int) returns varchar(30) reads sql data
begin
	declare category_name varchar(30);
    select c.`name` from categories c where c.category_id = category_id into category_name;
    return category_name;
end//
DELIMITER ;

drop function if exists get_director;
DELIMITER //
create function get_director(director_id int) returns varchar(61) reads sql data
begin
	declare director_info varchar(61);
    select concat(d.`name`, ' ', d.surname) from directors d where d.director_id = director_id into director_info;
    return director_info;
end//
DELIMITER ;

drop function if exists get_movies_for_actor;
DELIMITER //
create function get_movies_for_actor(actor_id int) returns text reads sql data
begin
	declare title varchar(50);
    declare release_date date;
    declare finished boolean default false;
    declare output text default '';
    
    declare movie_cursor cursor for
    select m.title, m.release_date
    from actor_movie am join movies m on am.movie_id = m.movie_id
    where am.actor_id = actor_id
    order by m.release_date desc;
    
    declare continue handler for not found set finished = true;
    
    open movie_cursor;
    get_movies: loop
    
    fetch movie_cursor into title, release_date;
    if finished = true then
		leave get_movies;
	end if;
    set output = concat(output, extract(year from release_date), ' ', title, '\n');
    
    end loop get_movies;
    close movie_cursor;
    
    return output;
end//
DELIMITER ;

drop function if exists get_tv_series_for_actor;
DELIMITER //
create function get_tv_series_for_actor(actor_id int) returns text reads sql data
begin
	declare title varchar(50);
    declare release_date date;
    declare finished boolean default false;
    declare output text default '';
    
    declare tv_series_cursor cursor for
    select tvs.title, tvs.release_date
    from actor_tv_series atvs join tv_series tvs on atvs.tv_series_id = tvs.tv_series_id
    where atvs.actor_id = actor_id
    order by tvs.release_date desc;
    
    declare continue handler for not found set finished = true;
    
    open tv_series_cursor;
    get_movies: loop
    
    fetch tv_series_cursor into title, release_date;
    if finished = true then
		leave get_movies;
	end if;
    set output = concat(output, extract(year from release_date), ' ', title, '\n');
    
    end loop get_movies;
    close tv_series_cursor;
    
    return output;
end//
DELIMITER ;

drop function if exists get_actors_for_movie;
DELIMITER //
create function get_actors_for_movie(movie_id int) returns text reads sql data
begin
    declare `name`, surname, `role` varchar(30);
    declare finished boolean default false;
    declare output text default '';
    
    declare actors_cursor cursor for
    select a.`name`, a.surname, am.`role`
	from actors a join actor_movie am on a.actor_id = am.actor_id
	where am.movie_id = movie_id
	order by a.surname asc;
    
    declare continue handler for not found set finished = true;
    
    open actors_cursor;
    get_actors: loop
    fetch actors_cursor into `name`, surname, `role`;
    
    if finished = true then
		leave get_actors;
	end if;
    set output = concat(output, `name`, ' ', surname, ' jako ', `role`, '\n');
    end loop get_actors;
    close actors_cursor;
    
    return output;
end//
DELIMITER ;

-- procedures

drop procedure if exists actor_info;
DELIMITER //
create procedure actor_info(in actor_id int)
begin
	declare a_name, a_surname varchar(30);
    declare date_of_birth, date_of_death date;
	declare output, summary text;
	
	select a.`name`, a.surname, a.date_of_birth, a.date_of_death, a.summary
    from actors a
    where a.actor_id = actor_id
    into a_name , a_surname , date_of_birth , date_of_death , summary;
	
	set output = concat('Aktor: ', a_name, ' ', a_surname);
	if date_of_death is null then
		set output = concat(output, '\nData urodzenia: ', date_format(date_of_birth, '%e %M %Y'), ' (', timestampdiff(year, date_of_birth, curdate()), ' lat)');
	else
		set output = concat(output, '\nData urodzenia: ', date_format(date_of_birth, '%e %M %Y'));
		set output = concat(output, '\nData śmierci: ', date_format(date_of_death, '%e %M %Y'), ' (żył(a) ', timestampdiff(year, date_of_birth, date_of_death), ' lat)');
    end if;
	set output = concat(output, '\nOpis: ', summary);
    set output = concat(output, '\n\nFilmy:\n', get_movies_for_actor(actor_id));
    set output = concat(output, '\nSeriale:\n', get_tv_series_for_actor(actor_id));
    
	select output;
end//
DELIMITER ;

drop procedure if exists movie_info;
DELIMITER //
create procedure movie_info(in movie_id int)
begin
	declare title, original_title varchar(30);
    declare director_id, category_id int;
    declare `description`, output text;
    declare release_date date;
    declare is_released boolean;
    declare average_score decimal(10, 8);
    
    if exists(select * from movies m where m.movie_id = movie_id) then
		select m.title, m.original_title, m.director_id, m.category_id, m.`description`, m.release_date, m.is_released, m.average_score
		from movies m
		where m.movie_id = movie_id
		into title, original_title, director_id, category_id, `description`, release_date, is_released, average_score;
		
        set output = concat('Film: ', title);
        
		if strcmp(title, original_title) != 0 then
			set output = concat(output, ' (oryginalny tytuł: ', original_title, ')');
		end if;
        if is_released = 1 then
			set output = concat(output, '\nData premiery: ');
        else
			set output = concat(output, '\nPlanowana data premiery: ');
        end if;
        set output = concat(output, date_format(release_date, '%e %M %Y'));
        set output = concat(output, '\nReżyser: ', get_director(director_id));
        set output = concat(output, '\nKategoria: ', get_category(category_id));
        set output = concat(output, '\nOcena: ');
        if average_score is null then
			set output = concat(output, 'nikt jeszcze nie ocenił tego filmu');
        else
			set output = concat(output, round(average_score, 2));
        end if;
        set output = concat(output, '\n\nOpis: ', `description`);
        set output = concat(output, '\n\nAktorzy:\n', get_actors_for_movie(movie_id));
        
		select output;
    else
		select 'Nie znaleziono filmu';
    end if;
end//
DELIMITER ;

drop procedure if exists rate_movie;
DELIMITER //
create procedure rate_movie(in user_id int, in movie_id int, in rating tinyint)
begin
	declare bad_rating condition for sqlstate '10001';
	declare exit handler for bad_rating
    select 'Ocena powinna być z zakresu <1, 10>';
    
	-- 1062 is error number for duplicate entry for key (when user tries to rate the same movie more than once)
	declare continue handler for 1062
    update movie_ratings mr
    set mr.rating = rating, rating_date = now()
    where mr.user_id = user_id and mr.movie_id = movie_id;
    
    insert into movie_ratings(user_id, movie_id, rating) values(user_id, movie_id, rating);
end//
DELIMITER ;

drop procedure if exists rate_tv_series;
DELIMITER //
create procedure rate_tv_series(in user_id int, in tv_series_id int, in rating tinyint)
begin
	declare bad_rating condition for sqlstate '10001';
	declare exit handler for bad_rating
    select 'Ocena powinna być z zakresu <1, 10>';
    
	-- 1062 is error number for duplicate entry for key (when user tries to rate the same movie more than once)
	declare continue handler for 1062
    update tv_series_ratings tvsr
    set tvsr.rating = rating, rating_date = now()
    where tvsr.user_id = user_id and tvsr.tv_series_id = tv_series_id;
    
    insert into tv_series_ratings(user_id, tv_series_id, rating) values(user_id, tv_series_id, rating);
end//
DELIMITER ;

drop procedure if exists rate_tv_season;
DELIMITER //
create procedure rate_tv_season(in user_id int, in tv_season_id int, in rating tinyint)
begin
	declare bad_rating condition for sqlstate '10001';
	declare exit handler for bad_rating
    select 'Ocena powinna być z zakresu <1, 10>';
    
	-- 1062 is error number for duplicate entry for key (when user tries to rate the same movie more than once)
	declare continue handler for 1062
    update tv_season_ratings tvsr
    set tvsr.rating = rating, rating_date = now()
    where tvsr.user_id = user_id and tvsr.tv_season_id = tv_season_id;
    
    insert into tv_season_ratings(user_id, tv_season_id, rating) values(user_id, tv_season_id, rating);
end//
DELIMITER ;

-- movie_ratings triggers
drop trigger if exists insert_check_movie_rating;
DELIMITER //
create trigger insert_check_movie_rating before insert on movie_ratings for each row
begin
	if new.rating < 1 or new.rating > 10 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists update_check_movie_rating;
DELIMITER //
create trigger update_check_movie_rating before update on movie_ratings for each row
begin
	if new.rating < 1 or new.rating > 10 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists add_movie_rating;
DELIMITER //
create trigger add_movie_rating after insert on movie_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from movie_ratings where movie_id = new.movie_id into avg_score;
    update movies set average_score = avg_score where movie_id = new.movie_id;
end//
DELIMITER ;

drop trigger if exists update_movie_rating;
DELIMITER //
create trigger update_movie_rating after update on movie_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from movie_ratings where movie_id = old.movie_id into avg_score;
    update movies set average_score = avg_score where movie_id = old.movie_id;
end//
DELIMITER ;

drop trigger if exists delete_movie_rating;
DELIMITER //
create trigger delete_movie_rating after delete on movie_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from movie_ratings where movie_id = old.movie_id into avg_score;
    update movies set average_score = avg_score where movie_id = old.movie_id;
end//
DELIMITER ;

-- tv_series_ratings triggers
drop trigger if exists insert_check_tv_series_rating;
DELIMITER //
create trigger insert_check_tv_series_rating before insert on tv_series_ratings for each row
begin
	if new.rating < 1 or new.rating > 10 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists update_check_tv_series_rating;
DELIMITER //
create trigger update_check_tv_series_rating before update on tv_series_ratings for each row
begin
	if new.rating < 1 or new.rating > 10 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists add_tv_series_rating;
DELIMITER //
create trigger add_tv_series_rating after insert on tv_series_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_series_ratings where tv_series_id = new.tv_series_id into avg_score;
    update tv_series set average_score = avg_score where tv_series_id = new.tv_series_id;
end//
DELIMITER ;

drop trigger if exists update_tv_series_rating;
DELIMITER //
create trigger update_tv_series_rating after update on tv_series_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_series_ratings where tv_series_id = old.tv_series_id into avg_score;
    update tv_series set average_score = avg_score where tv_series_id = old.tv_series_id;
end//
DELIMITER ;

drop trigger if exists delete_tv_series_rating;
DELIMITER //
create trigger delete_tv_series_rating after delete on tv_series_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_series_ratings where tv_series_id = old.tv_series_id into avg_score;
    update tv_series set average_score = avg_score where tv_series_id = old.tv_series_id;
end//
DELIMITER ;

-- tv_season_ratings triggers
drop trigger if exists insert_check_tv_season_rating;
DELIMITER //
create trigger insert_check_tv_season_rating before insert on tv_season_ratings for each row
begin
	if new.rating < 1 or new.rating > 10 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists update_check_tv_season_rating;
DELIMITER //
create trigger update_check_tv_season_rating before update on tv_season_ratings for each row
begin
	if new.rating < 1 or new.rating > 10 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists add_tv_season_rating;
DELIMITER //
create trigger add_tv_season_rating after insert on tv_season_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_season_ratings where tv_season_id = new.tv_season_id into avg_score;
    update tv_seasons set average_score = avg_score where tv_season_id = new.tv_season_id;
end//
DELIMITER ;

drop trigger if exists update_tv_season_rating;
DELIMITER //
create trigger update_tv_season_rating after update on tv_season_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_season_ratings where tv_season_id = old.tv_season_id into avg_score;
    update tv_seasons set average_score = avg_score where tv_season_id = old.tv_season_id;
end//
DELIMITER ;

drop trigger if exists delete_tv_season_rating;
DELIMITER //
create trigger delete_tv_season_rating after delete on tv_season_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_season_ratings where tv_season_id = old.tv_season_id into avg_score;
    update tv_seasons set average_score = avg_score where tv_season_id = old.tv_season_id;
end//
DELIMITER ;

-- tv_episode_ratings triggers
drop trigger if exists insert_check_tv_episode_rating;
DELIMITER //
create trigger insert_check_tv_episode_rating before insert on tv_episode_ratings for each row
begin
	if new.rating < 1 or new.rating > 10 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists update_check_tv_episode_rating;
DELIMITER //
create trigger update_check_tv_episode_rating before update on tv_episode_ratings for each row
begin
	if new.rating < 1 or new.rating > 10 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists add_tv_episode_rating;
DELIMITER //
create trigger add_tv_episode_rating after insert on tv_episode_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_episode_ratings where tv_episode_id = new.tv_episode_id into avg_score;
    update tv_seasons set average_score = avg_score where tv_episode_id = new.tv_episode_id;
end//
DELIMITER ;

drop trigger if exists update_tv_episode_rating;
DELIMITER //
create trigger update_tv_episode_rating after update on tv_episode_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_episode_ratings where tv_episode_id = old.tv_episode_id into avg_score;
    update tv_seasons set average_score = avg_score where tv_episode_id = old.tv_episode_id;
end//
DELIMITER ;

drop trigger if exists delete_tv_episode_rating;
DELIMITER //
create trigger delete_tv_episode_rating after delete on tv_episode_ratings for each row
begin
	declare avg_score decimal(10, 8);
    select avg(rating) from tv_episode_ratings where tv_episode_id = old.tv_episode_id into avg_score;
    update tv_seasons set average_score = avg_score where tv_episode_id = old.tv_episode_id;
end//
DELIMITER ;
