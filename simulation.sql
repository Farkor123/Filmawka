use filmawka;

-- 1. ocenienie filmu
select title, average_score, score_count from movies;
call rate_movie(1, 1, 7);
select title, average_score, score_count from movies;
select * from movie_ratings;

-- 2. próba ocenienia filmu błędną wartością (skala 1-10)
select title, average_score, score_count from movies;
call rate_movie(2, 1, 11);
select title, average_score, score_count from movies;

-- 3. zmiana wcześniej wystawionej oceny filmu
select title, average_score, score_count from movies;
select * from movie_ratings;
call rate_movie(1, 1, 9);
select title, average_score, score_count from movies;
select * from movie_ratings;

-- 4. usunięcie oceny filmu
select title, average_score, score_count from movies;
select * from movie_ratings;
call remove_movie_rating(1, 1);
select title, average_score, score_count from movies;
select * from movie_ratings;

-- 5. ocenienie serialu
select title, average_score, score_count from tv_series;
call rate_tv_series(1, 1, 6);
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;

-- 6. próba ocenienia serialu błędną wartością (skala 1-10)
select title, average_score, score_count from tv_series;
call rate_tv_series(2, 1, 0);
select title, average_score, score_count from tv_series;

-- 7. zmiana wcześniej wystawionej oceny serialu
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;
call rate_tv_series(1, 1, 8);
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;

-- 8. usunięcie oceny serialu
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;
call remove_tv_series_rating(1, 1);
select title, average_score, score_count from tv_series;
select * from tv_series_ratings;

-- 9. ocenienie sezonu serialu
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
call rate_tv_season(1, 1, 7);
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;

-- 10. próba ocenienia sezonu błędną wartością (skala 1-10)
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
call rate_tv_season(2, 1, 12);
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;

-- 11. zmiana wcześniej wystawionej oceny sezonu
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;
call rate_tv_season(1, 1, 10);
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;

-- 12. usunięcie oceny sezonu
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;
call remove_tv_season_rating(1, 1);
select title, season_number, sea.average_score, sea.score_count from tv_seasons sea join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_season_ratings;

-- 13. ocenienie odcinka
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
call rate_tv_episode(1, 1, 6);
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;

-- 14. próba ocenienia odcinka błędną wartością (skala 1-10)
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
call rate_tv_episode(2, 1, 11);
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;

-- 15. zmiana wcześniej wystawionej oceny odcinka
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;
call rate_tv_episode(1, 1, 9);
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;

-- 16. usunięcie oceny odcninka
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;
call remove_tv_episode_rating(1, 1);
select ser.title, sea.season_number, epi.episode_number, epi.average_score, epi.score_count from tv_episodes epi join tv_seasons sea on epi.tv_season_id = sea.tv_season_id join tv_series ser on sea.tv_series_id = ser.tv_series_id;
select * from tv_episode_ratings;
