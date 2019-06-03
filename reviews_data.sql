use filmawka;

insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (1, 1, 'przykladowe review 1',NOW(),3);
insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (2, 2, 'przykladowe review 2',NOW(),4);
insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (3, 2, 'przykladowe review 3',NOW(),0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (3, 3, 'przykladowe review 4',NOW(),0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (3, 4, 'przykladowe review 5',NOW(),0);

insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (3, 1, 'przykladowe review 6',NOW(),2);
insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (2, 3, 'przykladowe review 7',NOW(),0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (4, 5, 'przykladowe review 8',NOW(),0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (4, 4, 'przykladowe review 9',NOW(),0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review,review_date, points) values (5, 4, 'przykladowe review 10',NOW(),0);

insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review,review_date, points) values (1, 3, 'przykladowe review 4 tv',NOW(),0);
insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review,review_date, points) values (2, 4, 'przykladowe review 5 tv',NOW(),0);
insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review,review_date, points) values (3, 1, 'przykladowe review 6 tv',NOW(),0);
insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review,review_date, points) values (2, 3, 'przykladowe review 7 tv',NOW(),4);
insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review,review_date, points) values (4, 5, 'przykladowe review 8 tv',NOW(),3);

insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review_date,review) values (3,1,3,NOW(),'przykladowe review 3');
insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review_date,review) values (1,1,1,NOW(),'przykladowe review 1');
insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review_date,review) values (2,1,2,NOW(),'przykladowe review 2');
insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review_date,review) values (8,1,4,NOW(),'przykladowe review 8');

insert into main_reviews_tv_series(old_review_id,accept_review_moderator,tv_series_id,review_date,review) values (3,1,2,NOW(),'przykladowe review 6 tv');
insert into main_reviews_tv_series(old_review_id,accept_review_moderator,tv_series_id,review_date,review) values (4,1,4,NOW(),'przykladowe review 7 tv');

insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (1,1);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (1,2);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (1,3);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (2,4);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (2,1);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (2,2);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (2,3);

insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (4,1);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (4,2);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (4,3);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (4,4);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (5,1);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (5,2);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (5,3);

