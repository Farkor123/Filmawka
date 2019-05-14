drop database if exists filmawka;
create database if not exists filmawka;
use filmawka;

create table if not exists users (
	user_id int not null auto_increment,
    first_name varchar(20) not null,
    last_name varchar(20) not null,
    create_date date not null,
    is_active tinyint(1) not null,
    nick varchar(50) not null,
    email varchar(50) not null,
	is_moderator BOOLEAN not null DEFAULT false,
    primary key(user_id)
);

create table if not exists logged_in_users (
	logged_in_users_id int not null auto_increment,
	user_id int not null,
    primary key(logged_in_users_id)
);

create table if not exists account_settings (
    account_settings_id int not null auto_increment,
    user_id int not null,
    night_mode tinyint(1) not null,
	timezone varchar(30) not null,
	is_newsletter tinyint(1) not null,
    foreign key(user_id) references users(user_id),
    primary key(account_settings_id)
);

create table if not exists passwords (
	password_id int not null auto_increment,
    user_id int,
    password_hash binary(128) not null,
    foreign key(user_id) references users(user_id),
    primary key(password_id)
);

create table if not exists conversation (
    conversation_id int not null auto_increment,
    user_one int not null,
    user_two int not null,
    time int(11) default null,
    foreign key(user_one) references users(user_id),
    foreign key(user_two) references users(user_id),
    primary key(conversation_id)
);

create table if not exists conversation_reply (
    conversation_reply_id int not null auto_increment,
    reply text,
    user_id int not null,
    time int(11) not null,
    conversation_id int not null,
    foreign key(user_id) references users(user_id),
    foreign key(conversation_id) references conversation(conversation_id),
    primary key(conversation_reply_id)
);

create table if not exists actors (
	actor_id int not null auto_increment,
    `name` varchar(30) not null,
    surname varchar(30) not null,
    date_of_birth date not null,
    date_of_death date,
    summary text,
    primary key(actor_id)
);

create table if not exists directors (
	director_id int not null auto_increment,
    `name` varchar(30) not null,
    surname varchar(30) not null,
    date_of_birth date not null,
    date_of_death date,
    summary text,
    primary key(director_id)
);

create table if not exists categories (
	category_id int not null auto_increment,
    `name` varchar(30) not null,
    primary key(category_id)
);

create table if not exists movies (
	movie_id int not null auto_increment,
    title varchar(50) not null,
    original_title varchar(50),
    director_id int,
    `description` text,
    average_score decimal(10, 8),
    score_count int default 0,
    release_date date,
    is_released bool not null,
    category_id int,
    primary key(movie_id),
    foreign key(director_id) references directors(director_id),
    foreign key(category_id) references categories(category_id)
);

create table if not exists tv_series (
	tv_series_id int not null auto_increment,
    title varchar(50) not null,
    original_title varchar(50),
    `description` text,
    average_score decimal(10, 8),
    score_count int default 0,
    release_date date,
    is_released bool not null,
    category_id int,
    primary key(tv_series_id),
    foreign key(category_id) references categories(category_id)
);

create table if not exists tv_seasons (
	tv_season_id int not null auto_increment,
    season_number tinyint not null,
    number_of_episodes tinyint not null,
    average_score decimal(10, 8),
    score_count int default 0,
    tv_series_id int not null,
    primary key(tv_season_id),
    foreign key(tv_series_id) references tv_series(tv_series_id)
);

create table if not exists tv_episodes (
	tv_episode_id int not null auto_increment,
    episode_number tinyint not null,
    title varchar(50),
    tv_season_id int not null,
    duration_in_minutes tinyint unsigned not null,
    average_score decimal(10, 8),
    score_count int default 0,
    primary key(tv_episode_id),
    foreign key(tv_season_id) references tv_seasons(tv_season_id)
);

create table if not exists actor_movie (
	actor_movie_id int not null auto_increment,
    movie_id int,
    actor_id int,
    `role` varchar(50) not null,
    primary key(actor_movie_id),
    foreign key(movie_id) references movies(movie_id),
    foreign key(actor_id) references actors(actor_id),
    unique key ActorCanStarOnceInAMovie(movie_id, actor_id)
);

