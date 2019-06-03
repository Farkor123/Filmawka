use filmawka;
-- zalogowanie potrzebnych użytkowników (do zmiany na funkcję/procedurę)
insert into logged_in_users(user_id) values(1);
insert into logged_in_users(user_id) values(2);
insert into logged_in_users(user_id) values(10);
insert into logged_in_users(user_id) values(6);

select get_main_review_id_by_movie_id(1);
select get_main_review_id_by_tv_series_id(2);


select get_points_from_waiting_review_tv_series(3);

select get_the_most_pointed_review_of_movie(2);
select get_the_most_pointed_review_of_tv_series(2);

-- dodanie punktu do czekajacej recenzji filmu przez zalogowanego uzytkownika, a nastepnie 
select get_points_from_waiting_review_movie(2);
Call add_point_to_review_movie(2 ,6 );
select get_points_from_waiting_review_movie(2);
-- proba ponownego dodania punktu
Call add_point_to_review_movie(2 ,6 );
select get_points_from_waiting_review_movie(2);
-- proba usuniecia tego punktu przez innego uzytkownika
CALL remove_point_from_review_movie(2,10);
select get_points_from_waiting_review_movie(2);
-- poprawna proba usuniecia punktu
CALL remove_point_from_review_movie(2,6);
select get_points_from_waiting_review_movie(2);

-- proba dodania punktu przez niezalogowanego uzytkownika
Call add_point_to_review_movie(2 ,5 );



-- dodanie punktu do czekajacej recenzji serii tv przez zalogowanego uzytkownika, 
select get_points_from_waiting_review_tv_series(2);
Call add_point_to_review_tv_series(2 ,6 );
select get_points_from_waiting_review_tv_series(2);
-- proba ponownego dodania punktu
Call add_point_to_review_tv_series(2 ,6 );
select get_points_from_waiting_review_tv_series(2);
-- proba usuniecia tego punktu przez innego uzytkownika
CALL remove_point_from_review_tv_series(2,10);
select get_points_from_waiting_review_tv_series(2);
-- poprawna proba usuniecia punktu
CALL remove_point_from_review_tv_series(2,6);
select get_points_from_waiting_review_tv_series(2);


-- poprawne dodanie recenzji filmu
select count(*) from waiting_reviews_movies;
CALL add_waiting_movie_review(2,6,'text test');
select count(*) from waiting_reviews_movies;
-- ponowna proba dodania recenzji tego samego filmu
CALL add_waiting_movie_review(2,6,'text test');
select count(*) from waiting_reviews_movies;
-- proba dodania recenzji filmu przez niezalogowanego uzytkownika
CALL add_waiting_movie_review(2,9,'text test');
select count(*) from waiting_reviews_movies;
-- usuniecie recenzji przez uzytkownika
CALL remove_waiting_movie_review(get_wait_review_id_by_movie_id_and_user_id(2,6),6);
select count(*) from waiting_reviews_movies;
-- ponowna proba usuniecia recenzji
CALL remove_waiting_movie_review(get_wait_review_id_by_movie_id_and_user_id(2,6),6);
select count(*) from waiting_reviews_movies;

-- niepowodzenie, brak uprawnien
CALL add_waiting_movie_review(2,6,'text test');
select count(*) from waiting_reviews_movies;
CALL remove_waiting_movie_review(get_wait_review_id_by_movie_id_and_user_id(2,6),10);
select count(*) from waiting_reviews_movies;

-- poprawne dodanie i usuniecie oczekujacej recenzji
select count(*) from waiting_reviews_tv_series;
CALL add_waiting_tv_series_review(2,1,'text test');
select count(*) from waiting_reviews_tv_series;
CALL remove_waiting_tv_series_review(get_wait_review_id_by_tv_series_id_and_user_id(2,1),1);
select count(*) from waiting_reviews_tv_series;


