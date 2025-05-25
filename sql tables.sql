create database RPT;
use Rpt;
CREATE TABLE Profiles (
    ProfileId INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Age INT,
    Gender VARCHAR(20),
    UserName VARCHAR(50),
    Password VARCHAR(20)
);
CREATE TABLE Goals (
    GoalId INT AUTO_INCREMENT PRIMARY KEY,
    ProfileId INT,
    CurrentAge INT,
    RetirementAge INT,
    TargetSavings DECIMAL(18,2),
    CurrentSavings DECIMAL(18,2),
    MonthlyContribution DECIMAL(18,2),
    FOREIGN KEY (ProfileId) REFERENCES Profiles(ProfileId) on delete cascade
);
create table FinancialYearData(
Id INT auto_increment primary key,
    GoalId int, Month int, Year int,MonthlyInvestment decimal(15,2), FYear int,
    foreign key (GoalId) references Goals(GoalId) on delete cascade
    );
    
    create table Progress(
    ProgressId int auto_increment primary key,
    GoalId int, TotalContribution decimal(18,2),
    foreign key(GoalId) references Goals(GoalId) on delete cascade
    );
