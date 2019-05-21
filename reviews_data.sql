use filmawka;

insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (1, 1, 'przykladowe review 1',0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (2, 2, 'przykladowe review 2',0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (3, 2, 'przykladowe review 3',0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (3, 3, 'przykladowe review 4',0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (3, 4, 'przykladowe review 5',0);

insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (3, 1, 'przykladowe review 6',0);
insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (2, 3, 'przykladowe review 7',5);
insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (4, 5, 'przykladowe review 8',4);
insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (4, 4, 'przykladowe review 9',4);
insert into waiting_reviews_movies(movie_id, review_writer_id, review, points) values (5, 4, 'przykladowe review 10',4);

insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review, points) values (1, 3, 'przykladowe review 4 tv',0);
insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review, points) values (2, 4, 'przykladowe review 5 tv',0);
insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review, points) values (3, 1, 'przykladowe review 6 tv',0);
insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review, points) values (2, 3, 'przykladowe review 7 tv',5);
insert into waiting_reviews_tv_series(tv_series_id, review_writer_id, review, points) values (4, 5, 'przykladowe review 8 tv',4);


insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review) values (3,1,3,'przykladowe review 3');
insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review) values (1,1,1,'przykladowe review 1');
insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review) values (2,1,2,'przykladowe review 2');
insert into main_reviews_movie(old_review_id,accept_review_moderator,movie_id,review) values (8,1,4,'przykladowe review 8');

insert into main_reviews_tv_series(old_review_id,accept_review_moderator,tv_series_id,review) values (3,1,2,'przykladowe review 6 tv');
insert into main_reviews_tv_series(old_review_id,accept_review_moderator,tv_series_id,review) values (4,1,4,'przykladowe review 7 tv');

insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (2,1);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (2,2);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (2,3);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (2,4);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (3,1);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (3,2);
insert into points_on_reviews_movie(waiting_reviews_id,user_id) values (3,3);

insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (2,1);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (2,2);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (2,3);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (2,4);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (3,1);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (3,2);
insert into points_on_reviews_tv_series(waiting_reviews_id,user_id) values (3,3);

