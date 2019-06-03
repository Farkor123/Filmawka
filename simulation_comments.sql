use filmawka;

insert into logged_in_users(user_id) values(1);
insert into logged_in_users(user_id) values(2);
-- add comment to a movie
select count(*) from comments_movies where movie_id=1;
CALL add_comment(1,1,'komentarz testowy',0);
select count(*) from comments_movies where movie_id=1;
-- add comment by not logged user 
select count(*) from comments_movies where movie_id=1;
CALL add_comment(1,3,'nieudany komentarz testowy',0);
select count(*) from comments_movies where movie_id=1;
-- remove comment from movie
CALL get_all_comments_by_movie_id(1);
select count(*) from comments_movies where movie_id=1;
CALL remove_comment_movie(5,1);
select count(*) from comments_movies where movie_id=1;
CALL get_all_comments_by_movie_id(1);
-- try remove again
select count(*) from comments_movies where movie_id=1;
CALL remove_comment_movie(5,1);
select count(*) from comments_movies where movie_id=1;
-- try remove comment without permissions
CALL add_comment(1,1,'komentarz testowy 2',0);
CALL get_all_comments_by_movie_id(1);
select count(*) from comments_movies where movie_id=1;
CALL remove_comment_movie(6,2);
select count(*) from comments_movies where movie_id=1;

-- edit comment movie
CALL get_all_comments_by_movie_id(1); 
CALL edit_comment_movie(1, 1,'edytowany komentarz1'); 
CALL get_comments_movie_by_user(1,1);
select * from edited_comments_movies;

-- add comment to tv_series
select count(*) from comments_tv_series where tv_series_id=1;
CALL add_comment(1,2,'komentarz testowy',1);
select count(*) from comments_tv_series where tv_series_id=1;


CALL get_all_comments_by_tv_series(1);
CALL get_comments_tv_series_by_user(1,1);
CALL get_info_of_the_most_commented_movies();
CALL get_info_of_the_most_commented_tv_series();