-- poprawne dodanie i edycja recenzji filmu
select count(*) from waiting_reviews_movies;
CALL add_waiting_movie_review(3,6,'text test');
select count(*) from waiting_reviews_movies;
CALL get_waiting_reviews_movie_info_by_review_id(get_wait_review_id_by_movie_id_and_user_id(3,6));
CALL edit_waiting_movie_review(get_wait_review_id_by_movie_id_and_user_id(3,6),'edytowany tekst',6);
CALL get_waiting_reviews_movie_info_by_review_id(get_wait_review_id_by_movie_id_and_user_id(3,6));
-- edycja recenzji przez osobe nieuprawniona
CALL edit_waiting_movie_review(get_wait_review_id_by_movie_id_and_user_id(3,6),'edytowany tekst 2',10);
CALL get_waiting_reviews_movie_info_by_review_id(get_wait_review_id_by_movie_id_and_user_id(3,6));
-- edycja recenzji przez moderatora
CALL edit_waiting_movie_review(get_wait_review_id_by_movie_id_and_user_id(3,6),'edytowany tekst 3',1);
CALL get_waiting_reviews_movie_info_by_review_id(get_wait_review_id_by_movie_id_and_user_id(3,6));

-- proba ustawienia recenzji jako glowna recenzja przez osobe nieuprawniona
CALL set_waiting_review_movie_to_main_review(get_wait_review_id_by_movie_id_and_user_id(3,6),2);
-- poprawne ustawienie recenzji jako glowna recenzja
CALL get_main_review_info_by_movie_id(3);
CALL set_waiting_review_movie_to_main_review(get_wait_review_id_by_movie_id_and_user_id(3,6),1);
CALL get_main_review_info_by_movie_id(3);



-- poprawne dodanie i edycja recenzji serii tv
select count(*) from waiting_reviews_tv_series;
CALL add_waiting_tv_series_review(4,1,'text test');
select count(*) from waiting_reviews_tv_series;
CALL get_waiting_reviews_tv_series_info_by_review_id(get_wait_review_id_by_tv_series_id_and_user_id(4,1));
select * from waiting_reviews_tv_series;
CALL edit_waiting_tv_series_review(get_wait_review_id_by_tv_series_id_and_user_id(4,1),'edycja testowa',1);
CALL get_waiting_reviews_tv_series_info_by_review_id(get_wait_review_id_by_tv_series_id_and_user_id(4,1));


-- proba ustawienia recenzji jako glowna recenzja przez osobe nieuprawniona
CALL set_waiting_review_tv_series_to_main_review(get_wait_review_id_by_tv_series_id_and_user_id(4,1),2);
-- poprawne ustawienie recenzji jako glowna recenzja
CALL get_main_review_info_by_tv_series_id(4);
CALL set_waiting_review_tv_series_to_main_review(get_wait_review_id_by_tv_series_id_and_user_id(4,1),1);
CALL get_main_review_info_by_tv_series_id(4);

-- sprawdzanie czy dziala poprawnie id
CALL get_waiting_review_id_by_movie_id(3);
CALL get_waiting_review_id_by_tv_series_id(2);

-- inofrmacje
CALL get_all_reviews_by_movie_id(2);
CALL get_all_reviews_by_tv_series(2);

select * from waiting_reviews_movies;
CALL get_waiting_reviews_info_by_movie_id(1);
select * from waiting_reviews_tv_series;
CALL get_waiting_reviews_info_by_tv_series_id(1);

CALL get_waiting_reviews_movie_info_by_review_id(5);

CALL get_waiting_reviews_tv_series_info_by_review_id(1);

CALL get_main_movie_review_info_by_review_id(1);

CALL get_main_tv_series_review_info_by_review_id(1);

CALL get_main_review_info_by_movie_id(1);

CALL get_main_review_info_by_tv_series_id(2);

-- posegregowane recenzje wzgledem punktow
CALL points_on_tv_series_reviews_by_id(2);
CALL points_on_movie_reviews_by_id(2);

-- WIDOKI:
select * from points_on_movie_reviews;
select * from points_on_tv_series;

select * from waiting_reviews_movies;
