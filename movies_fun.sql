use filmawka;

drop procedure if exists get_movies_for_actor;
DELIMITER //
create procedure get_movies_for_actor(in actor_id int, inout output text)
begin
	declare title varchar(50);
    declare release_date date;
    declare finished boolean default false;
    
    declare movie_cursor cursor for
    select m.title, m.release_date
    from actor_movie am
    join movies m on am.movie_id = m.movie_id
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
	
	select output;
end//
DELIMITER ;