\c anticafe;

insert into Staff
	(id, firstName, lastName, age) values
	(1, 'Ivan', 'Getman', 22),
	(2, 'Polina', 'Bertz', 19),
	(3, 'Evgeniy', 'Alushkin', 20),
	(4, 'Pavel', 'Kravec', 24);

insert into Masters 
	(id, firstName, lastName, age) values
	(1, 'Valdimir', 'Krasnov', 27),
	(2, 'Ruslan', 'Vishin', 30),
	(3, 'Egor', 'Stepov', 25),
	(4, 'Nana', 'Klimova', 22),
	(5, 'Max', 'Shamov', 28);


insert into Tariffs
	(id, name, minutePrice) values
	(1, 'Weekend', 2.5),
	(2, 'Daily', 1.0);


insert into Clients 
	(id, tariffId, visitStartTime, visitFinishTime) values
	(1, 1, '2020-02-02 15:00:00', '2020-02-13 20:30:00'),
	(2, 2, '2020-02-03 15:00:00', '2020-02-13 17:45:00' ),
	(3, 2, '2020-02-14 00:30:00', '2020-02-14 04:00:00'),
	(4, 2, '2020-02-14 15:30:00', '2020-02-14 16:30:00');

insert into Rooms 
	(id, capacity) values
	(1, 5),
	(2, 6),
	(3, 6),
	(4, 3),
	(5, 8);

insert into BoardGames 
	(id, name, difficulty, minPlayersNum, maxPlayersNum, instanceNum) values
	(1, 'Uno', 'Easy', 2, 10, 3),
	(2, 'Mafia', 'Medium', 6, 14, 1),
	(3, 'Alias', 'Easy', 2, 6, 2),
	(4, 'GamesOfThones', 'Hard', 3, 6, 1),
	(5, 'Carcassonne', 'Medium', 3, 6, 1);


insert into RoomsBookingSchedule 
	(id, roomId, bookingStartTime, BookingFinishTime) values
	(1, 2, '2020-02-22 15:00:00', '2020-02-22 19:00:00'),
	(2, 5, '2020-02-22 14:00:00', '2020-02-22 15:00:00'),
	(3, 5, '2020-02-15 10:00:00', '2020-02-15 12:00:00'),
	(4, 5, '2020-02-16 10:00:00', '2020-02-16 12:00:00'),
	(5, 5, '2020-02-14 17:00:00', '2020-02-14 20:00:00');

insert into GameEvents 
	(id, eventName, maxPlayersNum, masterId, roomBookingId) values
	(1, 'Morning with Mafia', 8, 1, 3),
	(2, 'Dungeons and Dragons', 5, 2, 1),
	(3, 'Uno with Nana', 8, 4, 2),
	(5, 'Morning with Mafia', 8, 1, 4),
	(6, 'Carcassonne', 5, 1, 5);


insert into ClientEvents
	(clientId, eventId) values
	(1, 1),
	(2, 3),
	(2, 1);

insert into EventGames 
	(eventId, boardGameId) values 
	(1, 2),
	(3, 1),
	(5, 2),
	(6, 5);

insert into EventStaff 
	(eventId, staffId) values 
	(2, 1),
	(2, 2),
	(1, 4);
 
insert into BarShiftsSchedule
	(id, shiftDate, staffId) values
	(1, '2020-02-01', 1),
	(2, '2020-02-02', 2),
	(3, '2020-02-03', 1),
	(4, '2020-02-04', 3),
	(5, '2020-02-22', 2);
