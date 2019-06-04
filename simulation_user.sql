use Filmawka;

-- wyszukiwanie id użytkownika po jego nicku
set @var_get_user_id = get_user_id('gwashington');
select @var_get_user_id;

-- wyszukiwanie nazwy użytkownika po jego id
set @var_get_user = get_user(40);
select @var_get_user;

-- wyszkiwanie emaila użytkownika po jego id
set @var_get_user_email = get_user_email(4);
select @var_get_user_email;

-- wyszkiwanie danych personalnych użytkownika po jego id
set @var_get_user_personal_data = get_user_personal_data(4);
select @var_get_user_personal_data;

-- sprawdzanie strefy czasowej ustawionej przez użytkownika
set @var_get_user_timezone = get_user_timezone(4);
select @var_get_user_timezone;

-- pokazywanie wiadomości użytkownika po id
set @var_get_conversation_reply = get_conversation_reply(4);
select @var_get_conversation_reply;

-- wyszkiwanie rozmowy użytkownika po id
set @var_get_conversation = get_conversation(4);
select @var_get_conversation;

-- tworzenie nowego użytkownika
CALL add_user('Jan', 'Kowalski', 'jkowalski', 'jkowalski@example.com', 'test1234');
select nick from users where nick='jkowalski';

-- logowanie użytkownika do systemu
CALL login_user('jkowalski', 'test1234');
select * from logged_in_users;

-- wylogowywanie użytkownika
CALL logout_user(43);
select * from logged_in_users;

-- ustawienie trybu nocnego
CALL set_user_night_mode(6);
select * from account_settings where user_id=6;

-- ustawienie użytkownika jako aktywnego
CALL set_user_is_active(1);
select * from users where user_id=1;

-- aktywacja lub deaktywacja newslettera dla użytkownika
CALL set_user_newsletter(4);
select * from account_settings where user_id=4;

-- ustawienie użytkownika jako moderatora
CALL set_user_moderator(6);
select * from account_settings where user_id=6;

-- zmiana strefy czasowej użytkownika
CALL change_user_timezone(6, 'America/Mexico_City');
select * from account_settings;

-- wysłanie wiadomości do użytkownika
CALL send_message(2, 1, 'Witam');
set @var_get_conversation = get_conversation(4);
select @var_get_conversation;

-- utworzenie konwersacji
CALL create_conversation(23, 24);
select * from conversation;
