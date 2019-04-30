use filmawka;

-- ocenienie filmu
select title, average_score, score_count from movies;
call rate_movie(1, 1, 7);
select title, average_score, score_count from movies;
select * from movie_ratings;

-- próba ocenienia filmu błędną wartością (skala 1-10)
select title, average_score, score_count from movies;
call rate_movie(2, 1, 11);
select title, average_score, score_count from movies;

-- zmiana wcześniej wystawionej oceny filmu
select title, average_score, score_count from movies;
select * from movie_ratings;
call rate_movie(1, 1, 9);
select title, average_score, score_count from movies;
select * from movie_ratings;

-- usunięcie oceny filmu
select title, average_score, score_count from movies;
select * from movie_ratings;
call remove_movie_rating(1, 1);
select title, average_score, score_count from movies;
select * from movie_ratings;

-- ocenienie serialu
select title, average_score, score_count from tv_series;
call rate_tv_series(1, 1, 6);
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;

-- próba ocenienia serialu błędną wartością (skala 1-10)
select title, average_score, score_count from tv_series;
call rate_tv_series(2, 1, 0);
select title, average_score, score_count from tv_series;

-- zmiana wcześniej wystawionej oceny serialu
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;
call rate_tv_series(1, 1, 8);
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;

-- usunięcie oceny serialu
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;
call remove_tv_series_rating(1, 1);
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;

-- ocenienie sezonu serialu
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
call rate_tv_season(1, 1, 7);
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;

-- próba ocenienia sezonu błędną wartością (skala 1-10)
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
call rate_tv_season(2, 1, 12);
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;

-- zmiana wcześniej wystawionej oceny sezonu
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;
call rate_tv_season(1, 1, 10);
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;

-- usunięcie oceny sezonu
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;
call remove_tv_season_rating(1, 1);
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;

-- ocenienie odcinka
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
call rate_tv_episode(1, 1, 6);
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;

-- próba ocenienia odcinka błędną wartością (skala 1-10)
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
call rate_tv_episode(2, 1, 11);
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;

-- zmiana wcześniej wystawionej oceny odcinka
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;
call rate_tv_episode(1, 1, 9);
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;

-- usunięcie oceny odcninka
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;
call remove_tv_episode_rating(1, 1);
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;

-- wyszukiwanie filmu
select title, original_title from movies;
call search_movies('szybcy');
call search_movies('fast');

-- wyszukiwanie serialu
select title, original_title from tv_series;
call search_tv_series('pitbul');

-- wyszukiwanie aktorów
select `name`, surname from actors;
call search_actors('janusz');
call search_actors('jackson');

-- wyszukiwanie reżyserów
select `name`, surname from directors;
call search_directors('tarantino');

-- ranking najpopularniejszych filmów z danej kategorii
select title, c.`name` as category_name, average_score, score_count from movies m join categories c on m.category_id = c.category_id;
call show_popular_movies_ranking('akcja');

-- ranking najlepiej ocenianych filmów z danej kategorii
select title, c.`name` as category_name, average_score, score_count from movies m join categories c on m.category_id = c.category_id;
call show_best_movies_ranking('akcja');

-- ranking najpopularniejszych seriali z danej kategorii
select title, c.`name` as category_name, average_score, score_count from tv_series tvs join categories c on tvs.category_id = c.category_id;
call show_popular_tv_series_ranking('thriller');

-- ranking najlepiej ocenianych seriali z danej kategorii
select title, c.`name` as category_name, average_score, score_count from tv_series tvs join categories c on tvs.category_id = c.category_id;
call show_best_tv_series_ranking('thriller');

-- zmiana opisu filmu
select movie_id, title, `description` from movies where movie_id = 1;
call update_movie_description(1, 'Zmieniony opis filmu.');
select movie_id, title, `description` from movies where movie_id = 1;

