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
    
    if username is null then
		signal sqlstate '10002';
    end if;
    
    return username;
end//
DELIMITER ;

drop function if exists get_user_is_active;
DELIMITER //
create function get_user_is_active(user_id int) returns tinyint(1) reads sql data
begin
	declare is_active tinyint(1);
    select u.`is_active` from users u where u.user_id = user_id into is_active;
    return is_active;
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

drop function if exists get_conversation;
DELIMITER //
create function get_conversation(conversation_id_input int) returns text reads sql data
begin
	declare user_conversation text;
    select group_concat(reply separator '\r\n') from conversation_reply where conversation_id=conversation_id_input into user_conversation;
    return user_conversation;
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

drop procedure if exists set_user_moderator;
DELIMITER //
create procedure set_user_moderator(user_id_input int)
this_proc:begin
	declare user_moderator boolean;
    if (select exists(select * from users where user_id = user_id_input))=0 then
		select 'Podany użytkownik nie istnieje' as message;
        LEAVE this_proc;
	end if;
    select is_moderator from users where user_id=user_id_input into user_moderator;
    if user_moderator then
		update users set is_moderator=0 where user_id = user_id_input;
	else
		update users set is_moderator=1 where user_id = user_id_input;
    end if;
end//
DELIMITER ;

drop procedure if exists set_user_is_active;
DELIMITER //
create procedure set_user_is_active(user_id_input int)
this_proc:begin
	declare user_active boolean;
    if (select exists(select * from users where user_id = user_id_input))=0 then
		select 'Podany użytkownik nie istnieje' as message;
        LEAVE this_proc;
	end if;
    select is_active from users where user_id=user_id_input into user_active;
    if user_active then
		update users set is_active=0 where user_id = user_id_input;
	else
		update users set is_active=1 where user_id = user_id_input;
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
create procedure login_user(in username varchar(50), in password_input varchar(128))
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
	if STRCMP(login_user_password_hash, md5(password_input))=0 then
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
		insert into users(first_name, last_name, create_date, is_active, nick, email, is_moderator) values(first_name, last_name, CURDATE(), 1, nick, email, 0);
		select exists(select * from users where nick = username) into new_user_id;
		insert into passwords(user_id, password_hash) values (new_user_id, md5(user_password));
		insert into account_settings (user_id, night_mode, timezone, is_newsletter) values (new_user_id, 0, 'America/New_York', 1);
	end if;
end//
DELIMITER ;

drop procedure if exists create_conversation;
DELIMITER //
create procedure create_conversation(in user_one_input int, in user_two_input int)
this_proc:begin
	if (select exists(select * from conversation where (user_one = user_one_input and user_two=user_two_input) or (user_one = user_two_input and user_two=user_one_input)))=1 then
		select 'Konwersacja pomiędzy tymi użytkownikami już istnieje' as message;
        LEAVE this_proc;
	end if;
	insert into conversation(user_one, user_two, time) values (user_one, user_two, UNIX_TIMESTAMP());
end//
DELIMITER ;

drop procedure if exists send_message;
DELIMITER //
create procedure send_message(in sender_id int, in recipient_id int, message text)
this_proc:begin
	declare var_conversation_id int;
	if (select exists(select * from conversation where (user_one=sender_id and user_two=recipient_id) or (user_one=recipient_id and user_two=sender_id)))=0 then
		CALL create_conversation(sender_id, recipient_id);
	end if;
    select conversation_id from conversation where (user_one=sender_id and user_two=recipient_id) or (user_one=recipient_id and user_two=sender_id) into var_conversation_id;
	insert into conversation_reply(reply, user_id, time, conversation_id) values (message, recipient_id, UNIX_TIMESTAMP(), var_conversation_id);
end//
DELIMITER ;

-- triggers
drop trigger if exists check_add_user_email;
DELIMITER //
create trigger check_add_user_email after insert on users for each row
begin
	if new.email not regexp '^[^@]+@[^@]+\.[^@]{2,}$' then
		signal sqlstate '10001';
	end if;
end//
DELIMITER ;

drop trigger if exists check_add_user_date;
DELIMITER //
create trigger check_add_user_date after insert on users for each row
begin
	if new.create_date >= NOW() then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;

drop trigger if exists check_user_active;
DELIMITER //
create trigger check_user_active after insert on logged_in_users for each row
begin
	if (select is_active from users where user_id=new.user_id)=0 then
		signal sqlstate '10001';
    end if;
end//
DELIMITER ;