create table if not exists actor_tv_series (
	actor_tv_season_id int not null auto_increment,
    actor_id int,
    tv_series_id int,
    `role` varchar(50) not null,
    primary key(actor_tv_season_id),
    foreign key(actor_id) references actors(actor_id),
    foreign key(tv_series_id) references tv_series(tv_series_id),
    unique key ActorCanStarOnceInATvSeries(actor_id, tv_series_id)
);

create table if not exists movie_ratings (
	movie_rating_id int not null auto_increment,
    user_id int not null,
    movie_id int not null,
    rating tinyint,
    rating_date datetime not null default now(),
    primary key(movie_rating_id),
    foreign key(user_id) references users(user_id),
    foreign key(movie_id) references movies(movie_id),
    unique key UserCanRateMovieOnlyOnce(user_id, movie_id)
);

create table if not exists tv_series_ratings (
	tv_series_rating_id int not null auto_increment,
    user_id int not null,
    tv_series_id int not null,
    rating tinyint,
    rating_date datetime not null default now(),
    primary key(tv_series_rating_id),
    foreign key(user_id) references users(user_id),
    foreign key(tv_series_id) references tv_series(tv_series_id),
    unique key UserCanRateTVSeriesOnlyOnce(user_id, tv_series_id)
);

create table if not exists tv_season_ratings (
	tv_season_rating_id int not null auto_increment,
    user_id int not null,
    tv_season_id int not null,
    rating tinyint,
    rating_date datetime not null default now(),
    primary key(tv_season_rating_id),
    foreign key(user_id) references users(user_id),
    foreign key(tv_season_id) references tv_seasons(tv_season_id),
    unique key UserCanRateTVSeasonOnlyOnce(user_id, tv_season_id)
);

create table if not exists tv_episode_ratings (
	tv_episode_rating_id int not null auto_increment,
    user_id int not null,
    tv_episode_id int not null,
    rating tinyint,
    rating_date datetime not null default now(),
    primary key(tv_episode_rating_id),
    foreign key(user_id) references users(user_id),
    foreign key(tv_episode_id) references tv_episodes(tv_episode_id),
    unique key UserCanRateTVEpisodeOnlyOnce(user_id, tv_episode_id)
);

create table if not exists comments (
	comment_id int not null auto_increment,
    movie_id int null,
    tv_series_id int null,
    user_id int,
    comment_date datetime not null,
    content MEDIUMTEXT not null,
    primary key(comment_id),
    foreign key(movie_id) references movies(movie_id),
    foreign key(tv_series_id) references tv_series(tv_series_id),
    foreign key(user_id) references users(user_id)
);

create table if not exists edited_comments(
	edit_id  int not null auto_increment,
    edited_comment_id int not null,
    comment_edit_date datetime not null,
    content_before_edit Mediumtext not null,
	foreign key(edited_comment_id) references comments(comment_id),
    primary key (edit_id)
);


create table if not exists waiting_reviews(
	review_id int not null auto_increment,
	movie_id int null,
    tv_series_id int null,
	is_edited BOOLEAN DEFAULT false, 
	review_writer_id int not null,
	review MEDIUMTEXT,
	points int, 
	primary key(review_id),
    foreign key(tv_series_id) references tv_series(tv_series_id),
	foreign key(movie_id) references movies(movie_id),
	foreign key(review_writer_id) references users(user_id)
);

create table if not exists main_reviews(
	review_id int not null auto_increment,
	old_review_id int not null, 
	accept_review_moderator int not null,
	movie_id int null,
    tv_series_id int null,
	review MEDIUMTEXT,
	primary key(review_id),
    foreign key(tv_series_id) references tv_series(tv_series_id),
	foreign key(accept_review_moderator) references users(user_id),
	foreign key(movie_id) references movies(movie_id),
	foreign key(old_review_id) references waiting_reviews(review_id)
);

create table if not exists points_on_reviews(
	waiting_reviews_id int not null,
    user_id int not null,
    foreign key(waiting_reviews_id) references waiting_reviews(review_id),
    foreign key(user_id) references users(user_id)
);

