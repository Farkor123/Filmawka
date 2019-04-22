use filmawka;
insert into waiting_reviews(movie_id, review_writer_id, review, points) values (1, 1, 'przykladowe review 1',0);
insert into waiting_reviews(movie_id, review_writer_id, review, points) values (2, 2, 'przykladowe review 2',0);
insert into waiting_reviews(movie_id, review_writer_id, review, points) values (3, 2, 'przykladowe review 3',0);
insert into waiting_reviews(movie_id, review_writer_id, review, points) values (3, 3, 'przykladowe review 4',0);
insert into waiting_reviews(movie_id, review_writer_id, review, points) values (3, 4, 'przykladowe review 5',0);
insert into waiting_reviews(movie_id, review_writer_id, review, points) values (3, 1, 'przykladowe review 6',0);
insert into waiting_reviews(movie_id, review_writer_id, review, points) values (2, 3, 'przykladowe review 7',5);

insert into main_reviews(old_review_id,accept_review_moderator,review) values (1,1,'przykladowe review 1');
insert into main_reviews(old_review_id,accept_review_moderator,review) values (2,1,'przykladowe review 2');
insert into main_reviews(old_review_id,accept_review_moderator,review) values (3,1,'przykladowe review 1');