-- zmiana kategorii filmu
select m.movie_id, m.title, c.`name` from movies m join categories c on m.category_id = c.category_id where movie_id = 1;
call update_movie_category(1, 'gangsterski');
select m.movie_id, m.title, c.`name` from movies m join categories c on m.category_id = c.category_id where movie_id = 1;

-- zmiana kategorii filmu na taką, której nie ma w bazie
select * from categories;
select m.movie_id, m.title, c.`name` from movies m join categories c on m.category_id = c.category_id where movie_id = 1;
call update_movie_category(1, 'testowa');
select * from categories;
select m.movie_id, m.title, c.`name` from movies m join categories c on m.category_id = c.category_id where movie_id = 1;

-- zmiana reżysera filmu
select m.movie_id, m.title, concat(d.`name`, ' ', d.surname) as director from movies m join directors d on m.director_id = d.director_id where m.movie_id = 1;
call update_movie_director(1, 'Christopher Nolan');
select m.movie_id, m.title, concat(d.`name`, ' ', d.surname) as director from movies m join directors d on m.director_id = d.director_id where m.movie_id = 1;

-- dodanie aktora do filmu
select m.movie_id, m.title, concat(a.`name`, ' ', a.surname) as actor, am.`role` from movies m join actor_movie am on m.movie_id = am.movie_id join actors a on am.actor_id = a.actor_id where m.movie_id = 1;
call add_actor_to_movie('Lucy Liu', 'jakaś rola', 1);
select m.movie_id, m.title, concat(a.`name`, ' ', a.surname) as actor, am.`role` from movies m join actor_movie am on m.movie_id = am.movie_id join actors a on am.actor_id = a.actor_id where m.movie_id = 1;

-- próba dodania aktora który już gra w danym filmie
select m.movie_id, m.title, concat(a.`name`, ' ', a.surname) as actor, am.`role` from movies m join actor_movie am on m.movie_id = am.movie_id join actors a on am.actor_id = a.actor_id where m.movie_id = 1;
call add_actor_to_movie('Lucy Liu', 'jakaś rola', 1);
select m.movie_id, m.title, concat(a.`name`, ' ', a.surname) as actor, am.`role` from movies m join actor_movie am on m.movie_id = am.movie_id join actors a on am.actor_id = a.actor_id where m.movie_id = 1;

-- usunięcie aktora z filmu
select m.movie_id, m.title, concat(a.`name`, ' ', a.surname) as actor, am.`role` from movies m join actor_movie am on m.movie_id = am.movie_id join actors a on am.actor_id = a.actor_id where m.movie_id = 1;
call remove_actor_from_movie('Lucy Liu', 1);
select m.movie_id, m.title, concat(a.`name`, ' ', a.surname) as actor, am.`role` from movies m join actor_movie am on m.movie_id = am.movie_id join actors a on am.actor_id = a.actor_id where m.movie_id = 1;

-- zmiana opisu serialu
select tv_series_id, title, `description` from tv_series where tv_series_id = 1;
call update_tv_series_description(1, 'Zmieniony opis serialu.');
select tv_series_id, title, `description` from tv_series where tv_series_id = 1;

-- zmiana kategorii serialu
select tvs.tv_series_id, tvs.title, c.`name` from tv_series tvs join categories c on tvs.category_id = c.category_id where tvs.tv_series_id = 1;
call update_tv_series_category(1, 'kryminał');
select tvs.tv_series_id, tvs.title, c.`name` from tv_series tvs join categories c on tvs.category_id = c.category_id where tvs.tv_series_id = 1;

-- zmiana kategorii serialu na taką, której nie ma w bazie
select * from categories;
select tvs.tv_series_id, tvs.title, c.`name` from tv_series tvs join categories c on tvs.category_id = c.category_id where tvs.tv_series_id = 1;
call update_tv_series_category(1, 'testowa 2');
select * from categories;
select tvs.tv_series_id, tvs.title, c.`name` from tv_series tvs join categories c on tvs.category_id = c.category_id where tvs.tv_series_id = 1;

