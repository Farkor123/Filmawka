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

drop function if exists get_movie_id_for_title;
DELIMITER //
create function get_movie_id_for_title(title varchar(50), release_year int) returns int reads sql data
begin
	declare movie_id int;
    
    select m.movie_id from movies m where m.title = title and year(m.release_date) = release_year into movie_id;
    
    return movie_id;
end//
DELIMITER ;

drop function if exists get_tv_series_id_for_title;
DELIMITER //
create function get_tv_series_id_for_title(title varchar(50), release_year int) returns int reads sql data
begin
	declare tv_series_id int;
    
    select tvs.tv_series_id from tv_series tvs where tvs.title = title and year(tvs.release_date) = release_year into tv_series_id;
    
    return tv_series_id;
end//
DELIMITER ;

drop function if exists get_actor_id_for_full_name;
DELIMITER //
create function get_actor_id_for_full_name(full_name varchar(61)) returns int reads sql data
begin
	declare actor_id int;
    
    select a.actor_id from actors a where concat(a.`name`, ' ', a.surname) = full_name into actor_id;
    
    return actor_id;
end//
DELIMITER ;

drop function if exists get_director_id_for_full_name;
DELIMITER //
create function get_director_id_for_full_name(full_name varchar(61)) returns int reads sql data
begin
	declare director_id int;
    
    select d.director_id from directors d where concat(d.`name`, ' ', d.surname) = full_name into director_id;
    
    return director_id;
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

drop procedure if exists remove_movie_rating;
DELIMITER //
create procedure remove_movie_rating(in user_id int, in movie_id int)
begin
	delete from movie_ratings where movie_ratings.user_id = user_id and movie_ratings.movie_id = movie_id;
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

drop procedure if exists remove_tv_series_rating;
DELIMITER //
create procedure remove_tv_series_rating(in user_id int, in tv_series_id int)
begin
	delete from tv_series_ratings where tv_series_ratings.user_id = user_id and tv_series_ratings.tv_series_id = tv_series_id;
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

drop procedure if exists remove_tv_season_rating;
DELIMITER //
create procedure remove_tv_season_rating(in user_id int, in tv_season_id int)
begin
	delete from tv_season_ratings where tv_season_ratings.user_id = user_id and tv_season_ratings.tv_season_id = tv_season_id;
end//
DELIMITER ;

drop procedure if exists rate_tv_episode;
DELIMITER //
create procedure rate_tv_episode(in user_id int, in tv_episode_id int, in rating tinyint)
begin
	declare bad_rating condition for sqlstate '10001';
	declare exit handler for bad_rating
    select 'Ocena powinna być z zakresu <1, 10>';
    
	-- 1062 is error number for duplicate entry for key (when user tries to rate the same movie more than once)
	declare continue handler for 1062
    update tv_episode_ratings tver
    set tver.rating = rating, rating_date = now()
    where tver.user_id = user_id and tver.tv_episode_id = tv_episode_id;
    
    insert into tv_episode_ratings(user_id, tv_episode_id, rating) values(user_id, tv_episode_id, rating);
end//
DELIMITER ;

drop procedure if exists remove_tv_episode_rating;
DELIMITER //
create procedure remove_tv_episode_rating(in user_id int, in tv_episode_id int)
begin
	delete from tv_episode_ratings where tv_episode_ratings.user_id = user_id and tv_episode_ratings.tv_episode_id = tv_episode_id;
end//
DELIMITER ;

drop procedure if exists search_movies;
DELIMITER //
create procedure search_movies(in user_query varchar(50))
begin
	set user_query = concat('%', user_query, '%');
    
    select m.movie_id, m.title, m.original_title, m.release_date
    from movies m
    where m.title like user_query or m.original_title like user_query
    order by m.release_date desc;
end//
DELIMITER ;

drop procedure if exists search_tv_series;
DELIMITER //
create procedure search_tv_series(in user_query varchar(50))
begin
	set user_query = concat('%', user_query, '%');
    
    select tvs.tv_series_id, tvs.title, tvs.original_title, tvs.release_date
    from tv_series tvs
    where tvs.title like user_query or tvs.original_title like user_query
    order by tvs.release_date desc;
end//
DELIMITER ;

drop procedure if exists search_actors;
DELIMITER //
create procedure search_actors(in user_query varchar(50))
begin
	set user_query = concat('%', user_query, '%');
    
    select a.actor_id, a.`name`, a.surname
    from actors a
    where concat(a.`name`, ' ', a.surname) like user_query;
