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
