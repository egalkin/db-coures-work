\c postgres;

drop database anticafe;

create database anticafe;

\c anticafe;

-- Declaration section

create table Staff (
  id int not null,
  firstName varchar(30) not null,
  lastName varchar(30) not null,
  age int not null,
  primary key (id),
  constraint validate_staff_age check (age >= 18 AND age <= 99)
);

create table Masters (
  id int not null, 
  firstName varchar(30) not null,
  lastName varchar(30) not null,
  age int not null,
  primary key (id),
  constraint validate_master_age check (age >= 18 AND age <= 99)
);

create table Tariffs (
  id int not null,
  name varchar(20) not null,
  minutePrice float not null,
  primary key (id),
  constraint valid_minute_price check (minutePrice > 0.0)
);

create table Clients (
  id int not null,
  tariffId int not null references Tariffs(Id),
  visitStartTime timestamp not null,
  visitFinishTime timestamp,
  constraint valid_visit_date check (visitStartTime >= CURRENT_TIMESTAMP and visitStartTime < visitFinishTime),
  primary key(id)
);


create table Rooms (
  id int not null,
  capacity int not null,
  primary key(id),
  constraint validate_capacity check (capacity >= 1 and capacity <= 16)
);


create table RoomsBookingSchedule (
  id int not null, 
  roomId int not null references Rooms(id) on delete cascade,
  bookingStartTime timestamp not null,
  bookingFinishTime timestamp not null,
  constraint valid_booking_date check (bookingStartTime >= CURRENT_TIMESTAMP and bookingStartTime < bookingFinishTime),
  primary key (id)
);


create table GameEvents (
  id int not null,
  eventName varchar(200) not null,
  maxPlayersNum int not null,
  masterId int not null references Masters(id) on delete cascade,
  roomBookingId int not null references RoomsBookingSchedule(id) on delete cascade,
  primary key(id)
);


CREATE TYPE game_diffuculty AS ENUM (
  'Easy',
  'Medium',
  'Hard'
);

create table BoardGames (
  id int not null,
  name varchar(100) not null unique,
  difficulty game_diffuculty not null, 
  minPlayersNum int not null, 
  maxPlayersNum int not null,
  instanceNum int not null,
  primary key (id),
  constraint valid_players_num check (minPlayersNum >= 1 and maxPlayersNum >= minPlayersNum)
);


create table ClientEvents (
  clientId int not null references Clients(id) on delete cascade,
  eventId int not null references GameEvents(id) on delete cascade,
  primary key (clientId, eventId)
);

create table EventGames (
  eventId int not null references GameEvents(id) on delete cascade,
  boardGameId int not null references BoardGames(id) on delete cascade,
  primary key (eventId, boardGameId)
);

create table EventStaff (
  eventId int not null references GameEvents(id) on delete cascade,
  staffId int not null references Staff(id) on delete cascade, 
  primary key (eventId, staffId)
);

create table BarShiftsSchedule (
  id int not null,
  shiftDate date not null unique,
  staffId int not null references Staff(Id),
  primary key (id),
  constraint valid_shift_date check (shiftDate >= now())
);


-- Index section 

create index masters_name_index on Masters(firstName, lastName);
create index masters_age_Index on Masters(age);

create index events_names_index on GameEvents(eventName);

create index game_min_players_num_index on BoardGames using hash(minPlayersNum);
create index game_diffuculty_index on BoardGames(difficulty);
create index game_name_index on BoardGames(name);

-- Triggers section

create function convert_day_number_to_day_name(day_num int) returns varchar as $$
declare
  day_name varchar;
begin
  day_name := case day_num
    when 0 then 'Sunday'
    when 1 then 'Monday'
    when 2 then 'Tuesday'
    when 3 then 'Wednesday'
    when 4 then 'Thursday'
    when 5 then 'Friday'
    when 6 then 'Saturday'
    else '???'
  end;
  return day_name;
end;
$$ language plpgsql;

drop trigger valid_tariff_trigger on Clients;
drop function validate_tariff;

create function validate_tariff() returns trigger as $$
declare 
  week_day int;
  tariff_name varchar;
begin
  week_day := 
    (select extract (dow from new.visitStartTime));
  tariff_name :=
    (select tariffs.name from tariffs
      where tariffs.id = new.tariffid
    );
  if (((week_day Between 1 and 5) and tariff_name <> 'Daily')
        or (((week_day = 0 or week_day = 6) and tariff_name <> 'Weekend'))) then
    raise exception 'Invalid tariff for %: %', convert_day_number_to_day_name(week_day), Date(new.visitStartTime);
  end if;
  return new;
end;
$$ language plpgsql;

create trigger valid_tariff_trigger 
  before insert on Clients
  for each row 
  execute procedure validate_tariff();

drop trigger valid_booked_room_trigger on GameEvents;
drop function validate_booked_room_for_event;

create function validate_booked_room_for_event() returns trigger as $$
declare 
  room_capacity int;
begin
  room_capacity := (select rooms.capacity from rooms
    where 
    rooms.id = (select roomsBookingSchedule.roomId from roomsBookingSchedule 
      where roomsBookingSchedule.id = new.roomBookingId));
    if (new.maxPlayersNum > room_capacity) then
      raise exception 'Booked room is too small for this event. Book another one.';
    end if;
    return new;
end;
$$ language plpgsql; 

create trigger valid_booked_room_trigger 
  before insert on GameEvents
  for each row
  execute procedure validate_booked_room_for_event();

drop trigger disjoint_booking_dates_trigger on RoomsBookingSchedule;
drop function disjoint_booking_dates;

create function disjoint_booking_dates() returns trigger as $$
declare
  disjoint_predicate boolean;
begin
    disjoint_predicate := (not exists (
                  select * from RoomsBookingSchedule rbs
                    where 
                      rbs.roomId = new.roomId 
                      and
                      greatest(rbs.bookingStartTime, new.bookingStartTime) < least(rbs.bookingFinishTime, new.bookingFinishTime)
                  ));
    if (not disjoint_predicate) then
      raise exception 'New book intersect other books in this room.';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger disjoint_booking_dates_trigger
  before insert on RoomsBookingSchedule
  for each row
  execute procedure disjoint_booking_dates();