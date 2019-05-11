use filmawka;

-- functions
drop function if exists get_user_id;
DELIMITER //
create function get_user_id(username varchar(50)) returns int reads sql data
begin
	declare user_id int;
    select u.user_id from users u where u.`nick` = lower(username) into user_id;

    if user_id is null then
		signal sqlstate '10002';
    end if;

    return user_id;
end//
DELIMITER ;

drop function if exists get_user;
DELIMITER //
create function get_user(user_id int) returns varchar(50) reads sql data
begin
	declare username varchar(50);
    select u.`nick` from users u where u.user_id = user_id into username;
    return username;
end//
DELIMITER ;

drop function if exists get_user_email;
DELIMITER //
create function get_user_email(user_id int) returns varchar(50) reads sql data
begin
	declare email varchar(50);
    select u.`email` from users u where u.user_id = user_id into email;
    return email;
end//
DELIMITER ;

drop function if exists get_user_personal_data;
DELIMITER //
create function get_user_personal_data(user_id int) returns varchar(50) reads sql data
begin
	declare person_data varchar(40);
    select CONCAT(u.`first_name`, ' ', u.`last_name`) from users u where u.user_id = user_id into person_data;
    return person_data;
end//
DELIMITER ;

drop function if exists get_user_timezone;
DELIMITER //
create function get_user_timezone(user_id int) returns varchar(30) reads sql data
begin
	declare user_timezone varchar(30);
    select a.`timezone` from account_settings a where a.user_id = user_id into user_timezone;
    return user_timezone;
end//
DELIMITER ;

drop function if exists get_user_conversation_reply;
DELIMITER //
create function get_user_conversation_reply(conversation_reply_id int) returns text reads sql data
begin
	declare reply varchar(30);
    select c.`reply` from conversation_reply c where c.conversation_reply_id = conversation_reply_id into reply;
    return reply;
end//
DELIMITER ;

-- procedures
drop procedure if exists login_user;
DELIMITER //
create procedure login_user(in username varchar(50), in password_hash_input varchar(128))
this_proc:begin
	declare is_user_exist tinyint;
	declare login_user_id int;
    declare login_user_password_hash varchar(128);

    select exists(select * from users where nick = username) into is_user_exist;
	if is_user_exist = 1 then
		select exists(select user_id from users where nick = username) into login_user_id;
	else
		select 'Użytkownik nie istnieje' as message;
        LEAVE this_proc;
	end if;
    select password_hash from passwords where user_id = login_user_id into login_user_password_hash;
	if login_user_password_hash = password_hash_input then
		if is_user_logged_in(login_user_id) = 1 then
			select 'Użytkownik jest już zalogowany' as message;
            LEAVE this_proc;
        else
			insert into logged_in_users(user_id) values(login_user_id);
		end if;
	else
		select 'Podano błędne hasło' as message;
        LEAVE this_proc;
	end if;
end//
DELIMITER ;