end//
DELIMITER ;

drop procedure if exists search_directors;
DELIMITER //
create procedure search_directors(in user_query varchar(50))
begin
	set user_query = concat('%', user_query, '%');
    
    select d.director_id, d.`name`, d.surname
    from directors d
    where concat(d.`name`, ' ', d.surname) like user_query;
end//
DELIMITER ;

drop procedure if exists update_movie_description;
DELIMITER //
create procedure update_movie_description(in title varchar(50), in release_year int, in new_description text)
begin
	declare movie_id int;
    
    select get_movie_id_for_title(title, release_year) into movie_id;
    
    update movies m
    set m.`description` = new_description
    where m.movie_id = movie_id;
end//
DELIMITER ;

drop procedure if exists update_movie_director;
DELIMITER //
create procedure update_movie_director(in title varchar(50), in release_year int, in director_full_name varchar(61))
begin
	declare movie_id, new_director_id int;
    
    select get_movie_id_for_title(title, release_year) into movie_id;
    select get_director_id_for_full_name(director_full_name) into new_director_id;
    
    update movies m
    set m.director_id = new_director_id
    where m.movie_id = movie_id;
end//
DELIMITER ;

drop procedure if exists add_actor_to_movie;
DELIMITER //
create procedure add_actor_to_movie(in full_name varchar(61), in `role` varchar(50), in title varchar(50), in release_year int)
begin
	declare actor_id, movie_id int;
    declare exit handler for 1062
    select 'Aktor już gra w tym filmie, nie można dodać';
    
    select get_actor_id_for_full_name(full_name) into actor_id;
    select get_movie_id_for_title(title, release_year) into movie_id;
	
    insert into actor_movie(movie_id, actor_id, `role`) values(movie_id, actor_id, `role`);
end//
DELIMITER ;

drop procedure if exists remove_actor_from_movie;
DELIMITER //
create procedure remove_actor_from_movie(in full_name varchar(61), in title varchar(50), in release_year int)
begin
	declare actor_id, movie_id int;
    
    select get_actor_id_for_full_name(full_name) into actor_id;
    select get_movie_id_for_title(title, release_year) into movie_id;
    
    delete from actor_movie
    where actor_movie.actor_id = actor_id and actor_movie.movie_id = movie_id;
end//
DELIMITER ;

drop procedure if exists add_actor_to_tv_series;
DELIMITER //
create procedure add_actor_to_tv_series(in full_name varchar(61), in `role` varchar(50), in title varchar(50), in release_year int)
begin
	declare actor_id, tv_series_id int;
    declare exit handler for 1062
    select 'Aktor już gra w tym serialu, nie można dodać';
    
    select get_actor_id_for_full_name(full_name) into actor_id;
    select get_tv_series_id_for_title(title, release_year) into tv_series_id;
    
    insert into actor_tv_series(actor_id, tv_series_id, `role`) values(actor_id, tv_series_id, `role`);
end//
DELIMITER ;

drop procedure if exists remove_actor_from_tv_series;
DELIMITER //
create procedure remove_actor_from_tv_series(in full_name varchar(61), in title varchar(50), in release_year int)
begin
	declare actor_id, tv_series_id int;
    
    select get_actor_id_for_full_name(full_name) into actor_id;
    select get_tv_series_id_for_title(title, release_year) into tv_series_id;
    
    delete from actor_tv_series
    where actor_tv_series.actor_id = actor_id and actor_tv_series.tv_series_id = tv_series_id;
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
    declare score_count int;
    select avg(rating), count(*) from movie_ratings where movie_id = new.movie_id into avg_score, score_count;
    update movies m set m.average_score = avg_score, m.score_count = score_count where m.movie_id = new.movie_id;
end//
DELIMITER ;

drop trigger if exists update_movie_rating;
DELIMITER //
create trigger update_movie_rating after update on movie_ratings for each row
begin
	declare avg_score decimal(10, 8);
    declare score_count int;
    select avg(rating), count(*) from movie_ratings where movie_id = old.movie_id into avg_score, score_count;
    update movies m set m.average_score = avg_score, m.score_count = score_count where m.movie_id = old.movie_id;
end//
DELIMITER ;