-- dodanie aktora do serialu
select tvs.tv_series_id, tvs.title, concat(a.`name`, ' ', a.surname) as actor, atvs.`role` from tv_series tvs join actor_tv_series atvs on tvs.tv_series_id = atvs.tv_series_id join actors a on atvs.actor_id = a.actor_id where tvs.tv_series_id = 1;
call add_actor_to_tv_series('Cezary Pazura', 'jakaś rola', 1);
select tvs.tv_series_id, tvs.title, concat(a.`name`, ' ', a.surname) as actor, atvs.`role` from tv_series tvs join actor_tv_series atvs on tvs.tv_series_id = atvs.tv_series_id join actors a on atvs.actor_id = a.actor_id where tvs.tv_series_id = 1;

-- próba dodania aktora który już gra w danym serialu
select tvs.tv_series_id, tvs.title, concat(a.`name`, ' ', a.surname) as actor, atvs.`role` from tv_series tvs join actor_tv_series atvs on tvs.tv_series_id = atvs.tv_series_id join actors a on atvs.actor_id = a.actor_id where tvs.tv_series_id = 1;
call add_actor_to_tv_series('Cezary Pazura', 'jakaś rola', 1);
select tvs.tv_series_id, tvs.title, concat(a.`name`, ' ', a.surname) as actor, atvs.`role` from tv_series tvs join actor_tv_series atvs on tvs.tv_series_id = atvs.tv_series_id join actors a on atvs.actor_id = a.actor_id where tvs.tv_series_id = 1;

-- usunięcie aktora z serialu
select tvs.tv_series_id, tvs.title, concat(a.`name`, ' ', a.surname) as actor, atvs.`role` from tv_series tvs join actor_tv_series atvs on tvs.tv_series_id = atvs.tv_series_id join actors a on atvs.actor_id = a.actor_id where tvs.tv_series_id = 1;
call remove_actor_from_tv_series('Cezary Pazura', 1);
select tvs.tv_series_id, tvs.title, concat(a.`name`, ' ', a.surname) as actor, atvs.`role` from tv_series tvs join actor_tv_series atvs on tvs.tv_series_id = atvs.tv_series_id join actors a on atvs.actor_id = a.actor_id where tvs.tv_series_id = 1;

-- ustawienie daty śmierci aktora
select actor_id, concat(`name`, ' ', surname) as actor, date_of_death from actors where actor_id = 1;
call set_actor_date_of_death('John Travolta', curdate());
select actor_id, concat(`name`, ' ', surname) as actor, date_of_death from actors where actor_id = 1;

-- zmiana opisu aktora
select actor_id, concat(`name`, ' ', surname) as actor, summary from actors where actor_id = 1;
call update_actor_summary('John Travolta', 'Nowy opis aktora.');
select actor_id, concat(`name`, ' ', surname) as actor, summary from actors where actor_id = 1;

-- ustawienie daty śmierci reżysera
select director_id, concat(`name`, ' ', surname) as director, date_of_death from directors where director_id = 1;
call update_director_date_of_death('Quentin Tarantino', curdate());
select director_id, concat(`name`, ' ', surname) as director, date_of_death from directors where director_id = 1;

-- zmiana opisu reżysera
select director_id, concat(`name`, ' ', surname) as director, summary from directors where director_id = 1;
call update_director_summary('Quentin Tarantino', 'Nowy opis reżysera.');
select director_id, concat(`name`, ' ', surname) as director, summary from directors where director_id = 1;

-- wyświetlenie informacji o aktorze
call actor_info(2);
call actor_info(111);
call actor_info(107);
-- informacja o dacie śmierci
call actor_info(53);

-- wyświetlenie informacji o reżyserze
call director_info(1);
-- informacja o dacie śmierci
call director_info(19);

-- wyświetlenie informacji o filmie
call movie_info(1);
-- błędne id filmu
call movie_info(100);

-- wyświetlenie informacji o serialu
call tv_series_info(2);
-- błędne id serialu
call tv_series_info(100);
