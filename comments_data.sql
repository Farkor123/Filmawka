﻿use filmawka;



insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (1, 1, NOW(),'przykadowy komentarz 888');
insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (1, 2, NOW(),'przykadowy komentarz testtttesttttesttttesttttesttttesttttesttttesttt');
insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (1, 3, NOW(),'przykadowy komentarz 1');
insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (1, 4, NOW(),'przykadowy komentarz 2');
insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (1, 5, NOW(),'przykadowy komentarz 3');
insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (1, 6, NOW(),'przykadowy komentarz 4');
insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (2, 1, NOW(),'przykadowy komentarz 5');
insert into comments_tv_series(tv_series_id, user_id, comment_date,content) values (2, 3, NOW(),'przykadowy komentarz 6');
insert into comments_movies(movie_id, user_id, comment_date,content) values (1, 1, NOW(),'przykadowy komentarz aaaa');
insert into comments_movies(movie_id, user_id, comment_date,content) values (1, 1, NOW(),'przykadowy komentarz bbbb');
insert into comments_movies(movie_id, user_id, comment_date,content) values (1, 1, NOW(),'przykadowy komentarz cccc');
insert into comments_movies(movie_id, user_id, comment_date,content) values (1, 1, NOW(),'przykadowy komentarz dddd');

select * from comments_movies;
CALL edit_comment_movie(1,1,'edytowanie 1');
CALL edit_comment_movie(2,2,'edytowanie 2');
CALL edit_comment_movie(3,1,'edytowanie 3');
select * from edited_comments;
