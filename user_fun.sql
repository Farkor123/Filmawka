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
