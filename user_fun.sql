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

drop function if exists get_conversation_reply;
DELIMITER //
create function get_conversation_reply(conversation_reply_id int) returns text reads sql data
begin
	declare reply varchar(30);
    select c.`reply` from conversation_reply c where c.conversation_reply_id = conversation_reply_id into reply;
    return reply;
end//
DELIMITER ;

drop function if exists is_user_logged_in;
DELIMITER //
create function is_user_logged_in(user_id int) returns bool reads sql data
begin
	declare logged_in bool;
    
    select exists(select 1 from logged_in_users liu where liu.user_id = user_id) into logged_in;
    
	return logged_in;
end//
DELIMITER ;

-- procedures
drop procedure if exists set_user_night_mode;
DELIMITER //
create procedure set_user_night_mode(user_id_input int)
this_proc:begin
	declare user_night_mode tinyint(1);
    declare user_account_settings_id int;
    if (select exists(select * from users where user_id = user_id_input))=0 then
		select 'Podany użytkownik nie istnieje' as message;
        LEAVE this_proc;
	end if;
    select night_mode from account_settings where user_id=user_id_input into user_night_mode;
    select account_settings_id from account_settings where user_id=user_id_input into user_account_settings_id;
    if user_night_mode then
		update account_settings set night_mode=0 where account_settings_id = user_account_settings_id;
	else
		update account_settings set night_mode=1 where account_settings_id = user_account_settings_id;
    end if;
end//
DELIMITER ;

drop procedure if exists set_user_newsletter;
DELIMITER //
create procedure set_user_newsletter(user_id_input int)
this_proc:begin
	declare user_newsletter tinyint(1);
    declare user_account_settings_id int;
    if (select exists(select * from users where user_id = user_id_input))=0 then
		select 'Podany użytkownik nie istnieje' as message;
        LEAVE this_proc;
	end if;
    select is_newsletter from account_settings where user_id=user_id_input into user_newsletter;
    select account_settings_id from account_settings where user_id=user_id_input into user_account_settings_id;
    if user_newsletter then
		update account_settings set is_newsletter=0 where account_settings_id = user_account_settings_id;
	else
		update account_settings set is_newsletter=1 where account_settings_id = user_account_settings_id;
    end if;
end//
DELIMITER ;

drop procedure if exists change_user_timezone;
DELIMITER //
create procedure change_user_timezone(user_id_input int, timezone_input varchar(30))
this_proc:begin
    declare user_account_settings_id int;
    if (select exists(select * from users where user_id = user_id_input))=0 then
		select 'Podany użytkownik nie istnieje' as message;
        LEAVE this_proc;
	end if;
    select account_settings_id from account_settings where user_id=user_id_input into user_account_settings_id;
	update account_settings set timezone=timezone_input where account_settings_id = user_account_settings_id;
end//
DELIMITER ;

drop procedure if exists login_user;
DELIMITER //
create procedure login_user(in username varchar(50), in password_hash_input varchar(128))
this_proc:begin
	declare login_user_id int;
    declare login_user_password_hash varchar(128);

	if (select exists(select * from users where nick = username)) then
		select user_id from users where nick = username into login_user_id;
	else
		select 'Użytkownik nie istnieje' as message;
        LEAVE this_proc;
	end if;
    select password_hash from passwords where user_id = login_user_id into login_user_password_hash;
	if STRCMP(login_user_password_hash, password_hash_input)=0 then
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

drop procedure if exists logout_user;
DELIMITER //
create procedure logout_user(in user_id_input int)
this_proc:begin
	declare old_logged_in_user_id int;
	if (select exists(select * from logged_in_users where user_id = user_id_input)) then
		select logged_in_users_id from logged_in_users where user_id = user_id_input into old_logged_in_user_id;
		delete from logged_in_users where logged_in_users_id = old_logged_in_user_id;
	else
		select 'Użytkownik nie jest zalogowany' as message;
	end if;
end//
DELIMITER ;

drop procedure if exists add_user;
DELIMITER //
create procedure add_user(in first_name varchar(20), in last_name varchar(20), in username varchar(50), email varchar(50), user_password varchar(128))
this_proc:begin
	declare new_user_id int;
	if (select exists(select * from users where nick = username)) then
		select 'Użytkownik o podanym identyfikatorze już istnieje' as message;
        LEAVE this_proc;
	else
		insert into users(first_name, last_name, create_date, is_active, nick, email, is_moderator) values(first_name, last_name, NOW(), 1, nick, email, 0);
		select exists(select * from users where nick = username) into new_user_id;
		insert into passwords(user_id, password_hash) values (new_user_id, md5(user_password));
		insert into account_settings (user_id, night_mode, timezone, is_newsletter) values (new_user_id, 0, 'America/New_York', 1);
	end if;
end//
DELIMITER ;