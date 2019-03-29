use filmawka;

drop function if exists get_category;
DELIMITER //
create function get_category(category_id int) returns varchar(30) reads sql data
begin
	declare category_name varchar(30);
    select c.`name` from categories c where c.category_id = category_id into category_name;
    return category_name;
end//
DELIMITER ;

drop procedure if exists get_movies_for_actor;
DELIMITER //
create procedure get_movies_for_actor(in actor_id int, inout output text)
begin
	declare title varchar(50);
    declare release_date date;
    declare finished boolean default false;
    
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
end//
DELIMITER ;

drop procedure if exists get_tv_series_for_actor;
DELIMITER //
create procedure get_tv_series_for_actor(in actor_id int, inout output text)
begin
	declare title varchar(50);
    declare release_date date;
    declare finished boolean default false;
    
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
end//
DELIMITER ;

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
	
	set @movies = '';
	call get_movies_for_actor(actor_id, @movies);
    
    set output = concat(output, '\n\nFilmy:\n', @movies);
    
    set @tv_series = '';
    call get_tv_series_for_actor(actor_id, @tv_series);
    
    set output = concat(output, '\nSeriale:\n', @tv_series);
    
	select output;
end//
DELIMITER ;

drop procedure if exists get_actors_for_movie;
DELIMITER //
create procedure get_actors_for_movie(in movie_id int, inout output text)
begin
    declare `name`, surname, `role` varchar(30);
    declare finished boolean default false;
    
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
end//
DELIMITER ;