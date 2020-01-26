\c anticafe 

drop view events_dates;

create view events_dates as 
(
	select gameEvents.id as eventId, 
		gameEvents.eventName, 
		roomsBookingSchedule.bookingStartTime as startTime,
		roomsBookingSchedule.bookingFinishTime as finishTime
	from gameEvents
	inner join roomsBookingSchedule
	on gameEvents.roomBookingId = roomsBookingSchedule.id
)

drop view masters_events_view;

create view masters_events_view as
(
	select masters.id as masterId, masters.firstName, boardGames.name, gameEvents.eventName
	from masters
	inner join gameEvents
	on masters.id = gameEvents.masterId
	inner join eventGames
	on gameEvents.id = eventGames.eventId
	inner join boardGames
	on eventGames.boardgameId = boardGames.id
);


drop view small_company_games_view;

create view small_company_games_view as
(
	select boardGames.name, boardGames.difficulty  
	from boardGames
	where boardGames.minPlayersNum BETWEEN 2 AND 4
);


drop view games_popularity_view;

create view games_popularity_view  as 
(
	with 
	popularity as (
		select boardGameId, count(*) as usages from EventGames 
		group by boardGameId
		)
	select boardGames.name, popularity.usages
	from boardGames
	inner join popularity
	on boardGames.id = popularity.boardGameId
	order by usages DESC
)

drop view staff_that_rules_bar_and_help_with_event_same_day_view;

create view staff_that_rules_bar_and_help_with_event_same_day_view  as
(
	with 
	staff_at_events as (
		select eventStaff.staffId as id, staff.firstName, staff.lastName, gameEvents.eventName, gameEvents.eventDate
		from eventStaff
		inner join gameEvents
		on eventStaff.eventId = gameEvents.id
		inner join staff
		on staffId = staff.id
		)
	select staff_at_events.id, staff_at_events.firstName, staff_at_events.lastName, staff_at_events.eventName,  barShiftsSchedule.shiftDate
	from staff_at_events
	inner join barShiftsSchedule
	on date(staff_at_events.eventDate) = barShiftsSchedule.shiftDate and staff_at_events.id = barShiftsSchedule.staffId

);

drop view staff_that_rules_bar_and_help_with_event_same_day_view;

create view masters_game_usage_view as
(
	select masterId, masters_events_view.firstName, boardGameId, boardGames.name as boardGameName, count(boardGameId) as timeUsed
	from masters_events_view 
	inner join boardGames
	on boardgameId = boardGames.id
	group by masterId, masters_events_view.firstName, boardGameName, boardgameId
);


drop view total_revenue;

create view total_revenue as 
(
	select SUM(bill) as total_revenue from
	(select extract(epoch from (clients.visitFinishTime - clients.visitStartTime)) / 60 * tariffs.minutePrice as bill
		from clients
		inner join tariffs
		on clients.tariffId = tariffs.id) as bills
);
