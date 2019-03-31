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
    primary key(user_id)
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
    primary key(tv_episode_id),
    foreign key(tv_season_id) references tv_seasons(tv_season_id)
);

create table if not exists actor_movie (
	actor_movie_id int not null auto_increment,
    movie_id int,
    actor_id int,
    primary key(actor_movie_id),
    foreign key(movie_id) references movies(movie_id),
    foreign key(actor_id) references actors(actor_id)
);

create table if not exists actor_tv_series (
	actor_tv_season_id int not null auto_increment,
    actor_id int,
    tv_series_id int,
    primary key(actor_tv_season_id),
    foreign key(actor_id) references actors(actor_id),
    foreign key(tv_series_id) references tv_series(tv_series_id)
);

create table if not exists ratings (
	rating_id int not null auto_increment,
    user_id int,
    rating tinyint check (rating >= 1 and rating <= 10),
    rating_date datetime not null,
    primary key(rating_id),
    foreign key(user_id) references users(user_id)
);

create table if not exists rating_movie (
	rating_movie_id int not null auto_increment,
    rating_id int,
    movie_id int,
    primary key(rating_movie_id),
    foreign key(rating_id) references ratings(rating_id),
    foreign key(movie_id) references movies(movie_id)
);

create table if not exists rating_tv_series (
	rating_tv_series_id int not null auto_increment,
    rating_id int,
    tv_series_id int,
    primary key(rating_tv_series_id),
    foreign key(rating_id) references ratings(rating_id),
    foreign key(tv_series_id) references tv_series(tv_series_id)
);

create table if not exists rating_tv_season (
	rating_tv_season_id int not null auto_increment,
    rating_id int,
    tv_season_id int,
    primary key(rating_tv_season_id),
    foreign key(rating_id) references ratings(rating_id),
    foreign key(tv_season_id) references tv_seasons(tv_season_id)
);

create table if not exists rating_tv_episode (
	rating_tv_episode_id int not null auto_increment,
    rating_id int,
    tv_episode_id int,
    primary key(rating_tv_episode_id),
    foreign key(rating_id) references ratings(rating_id),
    foreign key(tv_episode_id) references tv_episodes(tv_episode_id)
);

create table if not exists comments (
	comment_id int not null auto_increment,
    movie_id int null,
    tv_series_id int null,
    user_id int,
    comment_date date not null,
    content text not null,
    primary key(comment_id),
    foreign key(movie_id) references movies(movie_id),
    foreign key(tv_series_id) references tv_series(tv_series_id),
    foreign key(user_id) references users(user_id),
    constraint MovieIdOrTvSeriesIdNotNull check (movie_id is not null or tv_series_id is not null)
)
