USE db309gkb2;

drop table SharingList;
drop table SharingListNote;
drop table ShoppingListItem;
drop table ShoppingListICategory;
drop table StandardTask;
drop table User;


create table User (
UserID char (100) not null,

Primary key (UserID));

create table SharingList (
UserID  char (100) not null,
foreign key (UserID) REFERENCES User (UserID), 
ListID char (100) not null,
ListName char (100) not null,
ListCreated datetime, 
ListUpdated datetime,
primary key(ListID));

create table SharingListNote(
Tital char (100)not null,
description char (100)not null,
NoteCreated datetime, 
NoteUpdated datetime,
NoteAlarm datetime,
Done boolean,Due datetime,
SharingListNoteID char(100) not null references SharingList (ListID),
DoneBy char (100) not null references User (UserID));

create table ShoppingListItem(
UserID   char (100) not null,
foreign key (UserID) REFERENCES  User (UserID ), 
ID int NOT NULL AUTO_INCREMENT,
ItemName char(100) not null,
DueDate date,
Updatedates datetime not null,
Done boolean not null,
Category char(100) not null,
AmountUnit char(100)not null,
Amount double not null,
primary key(ID));

create table ShoppingListICategory(
UserID char (100) not null,
foreign key (UserID) REFERENCES  User (UserID), 
CategoryID int NOT NULL AUTO_INCREMENT,
Title char (100) not null,
primary key (CategoryID));


create table StandardTask(
UserID  char (100) not null,
foreign key (UserID) REFERENCES  User (UserID),
ID int not null auto_increment,
TaskName char (100) not null,
DueDate date not null,
CheckMark boolean not null,
ReminderTime datetime not null,
Frequency char (20),
Updatedates datetime not null,
primary key(ID)
);





