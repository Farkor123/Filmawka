drop database if exists filmawka;
create database if not exists filmawka;
use filmawka;

create table if not exists users (
	user_id int not null auto_increment,
    `name` varchar(20) not null,
    surname varchar(20) not null,
    nick varchar(50) not null,
    email varchar(50) not null,
    primary key(user_id)
);

create table if not exists passwords (
	password_id int not null auto_increment,
    user_id int,
    password_hash binary(64) not null,
    foreign key(user_id) references users(user_id),
    primary key(password_id)
);

create table if not exists actors (
	actor_id int not null auto_increment,
    `name` varchar(30) not null,
    surname varchar(30) not null,
    date_of_birth date not null,
    summary text,
    primary key(actor_id)
);

create table if not exists directors (
	director_id int not null auto_increment,
    `name` varchar(30) not null,
    surname varchar(30) not null,
    date_of_birth date not null,
    summary text,
    primary key(director_id)
);

create table if not exists movies (
	movie_id int not null auto_increment,
    title varchar(50) not null,
    director_id int,
    `description` text,
    average_score decimal(10, 8),
    release_date date,
    is_released bool not null,
    primary key(movie_id),
    foreign key(director_id) references directors(director_id)
);

create table if not exists tv_series (
	tv_series_id int not null auto_increment,
    title varchar(50) not null,
    `description` text,
    average_score decimal(10, 8),
    primary key(tv_series_id)
);

create table if not exists tv_seasons (
	tv_season_id int not null auto_increment,
    season_number tinyint not null,
    number_of_episodes tinyint not null,
    average_score decimal(10, 8),
    primary key(tv_season_id)
);

create table if not exists tv_episodes (
	tv_episode_id int not null auto_increment,
    title varchar(50) not null,
    tv_season_id int,
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

create table if not exists actor_tv_season (
	actor_tv_season_id int not null auto_increment,
    actor_id int references actors(actor_id),
    tv_season_id int references tv_seasons(tv_season_id),
    primary key(actor_tv_season_id),
    foreign key(actor_id) references actors(actor_id),
    foreign key(tv_season_id) references tv_seasons(tv_season_id)
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

create table if not exists tv_episode_tv_season (
	tv_episode_tv_season_id int not null auto_increment,
    tv_episode_id int,
    tv_season_id int,
    primary key(tv_episode_tv_season_id),
    foreign key(tv_episode_id) references tv_episodes(tv_episode_id),
    foreign key(tv_season_id) references tv_seasons(tv_season_id)
);