drop trigger if exists delete_movie_rating;
DELIMITER //
create trigger delete_movie_rating after delete on movie_ratings for each row
begin
	declare avg_score decimal(10, 8);
    declare score_count int;
    select avg(rating), count(*) from movie_ratings where movie_id = old.movie_id into avg_score, score_count;
    update movies m set m.average_score = avg_score, m.score_count = score_count where movie_id = old.movie_id;
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
    declare score_count int;
    select avg(rating), count(*) from tv_series_ratings where tv_series_id = new.tv_series_id into avg_score, score_count;
    update tv_series tvs set tvs.average_score = avg_score, tvs.score_count = score_count where tvs.tv_series_id = new.tv_series_id;
end//
DELIMITER ;

drop trigger if exists update_tv_series_rating;
DELIMITER //
create trigger update_tv_series_rating after update on tv_series_ratings for each row
begin
	declare avg_score decimal(10, 8);
    declare score_count int;
    select avg(rating), count(*) from tv_series_ratings where tv_series_id = old.tv_series_id into avg_score, score_count;
    update tv_series tvs set tvs.average_score = avg_score, tvs.score_count = score_count where tvs.tv_series_id = old.tv_series_id;
end//
DELIMITER ;

drop trigger if exists delete_tv_series_rating;
DELIMITER //
create trigger delete_tv_series_rating after delete on tv_series_ratings for each row
begin
	declare avg_score decimal(10, 8);
    declare score_count int;
    select avg(rating), count(*) from tv_series_ratings where tv_series_id = old.tv_series_id into avg_score, score_count;
    update tv_series tvs set tvs.average_score = avg_score, tvs.score_count = score_count where tvs.tv_series_id = old.tv_series_id;
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
    declare score_count int;
    select avg(rating), count(*) from tv_season_ratings where tv_season_id = new.tv_season_id into avg_score, score_count;
    update tv_seasons tvs set tvs.average_score = avg_score, tvs.score_count = score_count where tvs.tv_season_id = new.tv_season_id;
end//
DELIMITER ;

drop trigger if exists update_tv_season_rating;
DELIMITER //
create trigger update_tv_season_rating after update on tv_season_ratings for each row
begin
	declare avg_score decimal(10, 8);
    declare score_count int;
    select avg(rating), count(*) from tv_season_ratings where tv_season_id = old.tv_season_id into avg_score, score_count;
    update tv_seasons tvs set tvs.average_score = avg_score, tvs.score_count = score_count where tvs.tv_season_id = old.tv_season_id;
end//
DELIMITER ;

drop trigger if exists delete_tv_season_rating;
DELIMITER //
create trigger delete_tv_season_rating after delete on tv_season_ratings for each row
begin
	declare avg_score decimal(10, 8);
    declare score_count int;
    select avg(rating), count(*) from tv_season_ratings where tv_season_id = old.tv_season_id into avg_score, score_count;
    update tv_seasons tvs set tvs.average_score = avg_score, tvs.score_count = score_count where tvs.tv_season_id = old.tv_season_id;
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
    declare score_count int;
    select avg(rating), count(*) from tv_episode_ratings where tv_episode_id = new.tv_episode_id into avg_score, score_count;
    update tv_episodes tve set tve.average_score = avg_score, tve.score_count = score_count where tve.tv_episode_id = new.tv_episode_id;
end//
DELIMITER ;

drop trigger if exists update_tv_episode_rating;
DELIMITER //
create trigger update_tv_episode_rating after update on tv_episode_ratings for each row
begin
	declare avg_score decimal(10, 8);
    declare score_count int;
    select avg(rating), count(*) from tv_episode_ratings where tv_episode_id = old.tv_episode_id into avg_score, score_count;
    update tv_episodes tve set tve.average_score = avg_score, tve.score_count = score_count where tve.tv_episode_id = old.tv_episode_id;
end//
DELIMITER ;

drop trigger if exists delete_tv_episode_rating;
DELIMITER //
create trigger delete_tv_episode_rating after delete on tv_episode_ratings for each row
begin
	declare avg_score decimal(10, 8);
    declare score_count int;
    select avg(rating), count(*) from tv_episode_ratings where tv_episode_id = old.tv_episode_id into avg_score, score_count;
    update tv_episodes tve set tve.average_score = avg_score, tve.score_count = score_count where tve.tv_episode_id = old.tv_episode_id;
end//
DELIMITER ;
